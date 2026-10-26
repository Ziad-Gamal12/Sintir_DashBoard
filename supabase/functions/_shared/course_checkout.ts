import { Firestore, createWrite, deleteWrite, updateWrite } from "./firebase.ts";
import { requiredSecret } from "./firebase.ts";

export const attemptsCollection = "CoursePaymentAttempts";
export const coursePath = (id: string) => `Courses/${id}`;
export const userPath = (id: string) => `Users/${id}`;
export const attemptPath = (id: string) => `${attemptsCollection}/${id}`;
export const checkoutLocks = "CourseCheckoutLocks";
export const enrollPath = (uid: string, courseId: string) => `Users/${uid}/Courses/${courseId}`;
export const subscriberPath = (courseId: string, uid: string) => `Courses/${courseId}/Subscribers/${uid}`;
export const couponPath = (courseId: string, code: string) => `Courses/${courseId}/Coupons/${code}`;
export type Quote = { originalAmountCents: number; discountAmountCents: number; amountCents: number; currency: "EGP"; couponCode: string | null; discountPercentage: number };
export function calculateQuote(priceEgp: number, discountPercentage: number, couponCode: string | null = null): Quote {
  if (!Number.isSafeInteger(priceEgp) || priceEgp < 0 || !Number.isFinite(discountPercentage) || discountPercentage < 0 || discountPercentage > 100) throw new Error("invalid_course_price");
  const originalAmountCents = priceEgp * 100;
  const amountCents = Math.max(0, originalAmountCents - Math.round(originalAmountCents * discountPercentage / 100));
  return { originalAmountCents, discountAmountCents: originalAmountCents - amountCents, amountCents, currency: "EGP", couponCode, discountPercentage };
}

export function decode(value: any): any {
  if (value == null) return null;
  if ("stringValue" in value) return value.stringValue;
  if ("integerValue" in value) return Number(value.integerValue);
  if ("doubleValue" in value) return value.doubleValue;
  if ("booleanValue" in value) return value.booleanValue;
  if ("timestampValue" in value) return new Date(value.timestampValue);
  if ("mapValue" in value) return Object.fromEntries(Object.entries(value.mapValue.fields ?? {}).map(([k, v]) => [k, decode(v)]));
  if ("arrayValue" in value) return (value.arrayValue.values ?? []).map(decode);
  return null;
}
export function decodeFields(fields: Record<string, any> = {}): Record<string, any> {
  return Object.fromEntries(Object.entries(fields).map(([key, value]) => [key, decode(value)]));
}
export function encode(value: any): any {
  if (value == null) return { nullValue: null };
  if (typeof value === "string") return { stringValue: value };
  if (typeof value === "boolean") return { booleanValue: value };
  if (typeof value === "number") return Number.isInteger(value) ? { integerValue: String(value) } : { doubleValue: value };
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  if (Array.isArray(value)) return { arrayValue: { values: value.map(encode) } };
  return { mapValue: { fields: Object.fromEntries(Object.entries(value).map(([k, v]) => [k, encode(v)])) } };
}
export function firestoreDocument(db: Firestore, path: string, data: Record<string, any>) {
  return db.document(path, Object.fromEntries(Object.entries(data).map(([key, value]) => [key, encode(value)])));
}
export async function checkoutLockPath(uid: string, courseId: string): Promise<string> {
  const bytes = new Uint8Array(await crypto.subtle.digest("SHA-256", new TextEncoder().encode(`${uid}:${courseId}`)));
  const key = [...bytes].map((byte) => byte.toString(16).padStart(2, "0")).join("");
  return `${checkoutLocks}/${key}`;
}

export type ActiveCheckout = { id: string; attempt: Record<string, any> } | {
  stale: true;
  reason: "missing_attempt_id" | "attempt_missing" | "ownership_mismatch";
  attemptIdentifierPresent: boolean;
  attemptRecordExists: boolean;
  ownershipChecksPassed: boolean;
} | null;

/** Resolve only the lock derived from the verified caller and exact course ID. */
export async function findActiveCheckout(db: Firestore, uid: string, courseId: string): Promise<ActiveCheckout> {
  const lock = await db.get(await checkoutLockPath(uid, courseId));
  if (!lock) return null;
  const lockData = decodeFields(lock.fields);
  const id = typeof lockData.paymentAttemptId === "string" ? lockData.paymentAttemptId : "";
  if (!id) return { stale: true, reason: "missing_attempt_id", attemptIdentifierPresent: false, attemptRecordExists: false, ownershipChecksPassed: false };
  const doc = await db.get(attemptPath(id));
  if (!doc) return { stale: true, reason: "attempt_missing", attemptIdentifierPresent: true, attemptRecordExists: false, ownershipChecksPassed: false };
  const attempt = decodeFields(doc.fields);
  if (attempt.uid !== uid || attempt.courseId !== courseId) return { stale: true, reason: "ownership_mismatch", attemptIdentifierPresent: true, attemptRecordExists: true, ownershipChecksPassed: false };
  return { id, attempt };
}

