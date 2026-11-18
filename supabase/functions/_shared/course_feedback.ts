// Course feedback + star ratings: Firestore orchestration and HTTP handler.
//
// The rating rules live in feedback_logic.ts (pure, unit-tested). This module
// reads the documents a request needs, applies those rules inside ONE
// Firestore transaction, and commits every write atomically:
//
//   Courses/{courseId}/Feedbacks/{uid}       the student's feedback
//   Courses/{courseId}                       rating stats (source of truth)
//   Users/{teacherId}/Courses/{courseId}     teacher's copy of the stats
//   Users/{uid}/Courses/{courseId}           student's enrollment: myRating
//
// Student enrollment snapshots are intentionally NOT fanned out: the app reads
// live stats from Courses/{courseId}.

import type { Firestore } from "./firebase.ts";
import { createWrite, deleteWrite, updateWrite } from "./firebase.ts";
import {
  coursePath,
  decode,
  decodeFields,
  encode,
  enrollPath,
  parseBody,
  requiredCourseId,
  requiredId,
  subscriberPath,
  userPath,
} from "./course_checkout.ts";
import { corsHeaders, error, json } from "./http.ts";
import {
  applyFeedbackDelete,
  applyFeedbackUpsert,
  buildFeedbackWrite,
  canDeleteFeedback,
  type CourseRatingStats,
  feedbackAuthorFromUser,
  feedbackSafeError,
  isEditTooSoon,
  isRetryableTransactionError,
  parseFeedbackText,
  parseRating,
  RATING_STATS_FIELDS,
  ratingEligibility,
  ratingStatsEqual,
  readCourseRatingStats,
  storedFeedbackFrom,
} from "./feedback_logic.ts";

export const feedbackPath = (courseId: string, uid: string) =>
  `Courses/${courseId}/Feedbacks/${uid}`;
export const teacherCoursePath = (teacherId: string, courseId: string) =>
  `Users/${teacherId}/Courses/${courseId}`;

/** The part of the REST Firestore client this module uses (real or fake). */
export type FeedbackStore = Pick<
  Firestore,
  "get" | "beginTransaction" | "commit" | "rollback" | "document"
>;
type StoredDocument = NonNullable<Awaited<ReturnType<FeedbackStore["get"]>>>;

export type FeedbackOptions = {
  now?: () => Date;
  maxAttempts?: number;
  sleep?: (ms: number) => Promise<void>;
  random?: () => number;
};

// Same shape as `requiredId` in course_checkout.ts. Anything used as a path
// segment must match it, so no value can add or escape a path segment.
const ID_PATTERN = /^[A-Za-z0-9_-]{1,160}$/;

function callerId(uid: string): string {
  // The uid comes from a verified Firebase token; still never let it shape a path.
  if (!ID_PATTERN.test(uid)) throw new Error("unauthorized");
  return uid;
}

/** Optional client hint: ignored (not rejected) when it is not a plain ID. */
function optionalId(value: unknown): string | null {
  return typeof value === "string" && ID_PATTERN.test(value) ? value : null;
}

function courseTeacherId(course: Record<string, unknown>): string | null {
  const creator = course.contentcreaterentity as
    | Record<string, unknown>
    | undefined;
  return optionalId(creator?.id);
}

function toDocument(
  db: FeedbackStore,
  path: string,
  data: Record<string, unknown>,
) {
  return db.document(
    path,
    Object.fromEntries(
      Object.entries(data).map(([key, value]) => [key, encode(value)]),
    ),
  );
}

// ---------------------------------------------------------------------------
// Transaction runner
// ---------------------------------------------------------------------------

const DEFAULT_MAX_ATTEMPTS = 3;
const defaultSleep = (ms: number) =>
  new Promise<void>((resolve) => setTimeout(resolve, ms));

type TransactionPlan<T> = { writes: unknown[]; result: T };

/**
 * Runs `work` in a Firestore transaction and commits its writes. Contention
 * (409) and transient outages (503) are retried with jittered exponential
 * backoff; after `maxAttempts` the caller gets `busy`. Domain errors thrown by
 * `work` roll the transaction back and are rethrown unchanged.
 */
