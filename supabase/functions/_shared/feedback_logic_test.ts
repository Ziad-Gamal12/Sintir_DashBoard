import {
  applyFeedbackDelete,
  applyFeedbackUpsert,
  averageRating,
  buildFeedbackWrite,
  canDeleteFeedback,
  type CourseRatingStats,
  feedbackAuthorFromUser,
  feedbackSafeError,
  isRetryableTransactionError,
  MAX_FEEDBACK_TEXT_LENGTH,
  parseFeedbackText,
  parseRating,
  RATING_STATS_FIELDS,
  ratingEligibility,
  ratingStatsEqual,
  type RatingValue,
  readCourseRatingStats,
  readStoredRating,
  rebuildRatingStats,
  storedFeedbackFrom,
} from "./feedback_logic.ts";

function canonical(value: unknown): string {
  if (value instanceof Date) return JSON.stringify(value.toISOString());
  if (Array.isArray(value)) return `[${value.map(canonical).join(",")}]`;
  if (value && typeof value === "object") {
    const entries = Object.entries(value as Record<string, unknown>)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([k, v]) => `${JSON.stringify(k)}:${canonical(v)}`);
    return `{${entries.join(",")}}`;
  }
  return JSON.stringify(value);
}

function expectEqual(actual: unknown, expected: unknown, label: string): void {
  if (canonical(actual) !== canonical(expected)) {
    throw new Error(
      `${label}\n  expected: ${canonical(expected)}\n  actual:   ${
        canonical(actual)
      }`,
    );
  }
}

function expectThrows(fn: () => unknown, code: string, label: string): void {
  try {
    fn();
  } catch (error) {
    if (error instanceof Error && error.message === code) return;
    throw new Error(`${label}: threw ${String(error)} instead of ${code}`);
  }
  throw new Error(`${label}: did not throw ${code}`);
}

const stats = (
  overrides: Partial<CourseRatingStats> & {
    dist?: [number, number, number, number, number];
  } = {},
): CourseRatingStats => {
  const [d1, d2, d3, d4, d5] = overrides.dist ?? [0, 0, 0, 0, 0];
  return readCourseRatingStats({
    ratingsSum: overrides.ratingsSum ?? 0,
    ratingsCount: overrides.ratingsCount ?? 0,
    feedBacksCount: overrides.feedBacksCount ?? 0,
    ratingDistribution: { "1": d1, "2": d2, "3": d3, "4": d4, "5": d5 },
  });
};

// ---------------------------------------------------------------------------
// Request validation
// ---------------------------------------------------------------------------

Deno.test("rating accepts only whole numbers 1 to 5", () => {
  for (const ok of [1, 2, 3, 4, 5]) {
    expectEqual(parseRating(ok), ok, `rating ${ok}`);
  }
  for (
    const bad of [
      0,
      6,
      -1,
      4.5,
      Number.NaN,
      Infinity,
      "5",
      null,
      undefined,
      true,
      {},
    ]
  ) {
    expectThrows(
      () => parseRating(bad),
      "invalid_rating",
      `rating ${String(bad)}`,
    );
  }
});

Deno.test("review text is optional, trimmed and cleaned", () => {
  expectEqual(parseFeedbackText(undefined), "", "undefined text");
  expectEqual(parseFeedbackText(null), "", "null text");
  expectEqual(parseFeedbackText("   "), "", "blank text");
  expectEqual(
    parseFeedbackText("  مدرس ممتاز  "),
    "مدرس ممتاز",
    "arabic trimmed",
  );
  expectEqual(parseFeedbackText("a\r\nb\rc"), "a\nb\nc", "line endings");
  expectEqual(
    parseFeedbackText("a\n\n\n\n\nb"),
    "a\n\nb",
    "blank lines collapsed",
  );
  expectEqual(parseFeedbackText("ok\u0000\u0007​ok"), "ok​ok", "control chars");
  expectEqual(parseFeedbackText("tab\there"), "tab\there", "tab kept");
  expectThrows(() => parseFeedbackText(42), "invalid_text", "number text");
  expectThrows(() => parseFeedbackText(["x"]), "invalid_text", "array text");
  expectThrows(
    () => parseFeedbackText("bad \uD800 surrogate"),
    "invalid_text",
    "lone surrogate",
  );
});