/** Resolve a competing reservation once, then make at most one transaction-safe retry. */
export async function reserveWithSingleConflictRecovery<T>(
  reserve: () => Promise<void>,
  recover: () => Promise<T | null>,
): Promise<{ kind: "reserved" } | { kind: "recovered"; value: T }> {
  try {
    await reserve();
    return { kind: "reserved" };
  } catch (cause) {
    if (!(cause instanceof Error) || cause.message !== "checkout_in_progress") throw cause;
    const recovered = await recover();
    if (recovered !== null) return { kind: "recovered", value: recovered };
    await reserve();
    return { kind: "reserved" };
  }
}

/** Find a prior confirmed outcome for installations whose old success path deleted its lock. */
export async function findResolvedCheckout(db: Firestore, uid: string, courseId: string): Promise<{ id: string; attempt: Record<string, any> } | null> {
  // A single-field equality query avoids requiring a new composite index.
  const docs = await db.queryEqual(attemptsCollection, { uid });
  const candidates = docs.map((doc) => ({ id: doc.name.split("/").pop() ?? "", attempt: decodeFields(doc.fields) }))
    .filter(({ id, attempt }) => id && attempt.uid === uid && attempt.courseId === courseId && ["succeeded", "paid_requires_review"].includes(String(attempt.status)));
  candidates.sort((left, right) => {
    const leftTime = Date.parse(String(left.attempt.updatedAt ?? left.attempt.createdAt ?? "")) || 0;
    const rightTime = Date.parse(String(right.attempt.updatedAt ?? right.attempt.createdAt ?? "")) || 0;
    return rightTime - leftTime;
  });
  return candidates[0] ?? null;
}

export function isTerminalAttemptStatus(status: unknown): boolean {
  return ["succeeded", "failed", "creation_failed", "paid_requires_review", "expired"].includes(String(status));
}

export function inquiryRetryAfterSeconds(lastReconciledAt: unknown, now = Date.now(), cooldownMs = 30_000): number {
  const last = lastReconciledAt instanceof Date
    ? lastReconciledAt.getTime()
    : Date.parse(String(lastReconciledAt ?? ""));
  if (!Number.isFinite(last)) return 0;
  return Math.max(0, Math.ceil((last + cooldownMs - now) / 1000));
}

export type ActiveCheckoutDisposition = "success" | "review" | "resolved_failure" | "resume" | "verify";
export function activeCheckoutDisposition(attempt: Record<string, any>): ActiveCheckoutDisposition {
  if (attempt.status === "succeeded") return "success";
  if (attempt.status === "paid_requires_review") return "review";
  if (["failed", "creation_failed", "expired"].includes(String(attempt.status))) return "resolved_failure";
  if (attempt.status === "pending" && typeof attempt.checkoutUrl === "string" && attempt.checkoutUrl.length > 0) return "resume";
  return "verify";
}

export function couponReservationDisposition(attempt: Record<string, any>): "release" | "unchanged" {
  if (isTerminalAttemptStatus(attempt.status)) return "unchanged";
  return attempt.couponCode && (attempt.couponReservationState === "reserved" || attempt.couponReservationState == null)
    ? "release"
    : "unchanged";
}

/** Delete a terminal attempt's lock only when it still owns that exact lock. */
export async function releaseTerminalCheckoutLock(db: Firestore, id: string): Promise<void> {
  const tx = await db.beginTransaction();
  const doc = await db.get(attemptPath(id), tx);
  if (!doc) return;
  const attempt = decodeFields(doc.fields);
  if (!isTerminalAttemptStatus(attempt.status)) return;
  const lockPath = await checkoutLockPath(String(attempt.uid), String(attempt.courseId));
  const lock = await db.get(lockPath, tx);
  if (lock && decodeFields(lock.fields).paymentAttemptId === id) await db.commit(tx, [deleteWrite(lock)]);
}
function cairoCalendarDate(date: Date): string {
  const parts = new Intl.DateTimeFormat("en-CA", { timeZone: "Africa/Cairo", year: "numeric", month: "2-digit", day: "2-digit" }).formatToParts(date);
  return `${parts.find((part) => part.type === "year")?.value}-${parts.find((part) => part.type === "month")?.value}-${parts.find((part) => part.type === "day")?.value}`;
}

