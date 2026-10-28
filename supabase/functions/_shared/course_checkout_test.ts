import {
  activeCheckoutDisposition,
  attemptPath,
  calculateQuote,
  canResumeCheckout,
  checkoutRecoveryDecision,
  checkoutLockPath,
  classifyPaymobInquiry,
  couponPath,
  couponReservationDisposition,
  coursePath,
  decodeFields,
  encode,
  enrollPath,
  FulfillmentRecordsMissingError,
  failAttemptAndReleaseReservation,
  fulfillPayment,
  findActiveCheckout,
  hasVerifiedPaymentEvidence,
  inquiryCorrelatesToAttempt,
  inquiryRetryAfterSeconds,
  paymobHmacFields,
  recoverableCheckoutUrl,
  requiredCourseId,
  requireCaller,
  retryVerifiedPaymentFulfillment,
  reserveWithSingleConflictRecovery,
  safeError,
  subscriberPath,
  userPath,
  verifyPaymobHmac,
} from "./course_checkout.ts";
import type { Firestore } from "./firebase.ts";

class MemoryFirestore {
  readonly documents = new Map<string, { name: string; fields: Record<string, any>; updateTime: string }>();
  private version = 0;
  commitCalls = 0;
  failOnCommitNumber: number | null = null;

  async beginTransaction(): Promise<string> { return `tx-${this.version}`; }
  async get(path: string): Promise<any> { return this.documents.get(path) ?? null; }
  document(path: string, fields: Record<string, any>): any { return { name: path, fields }; }
  async commit(_transaction: string, writes: any[]): Promise<void> {
    this.commitCalls++;
    if (this.commitCalls === this.failOnCommitNumber) {
      this.failOnCommitNumber = null;
      throw new Error("Firestore transaction could not commit (503).");
    }
    for (const write of writes) {
      if (write.delete) {
        this.documents.delete(write.delete);
        continue;
      }
      const path = write.update.name;
      const current = this.documents.get(path);
      if (write.currentDocument?.exists === false) {
        if (current) throw new Error(`Fake document already exists: ${path}`);
        this.version++;
        this.documents.set(path, {
          name: path,
          fields: { ...write.update.fields },
          updateTime: String(this.version),
        });
        continue;
      }
      if (!current) throw new Error(`Missing fake document: ${path}`);
      const data = decodeFields(current.fields);
      const incoming = decodeFields(write.update.fields);
      for (const fieldPath of write.updateMask.fieldPaths) {
        const segments = fieldPath.split(".");
        let source: any = incoming;
        for (const segment of segments) source = source?.[segment];
        if (source === undefined) continue;
        let target = data;
        for (const segment of segments.slice(0, -1)) {
          target[segment] ??= {};
          target = target[segment];
        }
        target[segments[segments.length - 1]] = source;
      }
      this.version++;
      this.documents.set(path, {
        ...current,
        fields: Object.fromEntries(Object.entries(data).map(([key, value]) => [key, encode(value)])),
        updateTime: String(this.version),
      });
    }
  }
  put(path: string, fields: Record<string, unknown>): void {
    this.documents.set(path, { name: path, fields: Object.fromEntries(Object.entries(fields).map(([key, value]) => [key, encode(value)])), updateTime: String(++this.version) });
  }
  read(path: string): Record<string, any> | null {
    const document = this.documents.get(path);
    return document ? decodeFields(document.fields) : null;
  }
}

const successfulPaymobResult = (attemptId: string) => ({
  id: "30001",
  pending: false,
  success: true,
  error_occured: false,
  is_auth: false,
  integration_id: 987,
  amount_cents: 12500,
  currency: "EGP",
  merchant_order_id: attemptId,
  order: { id: 65432, merchant_order_id: attemptId },
});

