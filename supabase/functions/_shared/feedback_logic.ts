// Pure logic for course feedback + star ratings.
//
// Used by the `upsert-course-feedback` and `delete-course-feedback` edge
// functions. Nothing here performs I/O, so every rule can be unit-tested with
// `deno test` without Firebase credentials.
//
// Firestore layout this logic maintains:
//   Courses/{courseId}/Feedbacks/{uid}
//     uid, name, userImage, fedBack, rating (1..5, missing on legacy docs),
//     datePosted, updatedAt
//   Courses/{courseId}                      } server-owned rating stats
//   Users/{teacherId}/Courses/{courseId}    } (see RATING_STATS_FIELDS)

export const RATING_VALUES = [1, 2, 3, 4, 5] as const;
export type RatingValue = typeof RATING_VALUES[number];

export const RATING_KEYS = ["1", "2", "3", "4", "5"] as const;
export type RatingKey = typeof RATING_KEYS[number];
export type RatingDistribution = Record<RatingKey, number>;

export const MAX_FEEDBACK_TEXT_LENGTH = 500;

/**
 * Fields on the course document (and the teacher's copy) that only the edge
 * functions may write. Use as the commit updateMask and in Firestore rules.
 */
export const RATING_STATS_FIELDS = [
  "ratingsSum",
  "ratingsCount",
  "averageRating",
  "ratingDistribution",
  "feedBacksCount",
] as const;

export type CourseRatingStats = {
  ratingsSum: number;
  ratingsCount: number;
  averageRating: number;
  ratingDistribution: RatingDistribution;
  /** All feedback docs, including legacy text-only ones without a rating. */
  feedBacksCount: number;
};

/** The part of an existing Feedbacks/{uid} document the stats depend on. */
export type StoredFeedback = { rating: RatingValue | null };

// ---------------------------------------------------------------------------
// Request validation
// ---------------------------------------------------------------------------

/** Strict: the client must send an integer 1..5 (no strings, no halves). */
export function parseRating(value: unknown): RatingValue {
  if (
    typeof value !== "number" || !Number.isInteger(value) || value < 1 ||
    value > 5
  ) {
    throw new Error("invalid_rating");
  }
  return value as RatingValue;
}

// C0/C1 control characters except tab (U+0009) and newline (U+000A).
// deno-lint-ignore no-control-regex
const CONTROL_CHARS = /[\u0000-\u0008\u000B-\u001F\u007F-\u009F]/gu;

/** Optional review text: trimmed, cleaned, max 500 characters (code points). */
export function parseFeedbackText(value: unknown): string {
  if (value === undefined || value === null) return "";
  if (typeof value !== "string") throw new Error("invalid_text");
  try {
    // Firestore rejects invalid UTF-16 (unpaired surrogates).
    encodeURIComponent(value);
  } catch {
    throw new Error("invalid_text");
  }
  const cleaned = value
    .replace(/\r\n?/g, "\n")
    .replace(CONTROL_CHARS, "")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
  if ([...cleaned].length > MAX_FEEDBACK_TEXT_LENGTH) {
    throw new Error("text_too_long");
  }
  return cleaned;
}

// ---------------------------------------------------------------------------
// Reading stored data (tolerant: legacy and partially corrupted documents)
// ---------------------------------------------------------------------------

/** A stored rating is trusted only if it is an integer 1..5; else legacy. */
export function readStoredRating(value: unknown): RatingValue | null {
  return typeof value === "number" && Number.isInteger(value) && value >= 1 &&
      value <= 5
    ? value as RatingValue
    : null;
}

/** `null` when the feedback document does not exist. */
export function storedFeedbackFrom(
  fields: Record<string, unknown> | null | undefined,
): StoredFeedback | null {
  if (!fields) return null;
  return { rating: readStoredRating(fields.rating) };
}

function nonNegativeInt(value: unknown): number {
  if (typeof value !== "number" || !Number.isFinite(value) || value <= 0) {
    return 0;
  }
  return Math.floor(value);
}

export function emptyRatingDistribution(): RatingDistribution {
  return { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0 };
}

const ratingKey = (rating: RatingValue): RatingKey =>
  String(rating) as RatingKey;

/**
 * Normalizes the stats stored on a decoded course document. Courses created
 * before ratings existed have no rating fields and read as zeros; their
 * existing `feedBacksCount` is preserved. The stored `averageRating` is never
 * trusted, it is always recomputed from sum and count.
 */