export async function requireCaller(request: Request): Promise<string> {
  const { firebaseUid } = await import("./firebase.ts");
  try { return await firebaseUid(request); } catch { throw new Error("unauthorized"); }
}
export function parseBody(value: unknown): Record<string, any> {
  if (!value || typeof value !== "object" || Array.isArray(value)) throw new Error("invalid_body");
  return value as Record<string, any>;
}
export async function readBody(request: Request): Promise<Record<string, any>> {
  try { return parseBody(await request.json()); } catch { throw new Error("invalid_body"); }
}
export function requiredId(value: unknown, name: string): string {
  if (typeof value !== "string" || !/^[A-Za-z0-9_-]{1,160}$/.test(value)) throw new Error(`invalid_${name}`);
  return value;
}
export function requiredCourseId(value: unknown): string {
  if (typeof value !== "string" || value.length === 0 || value.trim().length === 0) {
    throw new Error("invalid_course_id");
  }
  if (value.includes("/") || value === "." || value === ".." || /^__.*__$/.test(value)
    || /[\u0000-\u001F\u007F-\u009F]/u.test(value)) {
    throw new Error("invalid_course_id");
  }
  try {
    if (new TextEncoder().encode(value).byteLength > 1500) throw new Error("invalid_course_id");
    // Reject unpaired UTF-16 surrogates without normalizing the identifier.
    encodeURIComponent(value);
  } catch {
    throw new Error("invalid_course_id");
  }
  return value;
}
export async function loadQuote(db: Firestore, uid: string, courseId: string, couponCode?: string): Promise<{ quote: Quote; course: any; user: any; coupon: any | null }> {
  const [courseDoc, userDoc, enrollment] = await Promise.all([db.get(coursePath(courseId)), db.get(userPath(uid)), db.get(enrollPath(uid, courseId))]);
  if (!courseDoc || !userDoc) throw new Error("not_found");
  const course = decodeFields(courseDoc.fields);
  const user = decodeFields(userDoc.fields);
  if (course.state !== "Published") throw new Error("course_unavailable");
  if (course.contentcreaterentity?.id === uid) throw new Error("own_course");
  if (enrollment) throw new Error("already_enrolled");
  const price = Number(course.price);
  if (!Number.isSafeInteger(price) || price < 0) throw new Error("invalid_course_price");
  let coupon: any = null;
  let discountPercentage = 0;
  if (couponCode?.trim()) {
    const code = couponCode.trim();
    const couponDoc = await db.get(couponPath(courseId, code));
    if (!couponDoc) throw new Error("coupon_not_found");
    coupon = decodeFields(couponDoc.fields);
    const status = String(coupon.status ?? "").toLowerCase();
    const expiry = coupon.expiryDate ? new Date(coupon.expiryDate) : null;
    const limit = Number(coupon.usageLimit ?? 0);
    const used = Number(coupon.usedCount ?? 0);
    const reserved = Number(coupon.reservedCount ?? 0);
    const discount = Number(coupon.discountPercentage);
    if (status !== "active") throw new Error("coupon_inactive");
    if (!expiry || !Number.isFinite(expiry.getTime()) || cairoCalendarDate(new Date()) > cairoCalendarDate(expiry)) throw new Error("coupon_expired");
    if (!Number.isFinite(discount) || discount < 0 || discount > 100) throw new Error("coupon_invalid_discount");
    if (!Number.isSafeInteger(limit) || limit < 0 || !Number.isSafeInteger(used) || used < 0 || !Number.isSafeInteger(reserved) || reserved < 0 || (limit > 0 && used + reserved >= limit)) throw new Error("coupon_exhausted");
    discountPercentage = discount;
  }
  return { course, user, coupon, quote: calculateQuote(price, discountPercentage, couponCode?.trim() || null) };
}
export function safeError(error: unknown): { code: string; status: number; message: string } {
  const code = error instanceof Error ? error.message : "internal_error";
  const known: Record<string, [number, string]> = {
    invalid_body: [400, "Request body is invalid."], invalid_course_id: [400, "Course ID is invalid."], invalid_paymentAttemptId: [400, "Payment attempt ID is invalid."], invalid_idempotencyKey: [400, "Idempotency key is invalid."],
    not_found: [404, "Course or user was not found."], course_unavailable: [409, "This course is not available for enrollment."], own_course: [403, "You cannot enroll in your own course."], already_enrolled: [409, "You are already enrolled in this course."],
    coupon_not_found: [400, "Coupon was not found."], coupon_inactive: [400, "Coupon is inactive."], coupon_expired: [400, "Coupon has expired."], coupon_invalid_discount: [400, "Coupon is invalid."], coupon_exhausted: [409, "Coupon usage limit has been reached."], invalid_course_price: [409, "Course price is invalid."],
    coupon_changed: [409, "Coupon details changed. Refresh the quote and try again."], idempotency_conflict: [409, "This checkout key is already in use."],
    checkout_in_progress: [409, "A checkout is already active for this course."], stale_checkout_lock: [409, "An earlier checkout needs support review before another payment can start."], billing_phone_missing: [409, "Add a valid phone number to your account before checkout."], quote_changed: [409, "Course or coupon details changed. Refresh and try again."],
  };
  const [status, message] = known[code] ?? [500, "Checkout could not be completed."];
  return { code: known[code] ? code : "internal_error", status, message };
}
export function checkoutUrl(clientSecret: string): string {
  const publicKey = requiredSecret("PAYMOB_PUBLIC_KEY");
  return `https://accept.paymob.com/unifiedcheckout/?publicKey=${encodeURIComponent(publicKey)}&clientSecret=${encodeURIComponent(clientSecret)}`;
}
export function integrationIds(): number[] {
  const names = ["PAYMOB_WALLET_INTEGRATION_ID", "PAYMOB_ONLINE_CARD_INTEGRATION_ID", "PAYMOB_ACCEPT_KIOSK_INTEGRATION_ID", "PAYMOB_CASH_COLLECTION_INTEGRATION_ID"];
  const ids = names.map((name) => Number(requiredSecret(name))).filter((n) => Number.isSafeInteger(n) && n > 0);
  if (!ids.length) throw new Error("missing_integrations");
  return ids;
}

