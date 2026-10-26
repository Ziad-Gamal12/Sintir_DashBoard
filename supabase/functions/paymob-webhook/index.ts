import { Firestore } from "../_shared/firebase.ts";
import { error, json } from "../_shared/http.ts";
import { attemptPath, decodeFields, fulfillPayment, readBody, safeError, updateActiveAttempt, updateAttempt, verifyPaymobHmac } from "../_shared/course_checkout.ts";
Deno.serve(async (request) => {
  const requestId = crypto.randomUUID();
  const logCallback = (stage: string, details: Record<string, unknown> = {}) => {
    console.info(JSON.stringify({ function: "paymob-webhook", requestId, stage, ...details }));
  };
  logCallback("request_received", { method: request.method });
  if (request.method !== "POST") return error("method_not_allowed", "Use POST.", 405);
  try {
    const payload = await readBody(request);
    const obj = payload?.obj;
    if (!payload || typeof payload !== "object" || !obj || typeof obj !== "object" || payload.type !== "TRANSACTION") {
      logCallback("callback_rejected", { reason: "invalid_payload" });
      return error("invalid_callback", "Transaction callback payload is invalid.", 400);
    }
    const signature = new URL(request.url).searchParams.get("hmac");
    if (!await verifyPaymobHmac(obj, signature)) {
      logCallback("callback_rejected", { reason: "invalid_signature" });
      return error("invalid_signature", "Callback signature is invalid.", 401);
    }
    if (!Number.isSafeInteger(Number(obj.id)) || Number(obj.id) <= 0 || !Number.isSafeInteger(Number(obj.amount_cents)) || Number(obj.amount_cents) <= 0 || typeof obj.currency !== "string" || !Number.isSafeInteger(Number(obj.integration_id)) || Number(obj.integration_id) <= 0 || typeof obj.pending !== "boolean" || typeof obj.success !== "boolean" || !obj.order || obj.order.id === undefined) {
      logCallback("callback_rejected", { reason: "invalid_fields" });
      return error("invalid_callback", "Transaction callback fields are invalid.", 400);
    }
    const db = new Firestore();
    const attemptId = obj.merchant_order_id ?? obj.order?.merchant_order_id;
    if (typeof attemptId !== "string" || !/^[A-Za-z0-9_-]{1,160}$/.test(attemptId)) {
      logCallback("callback_rejected", { reason: "invalid_attempt_reference" });
      return error("unmatched_callback", "No matching payment attempt was found.", 404);
    }
    const doc = await db.get(attemptPath(attemptId));
    if (!doc) {
      logCallback("callback_rejected", { reason: "attempt_not_found" });
      return error("unmatched_callback", "No matching payment attempt was found.", 404);
    }
    const attempt = decodeFields(doc.fields);
    if (obj.order?.merchant_order_id != null && String(obj.order.merchant_order_id) !== attemptId) {
      logCallback("callback_rejected", { reason: "reference_mismatch" });
      return error("reference_mismatch", "Callback reference does not match the payment attempt.", 409);
    }
    if (attempt.paymobOrderId && String(obj.order?.id) !== String(attempt.paymobOrderId)) {
      logCallback("callback_rejected", { reason: "order_mismatch" });
      return error("order_mismatch", "Callback order does not match the payment attempt.", 409);
    }
    if (Number(obj.amount_cents) !== Number(attempt.amountCents) || obj.currency !== "EGP") {
      logCallback("callback_rejected", { reason: "payment_mismatch" });
      return error("payment_mismatch", "Callback amount or currency does not match the payment attempt.", 409);
    }
    const allowed = ["PAYMOB_WALLET_INTEGRATION_ID", "PAYMOB_ONLINE_CARD_INTEGRATION_ID", "PAYMOB_ACCEPT_KIOSK_INTEGRATION_ID", "PAYMOB_CASH_COLLECTION_INTEGRATION_ID"].map((name) => Number(Deno.env.get(name))).filter((value) => Number.isSafeInteger(value) && value > 0);
    if (!allowed.includes(Number(obj.integration_id))) {
      logCallback("callback_rejected", { reason: "integration_mismatch" });
      return error("integration_mismatch", "Callback integration is not configured for checkout.", 409);
    }
    logCallback("callback_validated", { attemptFound: true, attemptStatus: String(attempt.status ?? "unknown") });
    const paymentAction = obj.is_refunded === true || obj.is_refund === true || Number(obj.refunded_amount_cents ?? 0) > 0 || obj.is_voided === true || obj.is_void === true;
    if (attempt.status === "succeeded") {
      if (paymentAction) await updateAttempt(db, attemptId, { paymentLifecycleState: obj.is_refunded === true || obj.is_refund === true || Number(obj.refunded_amount_cents ?? 0) > 0 ? "refund_requires_review" : "void_requires_review", latestPaymobTransactionId: String(obj.id), lastCallbackAt: new Date() });
      logCallback("callback_acknowledged", { outcome: "duplicate_success" });
      return json({ ok: true, acknowledged: true, duplicate: true, status: attempt.status });
    }
    if (attempt.status === "paid_requires_review") {
      await updateAttempt(db, attemptId, { paymentLifecycleState: paymentAction ? "refund_or_void_requires_review" : "paid_conflict_requires_review", latestPaymobTransactionId: String(obj.id), lastCallbackAt: new Date() });
      logCallback("callback_acknowledged", { outcome: "review_required" });
      return json({ ok: true, acknowledged: true, status: attempt.status });
    }
    if (["failed", "creation_failed"].includes(attempt.status)) {
      logCallback("callback_acknowledged", { outcome: "duplicate_terminal_failure" });
      return json({ ok: true, acknowledged: true, duplicate: true, status: attempt.status });
    }
    if (obj.pending === true) {
      const status = await updateActiveAttempt(db, attemptId, { status: "pending", lastCallbackAt: new Date() });
      logCallback("callback_acknowledged", { outcome: "pending", status: status ?? "pending" });
      return json({ ok: true, acknowledged: true, status: status ?? "pending" });
    }
    const terminalSuccess = obj.success === true && obj.error_occured !== true && !paymentAction && (obj.is_auth !== true || obj.is_capture === true || obj.is_captured === true);
    if (!terminalSuccess) {
      // Paymob callbacks can describe follow-up actions and only report the
      // latest transaction. Let the authenticated inquiry job establish a
      // definitive failure before releasing this reservation.
      const status = await updateActiveAttempt(db, attemptId, { status: "pending", latestPaymobTransactionId: String(obj.id), lastCallbackAt: new Date(), reconciliationResult: paymentAction ? "payment_action_requires_review" : "callback_non_success_pending_inquiry" });
      logCallback("callback_acknowledged", { outcome: "non_success_inquiry_required", status: status ?? "pending" });
      return json({ ok: true, acknowledged: true, status: status ?? "pending" });
    }
    const status = await fulfillPayment(db, attemptId, obj);
    logCallback("callback_fulfillment_completed", { status });
    return json({ ok: true, acknowledged: true, status });
  } catch (cause) {
    const result = safeError(cause);
    logCallback("callback_processing_failed", { errorCode: result.code });
    return error(result.code, result.message, result.status === 500 ? 500 : result.status);
  }
});
