import { Firestore, requiredSecret } from "../_shared/firebase.ts";
import { corsHeaders } from "../_shared/http.ts";
import {
  attemptPath,
  activeCheckoutDisposition,
  canResumeCheckout,
  decodeFields,
  findActiveCheckout,
  findResolvedCheckout,
  failAttemptAndReleaseReservation,
  fulfillFreeEnrollment,
  loadQuote,
  readBody,
  requiredCourseId,
  requiredId,
  requireCaller,
  reconcileAttempt,
  releaseTerminalCheckoutLock,
  reserveAttempt,
  reserveWithSingleConflictRecovery,
  classifyPaymobInquiry,
  safeError,
  updateActiveAttempt,
  updateAttempt,
} from "../_shared/course_checkout.ts";
import { inquireIntention } from "../_shared/paymob_inquiry.ts";
import {
  checkoutErrorResponse,
  checkoutRequestId,
  checkoutResponse,
  diagnosticError,
  logCheckoutEvent,
  type CheckoutStage,
} from "../_shared/course_checkout_diagnostics.ts";

async function recoverLockedCheckout(
  db: Firestore,
  uid: string,
  courseId: string,
  couponCode: string | undefined,
  requestId: string,
): Promise<Response | null> {
  const active = await findActiveCheckout(db, uid, courseId);
  logCheckoutEvent(requestId, "checkout_lock_resolution", {
    lockFound: active !== null,
    resolution: !active ? "no_active_lock" : "stale" in active ? "review_required" : "attempt_found",
    ...(active && "stale" in active ? {
      staleReason: active.reason,
      attemptIdentifierPresent: active.attemptIdentifierPresent,
      attemptRecordExists: active.attemptRecordExists,
      ownershipChecksPassed: active.ownershipChecksPassed,
    } : {
      attemptIdentifierPresent: Boolean(active && "id" in active),
      attemptRecordExists: Boolean(active && "id" in active),
      ownershipChecksPassed: Boolean(active && "id" in active),
    }),
    attemptStatus: active && !("stale" in active) ? String(active.attempt.status ?? "unknown") : undefined,
  });
  if (!active) {
    const resolved = await findResolvedCheckout(db, uid, courseId);
    if (!resolved) return null;
    const status = String(resolved.attempt.status);
    return checkoutResponse({
      ok: true,
      paymentAttemptId: resolved.id,
      checkoutUrl: "",
      status,
      quote: resolved.attempt.quote ?? null,
      resumedExisting: true,
      requiresConfirmation: false,
      ...(status === "paid_requires_review" ? { message: "Payment is being reviewed. Do not pay again." } : {}),
    }, requestId);
  }
  if ("stale" in active) {
    return checkoutErrorResponse("stale_checkout_lock", "An earlier checkout needs support review before another payment can start.", 409, requestId);
  }

  let { id, attempt } = active;
  if (activeCheckoutDisposition(attempt) === "resolved_failure") {
    await releaseTerminalCheckoutLock(db, id);
    return null;
  }

  let inquiryOutcome = "not_attempted";
  if (["creating", "creation_unknown", "pending"].includes(String(attempt.status))) {
    try {
      const result = await inquireIntention({
        orderId: attempt.paymobOrderId ? String(attempt.paymobOrderId) : undefined,
        merchantReference: String(attempt.paymobSpecialReference ?? id),
      });
      inquiryOutcome = classifyPaymobInquiry(result);
      await reconcileAttempt(db, id, result);
    } catch (cause) {
      const code = cause instanceof Error ? cause.message : "unknown";
      inquiryOutcome = "unavailable";
      console.error("Active course checkout recovery inquiry failed", { requestId, code });
    }
    logCheckoutEvent(requestId, "checkout_active_attempt_inquiry", { attempted: true, outcome: inquiryOutcome });
    const refreshed = await db.get(attemptPath(id));
    if (refreshed) attempt = decodeFields(refreshed.fields);
    if (activeCheckoutDisposition(attempt) === "resolved_failure") {
      await releaseTerminalCheckoutLock(db, id);
      return null;
    }
  }

  if (!attempt.quote || typeof attempt.quote !== "object") {
    return checkoutErrorResponse("stale_checkout_lock", "An earlier checkout needs support review before another payment can start.", 409, requestId);
  }
  const status = String(attempt.status);
  const inquiryUnresolved = ["unavailable", "missing", "invalid"].includes(inquiryOutcome);
  const checkoutUrl = !inquiryUnresolved && canResumeCheckout(attempt) ? attempt.checkoutUrl : "";
  return checkoutResponse({
    ok: true,
    paymentAttemptId: id,
    checkoutUrl,
    status: status === "pending" && !checkoutUrl ? "verification_required" : status,
    ...(inquiryUnresolved ? { verificationState: inquiryOutcome === "unavailable" ? "provider_unavailable" : "inquiry_inconclusive" } : {}),
    quote: attempt.quote,
    resumedExisting: true,
    requiresConfirmation: !["succeeded", "paid_requires_review"].includes(status),
    originalCouponCode: attempt.couponCode ?? null,
    requestedCouponCode: couponCode?.trim() || null,
    requestDiffers: (attempt.couponCode ?? null) !== (couponCode?.trim() || null),
  }, requestId);
}

