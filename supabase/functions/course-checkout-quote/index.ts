import { Firestore } from "../_shared/firebase.ts";
import { error, json } from "../_shared/http.ts";
import { loadQuote, readBody, requiredCourseId, requireCaller, safeError } from "../_shared/course_checkout.ts";
Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: { "access-control-allow-origin": "*", "access-control-allow-headers": "authorization, apikey, content-type", "access-control-allow-methods": "POST, OPTIONS" } });
  if (request.method !== "POST") return error("method_not_allowed", "Use POST.", 405);
  try {
    const uid = await requireCaller(request);
    const body = await readBody(request);
    const courseId = requiredCourseId(body.courseId);
    if (body.couponCode !== undefined && typeof body.couponCode !== "string") return error("invalid_couponCode", "Coupon code is invalid.", 400);
    const { quote } = await loadQuote(new Firestore(), uid, courseId, body.couponCode);
    return json({ ok: true, quote });
  } catch (cause) {
    if (cause instanceof Error && cause.message === "unauthorized") return error("unauthorized", "Authentication is required.", 401);
    const result = safeError(cause);
    return error(result.code, result.message, result.status);
  }
});