export async function updateAttempt(db: Firestore, id: string, changes: Record<string, any>) {
  const transaction = await db.beginTransaction();
  const current = await db.get(attemptPath(id), transaction);
  if (!current) throw new Error("not_found");
  const fields = Object.fromEntries(Object.entries(changes).map(([key, value]) => [key, encode(value)]));
  await db.commit(transaction, [updateWrite(db.document(attemptPath(id), fields), Object.keys(fields), current.updateTime)]);
}

/** Apply a reconciliation/callback update only while the attempt remains active. */
export async function updateActiveAttempt(db: Firestore, id: string, changes: Record<string, any>): Promise<string | null> {
  const tx = await db.beginTransaction();
  const current = await db.get(attemptPath(id), tx);
  if (!current) return null;
  const attempt = decodeFields(current.fields);
  if (isTerminalAttemptStatus(attempt.status)) return String(attempt.status);
  const fields = Object.fromEntries(Object.entries(changes).map(([key, value]) => [key, encode(value)]));
  await db.commit(tx, [updateWrite(db.document(attemptPath(id), fields), Object.keys(fields), current.updateTime)]);
  return String(changes.status ?? attempt.status);
}

export async function reserveAttempt(db: Firestore, id: string, attempt: Record<string, any>, courseId: string): Promise<void> {
  const tx = await db.beginTransaction();
  const lockPath = await checkoutLockPath(String(attempt.uid), courseId);
  const [existing, courseDoc, enrollment, couponDoc, lockDoc] = await Promise.all([
    db.get(attemptPath(id), tx), db.get(coursePath(courseId), tx), db.get(enrollPath(attempt.uid, courseId), tx),
    attempt.couponCode ? db.get(couponPath(courseId, attempt.couponCode), tx) : Promise.resolve(null),
    db.get(lockPath, tx),
  ]);
  if (existing) throw new Error("idempotency_conflict");
  if (!courseDoc || decodeFields(courseDoc.fields).state !== "Published") throw new Error("course_unavailable");
  const currentCourse = decodeFields(courseDoc.fields);
  if (Number(currentCourse.price) * 100 !== Number(attempt.quote.originalAmountCents) || currentCourse.contentcreaterentity?.id !== attempt.teacherId) throw new Error("quote_changed");
  if (enrollment) throw new Error("already_enrolled");
  if (lockDoc) throw new Error("checkout_in_progress");
  const attemptWithReservation = { ...attempt, couponReservationState: attempt.couponCode ? "reserved" : "none" };
  const writes: unknown[] = [createWrite(firestoreDocument(db, attemptPath(id), attemptWithReservation))];
  writes.push(createWrite(firestoreDocument(db, lockPath, { paymentAttemptId: id, uid: attempt.uid, courseId, createdAt: new Date() })));
  if (attempt.couponCode) {
    if (!couponDoc) throw new Error("coupon_not_found");
    const coupon = decodeFields(couponDoc.fields);
    const limit = Number(coupon.usageLimit ?? 0);
    const used = Number(coupon.usedCount ?? 0);
    const reserved = Number(coupon.reservedCount ?? 0);
    if (String(coupon.status ?? "").toLowerCase() !== "active") throw new Error("coupon_inactive");
    if (Number(coupon.discountPercentage) !== Number(attempt.quote.discountPercentage)) throw new Error("coupon_changed");
    if (!Number.isSafeInteger(limit) || !Number.isSafeInteger(used) || !Number.isSafeInteger(reserved) || used < 0 || reserved < 0 || (limit > 0 && used + reserved >= limit)) throw new Error("coupon_exhausted");
    const expiry = coupon.expiryDate ? new Date(coupon.expiryDate) : null;
    if (!expiry || !Number.isFinite(expiry.getTime())) throw new Error("coupon_expired");
    if (cairoCalendarDate(new Date()) > cairoCalendarDate(expiry)) throw new Error("coupon_expired");
    writes.push(updateWrite(firestoreDocument(db, couponPath(courseId, String(attempt.couponCode)), { reservedCount: reserved + 1 }), ["reservedCount"], couponDoc.updateTime));
  }
  await db.commit(tx, writes);
}