async function seedPaidAttempt(
  db: MemoryFirestore,
  attemptId: string,
  missingRecords: string[] = [],
): Promise<{ uid: string; courseId: string; teacherId: string; lockPath: string }> {
  Deno.env.set("PAYMOB_WALLET_INTEGRATION_ID", "987");
  const uid = "student-fulfillment";
  const courseId = "course-fulfillment";
  const teacherId = "teacher-fulfillment";
  if (!missingRecords.includes("course")) {
    db.put(coursePath(courseId), {
      state: "Published",
      contentcreaterentity: { id: teacherId },
      studentsCount: 0,
      title: "Payment recovery test course",
    });
  }
  if (!missingRecords.includes("student")) {
    db.put(userPath(uid), {
      firstName: "Test student",
      phoneNumber: "01000000000",
      teacherExtraData: {},
    });
  }
  if (!missingRecords.includes("teacher")) {
    db.put(userPath(teacherId), {
      teacherExtraData: { wallet: { balance: 0, total_earned: 0 } },
    });
  }
  db.put(attemptPath(attemptId), {
    uid,
    courseId,
    teacherId,
    status: "pending",
    amountCents: 12500,
    paymobSpecialReference: attemptId,
    paymobOrderId: "65432",
    checkoutUrl: "https://accept.paymob.com/checkout/original",
    reconciliationResult: "pending",
    couponReservationState: "none",
    createdAt: new Date("2026-10-28T12:00:00.000Z"),
  });
  const lockPath = await checkoutLockPath(uid, courseId);
  db.put(lockPath, { paymentAttemptId: attemptId, uid, courseId });
  return { uid, courseId, teacherId, lockPath };
}
import { checkoutErrorResponse, diagnosticError } from "./course_checkout_diagnostics.ts";

Deno.test("course document IDs preserve Arabic-Indic and existing formats exactly", () => {
  const arabicId = "٤٥٢٧٣٥٤٦";
  if (requiredCourseId(arabicId) !== arabicId) throw new Error("Arabic-Indic course ID was changed.");
  if (coursePath(arabicId) !== `Courses/${arabicId}`) throw new Error("Course lookup path changed the ID.");
  if (enrollPath("student", arabicId) !== `Users/student/Courses/${arabicId}`) throw new Error("Enrollment lookup path changed the ID.");
  for (const existingFormat of ["45273546", "course_2024-A", "autoGeneratedDocId9xK"] ) {
    if (requiredCourseId(existingFormat) !== existingFormat) throw new Error(`Valid ID was rejected or normalized: ${existingFormat}`);
  }
});

Deno.test("course ID validation rejects unsafe inputs with structured 400 errors", () => {
  const invalidValues: unknown[] = [null, 45273546, "", "   ", "bad/course", "line\nbreak", "x".repeat(1501), ".", "..", "__reserved__", "\ud800"];
  for (const value of invalidValues) {
    let rejected = false;
    try { requiredCourseId(value); } catch (cause) { rejected = cause instanceof Error && cause.message === "invalid_course_id"; }
    if (!rejected) throw new Error(`Invalid course ID was accepted: ${String(value).slice(0, 30)}`);
  }
  const response = safeError(new Error("invalid_course_id"));
  if (response.status !== 400 || response.code !== "invalid_course_id" || response.message !== "Course ID is invalid.") {
    throw new Error("Invalid course ID did not map to the stable public 400 error.");
  }
  const missing = safeError(new Error("not_found"));
  if (missing.status !== 404) throw new Error("A valid missing course did not map to not-found.");
});

Deno.test("unexpected checkout failures stay generic for clients and retain a safe diagnostic correlation", async () => {
  const requestId = "a0d17c03-13d0-4d60-9882-b7998c21d2e4";
  const result = safeError(new Error("Firestore transaction could not commit (503)."));
  const response = checkoutErrorResponse(result.code, result.message, result.status, requestId);
  const payload = await response.json();
  if (response.status !== 500 || payload.error?.code !== "internal_error" || payload.error?.message !== "Checkout could not be completed.") {
    throw new Error("Unexpected server errors must keep the safe generic 500 response.");
  }
  if (payload.error?.requestId !== requestId || response.headers.get("x-checkout-request-id") !== requestId) {
    throw new Error("The correlation ID was not returned for support diagnostics.");
  }

  const diagnostic = diagnosticError(new Error("Paymob failed with Authorization: Bearer private-token client_secret=private-client-secret"));
  if (!diagnostic.message.includes("Paymob failed")) throw new Error("The server diagnostic lost the original failure context.");
  if (diagnostic.message.includes("private-token") || diagnostic.message.includes("private-client-secret")) {
    throw new Error("The server diagnostic leaked payment credentials.");
  }
});