Deno.test("review text limit counts characters, not UTF-16 units", () => {
  const emojis = "👍".repeat(MAX_FEEDBACK_TEXT_LENGTH);
  expectEqual(
    [...parseFeedbackText(emojis)].length,
    MAX_FEEDBACK_TEXT_LENGTH,
    "500 emojis allowed",
  );
  expectEqual(
    parseFeedbackText("م".repeat(500)).length,
    500,
    "500 arabic letters allowed",
  );
  expectThrows(
    () => parseFeedbackText("م".repeat(501)),
    "text_too_long",
    "501 letters",
  );
  // Surrounding whitespace does not count against the limit.
  expectEqual(
    parseFeedbackText(`  ${"a".repeat(500)}  `).length,
    500,
    "trim before limit",
  );
});

// ---------------------------------------------------------------------------
// Reading stored data
// ---------------------------------------------------------------------------

Deno.test("courses created before ratings read as zero stats and keep feedBacksCount", () => {
  expectEqual(readCourseRatingStats({ title: "Math", feedBacksCount: 7 }), {
    ratingsSum: 0,
    ratingsCount: 0,
    averageRating: 0,
    ratingDistribution: { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0 },
    feedBacksCount: 7,
  }, "legacy course");
  expectEqual(readCourseRatingStats(null).feedBacksCount, 0, "missing course");
});

Deno.test("corrupted stored stats are clamped and the stored average is ignored", () => {
  const read = readCourseRatingStats({
    ratingsSum: -10,
    ratingsCount: "3",
    averageRating: 99,
    feedBacksCount: Number.NaN,
    ratingDistribution: { "1": -2, "5": 2.9, "9": 4 },
  });
  expectEqual(read, {
    ratingsSum: 0,
    ratingsCount: 0,
    averageRating: 0,
    ratingDistribution: { "1": 0, "2": 0, "3": 0, "4": 0, "5": 2 },
    feedBacksCount: 0,
  }, "clamped stats");
  expectEqual(
    readCourseRatingStats({ ratingsSum: 9, ratingsCount: 2, averageRating: 1 })
      .averageRating,
    4.5,
    "recomputed average",
  );
  expectEqual(
    readCourseRatingStats({ ratingDistribution: [1, 2, 3] })
      .ratingDistribution["1"],
    0,
    "array distribution ignored",
  );
});

Deno.test("stored ratings are trusted only when they are 1 to 5", () => {
  expectEqual(readStoredRating(4), 4, "valid stored rating");
  for (const bad of [undefined, null, 0, 6, 3.5, "4"]) {
    expectEqual(readStoredRating(bad), null, `stored ${String(bad)}`);
  }
  expectEqual(storedFeedbackFrom(null), null, "missing doc");
  expectEqual(
    storedFeedbackFrom({ fedBack: "old text" }),
    { rating: null },
    "legacy doc",
  );
  expectEqual(storedFeedbackFrom({ rating: 5 }), { rating: 5 }, "rated doc");
});

Deno.test("average is rounded to two decimals and stays within 1..5", () => {
  expectEqual(averageRating(13, 3), 4.33, "13/3");
  expectEqual(averageRating(14, 3), 4.67, "14/3");
  expectEqual(averageRating(0, 0), 0, "no ratings");
  expectEqual(averageRating(40, 2), 5, "corrupt high sum capped");
  expectEqual(averageRating(1, 10), 1, "corrupt low sum floored");
});

// ---------------------------------------------------------------------------
// Upsert
// ---------------------------------------------------------------------------

Deno.test("first rating on a course creates the feedback and the stats", () => {
  expectEqual(applyFeedbackUpsert(stats(), null, 5), {
    ratingsSum: 5,
    ratingsCount: 1,
    averageRating: 5,
    ratingDistribution: { "1": 0, "2": 0, "3": 0, "4": 0, "5": 1 },
    feedBacksCount: 1,
  }, "first rating");
});

Deno.test("a new rating is added to existing stats", () => {
  const before = stats({
    ratingsSum: 9,
    ratingsCount: 2,
    feedBacksCount: 3,
    dist: [0, 0, 0, 1, 1],
  });
  expectEqual(applyFeedbackUpsert(before, null, 3), {
    ratingsSum: 12,
    ratingsCount: 3,
    averageRating: 4,
    ratingDistribution: { "1": 0, "2": 0, "3": 1, "4": 1, "5": 1 },
    feedBacksCount: 4,
  }, "add third rating");
});

Deno.test("changing a rating swaps it without changing the counts", () => {
  const before = stats({
    ratingsSum: 9,
    ratingsCount: 2,
    feedBacksCount: 2,
    dist: [0, 0, 0, 1, 1],
  });
  expectEqual(applyFeedbackUpsert(before, { rating: 5 }, 2), {
    ratingsSum: 6,
    ratingsCount: 2,
    averageRating: 3,
    ratingDistribution: { "1": 0, "2": 1, "3": 0, "4": 1, "5": 0 },
    feedBacksCount: 2,
  }, "5 → 2");
});