export async function failAttemptAndReleaseReservation(db: Firestore, id: string, changes: Record<string, any> = {}, status = "failed"): Promise<void> {
  const tx = await db.beginTransaction();
  const current = await db.get(attemptPath(id), tx);
  if (!current) return;
  const attempt = decodeFields(current.fields);
  if (isTerminalAttemptStatus(attempt.status)) return;
  const writes: unknown[] = [];
  const ownsReservation = couponReservationDisposition(attempt) === "release";
  const updateFields = { ...changes, status, ...(attempt.couponCode ? { couponReservationState: ownsReservation ? "released" : attempt.couponReservationState } : {}), updatedAt: new Date() };
  writes.push(updateWrite(firestoreDocument(db, attemptPath(id), updateFields), Object.keys(updateFields), current.updateTime));
  if (ownsReservation) {
    const couponDoc = await db.get(couponPath(String(attempt.courseId), String(attempt.couponCode)), tx);
    if (couponDoc) {
      const coupon = decodeFields(couponDoc.fields);
      writes.push(updateWrite(firestoreDocument(db, couponPath(String(attempt.courseId), String(attempt.couponCode)), { reservedCount: Math.max(0, Number(coupon.reservedCount ?? 0) - 1) }), ["reservedCount"], couponDoc.updateTime));
    }
  }
  const lockPath = await checkoutLockPath(String(attempt.uid), String(attempt.courseId));
  const lockDoc = await db.get(lockPath, tx);
  if (lockDoc && decodeFields(lockDoc.fields).paymentAttemptId === id) writes.push(deleteWrite(lockDoc));
  await db.commit(tx, writes);
}

export async function fulfillFreeEnrollment(db: Firestore, attemptId: string): Promise<void> {
  const tx = await db.beginTransaction();
  const attemptDoc = await db.get(attemptPath(attemptId), tx);
  if (!attemptDoc) throw new Error("attempt_not_found");
  const attempt = decodeFields(attemptDoc.fields);
  if (attempt.status === "succeeded") return;
  if (Number(attempt.amountCents) !== 0) throw new Error("payment_required");
  const uid = String(attempt.uid);
  const courseId = String(attempt.courseId);
  const lockPath = await checkoutLockPath(uid, courseId);
  const [courseDoc, studentDoc, enrollmentDoc, subscriberDoc, couponDoc, lockDoc] = await Promise.all([
    db.get(coursePath(courseId), tx), db.get(userPath(uid), tx), db.get(enrollPath(uid, courseId), tx), db.get(subscriberPath(courseId, uid), tx),
    attempt.couponCode ? db.get(couponPath(courseId, String(attempt.couponCode)), tx) : Promise.resolve(null), db.get(lockPath, tx),
  ]);
  if (!courseDoc || !studentDoc) throw new Error("fulfillment_records_missing");
  const course = decodeFields(courseDoc.fields);
  const student = decodeFields(studentDoc.fields);
  if (course.state !== "Published" || course.contentcreaterentity?.id === uid) throw new Error("course_unavailable");
  if (enrollmentDoc || subscriberDoc) throw new Error("already_enrolled");
  const writes: unknown[] = [
    createWrite(firestoreDocument(db, enrollPath(uid, courseId), course)),
    createWrite(firestoreDocument(db, subscriberPath(courseId, uid), { id: uid, name: student.firstName ?? "", joinedDate: new Date(), gender: student.gender ?? "", phone: student.phoneNumber ?? "", educationLevel: student.studentExtraData?.educationLevel ?? "", imageUrl: student.profilePicurl ?? "", address: student.address ?? "" })),
    updateWrite(firestoreDocument(db, coursePath(courseId), { studentsCount: Number(course.studentsCount ?? 0) + 1 }), ["studentsCount"], courseDoc.updateTime),
  ];
  if (attempt.couponCode && (attempt.couponReservationState === "reserved" || attempt.couponReservationState == null)) {
    if (!couponDoc) throw new Error("coupon_disappeared");
    const coupon = decodeFields(couponDoc.fields);
    const reserved = Number(coupon.reservedCount ?? 0);
    if (reserved < 1) throw new Error("coupon_reservation_missing");
    writes.push(updateWrite(firestoreDocument(db, couponPath(courseId, String(attempt.couponCode)), { usedCount: Number(coupon.usedCount ?? 0) + 1, reservedCount: reserved - 1 }), ["usedCount", "reservedCount"], couponDoc.updateTime));
  }
  writes.push(updateWrite(firestoreDocument(db, attemptPath(attemptId), { status: "succeeded", fulfillmentStatus: "free_enrolled", ...(attempt.couponCode ? { couponReservationState: "consumed" } : {}), updatedAt: new Date() }), ["status", "fulfillmentStatus", ...(attempt.couponCode ? ["couponReservationState"] : []), "updatedAt"], attemptDoc.updateTime));
  if (lockDoc && decodeFields(lockDoc.fields).paymentAttemptId === attemptId) {
    writes.push(updateWrite(firestoreDocument(db, lockPath, { paymentAttemptId: attemptId, uid, courseId, state: "succeeded", updatedAt: new Date() }), ["state", "updatedAt"], lockDoc.updateTime));
  }
  await db.commit(tx, writes);
}