export async function runInTransaction<T>(
  db: FeedbackStore,
  work: (transaction: string) => Promise<TransactionPlan<T>>,
  options: FeedbackOptions = {},
): Promise<T> {
  const maxAttempts = options.maxAttempts ?? DEFAULT_MAX_ATTEMPTS;
  const sleep = options.sleep ?? defaultSleep;
  const random = options.random ?? Math.random;

  for (let attempt = 1;; attempt++) {
    let transaction: string | undefined;
    let commitStarted = false;
    try {
      transaction = await db.beginTransaction();
      const plan = await work(transaction);
      commitStarted = true;
      await db.commit(transaction, plan.writes);
      return plan.result;
    } catch (cause) {
      // A failed commit already ends the transaction. Anything that failed
      // earlier must release its read locks now instead of waiting for expiry.
      if (transaction !== undefined && !commitStarted) {
        await db.rollback(transaction).catch(() => {});
      }
      if (!isRetryableTransactionError(cause)) throw cause;
      if (attempt >= maxAttempts) throw new Error("busy");
      await sleep(50 * 2 ** (attempt - 1) + Math.floor(random() * 50));
    }
  }
}

/**
 * Writes the new stats to the course and, when it exists, the teacher's copy.
 * The teacher copy is read only here (i.e. only when stats really changed),
 * unless the client's `teacherId` hint already prefetched the right one.
 */
async function courseStatsWrites(
  db: FeedbackStore,
  transaction: string,
  courseId: string,
  courseDoc: StoredDocument,
  teacherId: string | null,
  hinted: { teacherId: string | null; doc: StoredDocument | null },
  stats: CourseRatingStats,
): Promise<unknown[]> {
  const fields = [...RATING_STATS_FIELDS];
  const writes: unknown[] = [
    updateWrite(
      toDocument(db, coursePath(courseId), stats),
      fields,
      courseDoc.updateTime,
    ),
  ];
  if (teacherId === null) return writes;

  const copyPath = teacherCoursePath(teacherId, courseId);
  const copy = hinted.teacherId === teacherId
    ? hinted.doc
    : await db.get(copyPath, transaction);
  if (copy) {
    writes.push(
      updateWrite(toDocument(db, copyPath, stats), fields, copy.updateTime),
    );
  }
  return writes;
}

function readHintedTeacherCopy(
  db: FeedbackStore,
  transaction: string,
  courseId: string,
  teacherHint: string | null,
  excludedUid: string,
): Promise<StoredDocument | null> {
  // Reading Users/{uid}/Courses/{courseId} for the caller would just re-read
  // their own enrollment, so such a hint is skipped.
  return teacherHint !== null && teacherHint !== excludedUid
    ? db.get(teacherCoursePath(teacherHint, courseId), transaction)
    : Promise.resolve(null);
}

// ---------------------------------------------------------------------------
// Upsert
// ---------------------------------------------------------------------------

export type FeedbackView = {
  uid: string;
  name: string;
  userImage: string;
  fedBack: string;
  rating: number;
  datePosted: string;
  updatedAt: string;
};

export type UpsertFeedbackResult = {
  created: boolean;
  feedback: FeedbackView;
  stats: CourseRatingStats;
};

/**
 * Body: { courseId: string, rating: 1..5, text?: string, teacherId?: string }
 * `teacherId` is an optional, untrusted hint that saves one read round trip.
 */
