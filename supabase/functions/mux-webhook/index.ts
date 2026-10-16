import {
  Firestore, createWrite, firestoreString, getField, numberValue,
  stringValue, timestampValue,
} from "../_shared/firebase.ts";
import { corsHeaders, error, json } from "../_shared/http.ts";

const encoder = new TextEncoder();
function equalHex(left: string, right: string): boolean {
  if (left.length !== right.length) return false;
  let diff = 0;
  for (let i = 0; i < left.length; i++) diff |= left.charCodeAt(i) ^ right.charCodeAt(i);
  return diff === 0;
}
async function validSignature(request: Request, raw: string): Promise<boolean> {
  const header = request.headers.get("mux-signature") ?? "";
  const values = new Map(header.split(",").map((part) => part.trim().split("=", 2) as [string, string]));
  const timestamp = values.get("t");
  const signature = values.get("v1");
  if (!timestamp || !signature || !/^\d+$/.test(timestamp) || Math.abs(Date.now() / 1000 - Number(timestamp)) > 300) return false;
  const secret = Deno.env.get("MUX_WEBHOOK_SECRET");
  if (!secret) throw new Error("Missing webhook secret.");
  const key = await crypto.subtle.importKey("raw", encoder.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const bytes = await crypto.subtle.sign("HMAC", key, encoder.encode(`${timestamp}.${raw}`));
  const expected = [...new Uint8Array(bytes)].map((v) => v.toString(16).padStart(2, "0")).join("");
  return equalHex(signature.toLowerCase(), expected);
}
Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return error("method_not_allowed", "Use POST.", 405);
  try {
    const raw = await request.text();
    if (!(await validSignature(request, raw))) return error("invalid_signature", "Mux signature verification failed.", 401);
    const envelope = JSON.parse(raw) as { id?: string; type?: string; data?: Record<string, unknown> };
    if (!envelope.id || !envelope.type || !envelope.data) return error("invalid_event", "Malformed Mux webhook event.", 400);
    const kind = envelope.type;
    const data = envelope.data;
    const videoId = typeof data.passthrough === "string" ? data.passthrough : null;
    const db = new Firestore();
    if (!videoId || !/^[0-9a-f-]{36}$/i.test(videoId)) return json({ ok: true, ignored: true });

    // Resolve the parent IDs from our trusted upload record. Passthrough only
    // supplies a stable item ID; it never authorizes any client request.
    const prefix = "Courses/";
    // Course/section coordinates are embedded in the Mux-created document path.
    const lookup = Deno.env.get("MUX_VIDEO_LOOKUP_COLLECTION") ?? "MuxVideoIndex";
    const transaction = await db.beginTransaction();
    const eventPath = `MuxWebhookEvents/${envelope.id}`;
    if (await db.get(eventPath, transaction)) return json({ ok: true, duplicate: true });
    const index = await db.get(`${lookup}/${videoId}`, transaction);
    if (!index) return json({ ok: true, ignored: true });
    const courseId = firestoreString(getField(index.fields, ["courseId"]));
    const sectionId = firestoreString(getField(index.fields, ["sectionId"]));
    if (!courseId || !sectionId) return json({ ok: true, ignored: true });
    const itemPath = `${prefix}${courseId}/Sections/${sectionId}/Items/${videoId}`;
    const item = await db.get(itemPath, transaction);
    if (!item) return json({ ok: true, ignored: true });
    const fields: Record<string, Record<string, unknown>> = { updatedAt: timestampValue() };
    const masks = ["updatedAt"];
    if (kind === "video.upload.asset_created" || kind === "video.asset.created") {
      const assetId = typeof data.asset_id === "string" ? data.asset_id : data.id;
      if (typeof assetId === "string") { fields.muxAssetId = stringValue(assetId); masks.push("muxAssetId"); }
      fields.status = stringValue("processing"); masks.push("status");
    } else if (kind === "video.asset.ready") {
      const tracks = Array.isArray(data.tracks) ? data.tracks as Array<Record<string, unknown>> : [];
      const videoTrack = tracks.find((track) => track.type === "video");
      const width = Number(videoTrack?.max_width ?? 0);
      const height = Number(videoTrack?.max_height ?? 0);
      const available = [360, 480, 540, 720, 1080].filter((quality) => quality <= height).map((quality) => ({ stringValue: `${quality}p` }));
      const playbackIds = Array.isArray(data.playback_ids) ? data.playback_ids as Array<Record<string, unknown>> : [];
      const playback = playbackIds.find((entry) => entry.policy === "signed");
      if (typeof playback?.id !== "string") throw new Error("Ready Mux asset has no signed playback ID.");
      fields.muxAssetId = stringValue(String(data.id ?? "")); masks.push("muxAssetId");
      fields.muxPlaybackId = stringValue(playback.id); masks.push("muxPlaybackId");
      fields.status = stringValue("ready"); masks.push("status");
      fields.durationSeconds = numberValue(Number(data.duration ?? 0)); masks.push("durationSeconds");
      fields.sourceWidth = numberValue(width); masks.push("sourceWidth");
      fields.sourceHeight = numberValue(height); masks.push("sourceHeight");
      fields.availableQualities = { arrayValue: { values: available } }; masks.push("availableQualities");
    } else if (kind === "video.asset.errored") {
      fields.status = stringValue("failed"); masks.push("status");
      fields.processingError = stringValue(typeof data.errors === "object" ? JSON.stringify(data.errors).slice(0, 500) : "Mux asset processing failed."); masks.push("processingError");
    } else if (kind === "video.upload.cancelled") {
      fields.status = stringValue("cancelled"); masks.push("status");
    } else return json({ ok: true, ignored: true });

    const itemUpdate = db.document(itemPath, fields as never);
    const eventDoc = db.document(eventPath, { eventType: stringValue(kind), videoId: stringValue(videoId), receivedAt: timestampValue() });
    await db.commit(transaction, [
      { update: itemUpdate, updateMask: { fieldPaths: masks }, currentDocument: { updateTime: item.updateTime } },
      createWrite(eventDoc),
    ]);
    return json({ ok: true });
  } catch (exception) {
    console.error("Mux webhook processing failed", exception instanceof Error ? exception.message : "unknown error");
    return error("webhook_processing_failed", "Webhook processing failed and may be retried.", 500);
  }
});
