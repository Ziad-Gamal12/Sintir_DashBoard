import { Firestore } from "../_shared/firebase.ts";
import { error, json } from "../_shared/http.ts";
import { attemptPath, canResumeCheckout, classifyPaymobInquiry, decodeFields, enrollPath, FulfillmentRecordsMissingError, hasVerifiedPaymentEvidence, inquiryRetryAfterSeconds, isTerminalAttemptStatus, readBody, reconcileAttempt, requiredId, requireCaller, retryVerifiedPaymentFulfillment, safeError, subscriberPath, updateActiveAttempt } from "../_shared/course_checkout.ts";
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
    logStatus("attempt_loaded", { paymentAttemptId: id, attemptFound: true, ownershipChecksPassed: true, attemptStatus: String(attempt.status ?? "unknown") });
    let verificationState = "terminal";
    let retryAfterSeconds = 0;
    let paymentConfirmedForThisResponse = hasVerifiedPaymentEvidence(attempt, id);
    if (paymentConfirmedForThisResponse) {
      verificationState = "fulfillment_retry_required";
      logStatus("verified_payment_fulfillment_retry_started", {
        paymentAttemptId: id,
        paymentSuccessVerified: true,
        providerInquirySkipped: true,
      });
      try {
        const reconciledState = await retryVerifiedPaymentFulfillment(db, id);
        verificationState = ["succeeded", "paid_requires_review"].includes(reconciledState)
          ? "resolved"
          : "fulfillment_retry_required";
        logStatus("verified_payment_fulfillment_retry_completed", {
          paymentAttemptId: id,
          paymentSuccessVerified: true,
          reconciledState,
        });
      } catch (cause) {
        verificationState = cause instanceof FulfillmentRecordsMissingError
          ? "fulfillment_records_missing"
          : "fulfillment_retry_required";
        const errorCode = cause instanceof FulfillmentRecordsMissingError
          ? "fulfillment_records_missing"
          : cause instanceof Error && /^[a-z0-9_]+$/.test(cause.message)
            ? cause.message
            : "fulfillment_unexpected_error";
        logStatus("verified_payment_fulfillment_retry_failed", {
          paymentAttemptId: id,
          paymentSuccessVerified: true,
          errorCode,
          missingRecordCategories: cause instanceof FulfillmentRecordsMissingError
            ? cause.missingRecordCategories
            : [],
        });
      }
    } else if (!isTerminalAttemptStatus(attempt.status)) {
      retryAfterSeconds = inquiryRetryAfterSeconds(attempt.lastReconciledAt);
      if (retryAfterSeconds > 0) {
        verificationState = "cooldown";
        logStatus("inquiry_skipped_cooldown", { paymentAttemptId: id, attemptStatus: String(attempt.status), retryAfterSeconds });
      } else {
        verificationState = "inquiry_started";
        logStatus("inquiry_started", {
          paymentAttemptId: id,
          hasPersistedOrderId: Boolean(attempt.paymobOrderId),
          hasMerchantReference: Boolean(attempt.paymobSpecialReference ?? id),
        });
        let providerOutcome = "unavailable";
        let providerResultReceived = false;
        try {
          const result = await inquireIntention({
            orderId: attempt.paymobOrderId ? String(attempt.paymobOrderId) : undefined,
            merchantReference: String(attempt.paymobSpecialReference ?? id),
          });
          providerResultReceived = true;
          providerOutcome = classifyPaymobInquiry(result);
          const reconciledState = await reconcileAttempt(db, id, result);
          verificationState = reconciledState === "succeeded" || reconciledState === "failed" || reconciledState === "paid_requires_review"
            ? "resolved"
            : "inquiry_complete";
          logStatus("inquiry_completed", { paymentAttemptId: id, providerOutcome, reconciledState });
        } catch (cause) {
          const refreshedAfterFailure = await db.get(attemptPath(id));
          const currentAttempt = refreshedAfterFailure ? decodeFields(refreshedAfterFailure.fields) : attempt;
          paymentConfirmedForThisResponse = paymentConfirmedForThisResponse || hasVerifiedPaymentEvidence(currentAttempt, id);
          verificationState = paymentConfirmedForThisResponse
            ? cause instanceof FulfillmentRecordsMissingError ? "fulfillment_records_missing" : "fulfillment_retry_required"
            : providerResultReceived ? "inquiry_inconclusive" : "provider_unavailable";
          const errorCode = cause instanceof FulfillmentRecordsMissingError
            ? "fulfillment_records_missing"
            : cause instanceof Error && /^[a-z0-9_]+$/.test(cause.message)
              ? cause.message
              : "payment_reconciliation_failed";
          logStatus(paymentConfirmedForThisResponse ? "fulfillment_retry_required" : "inquiry_failed", {
            paymentAttemptId: id,
            providerOutcome,
            paymentSuccessVerified: paymentConfirmedForThisResponse,
            errorCode,
            missingRecordCategories: cause instanceof FulfillmentRecordsMissingError
              ? cause.missingRecordCategories
              : [],
          });
          await updateActiveAttempt(db, id, {
            lastReconciledAt: new Date(),
            reconciliationLastError: errorCode,
            reconciliationResult: verificationState === "fulfillment_records_missing"
              ? "fulfillment_records_missing"
              : paymentConfirmedForThisResponse ? "fulfillment_retry_required" : verificationState,
            ...(paymentConfirmedForThisResponse ? {
              fulfillmentStatus: verificationState === "fulfillment_records_missing"
                ? "canonical_records_missing_review"
                : "retry_required",
              fulfillmentMissingRecordCategories: cause instanceof FulfillmentRecordsMissingError
                ? cause.missingRecordCategories
                : [],
            } : {}),
          }).catch((updateCause) => {
            const updateCode = updateCause instanceof Error && /^[a-z0-9_]+$/.test(updateCause.message)
              ? updateCause.message
              : "diagnostic_persistence_failed";
            logStatus("attempt_diagnostic_persistence_failed", { paymentAttemptId: id, errorCode: updateCode });
            return null;
          });
        }
      }
    }

    const refreshed = await db.get(attemptPath(id));
    const current = refreshed ? decodeFields(refreshed.fields) : attempt;
    const paymentConfirmed = paymentConfirmedForThisResponse || hasVerifiedPaymentEvidence(current, id);
    let status = isTerminalAttemptStatus(current.status)
      ? String(current.status)
      : paymentConfirmed || ["creating", "creation_unknown"].includes(String(current.status)) || !current.checkoutUrl ? "verification_required" : "pending";
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
    retryAfterSeconds = isTerminalAttemptStatus(current.status) || paymentConfirmed
      ? 0
      : inquiryRetryAfterSeconds(current.lastReconciledAt);
    const canResume = !paymentConfirmed && canResumeCheckout(current);
    if (isTerminalAttemptStatus(current.status) && verificationState === "cooldown") verificationState = "terminal";
    logStatus("response_ready", { paymentAttemptId: id, status, verificationState, retryAfterSeconds, canResume, paymentConfirmed });
    return json({
      ok: true,
      paymentAttemptId: id,
      status,
      verificationState,
      retryAfterSeconds,
      canRetry: !isTerminalAttemptStatus(status),
      canResume,
      paymentConfirmed,
      amountCents: current.amountCents,
      currency: "EGP",
      checkoutUrl: paymentConfirmed ? "" : current.checkoutUrl ?? "",
      quote: current.quote ?? null,
    });
  } catch (cause) {
    logStatus("request_failed", { errorCode: cause instanceof Error ? cause.message.slice(0, 100) : "unknown" });
    if (cause instanceof Error && cause.message === "unauthorized") return error("unauthorized", "Authentication is required.", 401);
    const result = safeError(cause); return error(result.code, result.message, result.status);
  }
});