export function readCourseRatingStats(
  course: Record<string, unknown> | null | undefined,
): CourseRatingStats {
  const source = course ?? {};
  const distribution = emptyRatingDistribution();
  const rawDistribution = source.ratingDistribution;
  if (
    rawDistribution && typeof rawDistribution === "object" &&
    !Array.isArray(rawDistribution)
  ) {
    for (const key of RATING_KEYS) {
      distribution[key] = nonNegativeInt(
        (rawDistribution as Record<string, unknown>)[key],
      );
    }
  }
  return finalizeStats({
    ratingsSum: nonNegativeInt(source.ratingsSum),
    ratingsCount: nonNegativeInt(source.ratingsCount),
    averageRating: 0,
    ratingDistribution: distribution,
    feedBacksCount: nonNegativeInt(source.feedBacksCount),
  });
}

// ---------------------------------------------------------------------------
// Stats transitions
// ---------------------------------------------------------------------------

/** Rounded to 2 decimals; always within [1, 5] when there is a rating. */
export function averageRating(sum: number, count: number): number {
  if (count <= 0 || sum <= 0) return 0;
  const average = Math.min(5, Math.max(1, sum / count));
  return Math.round(average * 100) / 100;
}

function finalizeStats(stats: CourseRatingStats): CourseRatingStats {
  const ratingsCount = Math.max(0, stats.ratingsCount);
  const ratingsSum = ratingsCount === 0 ? 0 : Math.max(0, stats.ratingsSum);
  const ratingDistribution = emptyRatingDistribution();
  for (const key of RATING_KEYS) {
    ratingDistribution[key] = Math.max(0, stats.ratingDistribution[key]);
  }
  return {
    ratingsSum,
    ratingsCount,
    averageRating: averageRating(ratingsSum, ratingsCount),
    ratingDistribution,
    feedBacksCount: Math.max(0, stats.feedBacksCount),
  };
}

function cloneStats(stats: CourseRatingStats): CourseRatingStats {
  return { ...stats, ratingDistribution: { ...stats.ratingDistribution } };
}

/**
 * Create or edit the caller's feedback.
 * - `previous === null`: no feedback doc yet → feedBacksCount + 1.
 * - previous legacy doc (rating null): becomes rated → ratingsCount + 1.
 * - previous rated doc: the old rating is swapped for the new one.
 * Never mutates `stats`.
 */
export function applyFeedbackUpsert(
  stats: CourseRatingStats,
  previous: StoredFeedback | null,
  newRating: RatingValue,
): CourseRatingStats {
  const next = cloneStats(stats);
  if (previous === null) next.feedBacksCount += 1;
  const oldRating = previous?.rating ?? null;
  if (oldRating === newRating) return finalizeStats(next);

  if (oldRating === null) {
    next.ratingsCount += 1;
  } else {
    next.ratingsSum -= oldRating;
    next.ratingDistribution[ratingKey(oldRating)] -= 1;
  }
  next.ratingsSum += newRating;
  next.ratingDistribution[ratingKey(newRating)] += 1;
  return finalizeStats(next);
}

/** Remove an existing feedback doc (rated or legacy). Never mutates `stats`. */
export function applyFeedbackDelete(
  stats: CourseRatingStats,
  deleted: StoredFeedback,
): CourseRatingStats {
  const next = cloneStats(stats);
  next.feedBacksCount -= 1;
  if (deleted.rating !== null) {
    next.ratingsCount -= 1;
    next.ratingsSum -= deleted.rating;
    next.ratingDistribution[ratingKey(deleted.rating)] -= 1;
  }
  return finalizeStats(next);
}

/** When equal, the course docs need no write (e.g. a text-only edit). */
export function ratingStatsEqual(
  a: CourseRatingStats,
  b: CourseRatingStats,
): boolean {
  return a.ratingsSum === b.ratingsSum &&
    a.ratingsCount === b.ratingsCount &&
    a.averageRating === b.averageRating &&
    a.feedBacksCount === b.feedBacksCount &&
    RATING_KEYS.every((key) =>
      a.ratingDistribution[key] === b.ratingDistribution[key]
    );
}

/**
 * Recomputes stats from every feedback doc of a course. For a one-off repair
 * of courses whose counters drifted (e.g. deletes that never decremented
 * feedBacksCount before this change).
 */
export function rebuildRatingStats(
  feedbacks: Iterable<Record<string, unknown>>,
): CourseRatingStats {
  // Computed directly (not via applyFeedbackUpsert) so tests can use it as an
  // independent oracle for the incremental transitions.
  const stats = readCourseRatingStats(null);
  for (const feedback of feedbacks) {
    stats.feedBacksCount += 1;
    const rating = readStoredRating(feedback.rating);
    if (rating === null) continue;
    stats.ratingsCount += 1;
    stats.ratingsSum += rating;
    stats.ratingDistribution[ratingKey(rating)] += 1;
  }
  return finalizeStats(stats);
}