Deno.test("editing only the text leaves the stats unchanged so the course needs no write", () => {
  const before = stats({
    ratingsSum: 9,
    ratingsCount: 2,
    feedBacksCount: 2,
    dist: [0, 0, 0, 1, 1],
  });
  const after = applyFeedbackUpsert(before, { rating: 4 }, 4);
  if (!ratingStatsEqual(before, after)) {
    throw new Error("Same rating changed the stats.");
  }
});

Deno.test("a legacy text-only feedback that gets a rating is counted once", () => {
  // 3 feedbacks exist, only 1 of them was rated.
  const before = stats({
    ratingsSum: 4,
    ratingsCount: 1,
    feedBacksCount: 3,
    dist: [0, 0, 0, 1, 0],
  });
  expectEqual(applyFeedbackUpsert(before, { rating: null }, 2), {
    ratingsSum: 6,
    ratingsCount: 2,
    averageRating: 3,
    ratingDistribution: { "1": 0, "2": 1, "3": 0, "4": 1, "5": 0 },
    feedBacksCount: 3,
  }, "legacy gets rated");
});

Deno.test("transitions never mutate the stats they receive", () => {
  const before = stats({
    ratingsSum: 9,
    ratingsCount: 2,
    feedBacksCount: 2,
    dist: [0, 0, 0, 1, 1],
  });
  const snapshot = canonical(before);
  applyFeedbackUpsert(before, { rating: 5 }, 1);
  applyFeedbackUpsert(before, null, 3);
  applyFeedbackDelete(before, { rating: 4 });
  expectEqual(canonical(before), snapshot, "input stats mutated");
});

// ---------------------------------------------------------------------------
// Delete
// ---------------------------------------------------------------------------

Deno.test("deleting a rated feedback removes it from every stat", () => {
  const before = stats({
    ratingsSum: 12,
    ratingsCount: 3,
    feedBacksCount: 4,
    dist: [0, 0, 1, 1, 1],
  });
  expectEqual(applyFeedbackDelete(before, { rating: 5 }), {
    ratingsSum: 7,
    ratingsCount: 2,
    averageRating: 3.5,
    ratingDistribution: { "1": 0, "2": 0, "3": 1, "4": 1, "5": 0 },
    feedBacksCount: 3,
  }, "delete rated");
});

Deno.test("deleting a legacy text-only feedback only lowers feedBacksCount", () => {
  const before = stats({
    ratingsSum: 12,
    ratingsCount: 3,
    feedBacksCount: 4,
    dist: [0, 0, 1, 1, 1],
  });
  expectEqual(applyFeedbackDelete(before, { rating: null }), {
    ...before,
    feedBacksCount: 3,
  }, "delete legacy");
});

Deno.test("deleting the last rating resets the average to zero", () => {
  const before = stats({
    ratingsSum: 4,
    ratingsCount: 1,
    feedBacksCount: 1,
    dist: [0, 0, 0, 1, 0],
  });
  expectEqual(
    applyFeedbackDelete(before, { rating: 4 }),
    readCourseRatingStats(null),
    "back to empty",
  );
});

Deno.test("drifted counters never go negative", () => {
  // e.g. feedBacksCount was never incremented for a doc that is now deleted.
  const drifted = stats({ ratingsSum: 2, ratingsCount: 0, feedBacksCount: 0 });
  const after = applyFeedbackDelete(drifted, { rating: 5 });
  for (
    const field of ["ratingsSum", "ratingsCount", "feedBacksCount"] as const
  ) {
    if (after[field] < 0) throw new Error(`${field} went negative.`);
  }
  if (Object.values(after.ratingDistribution).some((n) => n < 0)) {
    throw new Error("Distribution went negative.");
  }
  const swapped = applyFeedbackUpsert(
    stats({ ratingsSum: 1, ratingsCount: 1 }),
    { rating: 5 },
    1,
  );
  if (swapped.ratingsSum < 0 || swapped.averageRating > 5) {
    throw new Error("Swapping on drifted stats produced an impossible value.");
  }
});

// ---------------------------------------------------------------------------
// Randomized: incremental stats must always equal a full rebuild
// ---------------------------------------------------------------------------