Deno.test("missing Firebase bearer token is rejected", async () => {
  let rejected = false;
  try { await requireCaller(new Request("https://example.test", { method: "POST" })); }
  catch (error) { rejected = error instanceof Error && error.message === "unauthorized"; }
  if (!rejected) throw new Error("Unauthenticated request was accepted.");
});

Deno.test("authoritative price uses integer cents and rounds coupon discounts", () => {
  const quote = calculateQuote(199, 12.5, "SAVE");
  if (quote.originalAmountCents !== 19900 || quote.discountAmountCents !== 2488 || quote.amountCents !== 17412) {
    throw new Error(`Unexpected quote: ${JSON.stringify(quote)}`);
  }
});

Deno.test("full coupon discounts produce zero without a negative charge", () => {
  const quote = calculateQuote(100, 100, "FREE");
  if (quote.amountCents !== 0 || quote.discountAmountCents !== 10000) throw new Error("Full discount was not clamped to zero.");
});

Deno.test("Paymob reconciliation distinguishes pending, definitive failure, success, and payment actions", () => {
  if (classifyPaymobInquiry(null) !== "missing") throw new Error("Missing transaction should remain unresolved.");
  if (classifyPaymobInquiry({ pending: true }) !== "pending") throw new Error("Pending transaction was not retained.");
  if (classifyPaymobInquiry({ pending: false, success: false, error_occured: false, order: { payment_status: "UNPAID" } }) !== "retryable_failure") throw new Error("An open order's failed transaction should not release its reservation.");
  if (classifyPaymobInquiry({ pending: false, success: false, error_occured: false, order: { is_canceled: true } }) !== "failed") throw new Error("Explicitly cancelled order was not classified as final.");
  if (classifyPaymobInquiry({ pending: false, success: false, order: { payment_status: "PAID" } }) !== "review") throw new Error("Paid order with failed latest transaction should require review.");
  if (classifyPaymobInquiry({ pending: false, success: true, error_occured: false, is_auth: false }) !== "succeeded") throw new Error("Successful captured transaction was not classified.");
  if (classifyPaymobInquiry({ pending: false, success: true, is_refunded: true }) !== "action") throw new Error("Refund callback was misclassified as a payment.");
  if (classifyPaymobInquiry({ pending: false, success: true, is_auth: true, is_capture: false }) !== "invalid") throw new Error("Auth-only transaction was misclassified as paid.");
});

Deno.test("payment status cooldown reports the remaining retry window", () => {
  const last = new Date("2026-10-26T12:00:00.000Z");
  if (inquiryRetryAfterSeconds(last, last.getTime() + 5_500) !== 25) throw new Error("Inquiry cooldown did not report the correct remaining seconds.");
  if (inquiryRetryAfterSeconds(last, last.getTime() + 30_000) !== 0) throw new Error("Elapsed inquiry cooldown continued blocking status checks.");
  if (inquiryRetryAfterSeconds(null, last.getTime()) !== 0) throw new Error("A missing prior check incorrectly started a cooldown.");
});

Deno.test("Paymob inquiry must correlate by stable reference or the persisted order ID", () => {
  const id = "attempt-1";
  const unknownOrder = { paymobSpecialReference: id };
  if (!inquiryCorrelatesToAttempt({ merchant_order_id: id, order: { id: 44 } }, unknownOrder, id)) throw new Error("Matching stable merchant reference was rejected.");
  if (inquiryCorrelatesToAttempt({ order: { id: 44 } }, unknownOrder, id)) throw new Error("Uncorrelated order was accepted for an attempt with no saved order ID.");

  const persistedOrder = { paymobSpecialReference: id, paymobOrderId: "44" };
  if (!inquiryCorrelatesToAttempt({ order: { id: 44 } }, persistedOrder, id)) throw new Error("Matching persisted Paymob order ID was rejected.");
  if (inquiryCorrelatesToAttempt({ merchant_order_id: "another-attempt", order: { id: 44 } }, persistedOrder, id)) throw new Error("Mismatched merchant reference was accepted despite the matching order ID.");
  if (inquiryCorrelatesToAttempt({ order: { id: 45 } }, persistedOrder, id)) throw new Error("Mismatched persisted order ID was accepted.");
});