export const paymobHmacFields = ["amount_cents", "created_at", "currency", "error_occured", "has_parent_transaction", "id", "integration_id", "is_3d_secure", "is_auth", "is_capture", "is_refunded", "is_standalone_payment", "is_voided", "order.id", "owner", "pending", "source_data.pan", "source_data.sub_type", "source_data.type", "success"];
function pathValue(value: any, path: string): any { return path.split(".").reduce((current, key) => current == null ? undefined : current[key], value); }
export async function verifyPaymobHmac(obj: any, signature: string | null): Promise<boolean> {
  const secret = requiredSecret("PAYMOB_WEBHOOK_HMAC_SECRET");
  if (!signature || !/^[0-9a-f]{128}$/i.test(signature)) return false;
  const values = paymobHmacFields.map((field) => {
    const value = pathValue(obj, field);
    return value == null ? "" : typeof value === "boolean" ? String(value) : String(value);
  }).join("");
  const key = await crypto.subtle.importKey("raw", new TextEncoder().encode(secret), { name: "HMAC", hash: "SHA-512" }, false, ["sign"]);
  const digest = new Uint8Array(await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(values)));
  const expected = [...digest].map((byte) => byte.toString(16).padStart(2, "0")).join("");
  const left = new TextEncoder().encode(expected.toLowerCase());
  const right = new TextEncoder().encode(signature.toLowerCase());
  let mismatch = left.length ^ right.length;
  for (let i = 0; i < Math.max(left.length, right.length); i++) mismatch |= (left[i] ?? 0) ^ (right[i] ?? 0);
  return mismatch === 0;
}

