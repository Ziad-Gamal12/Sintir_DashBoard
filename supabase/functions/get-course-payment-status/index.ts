import { Firestore } from "../_shared/firebase.ts";
import { error, json } from "../_shared/http.ts";
import { attemptPath, canResumeCheckout, classifyPaymobInquiry, decodeFields, enrollPath, inquiryRetryAfterSeconds, isTerminalAttemptStatus, readBody, reconcileAttempt, requiredId, requireCaller, safeError, subscriberPath, updateActiveAttempt } from "../_shared/course_checkout.ts";
import { inquireIntention } from "../_shared/paymob_inquiry.ts";
Deno.serve(async (request) => {
  const requestId = crypto.randomUUID();
  const logStatus = (stage: string, details: Record<string, unknown> = {}) => {
    console.info(JSON.stringify({ function: "get-course-payment-status", requestId, stage, ...details }));
  };
  logStatus("request_received", { method: request.method });
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
    logStatus("attempt_loaded", { attemptFound: true, ownershipChecksPassed: true, attemptStatus: String(attempt.status ?? "unknown") });
    let verificationState = "terminal";
    let retryAfterSeconds = 0;
    if (!isTerminalAttemptStatus(attempt.status)) {
      retryAfterSeconds = inquiryRetryAfterSeconds(attempt.lastReconciledAt);
      if (retryAfterSeconds > 0) {
        verificationState = "cooldown";
        logStatus("inquiry_skipped_cooldown", { attemptStatus: String(attempt.status), retryAfterSeconds });
      } else {
        verificationState = "inquiry_started";
        logStatus("inquiry_started", {
          hasPersistedOrderId: Boolean(attempt.paymobOrderId),
          hasMerchantReference: Boolean(attempt.paymobSpecialReference ?? id),
        });
        let providerOutcome = "unavailable";
        try {
          const result = await inquireIntention({
            orderId: attempt.paymobOrderId ? String(attempt.paymobOrderId) : undefined,
            merchantReference: String(attempt.paymobSpecialReference ?? id),
          });
          providerOutcome = classifyPaymobInquiry(result);
          const reconciledState = await reconcileAttempt(db, id, result);
          verificationState = reconciledState === "succeeded" || reconciledState === "failed" || reconciledState === "paid_requires_review"
            ? "resolved"
            : "inquiry_complete";
          logStatus("inquiry_completed", { providerOutcome, reconciledState });
        } catch (cause) {
          const failureCode = cause instanceof Error ? cause.message.slice(0, 100) : "unknown";
          verificationState = providerOutcome === "succeeded" ? "fulfillment_retry_required" : "provider_unavailable";
          logStatus(verificationState === "fulfillment_retry_required" ? "fulfillment_retry_required" : "inquiry_failed", {
            providerOutcome,
            errorCode: failureCode,
          });
          await updateActiveAttempt(db, id, {
            lastReconciledAt: new Date(),
            reconciliationLastError: failureCode,
            reconciliationResult: verificationState,
          }).catch((updateCause) => {
            const updateCode = updateCause instanceof Error ? updateCause.message.slice(0, 100) : "unknown";
            logStatus("attempt_diagnostic_persistence_failed", { errorCode: updateCode });
            return null;
          });
        }
      }
    }
    const refreshed = await db.get(attemptPath(id));
    const current = refreshed ? decodeFields(refreshed.fields) : attempt;
    let status = isTerminalAttemptStatus(current.status)
      ? String(current.status)
      : ["creating", "creation_unknown"].includes(String(current.status)) || !current.checkoutUrl ? "verification_required" : "pending";
    if (status === "succeeded") {
      const [enrollment, subscriber] = await Promise.all([
        db.get(enrollPath(uid, String(current.courseId))),
        db.get(subscriberPath(String(current.courseId), uid)),
      ]);
      const fulfillmentStatus = String(current.fulfillmentStatus ?? "");
      if (!enrollment || !subscriber || !["fulfilled", "free_enrolled"].includes(fulfillmentStatus)) {
        status = "paid_requires_review";
        verificationState = "fulfillment_inconsistent";
        logStatus("fulfillment_inconsistent", {
          enrollmentPresent: Boolean(enrollment),
          subscriberPresent: Boolean(subscriber),
          fulfillmentMarkerPresent: Boolean(fulfillmentStatus),
        });
      }
    }
    retryAfterSeconds = isTerminalAttemptStatus(current.status)
      ? 0
      : inquiryRetryAfterSeconds(current.lastReconciledAt);
    const canResume = canResumeCheckout(current);
    if (isTerminalAttemptStatus(current.status) && verificationState === "cooldown") verificationState = "terminal";
    logStatus("response_ready", { status, verificationState, retryAfterSeconds, canResume });
    return json({
      ok: true,
      paymentAttemptId: id,
      status,
      verificationState,
      retryAfterSeconds,
      canRetry: !isTerminalAttemptStatus(status),
      canResume,
      amountCents: current.amountCents,
      currency: "EGP",
      checkoutUrl: current.checkoutUrl ?? "",
      quote: current.quote ?? null,
    });
  } catch (cause) {
    logStatus("request_failed", { errorCode: cause instanceof Error ? cause.message.slice(0, 100) : "unknown" });
    if (cause instanceof Error && cause.message === "unauthorized") return error("unauthorized", "Authentication is required.", 401);
    const result = safeError(cause); return error(result.code, result.message, result.status);
  }
});