Deno.test("active checkout recovery preserves success, review, pending, and ambiguous attempts", () => {
  if (activeCheckoutDisposition({ status: "succeeded" }) !== "success") throw new Error("A paid attempt was not recognized as fulfilled.");
  if (activeCheckoutDisposition({ status: "paid_requires_review" }) !== "review") throw new Error("A review-required payment was not protected from a second charge.");
  if (activeCheckoutDisposition({ status: "pending", checkoutUrl: "https://accept.paymob.com/checkout" }) !== "resume") throw new Error("A usable pending checkout was not resumable.");
  if (activeCheckoutDisposition({ status: "creation_unknown" }) !== "verify") throw new Error("An ambiguous intention was not retained for verification.");
  if (activeCheckoutDisposition({ status: "failed" }) !== "resolved_failure") throw new Error("An authoritative terminal failure was not resolved.");
});

Deno.test("a pending checkout can resume its same intention when no transaction exists", () => {
  const url = "https://accept.paymob.com/checkout/example";
  if (!canResumeCheckout({ status: "pending", checkoutUrl: url, reconciliationResult: "pending" })) {
    throw new Error("A provider-confirmed pending checkout was not resumable.");
  }
  if (!canResumeCheckout({ status: "pending", checkoutUrl: url, reconciliationResult: "latest_transaction_failed_order_open" })) {
    throw new Error("An open order after a retryable failed transaction was not resumable.");
  }
  if (!canResumeCheckout({ status: "pending", checkoutUrl: url, reconciliationResult: "no_transaction_yet" })) {
    throw new Error("A missing transaction was incorrectly treated as proof the intention expired.");
  }
  for (const result of ["provider_unavailable", "invalid", "payment_action_requires_review"]) {
    if (canResumeCheckout({ status: "pending", checkoutUrl: url, reconciliationResult: result })) {
      throw new Error(`An unresolved or review-required attempt was incorrectly resumable: ${result}`);
    }
  }
  if (canResumeCheckout({ status: "failed", checkoutUrl: url, reconciliationResult: "pending" })) {
    throw new Error("A terminal failure was marked resumable.");
  }
});

Deno.test("checkout recovery exposes the server-authorized resumability decision", () => {
  const url = "https://accept.paymob.com/checkout/example";
  const attempt = { status: "pending", checkoutUrl: url, reconciliationResult: "no_transaction_yet" };
  const resumable = checkoutRecoveryDecision(attempt, "missing");
  if (!resumable.canResume || resumable.checkoutUrl !== url) {
    throw new Error("A recoverable attempt did not expose its server decision and saved URL.");
  }

  const unavailable = checkoutRecoveryDecision(attempt, "unavailable");
  if (unavailable.canResume || unavailable.checkoutUrl !== "") {
    throw new Error("An unavailable provider inquiry incorrectly authorized checkout resumption.");
  }
});
Deno.test("no transaction keeps the attempt pending and preserves its original checkout data", async () => {
  const db = new MemoryFirestore();
  const attemptId = "attempt-no-transaction";
  const url = "https://accept.paymob.com/unifiedcheckout/?clientSecret=redacted";
  const quote = { amountCents: 17000, currency: "EGP", couponCode: null };
  db.put(attemptPath(attemptId), {
    uid: "student-1", courseId: "course-1", status: "pending", checkoutUrl: url,
    quote, reconciliationAttempts: 0,
  });

  const result = await reconcileAttempt(db as unknown as Firestore, attemptId, null);
  const attempt = db.read(attemptPath(attemptId));
  if (result !== "no_transaction_yet" || attempt?.status !== "pending") {
    throw new Error("An inquiry without a transaction incorrectly terminalized the attempt.");
  }
  if (attempt.checkoutUrl !== url || JSON.stringify(attempt.quote) !== JSON.stringify(quote)) {
    throw new Error("The original Paymob URL or quote changed during reconciliation.");
  }
  if (!canResumeCheckout(attempt)) throw new Error("The original intention was not offered for resumption.");
  if (recoverableCheckoutUrl(attempt, "missing") !== url) {
    throw new Error("Recovery did not return the original Paymob URL after a missing transaction.");
  }
  if (recoverableCheckoutUrl(attempt, "unavailable") !== "") {
    throw new Error("A transport failure incorrectly returned a checkout URL.");
  }
});

