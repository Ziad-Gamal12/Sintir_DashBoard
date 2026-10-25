import { Firestore } from "../_shared/firebase.ts";
import { error, json } from "../_shared/http.ts";
import { attemptPath, decodeFields, readBody, requiredId, requireCaller, safeError } from "../_shared/course_checkout.ts";
Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: { "access-control-allow-origin": "*", "access-control-allow-headers": "authorization, apikey, content-type", "access-control-allow-methods": "POST, OPTIONS" } });
  if (request.method !== "POST") return error("method_not_allowed", "Use POST.", 405);
  try {
    const uid = await requireCaller(request);
    const body = await readBody(request);
    const id = requiredId(body.paymentAttemptId, "paymentAttemptId");
    const doc = await new Firestore().get(attemptPath(id));
    if (!doc) return error("not_found", "Payment attempt was not found.", 404);
    const attempt = decodeFields(doc.fields);
    if (attempt.uid !== uid) return error("forbidden", "This payment attempt does not belong to you.", 403);
    const status = ["succeeded", "failed", "expired", "creation_failed", "paid_requires_review"].includes(String(attempt.status)) ? attempt.status : "pending";
    return json({ ok: true, paymentAttemptId: id, status, amountCents: attempt.amountCents, currency: "EGP" });
  } catch (cause) {
    if (cause instanceof Error && cause.message === "unauthorized") return error("unauthorized", "Authentication is required.", 401);
    const result = safeError(cause); return error(result.code, result.message, result.status);
  }
});
