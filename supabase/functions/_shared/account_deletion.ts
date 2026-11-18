// Account deletion (Google Play / App Store requirement): removes the user's
// personal data, their uploads and their Firebase Auth account.
//
// What is deleted, what is kept, and why:
// - Profile, enrollments, results, mistakes, favorites, progress, video notes,
//   reviews (with their effect on course ratings), support tickets, uploaded
//   images: deleted.
// - A teacher's course that nobody bought: deleted with its lessons, files and
//   Mux videos.
// - A teacher's course that students paid for: kept so they keep what they
//   paid for, hidden from the store, with the teacher's name and photo
//   replaced.
// - Payment and payout records: kept for accounting without phone numbers.
// - Course reports the user filed: kept for moderation without the reporter.
//
// Every step can run again: a failed run leaves the account in "Deleting" and
// the app retries the same call.

import { decodeFields, encode, requiredId } from "./course_checkout.ts";
import {
  type FeedbackStore,
  removeFeedbackAsSystem,
  runInTransaction,
} from "./course_feedback.ts";
import { STAFF_ROLES } from "./course_access.ts";
import type { SafeError } from "./authed_handler.ts";
import type { FirebaseIdentity, Firestore } from "./firebase.ts";
import { deleteWrite, updateWrite, upsertWrite } from "./firebase.ts";
import { corsHeaders, error, json } from "./http.ts";
import { readCappedJson } from "./authed_handler.ts";

export type DeletionStore =
  & FeedbackStore
  & Pick<
    Firestore,
    "listPage" | "listCollectionIds" | "queryWhereEqual" | "commitWrites"
  >;

type StoredDocument = NonNullable<Awaited<ReturnType<FeedbackStore["get"]>>>;

export type DeletionServices = {
  deleteAuthUser: (uid: string) => Promise<void>;
  removeStorageFolder: (bucket: string, folder: string) => Promise<number>;
  /** Deletes the object behind a public URL of this project; ignores others. */
  removeStorageUrl: (url: unknown) => Promise<number>;
  deleteVideoAsset: (assetId: string) => Promise<void>;
  now?: () => Date;
  logError?: (event: string, details: Record<string, unknown>) => void;
};

export type DeleteAccountResult = {
  deleted: true;
  coursesKept: number;
  coursesDeleted: number;
  filesDeleted: number;
};

export const RECENT_LOGIN_SECONDS = 5 * 60;
export const DELETED_TEACHER_NAME = "مدرس سابق";
export const DELETED_ACCOUNT_ID = "deleted-account";
export const DELETING_STATUS = "Deleting";
const ACTIVE_PAYMENT_STATES = new Set(["creating", "creation_unknown", "pending"]);
const PAYMENT_HOLD_MS = 2 * 60 * 60 * 1000;
const UNPUBLISHED_ON_DELETE = new Set(["Published", "Pending", "Declined", "Rejected"]);
const BATCH_LIMIT = 400;

const userPath = (uid: string) => `Users/${uid}`;

/** Path relative to the database root, from a full document resource name. */
export function relativePath(name: string): string {
  const marker = "/documents/";
  const index = name.indexOf(marker);
  return index === -1 ? name : name.slice(index + marker.length);
}

const lastSegment = (path: string) => path.slice(path.lastIndexOf("/") + 1);

/** Course ID of a path under Courses/{courseId}/..., or null. */
export function courseIdOf(path: string): string | null {
  const parts = path.split("/");
  return parts[0] === "Courses" && parts.length >= 2 ? parts[1] : null;
}

function asDate(value: unknown): Date | null {
  if (value instanceof Date) return value;
  if (typeof value === "string") {
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
  }
  return null;
}

/** Collects writes and commits them in batches of at most BATCH_LIMIT. */
export class Batch {
  private writes: unknown[] = [];
  private paths = new Set<string>();
  committed = 0;

  constructor(private readonly store: DeletionStore) {}

  async add(path: string, write: unknown): Promise<void> {
    if (this.paths.has(path) || this.writes.length >= BATCH_LIMIT) {
      await this.flush();
    }
    this.paths.add(path);
    this.writes.push(write);
  }

  delete(path: string): Promise<void> {
    return this.add(path, deleteWrite(this.store.document(path, {})));
  }