Deno.test("verified payment is persisted before fulfillment and retries without reopening checkout", async () => {
  const db = new MemoryFirestore();
  const attemptId = "attempt-verified-payment";
  const { uid, courseId, teacherId } = await seedPaidAttempt(db, attemptId);
  const providerResult = successfulPaymobResult(attemptId);

  const firstResult = await fulfillPayment(db as unknown as Firestore, attemptId, providerResult);
  let attempt = db.read(attemptPath(attemptId));
  if (firstResult !== "succeeded" || attempt?.status !== "succeeded") {
    throw new Error("A correlated Paymob success did not complete shared fulfillment.");
  }
  if (attempt.paymentVerificationState !== "verified_succeeded" || attempt.paymobTransactionId !== providerResult.id) {
    throw new Error("Verified transaction evidence was not retained on the payment attempt.");
  }
  if (!db.read(enrollPath(uid, courseId)) || !db.read(subscriberPath(courseId, uid))) {
    throw new Error("Successful fulfillment did not create both enrollment records.");
  }
  if (db.read(coursePath(courseId))?.studentsCount !== 1) {
    throw new Error("Course subscriber count was not incremented exactly once.");
  }
  if (db.read(userPath(teacherId))?.teacherExtraData?.wallet?.balance !== 118.75) {
    throw new Error("Teacher wallet credit did not use the verified payment amount.");
  }
  const transactionRecords = [...db.documents.keys()].filter((path) =>
    path === `Transactions/${providerResult.id}` ||
    path.endsWith(`/Transactions/${providerResult.id}`)
  );
  if (transactionRecords.length !== 3) throw new Error("Financial transaction records were not written exactly once.");

  const recovery = checkoutRecoveryDecision(attempt, "fulfillment_retry_required");
  if (recovery.canResume || recovery.checkoutUrl !== "" || canResumeCheckout(attempt)) {
    throw new Error("A confirmed payment was exposed as a resumable unpaid checkout.");
  }
  if (await retryVerifiedPaymentFulfillment(db as unknown as Firestore, attemptId) !== "succeeded") {
    throw new Error("Persisted verified payment evidence did not support a safe retry.");
  }
  if (await fulfillPayment(db as unknown as Firestore, attemptId, providerResult) !== "succeeded") {
    throw new Error("A repeated callback/inquiry did not remain idempotent.");
  }
  attempt = db.read(attemptPath(attemptId));
  if (attempt?.status !== "succeeded" || db.read(coursePath(courseId))?.studentsCount !== 1) {
    throw new Error("Repeated fulfillment duplicated or changed the completed enrollment.");
  }
  const repeatedTransactions = [...db.documents.keys()].filter((path) =>
    path === `Transactions/${providerResult.id}` ||
    path.endsWith(`/Transactions/${providerResult.id}`)
  );
  if (repeatedTransactions.length !== 3) throw new Error("Repeated fulfillment duplicated financial transaction records.");
});

