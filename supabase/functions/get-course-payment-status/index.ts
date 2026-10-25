import { Firestore } from "../_shared/firebase.ts";
import { error, json } from "../_shared/http.ts";
import { attemptPath, decodeFields, isTerminalAttemptStatus, readBody, reconcileAttempt, requiredId, requireCaller, safeError, updateActiveAttempt } from "../_shared/course_checkout.ts";
import { inquireIntention } from "../_shared/paymob_inquiry.ts";
Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: { "access-control-allow-origin": "*", "access-control-allow-headers": "authorization, apikey, content-type", "access-control-allow-methods": "POST, OPTIONS" } });
  if (request.method !== "POST") return error("method_not_allowed", "Use POST.", 405);
  try {
    const uid = await requireCaller(request);
    const body = await readBody(request);
    const id = requiredId(body.paymentAttemptId, "paymentAttemptId");
    const db = new Firestore();
    const doc = await db.get(attemptPath(id));
    if (!doc) return error("not_found", "Payment attempt was not found.", 404);
    const attempt = decodeFields(doc.fields);
    if (attempt.uid !== uid) return error("forbidden", "This payment attempt does not belong to you.", 403);
    if (!isTerminalAttemptStatus(attempt.status)) {
      const last = attempt.lastReconciledAt instanceof Date ? attempt.lastReconciledAt.getTime() : Date.parse(String(attempt.lastReconciledAt ?? ""));
      if (!Number.isFinite(last) || Date.now() - last >= 30_000) {
        try {
          const result = await inquireIntention({
            orderId: attempt.paymobOrderId ? String(attempt.paymobOrderId) : undefined,
            merchantReference: String(attempt.paymobSpecialReference ?? id),
          });
          await reconcileAttempt(db, id, result);
        } catch (cause) {
          await updateActiveAttempt(db, id, { lastReconciledAt: new Date(), reconciliationLastError: cause instanceof Error ? cause.message : "unknown" }).catch(() => null);
        }
      }
    }
    const refreshed = await db.get(attemptPath(id));
    const current = refreshed ? decodeFields(refreshed.fields) : attempt;
    const status = isTerminalAttemptStatus(current.status)
      ? current.status
      : ["creating", "creation_unknown"].includes(String(current.status)) || !current.checkoutUrl ? "verification_required" : "pending";
    return json({ ok: true, paymentAttemptId: id, status, amountCents: current.amountCents, currency: "EGP", checkoutUrl: current.checkoutUrl ?? "", quote: current.quote ?? null });
  } catch (cause) {
    if (cause instanceof Error && cause.message === "unauthorized") return error("unauthorized", "Authentication is required.", 401);
    const result = safeError(cause); return error(result.code, result.message, result.status);
  }
});