  update(path: string, data: Record<string, unknown>, mask: string[]) {
    const fields = Object.fromEntries(
      Object.entries(data).map(([key, value]) => [key, encode(value)]),
    );
    return this.add(
      path,
      updateWrite(this.store.document(path, fields), mask),
    );
  }

  async flush(): Promise<void> {
    if (this.writes.length === 0) return;
    const writes = this.writes;
    this.writes = [];
    this.paths = new Set();
    await this.store.commitWrites(writes);
    this.committed += writes.length;
  }
}

type Visitor = (path: string, fields: Record<string, unknown>) => void;

async function listAll(
  store: DeletionStore,
  collectionPath: string,
): Promise<StoredDocument[]> {
  const documents: StoredDocument[] = [];
  let pageToken: string | undefined;
  do {
    const page = await store.listPage(collectionPath, pageToken);
    documents.push(...(page.documents as StoredDocument[]));
    pageToken = page.nextPageToken;
  } while (pageToken);
  return documents;
}

async function deleteCollection(
  store: DeletionStore,
  batch: Batch,
  collectionPath: string,
  visit?: Visitor,
): Promise<void> {
  for (const doc of await listAll(store, collectionPath)) {
    const path = relativePath(doc.name);
    if (doc.fields) visit?.(path, decodeFields(doc.fields));
    await deleteTree(store, batch, path, visit);
  }
}

/** Deletes a document and everything under it. */
export async function deleteTree(
  store: DeletionStore,
  batch: Batch,
  documentPath: string,
  visit?: Visitor,
): Promise<void> {
  for (const collectionId of await store.listCollectionIds(documentPath)) {
    await deleteCollection(store, batch, `${documentPath}/${collectionId}`, visit);
  }
  await batch.delete(documentPath);
}

function collectionGroup(
  store: DeletionStore,
  collectionId: string,
  fieldPath: string,
  uid: string,
) {
  return store.queryWhereEqual({
    parent: null,
    collectionId,
    fieldPath,
    value: uid,
    allDescendants: true,
  });
}

function topLevel(
  store: DeletionStore,
  collectionId: string,
  fieldPath: string,
  value: string,
) {
  return store.queryWhereEqual({ parent: null, collectionId, fieldPath, value });
}

// ---------------------------------------------------------------------------
// Checks
// ---------------------------------------------------------------------------

export function assertRecentLogin(
  authTime: number | null,
  now: Date,
): void {
  if (authTime === null) throw new Error("requires_recent_login");
  const age = now.getTime() / 1000 - authTime;
  if (age > RECENT_LOGIN_SECONDS || age < -60) {
    throw new Error("requires_recent_login");
  }
}

/** Throws when this account must not be deleted yet. */
export function assertDeletable(
  user: Record<string, unknown>,
  acknowledgeBalance: boolean,
): void {
  const role = String(user.role ?? "");
  if (STAFF_ROLES.has(role)) throw new Error("staff_account");
  if (role !== "Teacher") return;
  const extra = user.teacherExtraData as Record<string, unknown> | undefined;
  const wallet = (extra?.wallet ?? {}) as Record<string, unknown>;
  const pending = Number(wallet.payout_pending ?? wallet.payoutPending ?? 0);
  if (Number.isFinite(pending) && pending > 0) throw new Error("payout_pending");
  const balance = Number(wallet.balance ?? 0);
  if (Number.isFinite(balance) && balance > 0 && !acknowledgeBalance) {
    throw new Error("balance_remaining");
  }
}

export function hasPaymentInProgress(
  attempts: Array<Record<string, unknown>>,
  now: Date,
): boolean {
  return attempts.some((attempt) => {
    if (!ACTIVE_PAYMENT_STATES.has(String(attempt.status ?? ""))) return false;
    const created = asDate(attempt.createdAt) ?? asDate(attempt.updatedAt);
    return created === null || now.getTime() - created.getTime() < PAYMENT_HOLD_MS;
  });
}

// ---------------------------------------------------------------------------
// Steps
// ---------------------------------------------------------------------------

async function removeReviews(store: DeletionStore, uid: string) {
  for (const doc of await collectionGroup(store, "Feedbacks", "uid", uid)) {
    const courseId = courseIdOf(relativePath(doc.name));
    if (courseId) await removeFeedbackAsSystem(store, courseId, uid);
  }
}