Deno.test("missing canonical fulfillment records are classified without fabricating them", async () => {
  const attemptId = "attempt-missing-canonical-record";
  const providerResult = successfulPaymobResult(attemptId);
  for (const missingCategory of ["course", "student", "teacher"]) {
    const db = new MemoryFirestore();
    const { uid, courseId, teacherId, lockPath } = await seedPaidAttempt(db, attemptId, [missingCategory]);
    let failure: unknown;
    try {
      await fulfillPayment(db as unknown as Firestore, attemptId, providerResult);
    } catch (cause) {
      failure = cause;
    }
    if (!(failure instanceof FulfillmentRecordsMissingError) ||
      failure.missingRecordCategories.join(",") !== missingCategory) {
      throw new Error(`Missing ${missingCategory} data was not reported as a precise, sanitized prerequisite.`);
    }
    const attempt = db.read(attemptPath(attemptId));
    if (!hasVerifiedPaymentEvidence(attempt ?? {}, attemptId) ||
      attempt?.status !== "pending" ||
      attempt?.reconciliationResult !== "fulfillment_records_missing" ||
      JSON.stringify(attempt?.fulfillmentMissingRecordCategories) !== JSON.stringify([missingCategory])) {
      throw new Error("A paid attempt did not retain its evidence and actionable missing-record review state.");
    }
    if (!db.read(lockPath)) throw new Error("The checkout safety lock was released while payment fulfillment was incomplete.");
    if (db.read(coursePath(courseId)) === null && missingCategory !== "course") {
      throw new Error("An unrelated missing course record was not present in the fixture.");
    }
    if (db.read(userPath(uid)) === null && missingCategory !== "student") {
      throw new Error("An unrelated missing student record was not present in the fixture.");
    }
    if (db.read(userPath(teacherId)) === null && missingCategory !== "teacher") {
      throw new Error("An unrelated missing teacher record was not present in the fixture.");
    }
    if (db.read(enrollPath(uid, courseId)) || db.read(subscriberPath(courseId, uid))) {
      throw new Error("Fulfillment fabricated enrollment despite a missing canonical record.");
    }

    if (missingCategory === "course") {
      db.put(coursePath(courseId), { state: "Published", contentcreaterentity: { id: teacherId }, studentsCount: 0 });
    } else if (missingCategory === "student") {
      db.put(userPath(uid), { firstName: "Restored student", phoneNumber: "01000000000" });
    } else {
      db.put(userPath(teacherId), { teacherExtraData: { wallet: { balance: 0, total_earned: 0 } } });
    }
    if (await retryVerifiedPaymentFulfillment(db as unknown as Firestore, attemptId) !== "succeeded") {
      throw new Error(`Restoring canonical ${missingCategory} data did not recover the already-paid attempt.`);
    }
  }
});

Deno.test("transient Firestore fulfillment failure can retry from persisted payment evidence", async () => {
  const db = new MemoryFirestore();
  const attemptId = "attempt-transient-fulfillment";
  const { uid, courseId } = await seedPaidAttempt(db, attemptId);
  db.failOnCommitNumber = 2; // First commit stores verified payment evidence; second is fulfillment.
  let failed = false;
  try {
    await fulfillPayment(db as unknown as Firestore, attemptId, successfulPaymobResult(attemptId));
  } catch {
    failed = true;
  }
  const pending = db.read(attemptPath(attemptId));
  if (!failed || !hasVerifiedPaymentEvidence(pending ?? {}, attemptId) || pending?.status !== "pending") {
    throw new Error("A transient fulfillment failure lost the verified payment evidence or changed paid state unsafely.");
  }
  if (db.read(enrollPath(uid, courseId))) throw new Error("A failed Firestore transaction partially granted enrollment.");

  if (await retryVerifiedPaymentFulfillment(db as unknown as Firestore, attemptId) !== "succeeded") {
    throw new Error("A later retry did not complete fulfillment from stored evidence.");
  }
  if (db.read(coursePath(courseId))?.studentsCount !== 1 || !db.read(enrollPath(uid, courseId))) {
    throw new Error("The recovered attempt did not create one accessible enrollment.");
  }
});