export async function fulfillPayment(db: Firestore, attemptId: string, obj: any): Promise<string> {
  const tx = await db.beginTransaction();
  const attemptDoc = await db.get(attemptPath(attemptId), tx);
  if (!attemptDoc) throw new Error("attempt_not_found");
  const attempt = decodeFields(attemptDoc.fields);
  if (attempt.status === "succeeded") {
    if (obj?.id != null && String(obj.id) !== String(attempt.paymobTransactionId ?? "")) {
      await updateAttempt(db, attemptId, { paymentLifecycleState: "additional_transaction_requires_review", additionalPaymobTransactionId: String(obj.id), updatedAt: new Date() });
      console.error("Additional Paymob transaction for fulfilled checkout requires review", { attemptId, transactionId: String(obj.id) });
    }
    return "succeeded";
  }
  const uid = String(attempt.uid);
  const courseId = String(attempt.courseId);
  const lockPath = await checkoutLockPath(uid, courseId);
  const [courseDoc, studentDoc, teacherDoc, enrollmentDoc, subscriberDoc, couponDoc, lockDoc] = await Promise.all([
    db.get(coursePath(courseId), tx), db.get(userPath(uid), tx), db.get(userPath(String(attempt.teacherId)), tx), db.get(enrollPath(uid, courseId), tx), db.get(subscriberPath(courseId, uid), tx), attempt.couponCode ? db.get(couponPath(courseId, String(attempt.couponCode)), tx) : Promise.resolve(null),
    db.get(lockPath, tx),
  ]);
  if (!courseDoc || !studentDoc || !teacherDoc) throw new Error("fulfillment_records_missing");
  if (enrollmentDoc || subscriberDoc) {
    if (enrollmentDoc && subscriberDoc) {
      const writes: unknown[] = [];
      const ownsReservation = attempt.couponCode && couponDoc && (attempt.couponReservationState === "reserved" || attempt.couponReservationState == null);
      const update = firestoreDocument(db, attemptPath(attemptId), { status: "paid_requires_review", fulfillmentStatus: "already_enrolled_paid_review", paymobTransactionId: String(obj.id), ...(attempt.couponCode ? { couponReservationState: ownsReservation ? "consumed" : attempt.couponReservationState } : {}), updatedAt: new Date() });
      writes.push(updateWrite(update, ["status", "fulfillmentStatus", "paymobTransactionId", ...(attempt.couponCode ? ["couponReservationState"] : []), "updatedAt"], attemptDoc.updateTime));
      if (ownsReservation) {
        const coupon = decodeFields(couponDoc.fields);
        writes.push(updateWrite(firestoreDocument(db, couponPath(courseId, String(attempt.couponCode)), { usedCount: Number(coupon.usedCount ?? 0) + 1, reservedCount: Math.max(0, Number(coupon.reservedCount ?? 0) - 1) }), ["usedCount", "reservedCount"], couponDoc.updateTime));
      }
      // Keep this attempt's lock while a paid transaction requires manual review.
      await db.commit(tx, writes);
      console.error("Confirmed payment conflicts with existing enrollment; manual refund review required", { attemptId, transactionId: String(obj.id) });
      return "paid_requires_review";
    }
    throw new Error("partial_existing_fulfillment");
  }
  const student = decodeFields(studentDoc.fields);
  const course = decodeFields(courseDoc.fields);
  const teacher = decodeFields(teacherDoc.fields);
  const amountCents = Number(attempt.amountCents);
  const grossEgp = amountCents / 100;
  const netCents = Math.round(amountCents * 0.95);
  const wallet = teacher.teacherExtraData?.wallet ?? {};
  const txId = String(obj.id);
  const transactionRecord = { transaction_id: txId, created_at: new Date(), amount: grossEgp, currency: "EGP", issuer: "Paymob", mobile: student.phoneNumber ?? null, status: "SUCCESS", isReconciled: true, method: "PayMent" };
  const subscriber = { id: uid, name: student.firstName ?? "", joinedDate: new Date(), gender: student.gender ?? "", phone: student.phoneNumber ?? "", educationLevel: student.studentExtraData?.educationLevel ?? "", imageUrl: student.profilePicurl ?? "", address: student.address ?? "" };
  const attemptUpdate = firestoreDocument(db, attemptPath(attemptId), { status: "succeeded", fulfillmentStatus: "fulfilled", paymobTransactionId: txId, ...(attempt.couponCode ? { couponReservationState: "consumed" } : {}), updatedAt: new Date() });
  const writes: unknown[] = [
    createWrite(firestoreDocument(db, enrollPath(uid, courseId), course)),
    createWrite(firestoreDocument(db, subscriberPath(courseId, uid), subscriber)),
    updateWrite(firestoreDocument(db, coursePath(courseId), { studentsCount: Number(course.studentsCount ?? 0) + 1 }), ["studentsCount"], courseDoc.updateTime),
    updateWrite(firestoreDocument(db, userPath(String(attempt.teacherId)), { teacherExtraData: { wallet: { balance: (Number(wallet.balance ?? 0) * 100 + netCents) / 100, total_earned: (Number(wallet.total_earned ?? 0) * 100 + netCents) / 100, last_transaction_id: txId, updated_at: new Date().toISOString() } } }), ["teacherExtraData.wallet.balance", "teacherExtraData.wallet.total_earned", "teacherExtraData.wallet.last_transaction_id", "teacherExtraData.wallet.updated_at"], teacherDoc.updateTime),
    createWrite(firestoreDocument(db, `Courses/${courseId}/Transactions/${txId}`, transactionRecord)),
    createWrite(firestoreDocument(db, `Users/${uid}/Transactions/${txId}`, transactionRecord)),
    createWrite(firestoreDocument(db, `Transactions/${txId}`, transactionRecord)),
    updateWrite(attemptUpdate, ["status", "fulfillmentStatus", "paymobTransactionId", ...(attempt.couponCode ? ["couponReservationState"] : []), "updatedAt"], attemptDoc.updateTime),
  ];
  if (attempt.couponCode && (attempt.couponReservationState === "reserved" || attempt.couponReservationState == null)) {
    if (!couponDoc) throw new Error("coupon_disappeared");
    const coupon = decodeFields(couponDoc.fields);
    const limit = Number(coupon.usageLimit ?? 0);
    const used = Number(coupon.usedCount ?? 0);
    const reserved = Number(coupon.reservedCount ?? 0);
    if (!Number.isSafeInteger(reserved) || reserved < 1) throw new Error("coupon_reservation_missing");
    const couponUpdate = firestoreDocument(db, couponPath(courseId, String(attempt.couponCode)), { usedCount: used + 1, reservedCount: reserved - 1 });
    writes.push(updateWrite(couponUpdate, ["usedCount", "reservedCount"], couponDoc.updateTime));
  }
  if (lockDoc && decodeFields(lockDoc.fields).paymentAttemptId === attemptId) {
    writes.push(updateWrite(firestoreDocument(db, lockPath, { paymentAttemptId: attemptId, uid, courseId, state: "succeeded", updatedAt: new Date() }), ["state", "updatedAt"], lockDoc.updateTime));
  }
  await db.commit(tx, writes);
  return "succeeded";
}