function seededRandom(seed: number): () => number {
  // mulberry32
  return () => {
    seed |= 0;
    seed = (seed + 0x6D2B79F5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

Deno.test("10k random creates, edits and deletes always match a full rebuild", () => {
  for (const seed of [1, 7, 42, 2026, 99991]) {
    const random = seededRandom(seed);
    const docs = new Map<string, Record<string, unknown>>();
    // Start from a course that already has legacy text-only feedbacks.
    for (let i = 0; i < 5; i++) docs.set(`legacy-${i}`, { fedBack: "old" });
    let current = readCourseRatingStats({ feedBacksCount: docs.size });

    for (let step = 0; step < 2000; step++) {
      const uid = `student-${Math.floor(random() * 40)}`;
      const existingUid = [...docs.keys()][Math.floor(random() * docs.size)];
      const action = random();

      if (action < 0.6) {
        const rating = (1 + Math.floor(random() * 5)) as RatingValue;
        current = applyFeedbackUpsert(
          current,
          storedFeedbackFrom(docs.get(uid)),
          rating,
        );
        docs.set(uid, { ...(docs.get(uid) ?? {}), rating });
      } else if (action < 0.75 && existingUid) {
        // A legacy author rates their old feedback.
        const rating = (1 + Math.floor(random() * 5)) as RatingValue;
        current = applyFeedbackUpsert(
          current,
          storedFeedbackFrom(docs.get(existingUid)),
          rating,
        );
        docs.set(existingUid, { ...docs.get(existingUid), rating });
      } else if (existingUid) {
        const removed = storedFeedbackFrom(docs.get(existingUid))!;
        current = applyFeedbackDelete(current, removed);
        docs.delete(existingUid);
      }

      const rebuilt = rebuildRatingStats(docs.values());
      if (!ratingStatsEqual(current, rebuilt)) {
        throw new Error(
          `seed ${seed} step ${step}: incremental ${
            canonical(current)
          } != rebuilt ${canonical(rebuilt)}`,
        );
      }
      const distributionTotal = Object.values(current.ratingDistribution)
        .reduce((a, b) => a + b, 0);
      if (distributionTotal !== current.ratingsCount) {
        throw new Error(
          `seed ${seed} step ${step}: distribution does not add up to ratingsCount`,
        );
      }
      if (current.ratingsCount > current.feedBacksCount) {
        throw new Error(
          `seed ${seed} step ${step}: more ratings than feedbacks`,
        );
      }
    }
  }
});

Deno.test("rebuild repairs a course whose counters drifted", () => {
  const rebuilt = rebuildRatingStats([
    { rating: 5 },
    { rating: 4 },
    { fedBack: "legacy without rating" },
    { rating: "5" }, // corrupt → treated as unrated
  ]);
  expectEqual(rebuilt, {
    ratingsSum: 9,
    ratingsCount: 2,
    averageRating: 4.5,
    ratingDistribution: { "1": 0, "2": 0, "3": 0, "4": 1, "5": 1 },
    feedBacksCount: 4,
  }, "rebuild");
});

Deno.test("stats object has exactly the server-owned fields used as updateMask", () => {
  expectEqual(
    Object.keys(readCourseRatingStats(null)).sort(),
    [...RATING_STATS_FIELDS].sort(),
    "field list",
  );
});

// ---------------------------------------------------------------------------
// Authorization
// ---------------------------------------------------------------------------

Deno.test("only active subscribed students can rate a published course", () => {
  const base = {
    role: "Student",
    status: "Active",
    owner: false,
    coursePublished: true,
    hasEnrollment: true,
    hasSubscriber: true,
  };
  expectEqual(ratingEligibility(base), "ok", "subscribed student");
  expectEqual(
    ratingEligibility({ ...base, status: "Blocked" }),
    "inactive_user",
    "blocked",
  );
  expectEqual(
    ratingEligibility({ ...base, role: "Teacher", owner: true }),
    "own_course",
    "own course",
  );
  expectEqual(
    ratingEligibility({ ...base, role: "Teacher" }),
    "not_student",
    "other teacher",
  );
  expectEqual(
    ratingEligibility({ ...base, role: "Admin" }),
    "not_student",
    "admin",
  );
  expectEqual(
    ratingEligibility({ ...base, coursePublished: false }),
    "course_unavailable",
    "unpublished",
  );
  expectEqual(
    ratingEligibility({ ...base, hasEnrollment: false }),
    "not_subscribed",
    "no enrollment",
  );
  expectEqual(
    ratingEligibility({ ...base, hasSubscriber: false }),
    "not_subscribed",
    "no subscriber record",
  );
});

Deno.test("admins delete any feedback, students only their own", () => {
  const base = {
    callerUid: "s1",
    callerRole: "Student",
    callerStatus: "Active",
    feedbackUid: "s1",
  };
  if (!canDeleteFeedback(base)) throw new Error("Owner could not delete.");
  if (canDeleteFeedback({ ...base, feedbackUid: "s2" })) {
    throw new Error("Student deleted someone else's feedback.");
  }
  if (canDeleteFeedback({ ...base, callerStatus: "Blocked" })) {
    throw new Error("Blocked student deleted feedback.");
  }
  if (
    canDeleteFeedback({ ...base, callerRole: "Teacher", feedbackUid: "s2" })
  ) throw new Error("Teacher deleted a student's feedback.");
  if (
    !canDeleteFeedback({
      ...base,
      callerRole: "Admin",
      callerUid: "a1",
      feedbackUid: "s2",
    })
  ) throw new Error("Admin could not delete.");
});

// ---------------------------------------------------------------------------
// Feedback document
// ---------------------------------------------------------------------------

Deno.test("author name and image come from the user document", () => {
  expectEqual(
    feedbackAuthorFromUser({
      firstName: " Ziad ",
      lastName: "Gamal",
      profilePicurl: "https://img",
    }),
    { name: "Ziad Gamal", userImage: "https://img" },
    "full user",
  );
  expectEqual(feedbackAuthorFromUser({ firstName: "Ziad" }), {
    name: "Ziad",
    userImage: "",
  }, "partial user");
  expectEqual(
    feedbackAuthorFromUser(null),
    { name: "", userImage: "" },
    "missing user",
  );
});

Deno.test("new feedback sets datePosted once; edits keep datePosted and uid", () => {
  const now = new Date("2026-11-17T10:00:00Z");
  const author = { name: "Ziad Gamal", userImage: "https://img" };
  const created = buildFeedbackWrite({
    uid: "s1",
    author,
    rating: 5,
    text: "مدرس ممتاز",
    now,
    isNew: true,
  });
  expectEqual(created, {
    data: {
      uid: "s1",
      name: "Ziad Gamal",
      userImage: "https://img",
      fedBack: "مدرس ممتاز",
      rating: 5,
      updatedAt: now,
      datePosted: now,
    },
    updateMask: null,
  }, "create");

  const edited = buildFeedbackWrite({
    uid: "s1",
    author,
    rating: 3,
    text: "",
    now,
    isNew: false,
  });
  if (edited.updateMask === null) {
    throw new Error("Edit would overwrite the whole doc.");
  }
  for (const kept of ["datePosted", "uid"]) {
    if (kept in edited.data || edited.updateMask.includes(kept)) {
      throw new Error(`Edit would overwrite ${kept}.`);
    }
  }
  expectEqual(edited.updateMask.sort(), [
    "fedBack",
    "name",
    "rating",
    "updatedAt",
    "userImage",
  ], "edit mask");
});

// ---------------------------------------------------------------------------
// Errors
// ---------------------------------------------------------------------------

Deno.test("only Firestore contention and outages are retried", () => {
  if (
    !isRetryableTransactionError(
      new Error("Firestore transaction could not commit (409)."),
    )
  ) {
    throw new Error("Contention was not retried.");
  }
  if (!isRetryableTransactionError(new Error("Firestore read failed (503)."))) {
    throw new Error("Outage was not retried.");
  }
  for (
    const other of [
      new Error("Firestore transaction could not commit (400)."),
      new Error("Firestore read failed (403)."),
      new Error("invalid_rating"),
      "409",
    ]
  ) {
    if (isRetryableTransactionError(other)) {
      throw new Error(`Retried ${String(other)}.`);
    }
  }
});

Deno.test("error codes map to safe responses and unknown errors stay generic", () => {
  expectEqual(
    feedbackSafeError(new Error("not_subscribed")).status,
    403,
    "not subscribed",
  );
  expectEqual(
    feedbackSafeError(new Error("invalid_rating")).status,
    400,
    "invalid rating",
  );
  expectEqual(feedbackSafeError(new Error("busy")).status, 409, "busy");
  expectEqual(
    feedbackSafeError(
      new Error("Firestore read failed (500) projects/x/secret"),
    ),
    {
      code: "internal_error",
      status: 500,
      message: "Feedback could not be saved.",
    },
    "unknown error hidden",
  );
  expectEqual(feedbackSafeError("boom").code, "internal_error", "non-Error");
});