Deno.test("active checkout lock lookup is scoped to the caller and retains stale locks", async () => {
  const uid = "student-1";
  const courseId = "course-1";
  const path = await checkoutLockPath(uid, courseId);
  const attemptFields = (owner: string, course: string) => ({
    uid: { stringValue: owner },
    courseId: { stringValue: course },
    status: { stringValue: "pending" },
    quote: { mapValue: { fields: { amountCents: { integerValue: "5000" } } } },
  });
  const attemptId = "attempt-1";
  const db = {
    get: async (requestedPath: string) => {
      if (requestedPath === path) return { name: path, fields: { paymentAttemptId: { stringValue: attemptId } } };
      if (requestedPath === `CoursePaymentAttempts/${attemptId}`) return { name: requestedPath, fields: attemptFields(uid, courseId) };
      return null;
    },
  } as unknown as Firestore;
  const active = await findActiveCheckout(db, uid, courseId);
  if (!active || "stale" in active || active.id !== attemptId || active.attempt.uid !== uid) throw new Error("The owner's active attempt was not recovered from its lock.");

  const foreignDb = {
    get: async (requestedPath: string) => requestedPath === path
      ? { name: path, fields: { paymentAttemptId: { stringValue: attemptId } } }
      : requestedPath === `CoursePaymentAttempts/${attemptId}`
        ? { name: requestedPath, fields: attemptFields("another-student", courseId) }
        : null,
  } as unknown as Firestore;
  const foreign = await findActiveCheckout(foreignDb, uid, courseId);
  if (!foreign || !("stale" in foreign)) throw new Error("A foreign attempt was exposed or reused.");

  const missingDb = {
    get: async (requestedPath: string) => requestedPath === path
      ? { name: path, fields: { paymentAttemptId: { stringValue: "missing-attempt" } } }
      : null,
  } as unknown as Firestore;
  const missing = await findActiveCheckout(missingDb, uid, courseId);
  if (!missing || !("stale" in missing) || missing.reason !== "attempt_missing" || !missing.attemptIdentifierPresent || missing.attemptRecordExists) throw new Error("A stale lock was not retained and classified for review.");
});

Deno.test("reservation conflict resolves the winning attempt before a bounded retry", async () => {
  let reserveCalls = 0;
  const recovered = await reserveWithSingleConflictRecovery(
    async () => {
      reserveCalls++;
      if (reserveCalls === 1) throw new Error("checkout_in_progress");
    },
    async () => ({ id: "winning-attempt" }),
  );
  if (reserveCalls !== 1 || recovered.kind !== "recovered" || recovered.value.id !== "winning-attempt") {
    throw new Error("An authoritative competing attempt was not returned before reserving again.");
  }
});

Deno.test("reservation retries only once after the competing lock is resolved", async () => {
  let reserveCalls = 0;
  let recoverCalls = 0;
  const result = await reserveWithSingleConflictRecovery(
    async () => {
      reserveCalls++;
      if (reserveCalls === 1) throw new Error("checkout_in_progress");
    },
    async () => { recoverCalls++; return null; },
  );
  if (result.kind !== "reserved" || reserveCalls !== 2 || recoverCalls !== 1) {
    throw new Error("Reservation did not use exactly one bounded retry.");
  }
});

Deno.test("reservation does not retry after a second concurrent conflict", async () => {
  let reserveCalls = 0;
  let recoverCalls = 0;
  let rejected = false;
  try {
    await reserveWithSingleConflictRecovery(
      async () => { reserveCalls++; throw new Error("checkout_in_progress"); },
      async () => { recoverCalls++; return null; },
    );
  } catch (cause) {
    rejected = cause instanceof Error && cause.message === "checkout_in_progress";
  }
  if (!rejected || reserveCalls !== 2 || recoverCalls !== 1) {
    throw new Error("Repeated conflicts must stop after one retry and one recovery read.");
  }
});

Deno.test("coupon reservation cleanup is owned and idempotent per attempt", () => {
  const pending = { status: "pending", couponCode: "SAVE", couponReservationState: "reserved" };
  if (couponReservationDisposition(pending) !== "release") throw new Error("The active attempt's reservation was not eligible for one release.");
  const released = { ...pending, status: "failed", couponReservationState: "released" };
  if (couponReservationDisposition(released) !== "unchanged") throw new Error("A repeated cleanup could decrement the reservation twice.");
  if (couponReservationDisposition({ status: "creation_failed", couponCode: "SAVE" }) !== "unchanged") throw new Error("A terminal creation failure could decrement a reservation twice.");
  if (couponReservationDisposition({ status: "pending", couponCode: "SAVE", couponReservationState: "consumed" }) !== "unchanged") throw new Error("A consumed reservation was eligible for release.");
});

