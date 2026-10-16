import {
  Firestore, createWrite, firebaseUid, firestoreString,
  getField, numberValue, stringValue, timestampValue,
} from "./firebase.ts";
import { error, json } from "./http.ts";
import { importPKCS8, SignJWT } from "npm:jose@5.10.0";

const muxBase = "https://api.mux.com/video/v1";
const pathFor = (courseId: string, sectionId: string, videoId: string) =>
  `Courses/${courseId}/Sections/${sectionId}/Items/${videoId}`;
function muxHeaders() {
  const token = btoa(`${required("MUX_TOKEN_ID")}:${required("MUX_TOKEN_SECRET")}`);
  return { authorization: `Basic ${token}`, "content-type": "application/json" };
}
function required(name: string) {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing server secret ${name}`);
  return value;
}
function derObject(tag: number, bytes: Uint8Array): Uint8Array {
  const length = bytes.length;
  const lengthOctets = lengthBytes(length);
  const encodedLength = length < 128
    ? new Uint8Array([length])
    : new Uint8Array([0x80 | lengthOctets.length, ...lengthOctets]);
  const result = new Uint8Array(1 + encodedLength.length + length);
  result[0] = tag;
  result.set(encodedLength, 1);
  result.set(bytes, 1 + encodedLength.length);
  return result;
}
function lengthBytes(length: number): number[] {
  const bytes: number[] = [];
  for (let value = length; value > 0; value = Math.floor(value / 256)) bytes.unshift(value & 0xff);
  return bytes;
}
function concatBytes(...parts: Uint8Array[]): Uint8Array {
  const result = new Uint8Array(parts.reduce((total, part) => total + part.length, 0));
  let offset = 0;
  for (const part of parts) { result.set(part, offset); offset += part.length; }
  return result;
}
function pemFromMuxSecret(secret: string): string {
  const decoded = atob(secret);
  if (decoded.includes("-----BEGIN PRIVATE KEY-----")) return decoded;
  const block = decoded.match(/-----BEGIN RSA PRIVATE KEY-----([\s\S]+?)-----END RSA PRIVATE KEY-----/);
  if (!block) throw new Error("Mux signing key is not a supported PEM value.");
  const base64Body = block[1].replace(/\s/g, "");
  const pkcs1 = Uint8Array.from(atob(base64Body), (character) => character.charCodeAt(0));
  const rsaAlgorithm = new Uint8Array([0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]);
  const privateKeyInfo = derObject(0x30, concatBytes(
    derObject(0x02, new Uint8Array([0])),
    rsaAlgorithm,
    derObject(0x04, pkcs1),
  ));
  let binary = "";
  for (let start = 0; start < privateKeyInfo.length; start += 4096) {
    binary += String.fromCharCode(...privateKeyInfo.subarray(start, start + 4096));
  }
  const base64 = btoa(binary).match(/.{1,64}/g)?.join("\n") ?? "";
  return `-----BEGIN PRIVATE KEY-----\n${base64}\n-----END PRIVATE KEY-----`;
}
async function readJson(request: Request): Promise<Record<string, unknown>> {
  const value = await request.json();
  if (!value || typeof value !== "object" || Array.isArray(value)) throw new Error("Invalid request body.");
  return value as Record<string, unknown>;
}
function id(value: unknown, field: string): string {
  if (typeof value !== "string") throw new Error(`${field} is invalid.`);
  const normalized = value.trim();
  // Firestore document IDs may contain Unicode and punctuation. Only `/` and
  // control characters are unsafe here; `/` would change the document path.
  if (normalized.length === 0 || normalized.length > 160 || /[\/\u0000-\u001f\u007f]/u.test(normalized)) {
    throw new Error(`${field} is invalid.`);
  }
  return normalized;
}
function str(value: unknown, field: string, max: number): string {
  if (typeof value !== "string" || value.trim().length === 0 || value.length > max) throw new Error(`${field} is invalid.`);
  return value.trim();
}
async function authorizeTeacher(db: Firestore, uid: string, courseId: string) {
  const [user, course] = await Promise.all([db.get(`Users/${uid}`), db.get(`Courses/${courseId}`)]);
  if (!user || firestoreString(getField(user.fields, ["role"])) !== "Teacher" ||
      firestoreString(getField(user.fields, ["status"])) !== "Active") throw new Error("forbidden");
  if (!course || firestoreString(getField(course.fields, ["contentcreaterentity", "id"])) !== uid) throw new Error("forbidden");
  return course;
}
function responseError(exception: unknown): Response {
  const message = exception instanceof Error ? exception.message : "Unexpected error.";
  if (message === "forbidden") return error("forbidden", "You are not authorized for this course.", 403);
  if (message.endsWith("is invalid.") || message === "Invalid request body.") return error("invalid_request", message, 400);
  console.error("video function failed", message);
  return error("internal_error", "Could not process the video request.", 500);
}
async function muxFetch(path: string, init: RequestInit = {}) {
  const response = await fetch(`${muxBase}${path}`, { ...init, headers: { ...muxHeaders(), ...(init.headers ?? {}) } });
  if (!response.ok) {
    console.error("Mux API request failed", { status: response.status });
    throw new Error("Mux request failed.");
  }
  if (response.status === 204) return {};
  return await response.json();
}

export async function handleVideoRequest(request: Request, action: "create" | "resume" | "cancel" | "playback"): Promise<Response> {
  if (request.method === "OPTIONS") return new Response("ok", { headers: { "access-control-allow-origin": "*", "access-control-allow-headers": "authorization, apikey, content-type", "access-control-allow-methods": "POST, OPTIONS" } });
  if (request.method !== "POST") return error("method_not_allowed", "Use POST.", 405);
  let uid: string;
  try { uid = await firebaseUid(request); } catch { return error("unauthenticated", "A valid Firebase ID token is required.", 401); }
  try {
    const body = await readJson(request);
    const db = new Firestore();
    if (action === "create") return await createUpload(db, uid, body);
    const courseId = id(body.courseId, "courseId");
    const sectionId = id(body.sectionId, "sectionId");
    const videoId = id(body.videoId, "videoId");
    const path = pathFor(courseId, sectionId, videoId);
    const [course, video] = await Promise.all([authorizeTeacher(db, uid, courseId), db.get(path)]);
    void course;
    if (!video || firestoreString(getField(video.fields, ["createdBy"])) !== uid) return error("not_found", "Video upload was not found.", 404);
    if (action === "resume") {
      const uploadId = firestoreString(getField(video.fields, ["muxUploadId"]));
      if (!uploadId) return error("invalid_state", "Video has no resumable upload.", 409);
      const result = await muxFetch(`/uploads/${encodeURIComponent(uploadId)}`);
      const data = (result as { data?: Record<string, unknown> }).data ?? {};
      // Mux only returns a new signed upload URL at creation. Keep it in the active
      // Flutter upload session; this endpoint confirms whether the original is resumable.
      return json({ ok: true, uploadId, status: data.status, resumable: data.status === "waiting" });
    }
    if (action === "cancel") {
      const uploadId = firestoreString(getField(video.fields, ["muxUploadId"]));
      const assetId = firestoreString(getField(video.fields, ["muxAssetId"]));
      if (assetId) {
        await muxFetch(`/assets/${encodeURIComponent(assetId)}`, { method: "DELETE" });
      } else if (uploadId) {
        await muxFetch(`/uploads/${encodeURIComponent(uploadId)}/cancel`, { method: "PUT", body: "{}" });
      }
      const fields = { status: stringValue("cancelled"), updatedAt: timestampValue() };
      const doc = db.document(path, fields);
      await db.commit(await db.beginTransaction(), [{ update: doc, updateMask: { fieldPaths: ["status", "updatedAt"] }, currentDocument: { updateTime: video.updateTime } }]);
      return json({ ok: true });
    }
    return await playback(db, uid, body, courseId, sectionId, videoId);
  } catch (exception) { return responseError(exception); }
}

async function createUpload(db: Firestore, uid: string, body: Record<string, unknown>): Promise<Response> {
  const courseId = id(body.courseId, "courseId");
  const sectionId = id(body.sectionId, "sectionId");
  const title = str(body.title, "title", 200);
  const description = typeof body.description === "string" ? body.description.slice(0, 4000) : "";
  const fileName = str(body.fileName, "fileName", 255);
  const mimeType = str(body.mimeType, "mimeType", 120);
  const fileSize = Number(body.fileSizeBytes);
  if (!mimeType.startsWith("video/") || !Number.isSafeInteger(fileSize) || fileSize <= 0 || fileSize > 10 * 1024 ** 3) throw new Error("fileSizeBytes is invalid.");
  await authorizeTeacher(db, uid, courseId);
  const videoId = crypto.randomUUID();
  const muxResponse = await muxFetch("/uploads", {
    method: "POST",
    body: JSON.stringify({ timeout: 604800, cors_origin: "*", new_asset_settings: { playback_policies: ["signed"], video_quality: "basic", passthrough: videoId } }),
  }) as { data?: { id?: string; url?: string } };
  const uploadId = muxResponse.data?.id;
  const uploadUrl = muxResponse.data?.url;
  if (!uploadId || !uploadUrl) throw new Error("Mux did not return an upload session.");
  const path = pathFor(courseId, sectionId, videoId);
  const doc = db.document(path, {
    id: stringValue(videoId), title: stringValue(title), description: stringValue(description), type: stringValue("Video"),
    videoProvider: stringValue("mux"), muxUploadId: stringValue(uploadId), status: stringValue("uploading"),
    createdBy: stringValue(uid), courseId: stringValue(courseId), sectionId: stringValue(sectionId),
    fileName: stringValue(fileName), fileSizeBytes: numberValue(fileSize), mimeType: stringValue(mimeType),
    createdAt: timestampValue(), updatedAt: timestampValue(), durationTime: numberValue(0),
  });
  const index = db.document(`MuxVideoIndex/${videoId}`, {
    courseId: stringValue(courseId), sectionId: stringValue(sectionId), videoId: stringValue(videoId),
  });
  try { await db.commit(await db.beginTransaction(), [createWrite(doc), createWrite(index)]); }
  catch (exception) { await muxFetch(`/uploads/${encodeURIComponent(uploadId)}/cancel`, { method: "PUT", body: "{}" }); throw exception; }
  return json({ ok: true, videoId, uploadId, uploadUrl, status: "uploading" }, 201);
}

async function playback(db: Firestore, uid: string, body: Record<string, unknown>, courseId: string, sectionId: string, videoId: string): Promise<Response> {
  const course = await db.get(`Courses/${courseId}`);
  const video = await db.get(pathFor(courseId, sectionId, videoId));
  const user = await db.get(`Users/${uid}`);
  if (!course || !video || !user || firestoreString(getField(video.fields, ["videoProvider"])) !== "mux" ||
      firestoreString(getField(video.fields, ["status"])) !== "ready") return error("not_found", "Ready video was not found.", 404);
  const owner = firestoreString(getField(course.fields, ["contentcreaterentity", "id"])) === uid;
  if (!owner) {
    const [enrollment, subscriber] = await Promise.all([
      db.get(`Users/${uid}/Courses/${courseId}`),
      db.get(`Courses/${courseId}/Subscribers/${uid}`),
    ]);
    if (firestoreString(getField(course.fields, ["state"])) !== "Published" ||
        firestoreString(getField(user.fields, ["role"])) !== "Student" ||
        firestoreString(getField(user.fields, ["status"])) !== "Active" || !enrollment || !subscriber) {
      return error("forbidden", "Course enrollment is required.", 403);
    }
  }
  const playbackId = firestoreString(getField(video.fields, ["muxPlaybackId"]));
  if (!playbackId) return error("invalid_state", "Playback is not available yet.", 409);
  const requested = body.quality === "Auto" || body.quality == null ? null : str(body.quality, "quality", 8);
  const allowed = ["360p", "480p", "540p", "720p", "1080p"];
  if (requested && !allowed.includes(requested)) throw new Error("quality is invalid.");
  const availableRaw = getField(video.fields, ["availableQualities"])?.arrayValue as { values?: Array<{ stringValue?: string }> } | undefined;
  const available = (availableRaw?.values ?? []).map((v) => v.stringValue).filter((v): v is string => typeof v === "string");
  if (requested && !available.includes(requested)) return error("quality_unavailable", "Requested quality is not available for this video.", 422);
  const duration = Number(getField(video.fields, ["durationSeconds"])?.doubleValue ?? 0);
  const tokenLifetime = Math.min(24 * 60 * 60, Math.max(60 * 60, duration + 10 * 60));
  const signingKeyId = required("MUX_SIGNING_KEY_ID");
  const claims: Record<string, unknown> = { sub: playbackId, aud: "v", exp: Math.floor(Date.now() / 1000) + tokenLifetime };
  if (requested) claims.max_resolution = requested;
  const pem = pemFromMuxSecret(required("MUX_SIGNING_KEY_PRIVATE_BASE64"));
  const key = await importPKCS8(pem, "RS256");
  const token = await new SignJWT(claims).setProtectedHeader({ alg: "RS256", typ: "JWT", kid: signingKeyId }).sign(key);
  return json({ ok: true, playbackUrl: `https://stream.mux.com/${encodeURIComponent(playbackId)}.m3u8?token=${encodeURIComponent(token)}`, expiresAt: new Date((claims.exp as number) * 1000).toISOString(), quality: requested ?? "Auto", availableQualities: available });
}