/** Ends each enrollment: the course loses one student. */
async function removeEnrollments(store: DeletionStore, uid: string) {
  for (const doc of await listAll(store, `${userPath(uid)}/Courses`)) {
    const fields = decodeFields(doc.fields ?? {});
    const ownerId = fields.contentcreaterentity?.id;
    if (ownerId === uid) continue;
    const courseId = lastSegment(relativePath(doc.name));
    await runInTransaction(store, async (transaction) => {
      const [course, subscriber] = await Promise.all([
        store.get(`Courses/${courseId}`, transaction),
        store.get(`Courses/${courseId}/Subscribers/${uid}`, transaction),
      ]);
      const writes: unknown[] = [];
      if (subscriber) {
        writes.push(
          deleteWrite(
            store.document(`Courses/${courseId}/Subscribers/${uid}`, {}),
            subscriber.updateTime,
          ),
        );
        const count = Number(decodeFields(course?.fields ?? {}).studentsCount ?? 0);
        if (course && Number.isFinite(count) && count > 0) {
          writes.push(
            updateWrite(
              store.document(`Courses/${courseId}`, {
                studentsCount: encode(count - 1),
              }),
              ["studentsCount"],
              course.updateTime,
            ),
          );
        }
      }
      return { writes, result: null };
    });
  }
}

async function removeActivity(store: DeletionStore, batch: Batch, uid: string) {
  const groups: Array<[string, string]> = [
    ["JoinedBy", "uid"],
    ["VideoNotes", "user.uid"],
    ["Results", "joinedby.uid"],
  ];
  for (const [collectionId, fieldPath] of groups) {
    for (const doc of await collectionGroup(store, collectionId, fieldPath, uid)) {
      await batch.delete(relativePath(doc.name));
    }
  }
}

async function anonymizeReports(
  store: DeletionStore,
  batch: Batch,
  uid: string,
  now: Date,
) {
  for (const doc of await collectionGroup(store, "Reports", "reporterId", uid)) {
    await batch.update(
      relativePath(doc.name),
      { reporterId: DELETED_ACCOUNT_ID },
      ["reporterId"],
    );
  }
  for (const doc of await topLevel(store, "ReviewReports", "reportedBy", uid)) {
    await batch.update(
      relativePath(doc.name),
      { reportedBy: DELETED_ACCOUNT_ID },
      ["reportedBy"],
    );
  }
  for (const doc of await topLevel(store, "ReviewReports", "reviewUid", uid)) {
    const fields = decodeFields(doc.fields ?? {});
    if (fields.status !== "open") continue;
    await batch.update(
      relativePath(doc.name),
      { status: "closed", resolution: "review_removed", resolvedAt: now },
      ["status", "resolution", "resolvedAt"],
    );
  }
}

async function removeTickets(store: DeletionStore, batch: Batch, uid: string) {
  for (const doc of await topLevel(store, "Tickets", "sender.uid", uid)) {
    await deleteTree(store, batch, relativePath(doc.name));
  }
}

/** Keeps payment records but drops the buyer's phone number. */
async function anonymizePayments(
  store: DeletionStore,
  batch: Batch,
  attempts: Array<Record<string, unknown>>,
) {
  const paths = new Set<string>();
  for (const attempt of attempts) {
    const transactionId = attempt.paymobTransactionId;
    if (typeof transactionId !== "string" && typeof transactionId !== "number") {
      continue;
    }
    const id = String(transactionId);
    if (!/^[A-Za-z0-9_-]{1,160}$/.test(id)) continue;
    paths.add(`Transactions/${id}`);
    if (typeof attempt.courseId === "string" && attempt.courseId.length > 0) {
      paths.add(`Courses/${attempt.courseId}/Transactions/${id}`);
    }
  }
  for (const path of paths) {
    const doc = await store.get(path);
    if (!doc) continue;
    await batch.update(path, { accountDeleted: true }, ["mobile", "accountDeleted"]);
  }
}

/** Copies payouts out of the user's documents, without the phone number. */
async function archiveWithdrawals(
  store: DeletionStore,
  batch: Batch,
  uid: string,
  now: Date,
) {
  for (const doc of await listAll(store, `${userPath(uid)}/Transactions`)) {
    const fields = decodeFields(doc.fields ?? {});
    if (fields.method !== "PayOut") continue;
    const id = lastSegment(relativePath(doc.name));
    const { mobile: _mobile, ...kept } = fields;
    const archived = { ...kept, teacherUid: uid, archivedAt: now };
    const path = `ArchivedWithdrawals/${uid}_${id}`;
    await batch.add(
      path,
      upsertWrite(
        store.document(
          path,
          Object.fromEntries(
            Object.entries(archived).map(([key, value]) => [key, encode(value)]),
          ),
        ),
      ),
    );
  }
}