export async function upsertCourseFeedback(
  db: FeedbackStore,
  callerUid: string,
  body: Record<string, unknown>,
  options: FeedbackOptions = {},
): Promise<UpsertFeedbackResult> {
  // Validate everything before touching Firestore.
  const uid = callerId(callerUid);
  const courseId = requiredCourseId(body.courseId);
  const rating = parseRating(body.rating);
  const text = parseFeedbackText(body.text);
  const teacherHint = optionalId(body.teacherId);
  const clock = options.now ?? (() => new Date());

  return await runInTransaction(db, async (transaction) => {
    const [
      courseDoc,
      userDoc,
      enrollmentDoc,
      subscriberDoc,
      feedbackDoc,
      hintedCopy,
    ] = await Promise.all([
      db.get(coursePath(courseId), transaction),
      db.get(userPath(uid), transaction),
      db.get(enrollPath(uid, courseId), transaction),
      db.get(subscriberPath(courseId, uid), transaction),
      db.get(feedbackPath(courseId, uid), transaction),
      readHintedTeacherCopy(db, transaction, courseId, teacherHint, uid),
    ]);
    if (!courseDoc || !userDoc) throw new Error("not_found");

    const course = decodeFields(courseDoc.fields);
    const user = decodeFields(userDoc.fields);
    const teacherId = courseTeacherId(course);
    const eligibility = ratingEligibility({
      role: String(user.role ?? ""),
      status: String(user.status ?? ""),
      owner: teacherId === uid,
      coursePublished: course.state === "Published",
      hasEnrollment: enrollmentDoc !== null,
      hasSubscriber: subscriberDoc !== null,
    });
    if (eligibility !== "ok") throw new Error(eligibility);

    const now = clock();
    const previous = feedbackDoc ? decodeFields(feedbackDoc.fields) : null;
    if (isEditTooSoon(previous, now)) throw new Error("too_many_requests");

    const before = readCourseRatingStats(course);
    const stats = applyFeedbackUpsert(
      before,
      storedFeedbackFrom(previous),
      rating,
    );
    const author = feedbackAuthorFromUser(user);
    const feedback = buildFeedbackWrite({
      uid,
      author,
      rating,
      text,
      now,
      isNew: feedbackDoc === null,
    });
    const feedbackDocument = toDocument(
      db,
      feedbackPath(courseId, uid),
      feedback.data,
    );

    const writes: unknown[] = [
      feedbackDoc && feedback.updateMask
        ? updateWrite(
          feedbackDocument,
          feedback.updateMask,
          feedbackDoc.updateTime,
        )
        : createWrite(feedbackDocument),
    ];
    if (!ratingStatsEqual(before, stats)) {
      writes.push(
        ...await courseStatsWrites(
          db,
          transaction,
          courseId,
          courseDoc,
          teacherId,
          { teacherId: teacherHint, doc: hintedCopy },
          stats,
        ),
      );
    }
    // enrollmentDoc is non-null here: eligibility required it.
    if (decode(enrollmentDoc!.fields?.myRating) !== rating) {
      writes.push(
        updateWrite(
          toDocument(db, enrollPath(uid, courseId), { myRating: rating }),
          ["myRating"],
          enrollmentDoc!.updateTime,
        ),
      );
    }

    const datePosted = previous?.datePosted instanceof Date
      ? previous.datePosted
      : now;
    return {
      writes,
      result: {
        created: feedbackDoc === null,
        stats,
        feedback: {
          uid,
          ...author,
          fedBack: text,
          rating,
          datePosted: datePosted.toISOString(),
          updatedAt: now.toISOString(),
        },
      },
    };
  }, options);
}

// ---------------------------------------------------------------------------
// Delete
// ---------------------------------------------------------------------------

export type DeleteFeedbackResult = {
  deleted: true;
  /** `null` when the course document no longer exists. */
  stats: CourseRatingStats | null;
};

/**
 * Body: { courseId: string, feedbackUid?: string, teacherId?: string }
 * `feedbackUid` defaults to the caller (a student deleting their own review).
 */
export async function deleteCourseFeedback(
  db: FeedbackStore,
  callerUid: string,
  body: Record<string, unknown>,
  options: FeedbackOptions = {},
): Promise<DeleteFeedbackResult> {
  const uid = callerId(callerUid);
  const courseId = requiredCourseId(body.courseId);
  const feedbackUid =
    body.feedbackUid === undefined || body.feedbackUid === null
      ? uid
      : requiredId(body.feedbackUid, "feedback_id");
  const teacherHint = optionalId(body.teacherId);

  return await runInTransaction(db, async (transaction) => {
    const [callerDoc, courseDoc, feedbackDoc, enrollmentDoc, hintedCopy] =
      await Promise.all([
        db.get(userPath(uid), transaction),
        db.get(coursePath(courseId), transaction),
        db.get(feedbackPath(courseId, feedbackUid), transaction),
        db.get(enrollPath(feedbackUid, courseId), transaction),
        readHintedTeacherCopy(
          db,
          transaction,
          courseId,
          teacherHint,
          feedbackUid,
        ),
      ]);
    if (!callerDoc) throw new Error("not_found");

    // Authorize before revealing whether the feedback exists.
    const caller = decodeFields(callerDoc.fields);
    if (
      !canDeleteFeedback({
        callerUid: uid,
        callerRole: String(caller.role ?? ""),
        callerStatus: String(caller.status ?? ""),
        feedbackUid,
      })
    ) throw new Error("forbidden");
    if (!feedbackDoc) throw new Error("feedback_not_found");

    const removed = storedFeedbackFrom(decodeFields(feedbackDoc.fields))!;
    const writes: unknown[] = [
      deleteWrite(
        toDocument(db, feedbackPath(courseId, feedbackUid), {}),
        feedbackDoc.updateTime,
      ),
    ];

    let stats: CourseRatingStats | null = null;
    if (courseDoc) {
      const course = decodeFields(courseDoc.fields);
      const before = readCourseRatingStats(course);
      stats = applyFeedbackDelete(before, removed);
      if (!ratingStatsEqual(before, stats)) {
        writes.push(
          ...await courseStatsWrites(
            db,
            transaction,
            courseId,
            courseDoc,
            courseTeacherId(course),
            { teacherId: teacherHint, doc: hintedCopy },
            stats,
          ),
        );
      }
    }
    if (enrollmentDoc && decode(enrollmentDoc.fields?.myRating) !== null) {
      // A field listed in the mask but absent from the document is removed.
      writes.push(
        updateWrite(
          toDocument(db, enrollPath(feedbackUid, courseId), {}),
          ["myRating"],
          enrollmentDoc.updateTime,
        ),
      );
    }
    return { writes, result: { deleted: true as const, stats } };
  }, options);
}