Deno.test("terminal cleanup releases one coupon reservation and only its own lock", async () => {
  const db = new MemoryFirestore();
  const attemptId = "attempt-owned";
  const uid = "student-cleanup";
  const courseId = "course-cleanup";
  const lockPath = await checkoutLockPath(uid, courseId);
  db.put(attemptPath(attemptId), {
    uid, courseId, status: "pending", couponCode: "SAVE",
    couponReservationState: "reserved", createdAt: new Date(),
  });
  db.put(couponPath(courseId, "SAVE"), { usedCount: 2, reservedCount: 4 });
  db.put(lockPath, { paymentAttemptId: attemptId, uid, courseId });

  await failAttemptAndReleaseReservation(db as unknown as Firestore, attemptId, { reconciliationResult: "definitive_failure" });
  if (db.read(attemptPath(attemptId))?.couponReservationState !== "released") throw new Error("Attempt reservation was not marked released.");
  if (db.read(couponPath(courseId, "SAVE"))?.reservedCount !== 3) throw new Error("The attempt's reserved coupon count was not released exactly once.");
  if (db.read(lockPath) !== null) throw new Error("The terminal attempt's owned lock was not deleted.");

  await failAttemptAndReleaseReservation(db as unknown as Firestore, attemptId, { reconciliationResult: "duplicate_cleanup" });
  if (db.read(couponPath(courseId, "SAVE"))?.reservedCount !== 3) throw new Error("Repeated cleanup decremented another checkout's reservation.");
});

Deno.test("terminal cleanup does not delete a lock owned by a different attempt", async () => {
  const db = new MemoryFirestore();
  const attemptId = "attempt-old";
  const lockOwner = "attempt-new";
  const uid = "student-lock-owner";
  const courseId = "course-lock-owner";
  const lockPath = await checkoutLockPath(uid, courseId);
  db.put(attemptPath(attemptId), { uid, courseId, status: "pending", couponReservationState: "none" });
  db.put(lockPath, { paymentAttemptId: lockOwner, uid, courseId });

  await failAttemptAndReleaseReservation(db as unknown as Firestore, attemptId);
  if (db.read(lockPath)?.paymentAttemptId !== lockOwner) throw new Error("Cleanup deleted a lock owned by another attempt.");
});

Deno.test("Paymob transaction HMAC verifies only the official ordered field set", async () => {
  const secret = "test-only-paymob-hmac-secret";
  Deno.env.set("PAYMOB_WEBHOOK_HMAC_SECRET", secret);
  const obj = {
    amount_cents: 12500, created_at: "2026-01-01T00:00:00Z", currency: "EGP", error_occured: false,
    has_parent_transaction: false, id: 12345, integration_id: 987, is_3d_secure: true, is_auth: false,
    is_capture: false, is_refunded: false, is_standalone_payment: true, is_voided: false,
    order: { id: 65432 }, owner: 111, pending: false,
    source_data: { pan: "1234", sub_type: "Visa", type: "card" }, success: true,
  };
  const valueAt = (path: string) => path.split(".").reduce<any>((current, key) => current?.[key], obj);
  const signed = paymobHmacFields.map((path) => String(valueAt(path))).join("");
  const key = await crypto.subtle.importKey("raw", new TextEncoder().encode(secret), { name: "HMAC", hash: "SHA-512" }, false, ["sign"]);
  const bytes = new Uint8Array(await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(signed)));
  const signature = [...bytes].map((byte) => byte.toString(16).padStart(2, "0")).join("");
  if (!await verifyPaymobHmac(obj, signature)) throw new Error("Valid Paymob callback signature was rejected.");
  if (await verifyPaymobHmac(obj, `${signature.slice(0, -1)}0`)) throw new Error("Invalid callback signature was accepted.");
  if (await verifyPaymobHmac(obj, null)) throw new Error("Missing callback signature was accepted.");
});