async function keepPaidCourse(
  store: DeletionStore,
  batch: Batch,
  uid: string,
  courseId: string,
  course: Record<string, unknown>,
  subscriberIds: string[],
) {
  const formerTeacher = {
    id: uid,
    name: DELETED_TEACHER_NAME,
    profileImageUrl: "",
    title: "",
  };
  const state = String(course.state ?? "");
  await batch.update(
    `Courses/${courseId}`,
    {
      state: UNPUBLISHED_ON_DELETE.has(state) ? "DeletedByTeacher" : state,
      contentcreaterentity: formerTeacher,
      ownerAccountDeleted: true,
    },
    ["state", "contentcreaterentity", "ownerAccountDeleted"],
  );
  await deleteCollection(store, batch, `Courses/${courseId}/Coupons`);
  for (let i = 0; i < subscriberIds.length; i += 20) {
    const chunk = subscriberIds.slice(i, i + 20);
    const snapshots = await Promise.all(
      chunk.map((id) => store.get(`Users/${id}/Courses/${courseId}`)),
    );
    for (let j = 0; j < chunk.length; j++) {
      if (!snapshots[j]) continue;
      await batch.update(
        `Users/${chunk[j]}/Courses/${courseId}`,
        { contentcreaterentity: formerTeacher },
        ["contentcreaterentity"],
      );
    }
  }
}

async function purgeCourse(
  store: DeletionStore,
  services: DeletionServices,
  batch: Batch,
  courseId: string,
  course: Record<string, unknown>,
): Promise<number> {
  const videoAssets: string[] = [];
  const fileUrls: unknown[] = [course.posterUrl];
  await deleteTree(store, batch, `Courses/${courseId}`, (_path, fields) => {
    if (typeof fields.muxAssetId === "string" && fields.muxAssetId.length > 0) {
      videoAssets.push(fields.muxAssetId);
    }
    for (const key of ["fileUrl", "url", "imageUrl", "posterUrl"]) {
      if (typeof fields[key] === "string") fileUrls.push(fields[key]);
    }
  });
  await batch.flush();
  let files = 0;
  files += await services.removeStorageFolder("CourseFiles", courseId);
  files += await services.removeStorageFolder("Courses", courseId);
  for (const url of fileUrls) files += await services.removeStorageUrl(url);
  for (const assetId of videoAssets) {
    try {
      await services.deleteVideoAsset(assetId);
    } catch {
      (services.logError ?? console.error)("account_deletion_video_left", {
        courseId,
      });
    }
  }
  return files;
}