// ---------------------------------------------------------------------------
// Authorization
// ---------------------------------------------------------------------------

export type RatingEligibility =
  | "ok"
  | "inactive_user"
  | "own_course"
  | "not_student"
  | "course_unavailable"
  | "not_subscribed";

/** Mirrors video playback access: active student, published course, both enrollment records. */
export function ratingEligibility(input: {
  role: string;
  status: string;
  owner: boolean;
  coursePublished: boolean;
  hasEnrollment: boolean;
  hasSubscriber: boolean;
}): RatingEligibility {
  if (input.status !== "Active") return "inactive_user";
  if (input.owner) return "own_course";
  if (input.role !== "Student") return "not_student";
  if (!input.coursePublished) return "course_unavailable";
  if (!input.hasEnrollment || !input.hasSubscriber) return "not_subscribed";
  return "ok";
}

/** Admins (dashboard) can delete any feedback; an active student only their own. */
export function canDeleteFeedback(input: {
  callerUid: string;
  callerRole: string;
  callerStatus: string;
  feedbackUid: string;
}): boolean {
  if (input.callerRole === "Admin") return true;
  return input.callerStatus === "Active" &&
    input.callerUid === input.feedbackUid;
}

// ---------------------------------------------------------------------------
// Feedback document
// ---------------------------------------------------------------------------

const text = (value: unknown): string =>
  typeof value === "string" ? value.trim() : "";

/** Name and image come from Users/{uid}, never from the request body. */
export function feedbackAuthorFromUser(
  user: Record<string, unknown> | null | undefined,
): { name: string; userImage: string } {
  const source = user ?? {};
  return {
    name: [text(source.firstName), text(source.lastName)]
      .filter((part) => part.length > 0)
      .join(" "),
    userImage: text(source.profilePicurl),
  };
}

export type FeedbackWrite = {
  data: Record<string, unknown>;
  /** `null` → create the doc; otherwise update only these fields. */
  updateMask: string[] | null;
};

/**
 * Field names match the Flutter Coursefeedbacksmodel (`fedBack` included).
 * `datePosted` and `uid` are written once on create and kept on edits.
 */
export function buildFeedbackWrite(input: {
  uid: string;
  author: { name: string; userImage: string };
  rating: RatingValue;
  text: string;
  now: Date;
  isNew: boolean;
}): FeedbackWrite {
  const editable = {
    name: input.author.name,
    userImage: input.author.userImage,
    fedBack: input.text,
    rating: input.rating,
    updatedAt: input.now,
  };
  if (input.isNew) {
    return {
      data: { uid: input.uid, ...editable, datePosted: input.now },
      updateMask: null,
    };
  }
  return { data: editable, updateMask: Object.keys(editable) };
}

// ---------------------------------------------------------------------------
// Errors
// ---------------------------------------------------------------------------

/** Transaction contention (ABORTED → 409) or a transient outage (503). */
export function isRetryableTransactionError(error: unknown): boolean {
  return error instanceof Error && error.message.includes("Firestore") &&
    /\((409|503)\)/.test(error.message);
}

export function feedbackSafeError(
  error: unknown,
): { code: string; status: number; message: string } {
  const code = error instanceof Error ? error.message : "internal_error";
  const known: Record<string, [number, string]> = {
    unauthorized: [401, "Authentication is required."],
    invalid_body: [400, "Request body is invalid."],
    invalid_course_id: [400, "Course ID is invalid."],
    invalid_feedback_id: [400, "Feedback ID is invalid."],
    invalid_rating: [400, "Rating must be a whole number from 1 to 5."],
    invalid_text: [400, "Feedback text is invalid."],
    text_too_long: [
      400,
      `Feedback text must be at most ${MAX_FEEDBACK_TEXT_LENGTH} characters.`,
    ],
    not_found: [404, "Course or user was not found."],
    feedback_not_found: [404, "Feedback was not found."],
    inactive_user: [403, "Your account is not active."],
    own_course: [403, "You cannot rate your own course."],
    not_student: [403, "Only students can rate courses."],
    course_unavailable: [409, "This course is not available."],
    not_subscribed: [403, "Subscribe to the course to rate it."],
    forbidden: [403, "You cannot delete this feedback."],
    busy: [409, "The course is busy right now. Try again."],
  };
  const [status, message] = known[code] ??
    [500, "Feedback could not be saved."];
  return { code: known[code] ? code : "internal_error", status, message };
}