export function classifyPaymobInquiry(obj: Record<string, any> | null): "missing" | "pending" | "succeeded" | "failed" | "action" | "retryable_failure" | "review" | "invalid" {
  if (!obj) return "missing";
  if (obj.pending === true) return "pending";
  if (obj.is_refunded === true || obj.is_refund === true || Number(obj.refunded_amount_cents ?? 0) > 0 || obj.is_voided === true || obj.is_void === true) return "action";
  if (obj.success === true && obj.error_occured !== true && (obj.is_auth !== true || obj.is_capture === true || obj.is_captured === true)) return "succeeded";
  if (obj.success === false && obj.pending === false) {
    const orderState = String(obj.order?.payment_status ?? "").toUpperCase();
    if (orderState === "PAID") return "review";
    if (obj.order?.is_cancel === true || obj.order?.is_canceled === true || ["CANCELLED", "CANCELED"].includes(orderState)) return "failed";
    return "retryable_failure";
  }
  return "invalid";
}

export function inquiryCorrelatesToAttempt(result: Record<string, any>, attempt: Record<string, any>, id: string): boolean {
  const expectedReference = String(attempt.paymobSpecialReference ?? id);
  const reference = result.merchant_order_id ?? result.order?.merchant_order_id;
  const orderId = result.order?.id;
  if (!Number.isSafeInteger(Number(orderId)) || Number(orderId) <= 0) return false;
  if (reference != null && String(reference) !== expectedReference) return false;
  const referenceMatches = reference != null && String(reference) === expectedReference;
  const storedOrderMatches = Boolean(attempt.paymobOrderId) && String(orderId) === String(attempt.paymobOrderId);
  if (attempt.paymobOrderId && !storedOrderMatches) return false;
  return referenceMatches || storedOrderMatches;
}

export async function reconcileAttempt(db: Firestore, id: string, result: Record<string, any> | null): Promise<string> {
  const doc = await db.get(attemptPath(id));
  if (!doc) return "missing_attempt";
  const attempt = decodeFields(doc.fields);
  if (["succeeded", "creation_failed", "failed"].includes(String(attempt.status))) return String(attempt.status);
  const now = new Date();
  if (!result) {
    await updateAttempt(db, id, { lastReconciledAt: now, reconciliationResult: "no_transaction_yet", reconciliationAttempts: Number(attempt.reconciliationAttempts ?? 0) + 1 });
    return "no_transaction_yet";
  }
  const state = classifyPaymobInquiry(result);
  const orderId = result.order?.id;
  if (!inquiryCorrelatesToAttempt(result, attempt, id)) throw new Error("reconciliation_reference_mismatch");
  if (!Number.isSafeInteger(Number(result.id)) || Number(result.id) <= 0 || !Number.isSafeInteger(Number(result.integration_id)) || !Number.isSafeInteger(Number(result.amount_cents)) || Number(result.amount_cents) !== Number(attempt.amountCents) || result.currency !== "EGP") throw new Error("reconciliation_payment_mismatch");
  const integrations = ["PAYMOB_WALLET_INTEGRATION_ID", "PAYMOB_ONLINE_CARD_INTEGRATION_ID", "PAYMOB_ACCEPT_KIOSK_INTEGRATION_ID", "PAYMOB_CASH_COLLECTION_INTEGRATION_ID"].map((name) => Number(Deno.env.get(name))).filter((value) => Number.isSafeInteger(value) && value > 0);
  if (!integrations.includes(Number(result.integration_id))) throw new Error("reconciliation_integration_mismatch");
  if (state === "succeeded") {
    return await fulfillPayment(db, id, result);
  }
  if (state === "failed") {
    await failAttemptAndReleaseReservation(db, id, { paymobTransactionId: String(result.id), lastReconciledAt: now, reconciliationResult: "definitive_failure" });
    return "failed";
  }
  if (state === "review") {
    return await updateActiveAttempt(db, id, { status: "paid_requires_review", paymentLifecycleState: "order_paid_but_latest_transaction_failed", latestPaymobTransactionId: String(result.id), lastReconciledAt: now, reconciliationResult: "paid_order_transaction_conflict" }) ?? "missing_attempt";
  }
  return await updateActiveAttempt(db, id, {
    status: "pending", lastReconciledAt: now,
    reconciliationResult: state === "action" ? "payment_action_requires_review" : state === "retryable_failure" ? "latest_transaction_failed_order_open" : state,
    reconciliationAttempts: Number(attempt.reconciliationAttempts ?? 0) + 1,
    ...(orderId != null && !attempt.paymobOrderId ? { paymobOrderId: String(orderId) } : {}),
    ...(["action", "retryable_failure"].includes(state) ? { paymentLifecycleState: state === "action" ? "action_requires_review" : "order_still_open_review", latestPaymobTransactionId: String(result.id) } : {}),
  }) ?? "missing_attempt";
}