async function handleTeacherCourses(
  store: DeletionStore,
  services: DeletionServices,
  batch: Batch,
  uid: string,
): Promise<{ kept: number; deleted: number; files: number }> {
  const summary = { kept: 0, deleted: 0, files: 0 };
  const courses = await topLevel(store, "Courses", "contentcreaterentity.id", uid);
  for (const doc of courses) {
    const courseId = lastSegment(relativePath(doc.name));
    const course = decodeFields(doc.fields ?? {});
    const subscriberIds = (await listAll(store, `Courses/${courseId}/Subscribers`))
      .filter((subscriber) => subscriber.fields)
      .map((subscriber) => lastSegment(relativePath(subscriber.name)));
    if (subscriberIds.length > 0) {
      await keepPaidCourse(store, batch, uid, courseId, course, subscriberIds);
      summary.kept++;
    } else {
      summary.files += await purgeCourse(store, services, batch, courseId, course);
      summary.deleted++;
    }
  }
  return summary;
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

/** Body: { acknowledgeBalance?: boolean } */
export async function deleteAccount(
  store: DeletionStore,
  services: DeletionServices,
  identity: FirebaseIdentity,
  body: Record<string, unknown>,
): Promise<DeleteAccountResult> {
  const uid = requiredId(identity.uid, "user_id");
  const now = (services.now ?? (() => new Date()))();
  assertRecentLogin(identity.authTime, now);

  const userDoc = await store.get(userPath(uid));
  const user = userDoc ? decodeFields(userDoc.fields ?? {}) : {};
  if (user.status !== DELETING_STATUS) {
    assertDeletable(user, body.acknowledgeBalance === true);
  }

  const attempts = (await topLevel(store, "CoursePaymentAttempts", "uid", uid))
    .map((doc) => decodeFields(doc.fields ?? {}));
  if (user.status !== DELETING_STATUS && hasPaymentInProgress(attempts, now)) {
    throw new Error("payment_in_progress");
  }

  if (userDoc && user.status !== DELETING_STATUS) {
    await store.commitWrites([
      updateWrite(
        store.document(userPath(uid), {
          status: encode(DELETING_STATUS),
          deletionRequestedAt: encode(now),
        }),
        ["status", "deletionRequestedAt"],
        userDoc.updateTime,
      ),
    ]);
  }

  const batch = new Batch(store);
  await removeReviews(store, uid);
  await removeEnrollments(store, uid);
  await removeActivity(store, batch, uid);
  await anonymizeReports(store, batch, uid, now);
  await removeTickets(store, batch, uid);
  await anonymizePayments(store, batch, attempts);
  await batch.flush();

  const courses = await handleTeacherCourses(store, services, batch, uid);
  await archiveWithdrawals(store, batch, uid, now);
  await batch.flush();

  let filesDeleted = courses.files;
  filesDeleted += await services.removeStorageFolder("Users", uid);
  filesDeleted += await services.removeStorageFolder("Support", uid);
  filesDeleted += await services.removeStorageUrl(user.profilePicurl);

  await deleteTree(store, batch, userPath(uid));
  await batch.add(
    `DeletedAccounts/${uid}`,
    upsertWrite(store.document(`DeletedAccounts/${uid}`, {
      deletedAt: encode(now),
      role: encode(String(user.role ?? "")),
      coursesKept: encode(courses.kept),
      coursesDeleted: encode(courses.deleted),
    })),
  );
  await batch.flush();

  await services.deleteAuthUser(uid);
  return {
    deleted: true,
    coursesKept: courses.kept,
    coursesDeleted: courses.deleted,
    filesDeleted,
  };
}

export function accountDeletionSafeError(cause: unknown): SafeError {
  const code = cause instanceof Error ? cause.message : "internal_error";
  const known: Record<string, [number, string]> = {
    unauthorized: [401, "Authentication is required."],
    invalid_body: [400, "Request body is invalid."],
    payload_too_large: [413, "Request body is too large."],
    invalid_user_id: [400, "User ID is invalid."],
    requires_recent_login: [401, "Sign in again to delete your account."],
    staff_account: [403, "Staff accounts are removed by an administrator."],
    payout_pending: [409, "Wait until your pending payout is finished."],
    balance_remaining: [409, "Your wallet still has a balance."],
    payment_in_progress: [409, "A payment is still in progress."],
  };
  const entry = known[code];
  if (entry) return { code, status: entry[0], message: entry[1] };
  return {
    code: "deletion_incomplete",
    status: 503,
    message: "Some of your data could not be deleted yet. Try again.",
  };
}

export type DeleteAccountHandlerDeps = {
  identify: (request: Request) => Promise<FirebaseIdentity>;
  store: () => DeletionStore;
  services: () => DeletionServices;
  logError?: (event: string, details: Record<string, unknown>) => void;
};

export function createDeleteAccountHandler(
  deps: DeleteAccountHandlerDeps,
): (request: Request) => Promise<Response> {
  return async (request) => {
    if (request.method === "OPTIONS") {
      return new Response("ok", { headers: corsHeaders });
    }
    if (request.method !== "POST") {
      return error("method_not_allowed", "Use POST.", 405);
    }
    try {
      let identity: FirebaseIdentity;
      try {
        identity = await deps.identify(request);
      } catch {
        throw new Error("unauthorized");
      }
      const body = await readCappedJson(request, 4 * 1024);
      const result = await deleteAccount(deps.store(), deps.services(), identity, body);
      return json({ ok: true, ...result });
    } catch (cause) {
      const safe = accountDeletionSafeError(cause);
      if (safe.status >= 500) {
        (deps.logError ?? console.error)("delete_account_failed", {
          reason: cause instanceof Error ? cause.message : typeof cause,
        });
      }
      return error(safe.code, safe.message, safe.status);
    }
  };
}