Deno.serve(async (request) => {
  const requestId = checkoutRequestId();
  let stage: CheckoutStage = "request_received";
  let db: Firestore | undefined;
  let attemptId = "";
  let callerUid = "";
  let requestCourseId = "";
  let requestedCoupon: string | undefined;
  let attemptReserved = false;
  let paymobRequestStarted = false;
  let paymobResponseStatus: number | null = null;
  let paymobIntentionCreated = false;

  logCheckoutEvent(requestId, stage, { method: request.method });
  if (request.method === "OPTIONS") {
    return new Response("ok", {
      headers: { ...corsHeaders, "x-checkout-request-id": requestId },
    });
  }
  if (request.method !== "POST") {
    return checkoutErrorResponse("method_not_allowed", "Use POST.", 405, requestId);
  }

  try {
    // Construct inside the try so missing server configuration is logged and
    // returned through the same safe error envelope as later checkout stages.
    stage = "firestore_client_initialization";
    db = new Firestore();
    logCheckoutEvent(requestId, "firestore_client_initialization");
    stage = "firebase_identity_verification";
    const uid = await requireCaller(request);
    callerUid = uid;
    stage = "firebase_identity_verified";
    logCheckoutEvent(requestId, stage);

    stage = "request_parsing";
    const body = await readBody(request);
    const courseId = requiredCourseId(body.courseId);
    requestCourseId = courseId;
    requestedCoupon = typeof body.couponCode === "string" ? body.couponCode : undefined;
    attemptId = requiredId(body.idempotencyKey, "idempotencyKey");
    if (body.couponCode !== undefined && typeof body.couponCode !== "string") {
      return checkoutErrorResponse("invalid_couponCode", "Coupon code is invalid.", 400, requestId);
    }
    stage = "request_validated";
    logCheckoutEvent(requestId, stage, { hasCoupon: Boolean(body.couponCode?.trim()) });

    stage = "idempotency_lookup";
    const existing = await db.get(attemptPath(attemptId));
    stage = "idempotency_checked";
    logCheckoutEvent(requestId, stage, { existingAttempt: Boolean(existing) });
    if (existing) {
      const attempt = decodeFields(existing.fields);
      if (
        attempt.uid !== uid || attempt.courseId !== courseId ||
        (attempt.couponCode ?? null) !==
          ((typeof body.couponCode === "string" && body.couponCode.trim()) ? body.couponCode.trim() : null)
      ) {
        return checkoutErrorResponse("idempotency_conflict", "This checkout key is already in use.", 409, requestId);
      }
      const recovered = await recoverLockedCheckout(db, uid, courseId, body.couponCode, requestId);
      if (recovered) return recovered;
      const refreshedExisting = await db.get(attemptPath(attemptId));
      if (refreshedExisting) Object.assign(attempt, decodeFields(refreshedExisting.fields));
      if (attempt.status === "succeeded" && attempt.fulfillmentStatus === "free_enrolled") {
        return checkoutResponse({ ok: true, paymentAttemptId: attemptId, checkoutUrl: "", status: "succeeded", quote: attempt.quote, resumedExisting: true }, requestId);
      }
      if (attempt.status === "creating") {
        return checkoutErrorResponse("checkout_processing", "Checkout creation is still processing. Retry shortly.", 409, requestId);
      }
      if (attempt.status === "creation_unknown") {
        return checkoutErrorResponse("checkout_status_unknown", "Checkout status is being confirmed. Check your course access before trying again.", 409, requestId);
      }
      if (attempt.status === "paid_requires_review") {
        return checkoutErrorResponse("paid_requires_review", "Paymob reported a payment that needs support review. Do not pay again yet.", 409, requestId);
      }
      return checkoutErrorResponse("checkout_creation_failed", "Checkout could not be started. Start a new checkout attempt.", 409, requestId);
    }

    // The server lock outlives the app's in-memory idempotency key. Resolve it
    // before loading a new quote or reserving another coupon/payment attempt.
    const recovered = await recoverLockedCheckout(db, uid, courseId, body.couponCode, requestId);
    if (recovered) return recovered;

    stage = "course_quote_loading";
    const { quote, course, user } = await loadQuote(db, uid, courseId, body.couponCode);
    stage = "course_loaded";
    logCheckoutEvent(requestId, stage);
    if (body.couponCode?.trim()) {
      stage = "coupon_validated";
      logCheckoutEvent(requestId, stage);
    }
    stage = "billing_data_validation";
    if (typeof user.phoneNumber !== "string" || user.phoneNumber.trim().length < 7 || user.phoneNumber.trim().toUpperCase() === "NA") {
      throw new Error("billing_phone_missing");
    }
    stage = "billing_validated";
    logCheckoutEvent(requestId, stage);

    const teacherId = course.contentcreaterentity?.id;
    if (typeof teacherId !== "string" || !teacherId) {
      return checkoutErrorResponse("course_owner_missing", "Course owner is unavailable.", 409, requestId);
    }
    if (quote.amountCents === 0) {
      const freeAttempt = {
        uid,
        courseId,
        teacherId,
        status: "creating",
        amountCents: 0,
        quote,
        couponCode: quote.couponCode,
      providerRequestState: "not_sent",
        createdAt: new Date(),
        updatedAt: new Date(),
        paymobSpecialReference: attemptId,
      };
      stage = "checkout_reservation";
      const reservation = await reserveWithSingleConflictRecovery(
        async () => {
          await reserveAttempt(db!, attemptId, freeAttempt, courseId);
          attemptReserved = true;
        },
        async () => {
          logCheckoutEvent(requestId, "checkout_reservation_conflict", { recoveryAttempted: true, freeEnrollment: true });
          return callerUid && requestCourseId
            ? await recoverLockedCheckout(db!, callerUid, requestCourseId, requestedCoupon, requestId)
            : null;
        },
      );
      if (reservation.kind === "recovered") return reservation.value;
      stage = "checkout_reservation_created";
      logCheckoutEvent(requestId, stage, { freeEnrollment: true });
      stage = "free_enrollment_fulfillment";
      await fulfillFreeEnrollment(db, attemptId);
      stage = "checkout_response_ready";
      logCheckoutEvent(requestId, stage, { freeEnrollment: true });
      return checkoutResponse({ ok: true, paymentAttemptId: attemptId, checkoutUrl: "", status: "succeeded", quote }, requestId);
    }

    // Read and validate all payment configuration before reserving a coupon.
    stage = "paymob_configuration";
    const paymobSecret = requiredSecret("PAYMOB_SECRET_KEY");
    const publicKey = requiredSecret("PAYMOB_PUBLIC_KEY");
    const base = requiredSecret("SUPABASE_URL");
    const integrations = [
      "PAYMOB_WALLET_INTEGRATION_ID",
      "PAYMOB_ONLINE_CARD_INTEGRATION_ID",
      "PAYMOB_ACCEPT_KIOSK_INTEGRATION_ID",
      "PAYMOB_CASH_COLLECTION_INTEGRATION_ID",
    ].map((name) => Deno.env.get(name))
      .filter((value): value is string => Boolean(value))
      .map(Number)
      .filter((value) => Number.isSafeInteger(value) && value > 0);
    if (!integrations.length) throw new Error("missing_integrations");
    stage = "configuration_validated";
    logCheckoutEvent(requestId, stage, { integrationCount: integrations.length });

    // Reserve before calling Paymob. This stable reference lets the webhook
    // and reconciliation function recover an intention if persistence fails.
    const attempt = {
      uid,
      courseId,
      teacherId,
      status: "creating",
      amountCents: quote.amountCents,
      quote,
      couponCode: quote.couponCode,
      providerRequestState: "not_sent",
      createdAt: new Date(),
      updatedAt: new Date(),
      paymobSpecialReference: attemptId,
    };
    stage = "checkout_reservation";
    const reservation = await reserveWithSingleConflictRecovery(
      async () => {
        await reserveAttempt(db!, attemptId, attempt, courseId);
        attemptReserved = true;
      },
      async () => {
        logCheckoutEvent(requestId, "checkout_reservation_conflict", { recoveryAttempted: true, freeEnrollment: false });
        return callerUid && requestCourseId
          ? await recoverLockedCheckout(db!, callerUid, requestCourseId, requestedCoupon, requestId)
          : null;
      },
    );
    if (reservation.kind === "recovered") return reservation.value;
    stage = "checkout_reservation_created";
    logCheckoutEvent(requestId, stage, { freeEnrollment: false });

    stage = "paymob_intention_requested";
    await updateAttempt(db, attemptId, { providerRequestState: "may_have_been_sent", providerRequestStartedAt: new Date() });
    paymobRequestStarted = true;
    logCheckoutEvent(requestId, stage);
    const intention = await fetch("https://accept.paymob.com/v1/intention/", {
      method: "POST",
      headers: { authorization: `Token ${paymobSecret}`, "content-type": "application/json" },
      body: JSON.stringify({
        amount: quote.amountCents,
        currency: quote.currency,
        payment_methods: integrations,
        items: [{ name: String(course.title ?? "Course subscription"), amount: quote.amountCents, description: String(course.description ?? "") }],
        billing_data: {
          apartment: "NA",
          building: "NA",
          city: user.address || "NA",
          country: "EG",
          email: user.email || "NA",
          floor: "NA",
          first_name: user.firstName || "Student",
          last_name: user.lastName || user.firstName || "Student",
          phone_number: user.phoneNumber.trim(),
          street: "NA",
        },
        special_reference: attemptId,
        notification_url: `${base}/functions/v1/paymob-webhook`,
      }),
    });
    paymobResponseStatus = intention.status;
    stage = "paymob_intention_responded";
    logCheckoutEvent(requestId, stage, { providerStatus: intention.status });

    stage = "paymob_response_parsing";
    const response = await intention.json().catch(() => ({}));
    const clientSecret = typeof response.client_secret === "string" ? response.client_secret.trim() : "";
    paymobIntentionCreated = intention.ok && clientSecret.length > 0;
    const definitiveRejection = intention.status >= 400 && intention.status < 500 && ![408, 409, 429].includes(intention.status);
    if (definitiveRejection) {
      stage = "attempt_failure_persistence";
      await failAttemptAndReleaseReservation(db, attemptId, { creationErrorCode: "paymob_rejected" }, "creation_failed");
      attemptReserved = false;
      const latestAttempt = await db.get(attemptPath(attemptId));
      const latest = latestAttempt ? decodeFields(latestAttempt.fields) : null;
      if (latest && ["succeeded", "paid_requires_review"].includes(String(latest.status))) {
        return checkoutResponse({ ok: true, paymentAttemptId: attemptId, checkoutUrl: "", status: latest.status, quote: latest.quote ?? quote, resumedExisting: true, requiresConfirmation: false }, requestId);
      }
      return checkoutErrorResponse("paymob_intention_failed", "Paymob could not start checkout. Please retry.", 502, requestId);
    }
    if (!intention.ok || !clientSecret) {
      stage = "payment_attempt_persistence";
      await updateActiveAttempt(db, attemptId, { status: "creation_unknown", creationErrorCode: "ambiguous_paymob_response", updatedAt: new Date() });
      const latestAttempt = await db.get(attemptPath(attemptId));
      const latest = latestAttempt ? decodeFields(latestAttempt.fields) : null;
      if (latest && ["succeeded", "paid_requires_review"].includes(String(latest.status))) {
        return checkoutResponse({ ok: true, paymentAttemptId: attemptId, checkoutUrl: "", status: latest.status, quote: latest.quote ?? quote, resumedExisting: true, requiresConfirmation: false }, requestId);
      }
      return checkoutErrorResponse("paymob_intention_unknown", "Checkout status is being confirmed. Please check again shortly.", 502, requestId);
    }

    stage = "paymob_intention_created";
    logCheckoutEvent(requestId, stage, {
      intentionIdPresent: response.id !== undefined && response.id !== null,
      orderIdPresent: response.intention_order_id !== undefined && response.intention_order_id !== null,
    });
    const url = `https://accept.paymob.com/unifiedcheckout/?publicKey=${encodeURIComponent(publicKey)}&clientSecret=${encodeURIComponent(clientSecret)}`;
    stage = "payment_attempt_persistence";
    const persistedStatus = await updateActiveAttempt(db, attemptId, {
      status: "pending",
      checkoutUrl: url,
      paymobIntentionId: String(response.id ?? ""),
      paymobOrderId: String(response.intention_order_id ?? ""),
      updatedAt: new Date(),
    });
    const latestAttempt = await db.get(attemptPath(attemptId));
    const latest = latestAttempt ? decodeFields(latestAttempt.fields) : null;
    if (latest && ["succeeded", "paid_requires_review", "failed", "creation_failed"].includes(String(latest.status))) {
      return checkoutResponse({
        ok: true,
        paymentAttemptId: attemptId,
        checkoutUrl: "",
        status: latest.status,
        quote: latest.quote ?? quote,
        resumedExisting: true,
        requiresConfirmation: false,
      }, requestId);
    }
    stage = "payment_attempt_persisted";
    logCheckoutEvent(requestId, stage, { paymobIntentionCreated: true, persistedStatus });
    stage = "checkout_response_ready";
    logCheckoutEvent(requestId, stage);
    return checkoutResponse({ ok: true, paymentAttemptId: attemptId, checkoutUrl: url, status: "pending", quote }, requestId);
  } catch (cause) {
    const result = safeError(cause);
    const exception = diagnosticError(cause);
    logCheckoutEvent(requestId, "checkout_failed", {
      failedStage: stage,
      errorCode: result.code,
      errorName: exception.name,
      errorMessage: exception.message,
      ...(exception.stack ? { errorStack: exception.stack } : {}),
      attemptMayExist: attemptReserved || paymobRequestStarted,
      newAttemptMayExist: attemptReserved || paymobRequestStarted,
      activeLockMayExist: result.code === "checkout_in_progress",
      paymobRequestStarted,
      paymobResponseStatus,
      paymobIntentionMayExist: paymobIntentionCreated || (paymobRequestStarted && (
        paymobResponseStatus === null ||
        paymobResponseStatus >= 200 && paymobResponseStatus < 400 ||
        paymobResponseStatus >= 500 ||
        [408, 409, 429].includes(paymobResponseStatus)
      )),
    });

    if (attemptId && db && (attemptReserved || paymobRequestStarted)) {
      try {
        const current = await db.get(attemptPath(attemptId));
        if (current && decodeFields(current.fields).status === "creating") {
          await updateAttempt(db, attemptId, { status: "creation_unknown", updatedAt: new Date() });
        }
      } catch (cleanupCause) {
        const cleanupError = diagnosticError(cleanupCause);
        logCheckoutEvent(requestId, "checkout_failed", {
          failedStage: "attempt_recovery",
          errorName: cleanupError.name,
          errorMessage: cleanupError.message,
          ...(cleanupError.stack ? { errorStack: cleanupError.stack } : {}),
          attemptMayExist: true,
          paymobRequestStarted,
          paymobResponseStatus,
          paymobIntentionMayExist: paymobIntentionCreated || paymobRequestStarted,
        });
      }
    }
    if (result.code === "checkout_in_progress" && db) {
      try {
        if (callerUid && requestCourseId) {
          const recovered = await recoverLockedCheckout(db, callerUid, requestCourseId, requestedCoupon, requestId);
          if (recovered) return recovered;
        }
      } catch (recoveryCause) {
        const recoveryError = diagnosticError(recoveryCause);
        logCheckoutEvent(requestId, "checkout_lock_resolution", {
          lockFound: null,
          resolution: "recovery_unavailable",
          errorName: recoveryError.name,
          errorMessage: recoveryError.message,
        });
      }
      return checkoutErrorResponse("checkout_retry_required", "Checkout status changed while this request was starting. Check payment status or retry shortly.", 409, requestId);
    }
    if (cause instanceof Error && cause.message === "unauthorized") {
      return checkoutErrorResponse("unauthorized", "Authentication is required.", 401, requestId);
    }
    return checkoutErrorResponse(result.code, result.message, result.status, requestId);
  }
});