// ---------------------------------------------------------------------------
// HTTP
// ---------------------------------------------------------------------------

export const MAX_BODY_BYTES = 16 * 1024;

/** Reads a JSON object body, refusing anything over MAX_BODY_BYTES early. */
export async function readJsonBody(
  request: Request,
): Promise<Record<string, unknown>> {
  const declared = Number(request.headers.get("content-length") ?? "0");
  if (declared > MAX_BODY_BYTES) throw new Error("payload_too_large");
  if (!request.body) throw new Error("invalid_body");

  // Stream with a cap: a missing or false content-length cannot force a
  // large read into memory.
  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let size = 0;
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    size += value.byteLength;
    if (size > MAX_BODY_BYTES) {
      await reader.cancel().catch(() => {});
      throw new Error("payload_too_large");
    }
    chunks.push(value);
  }
  const bytes = new Uint8Array(size);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.byteLength;
  }
  try {
    return parseBody(
      JSON.parse(new TextDecoder("utf-8", { fatal: true }).decode(bytes)),
    );
  } catch {
    throw new Error("invalid_body");
  }
}

/**
 * Reuses one Firestore client per isolate so warm requests skip minting a new
 * service-account token. The client caches its token without expiry, so it is
 * replaced well before Google's 60-minute token lifetime.
 */
export function reusableStore<S extends FeedbackStore = FeedbackStore>(
  create: () => S,
  ttlMs = 50 * 60_000,
  nowMs: () => number = Date.now,
): () => S {
  let cached: { store: S; createdAt: number } | null = null;
  return () => {
    const now = nowMs();
    if (cached === null || now - cached.createdAt >= ttlMs) {
      cached = { store: create(), createdAt: now };
    }
    return cached.store;
  };
}

export type FeedbackAction<T> = (
  db: FeedbackStore,
  callerUid: string,
  body: Record<string, unknown>,
) => Promise<T>;

export type FeedbackHandlerDeps = {
  authenticate: (request: Request) => Promise<string>;
  store: () => FeedbackStore;
  logError?: (event: string, details: Record<string, unknown>) => void;
};

/** Tokens, bodies and document contents are never logged. */
const defaultLogError = (event: string, details: Record<string, unknown>) =>
  console.error(event, details);

export function createFeedbackHandler<T extends Record<string, unknown>>(
  name: string,
  action: FeedbackAction<T>,
  deps: FeedbackHandlerDeps,
): (request: Request) => Promise<Response> {
  return async (request) => {
    if (request.method === "OPTIONS") {
      return new Response("ok", { headers: corsHeaders });
    }
    if (request.method !== "POST") {
      return error("method_not_allowed", "Use POST.", 405);
    }
    try {
      // Authenticate before reading the body or creating a Firestore client.
      const uid = await deps.authenticate(request);
      const body = await readJsonBody(request);
      const result = await action(deps.store(), uid, body);
      return json({ ok: true, ...result });
    } catch (cause) {
      const safe = feedbackSafeError(cause);
      if (safe.status >= 500) {
        (deps.logError ?? defaultLogError)(`${name}_failed`, {
          reason: cause instanceof Error ? cause.message : typeof cause,
        });
      }
      return error(safe.code, safe.message, safe.status);
    }
  };
}
