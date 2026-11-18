import {
  coursePath,
  enrollPath,
  subscriberPath,
  userPath,
} from "./course_checkout.ts";
import {
  createFeedbackHandler,
  deleteCourseFeedback,
  feedbackPath,
  type FeedbackStore,
  MAX_BODY_BYTES,
  readJsonBody,
  reusableStore,
  runInTransaction,
  teacherCoursePath,
  upsertCourseFeedback,
} from "./course_feedback.ts";
import {
  FEEDBACK_EDIT_COOLDOWN_MS,
  RATING_STATS_FIELDS,
  readCourseRatingStats,
  rebuildRatingStats,
} from "./feedback_logic.ts";
import { FakeFirestore } from "./test_support/fake_firestore.ts";

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const COURSE = "course-1";
const TEACHER = "teacher-1";
const ADMIN = "admin-1";
const T0 = new Date("2026-11-17T10:00:00.000Z");
const STATS_MASK = [...RATING_STATS_FIELDS].sort();
const noSleep = () => Promise.resolve();

function clock(start = T0) {
  let time = start.getTime();
  return {
    now: () => new Date(time),
    advance: (ms = FEEDBACK_EDIT_COOLDOWN_MS) => {
      time += ms;
    },
  };
}

function world(
  options: { course?: Record<string, unknown>; teacherCopy?: boolean } = {},
) {
  const db = new FakeFirestore();
  db.seed(coursePath(COURSE), {
    id: COURSE,
    title: "Math",
    state: "Published",
    price: 170,
    feedBacksCount: 0,
    contentcreaterentity: { id: TEACHER, name: "Mohamed Ashref" },
    ...options.course,
  });
  if (options.teacherCopy !== false) {
    db.seed(teacherCoursePath(TEACHER, COURSE), {
      id: COURSE,
      title: "Math",
      feedBacksCount: 0,
    });
  }
  db.seed(userPath(TEACHER), {
    uid: TEACHER,
    role: "Teacher",
    status: "Active",
    firstName: "Mohamed",
  });
  db.seed(userPath(ADMIN), { uid: ADMIN, role: "Admin" });
  return db;
}

function addStudent(
  db: FakeFirestore,
  uid: string,
  options: { status?: string; enrolled?: boolean; subscribed?: boolean } = {},
) {
  db.seed(userPath(uid), {
    uid,
    role: "Student",
    status: options.status ?? "Active",
    firstName: "Ziad",
    lastName: "Gamal",
    profilePicurl: `https://img.example/${uid}.png`,
  });
  // The enrollment is a stale snapshot of the course, like checkout writes it.
  if (options.enrolled !== false) {
    db.seed(enrollPath(uid, COURSE), {
      id: COURSE,
      title: "Math",
      feedBacksCount: 0,
    });
  }
  if (options.subscribed !== false) {
    db.seed(subscriberPath(COURSE, uid), { id: uid });
  }
}

function rate(
  db: FeedbackStore,
  uid: string,
  body: Record<string, unknown>,
  time = clock(),
  maxAttempts?: number,
) {
  return upsertCourseFeedback(db, uid, { courseId: COURSE, ...body }, {
    now: time.now,
    sleep: noSleep,
    maxAttempts,
  });
}

function remove(db: FeedbackStore, uid: string, body: Record<string, unknown>) {
  return deleteCourseFeedback(db, uid, { courseId: COURSE, ...body }, {
    sleep: noSleep,
  });
}

function canonical(value: unknown): string {
  if (value instanceof Date) return JSON.stringify(value.toISOString());
  if (Array.isArray(value)) return `[${value.map(canonical).join(",")}]`;
  if (value && typeof value === "object") {
    return `{${
      Object.entries(value as Record<string, unknown>)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([k, v]) => `${JSON.stringify(k)}:${canonical(v)}`)
        .join(",")
    }}`;
  }
  return JSON.stringify(value);
}

function expectEqual(actual: unknown, expected: unknown, label: string) {
  if (canonical(actual) !== canonical(expected)) {
    throw new Error(
      `${label}\n  expected: ${canonical(expected)}\n  actual:   ${
        canonical(actual)
      }`,
    );
  }
}

async function expectRejects(
  promise: Promise<unknown>,
  code: string,
  label: string,
) {
  try {
    await promise;
  } catch (error) {
    if (error instanceof Error && error.message === code) return;
    throw new Error(`${label}: rejected with ${String(error)}, wanted ${code}`);
  }
  throw new Error(`${label}: resolved, wanted ${code}`);
}

/** Stored stats on the course and teacher copy must equal a full recount. */
function expectConsistent(db: FakeFirestore, label: string) {
  const expected = rebuildRatingStats(
    db.list(`${coursePath(COURSE)}/Feedbacks`),
  );
  const pick = (data: Record<string, unknown> | null) =>
    readCourseRatingStats(data);
  expectEqual(pick(db.data(coursePath(COURSE))), expected, `${label}: course`);
  if (db.data(teacherCoursePath(TEACHER, COURSE))) {
    expectEqual(
      pick(db.data(teacherCoursePath(TEACHER, COURSE))),
      expected,
      `${label}: teacher copy`,
    );
  }
  // Stored averages are written by the server, so compare them too.
  const stored = db.data(coursePath(COURSE))!;
  if ((stored.averageRating ?? 0) !== expected.averageRating) {
    throw new Error(`${label}: stored averageRating is stale`);
  }
}

// ---------------------------------------------------------------------------
// Upsert: behaviour
// ---------------------------------------------------------------------------

Deno.test("first rating writes feedback, course, teacher copy and myRating in one commit", async () => {
  const db = world();
  addStudent(db, "s1");
  const result = await rate(db, "s1", {
    rating: 5,
    text: "  مدرس ممتاز  ",
    teacherId: TEACHER,
  });

  expectEqual(db.calls.commit, 1, "single commit");
  expectEqual(db.commits[0], [
    { path: feedbackPath(COURSE, "s1"), kind: "create" },
    { path: coursePath(COURSE), kind: "update", mask: STATS_MASK },
    {
      path: teacherCoursePath(TEACHER, COURSE),
      kind: "update",
      mask: STATS_MASK,
    },
    { path: enrollPath("s1", COURSE), kind: "update", mask: ["myRating"] },
  ], "writes");

  expectEqual(db.data(feedbackPath(COURSE, "s1")), {
    uid: "s1",
    name: "Ziad Gamal",
    userImage: "https://img.example/s1.png",
    fedBack: "مدرس ممتاز",
    rating: 5,
    datePosted: T0,
    updatedAt: T0,
  }, "feedback doc");
  expectEqual(db.data(enrollPath("s1", COURSE))!.myRating, 5, "myRating");
  expectEqual(result.created, true, "created");
  expectEqual(result.stats.averageRating, 5, "average");
  expectEqual(result.feedback.datePosted, T0.toISOString(), "response date");
  // Untouched course fields survive the masked update.
  expectEqual(db.data(coursePath(COURSE))!.price, 170, "price kept");
  expectConsistent(db, "after first rating");
});

Deno.test("changing a rating keeps datePosted and uid and swaps the stats", async () => {
  const db = world();
  addStudent(db, "s1");
  addStudent(db, "s2");
  const time = clock();
  await rate(db, "s1", { rating: 5 }, time);
  await rate(db, "s2", { rating: 4 }, time);
  time.advance();
  const result = await rate(db, "s1", { rating: 2, text: "changed" }, time);

  const doc = db.data(feedbackPath(COURSE, "s1"))!;
  expectEqual(doc.datePosted, T0, "datePosted kept");
  expectEqual(doc.uid, "s1", "uid kept");
  expectEqual(doc.rating, 2, "new rating");
  expectEqual(
    doc.updatedAt,
    new Date(T0.getTime() + FEEDBACK_EDIT_COOLDOWN_MS),
    "updatedAt",
  );
  expectEqual(result.created, false, "edit");
  expectEqual(result.stats.ratingsCount, 2, "count unchanged");
  expectEqual(result.stats.averageRating, 3, "(2 + 4) / 2");
  expectEqual(result.stats.ratingDistribution, {
    "1": 0,
    "2": 1,
    "3": 0,
    "4": 1,
    "5": 0,
  }, "distribution");
  expectConsistent(db, "after edit");
});

Deno.test("editing only the text writes just the feedback document", async () => {
  const db = world();
  addStudent(db, "s1");
  const time = clock();
  await rate(db, "s1", { rating: 4, text: "good" }, time);
  const courseVersion = db.version(coursePath(COURSE));
  const copyVersion = db.version(teacherCoursePath(TEACHER, COURSE));
  db.resetCounters();
  time.advance();

  await rate(db, "s1", { rating: 4, text: "very good" }, time);
  expectEqual(db.commits[0], [{
    path: feedbackPath(COURSE, "s1"),
    kind: "update",
    mask: ["fedBack", "name", "rating", "updatedAt", "userImage"],
  }], "only the feedback is written");
  expectEqual(db.version(coursePath(COURSE)), courseVersion, "course");
  expectEqual(
    db.version(teacherCoursePath(TEACHER, COURSE)),
    copyVersion,
    "teacher copy",
  );
  if (db.readWaves.flat().includes(teacherCoursePath(TEACHER, COURSE))) {
    throw new Error("Teacher copy was read although stats did not change.");
  }
  expectEqual(
    db.data(feedbackPath(COURSE, "s1"))!.fedBack,
    "very good",
    "text",
  );
});

Deno.test("a legacy text-only feedback gets a rating without being counted twice", async () => {
  const db = world({ course: { feedBacksCount: 2 } });
  addStudent(db, "s1");
  db.seed(feedbackPath(COURSE, "s1"), {
    uid: "s1",
    name: "Ziad Gamal",
    userImage: "",
    fedBack: "old review",
    datePosted: new Date("2026-09-06T12:00:00Z"),
  });
  db.seed(feedbackPath(COURSE, "legacy-2"), {
    uid: "legacy-2",
    fedBack: "another old one",
    datePosted: new Date("2026-09-07T12:00:00Z"),
  });

  const result = await rate(db, "s1", { rating: 3, text: "old review" });
  expectEqual(result.created, false, "existing doc");
  expectEqual(result.stats.feedBacksCount, 2, "feedBacksCount unchanged");
  expectEqual(result.stats.ratingsCount, 1, "now rated");
  expectEqual(
    db.data(feedbackPath(COURSE, "s1"))!.datePosted,
    new Date("2026-09-06T12:00:00Z"),
    "original date kept",
  );
  expectConsistent(db, "legacy rated");
});

Deno.test("rating succeeds when the teacher copy is missing", async () => {
  const db = world({ teacherCopy: false });
  addStudent(db, "s1");
  await rate(db, "s1", { rating: 4 });
  if (
    db.commits[0].some((w) => w.path === teacherCoursePath(TEACHER, COURSE))
  ) {
    throw new Error("Wrote a teacher copy that did not exist.");
  }
  expectEqual(db.data(teacherCoursePath(TEACHER, COURSE)), null, "not created");
  expectConsistent(db, "no teacher copy");
});

Deno.test("saving twice within the cooldown is rejected without writes", async () => {
  const db = world();
  addStudent(db, "s1");
  const time = clock();
  await rate(db, "s1", { rating: 4 }, time);
  db.resetCounters();
  time.advance(FEEDBACK_EDIT_COOLDOWN_MS - 1);
  await expectRejects(
    rate(db, "s1", { rating: 5 }, time),
    "too_many_requests",
    "double tap",
  );
  expectEqual(db.calls.commit, 0, "no commit");
  expectEqual(db.calls.rollback, 1, "locks released");
  time.advance(1);
  await rate(db, "s1", { rating: 5 }, time);
  expectEqual(db.data(feedbackPath(COURSE, "s1"))!.rating, 5, "after cooldown");
});

// ---------------------------------------------------------------------------
// Upsert: authorization
// ---------------------------------------------------------------------------

Deno.test("only active, subscribed students of a published course can rate", async () => {
  const cases: Array<
    [string, (db: FakeFirestore) => string, string]
  > = [
    ["not enrolled", (db) => {
      addStudent(db, "s1", { enrolled: false });
      return "s1";
    }, "not_subscribed"],
    ["enrollment without subscriber record", (db) => {
      addStudent(db, "s1", { subscribed: false });
      return "s1";
    }, "not_subscribed"],
    ["blocked student", (db) => {
      addStudent(db, "s1", { status: "Blocked" });
      return "s1";
    }, "inactive_user"],
    ["course owner", () => TEACHER, "own_course"],
    ["another teacher", (db) => {
      db.seed(userPath("teacher-2"), { role: "Teacher", status: "Active" });
      db.seed(enrollPath("teacher-2", COURSE), { id: COURSE });
      db.seed(subscriberPath(COURSE, "teacher-2"), { id: "teacher-2" });
      return "teacher-2";
    }, "not_student"],
    ["admin", () => ADMIN, "inactive_user"],
    ["unpublished course", (db) => {
      db.seed(coursePath(COURSE), {
        state: "Pending",
        contentcreaterentity: { id: TEACHER },
      });
      addStudent(db, "s1");
      return "s1";
    }, "course_unavailable"],
    ["unknown user", () => "ghost", "not_found"],
  ];
  for (const [label, setup, code] of cases) {
    const db = world();
    const uid = setup(db);
    db.resetCounters();
    await expectRejects(rate(db, uid, { rating: 5 }), code, label);
    expectEqual(db.calls.commit, 0, `${label}: no commit`);
    expectEqual(db.calls.rollback, 1, `${label}: rolled back`);
    expectEqual(db.openTransactions, 0, `${label}: no open transaction`);
    expectEqual(db.data(feedbackPath(COURSE, uid)), null, `${label}: no doc`);
  }

  const missing = world();
  addStudent(missing, "s1");
  await expectRejects(
    upsertCourseFeedback(missing, "s1", { courseId: "nope", rating: 5 }, {
      sleep: noSleep,
    }),
    "not_found",
    "missing course",
  );
});

// ---------------------------------------------------------------------------
// Security
// ---------------------------------------------------------------------------

Deno.test("invalid input is rejected before any Firestore call", async () => {
  const cases: Array<[Record<string, unknown>, string]> = [
    [{ rating: 0 }, "invalid_rating"],
    [{ rating: 6 }, "invalid_rating"],
    [{ rating: "5" }, "invalid_rating"],
    [{ rating: 4.5 }, "invalid_rating"],
    [{}, "invalid_rating"],
    [{ rating: 5, text: "x".repeat(501) }, "text_too_long"],
    [{ rating: 5, text: { $gt: "" } }, "invalid_text"],
    [{ rating: 5, courseId: "a/b" }, "invalid_course_id"],
    [{ rating: 5, courseId: ".." }, "invalid_course_id"],
    [{ rating: 5, courseId: "" }, "invalid_course_id"],
    [{ rating: 5, courseId: 42 }, "invalid_course_id"],
  ];
  for (const [body, code] of cases) {
    const db = world();
    addStudent(db, "s1");
    db.resetCounters();
    await expectRejects(rate(db, "s1", body), code, canonical(body));
    expectEqual(db.calls, { begin: 0, get: 0, commit: 0, rollback: 0 }, code);
  }
});

Deno.test("a caller uid that could change a path is refused", async () => {
  const db = world();
  for (const uid of ["a/b", "../x", "", "x".repeat(161)]) {
    await expectRejects(rate(db, uid, { rating: 5 }), "unauthorized", uid);
    await expectRejects(remove(db, uid, {}), "unauthorized", uid);
  }
  expectEqual(db.calls.begin, 0, "no transaction");
});

Deno.test("client cannot set name, image, stats, uid or dates", async () => {
  const db = world();
  addStudent(db, "s1");
  const result = await rate(db, "s1", {
    rating: 5,
    name: "Admin",
    userImage: "https://evil.example/x.png",
    uid: "someone-else",
    datePosted: "2020-01-01",
    ratingsSum: 9999,
    averageRating: 5,
    feedBacksCount: -100,
  });
  const doc = db.data(feedbackPath(COURSE, "s1"))!;
  expectEqual(
    Object.keys(doc).sort(),
    [
      "datePosted",
      "fedBack",
      "name",
      "rating",
      "uid",
      "updatedAt",
      "userImage",
    ],
    "only server fields",
  );
  expectEqual(doc.name, "Ziad Gamal", "name from Users doc");
  expectEqual(doc.userImage, "https://img.example/s1.png", "image from Users");
  expectEqual(doc.uid, "s1", "uid from token");
  expectEqual(db.data(feedbackPath(COURSE, "someone-else")), null, "no spoof");
  expectEqual(result.stats.ratingsSum, 5, "stats not injectable");
  expectConsistent(db, "injection");
});

Deno.test("a wrong or malicious teacherId hint never redirects writes", async () => {
  for (const hint of ["teacher-2", "s1", "x/../../Users", 7, ""]) {
    const db = world();
    addStudent(db, "s1");
    db.seed(teacherCoursePath("teacher-2", COURSE), { feedBacksCount: 0 });
    const decoyVersion = db.version(teacherCoursePath("teacher-2", COURSE));
    await rate(db, "s1", { rating: 4, teacherId: hint });
    expectEqual(
      db.version(teacherCoursePath("teacher-2", COURSE)),
      decoyVersion,
      `decoy untouched for ${String(hint)}`,
    );
    expectEqual(
      readCourseRatingStats(db.data(teacherCoursePath(TEACHER, COURSE)))
        .ratingsCount,
      1,
      `real teacher copy updated for ${String(hint)}`,
    );
    expectConsistent(db, `hint ${String(hint)}`);
  }
});

// ---------------------------------------------------------------------------
// Concurrency and retries
// ---------------------------------------------------------------------------

Deno.test("contention is retried and the final stats are correct", async () => {
  const db = world();
  addStudent(db, "s1");
  db.beforeCommit = (n) => {
    if (n === 1) db.touch(coursePath(COURSE)); // someone wrote the course
  };
  await rate(db, "s1", { rating: 4 });
  expectEqual(db.calls.begin, 2, "two attempts");
  expectEqual(db.calls.commit, 2, "second commit wins");
  expectEqual(db.calls.rollback, 0, "failed commit needs no rollback");
  expectConsistent(db, "after retry");
});

Deno.test("persistent contention gives up with busy after 3 attempts and backs off", async () => {
  const db = world();
  addStudent(db, "s1");
  db.beforeCommit = () => db.touch(coursePath(COURSE));
  const waits: number[] = [];
  await expectRejects(
    upsertCourseFeedback(db, "s1", { courseId: COURSE, rating: 4 }, {
      now: clock().now,
      sleep: (ms) => {
        waits.push(ms);
        return Promise.resolve();
      },
      random: () => 0.5,
    }),
    "busy",
    "busy",
  );
  expectEqual(db.calls.begin, 3, "3 attempts");
  expectEqual(waits, [75, 125], "jittered exponential backoff");
  expectEqual(db.data(feedbackPath(COURSE, "s1")), null, "nothing written");
  expectEqual(db.openTransactions, 0, "no leaked transaction");
});

Deno.test("unexpected Firestore errors are not retried and release the transaction", async () => {
  const db = world();
  addStudent(db, "s1");
  db.failGet = (path) =>
    path === coursePath(COURSE)
      ? new Error("Firestore read failed (500).")
      : null;
  await expectRejects(
    rate(db, "s1", { rating: 4 }),
    "Firestore read failed (500).",
    "500",
  );
  expectEqual(db.calls.begin, 1, "no retry");
  expectEqual(db.calls.rollback, 1, "rolled back");
});

Deno.test("40 students rating at the same time never lose an update", async () => {
  for (const seed of [1, 2, 3]) {
    let state = seed;
    const random = () => {
      state = (state * 1103515245 + 12345) % 2147483648;
      return state / 2147483648;
    };
    const db = world();
    db.latency = () => Math.floor(random() * 3);
    const students = Array.from({ length: 40 }, (_, i) => `s${i}`);
    students.forEach((uid) => addStudent(db, uid));

    await Promise.all(
      students.map((uid, i) =>
        rate(db, uid, { rating: (i % 5) + 1 }, clock(), 200)
      ),
    );
    expectConsistent(db, `seed ${seed}`);
    expectEqual(
      readCourseRatingStats(db.data(coursePath(COURSE))).ratingsCount,
      40,
      `seed ${seed}: all counted`,
    );
    if (db.calls.begin <= students.length) {
      throw new Error(`seed ${seed}: no contention was exercised`);
    }
  }
});

Deno.test("with the production retry limit, contention may say busy but never corrupts stats", async () => {
  const db = world();
  db.latency = () => 1;
  const students = Array.from({ length: 30 }, (_, i) => `s${i}`);
  students.forEach((uid) => addStudent(db, uid));
  const outcomes = await Promise.allSettled(
    students.map((uid) => rate(db, uid, { rating: 4 })),
  );
  for (const outcome of outcomes) {
    if (
      outcome.status === "rejected" &&
      !(outcome.reason instanceof Error && outcome.reason.message === "busy")
    ) throw outcome.reason;
  }
  if (!outcomes.some((outcome) => outcome.status === "fulfilled")) {
    throw new Error("No rating succeeded under contention.");
  }
  expectConsistent(db, "partial success");
  expectEqual(db.openTransactions, 0, "no leaked transactions");
});

// ---------------------------------------------------------------------------
// Performance: round trips and reads per request
// ---------------------------------------------------------------------------

Deno.test("new rating with the teacherId hint: 1 read round trip, 6 reads, 1 commit", async () => {
  const db = world();
  addStudent(db, "s1");
  db.resetCounters();
  await rate(db, "s1", { rating: 5, teacherId: TEACHER });
  expectEqual(db.readWaves.length, 1, "read round trips");
  expectEqual(db.calls, { begin: 1, get: 6, commit: 1, rollback: 0 }, "calls");
});

Deno.test("new rating without the hint costs one extra round trip, not more", async () => {
  const db = world();
  addStudent(db, "s1");
  db.resetCounters();
  await rate(db, "s1", { rating: 5 });
  expectEqual(db.readWaves.length, 2, "read round trips");
  expectEqual(db.readWaves[1], [teacherCoursePath(TEACHER, COURSE)], "wave 2");
  expectEqual(db.calls, { begin: 1, get: 6, commit: 1, rollback: 0 }, "calls");
});

Deno.test("delete with the hint: 1 read round trip, 5 reads, 1 commit", async () => {
  const db = world();
  addStudent(db, "s1");
  await rate(db, "s1", { rating: 5 });
  db.resetCounters();
  await remove(db, "s1", { teacherId: TEACHER });
  expectEqual(db.readWaves.length, 1, "read round trips");
  expectEqual(db.calls, { begin: 1, get: 5, commit: 1, rollback: 0 }, "calls");
});

// ---------------------------------------------------------------------------
// Delete
// ---------------------------------------------------------------------------

Deno.test("a student deletes their own rating and every stat follows", async () => {
  const db = world();
  addStudent(db, "s1");
  addStudent(db, "s2");
  await rate(db, "s1", { rating: 5 });
  await rate(db, "s2", { rating: 2 });
  const result = await remove(db, "s1", {});

  expectEqual(db.data(feedbackPath(COURSE, "s1")), null, "feedback deleted");
  expectEqual(result.stats?.ratingsCount, 1, "count");
  expectEqual(result.stats?.averageRating, 2, "average");
  if ("myRating" in db.data(enrollPath("s1", COURSE))!) {
    throw new Error("myRating was not cleared.");
  }
  expectEqual(
    db.data(enrollPath("s1", COURSE))!.title,
    "Math",
    "snapshot kept",
  );
  expectConsistent(db, "after delete");
});

Deno.test("students cannot delete someone else's feedback, even to probe if it exists", async () => {
  const db = world();
  addStudent(db, "s1");
  addStudent(db, "s2");
  await rate(db, "s2", { rating: 1 });
  db.resetCounters();
  await expectRejects(
    remove(db, "s1", { feedbackUid: "s2" }),
    "forbidden",
    "existing",
  );
  await expectRejects(
    remove(db, "s1", { feedbackUid: "nobody" }),
    "forbidden",
    "missing",
  );
  expectEqual(db.calls.commit, 0, "no commit");
  expectEqual(db.data(feedbackPath(COURSE, "s2"))!.rating, 1, "still there");
});

Deno.test("the course teacher and blocked students cannot delete; admins can", async () => {
  const db = world();
  addStudent(db, "s1");
  await rate(db, "s1", { rating: 1 });
  await expectRejects(
    remove(db, TEACHER, { feedbackUid: "s1" }),
    "forbidden",
    "teacher",
  );
  db.seed(userPath("s1"), { role: "Student", status: "Blocked" });
  await expectRejects(remove(db, "s1", {}), "forbidden", "blocked owner");

  const result = await remove(db, ADMIN, { feedbackUid: "s1" });
  expectEqual(result.stats?.ratingsCount, 0, "admin deleted");
  expectEqual(result.stats?.averageRating, 0, "average reset");
  expectConsistent(db, "admin delete");
});

Deno.test("deleting a missing, legacy or orphaned feedback", async () => {
  const db = world({ course: { feedBacksCount: 1 } });
  addStudent(db, "s1");
  await expectRejects(remove(db, "s1", {}), "feedback_not_found", "missing");

  db.seed(feedbackPath(COURSE, "legacy"), { uid: "legacy", fedBack: "old" });
  const legacy = await remove(db, ADMIN, { feedbackUid: "legacy" });
  expectEqual(legacy.stats?.feedBacksCount, 0, "legacy lowers count only");
  expectEqual(legacy.stats?.ratingsCount, 0, "no rating change");

  // Course deleted but its Feedbacks subcollection remains.
  const orphan = world();
  orphan.seed(feedbackPath(COURSE, "x"), { uid: "x", rating: 5 });
  orphan.drop(coursePath(COURSE));
  const result = await remove(orphan, ADMIN, { feedbackUid: "x" });
  expectEqual(result.stats, null, "no stats without a course");
  expectEqual(orphan.data(feedbackPath(COURSE, "x")), null, "orphan deleted");
});

Deno.test("invalid feedbackUid is rejected before any Firestore call", async () => {
  const db = world();
  for (const feedbackUid of ["a/b", "", 5, "x".repeat(161)]) {
    await expectRejects(
      remove(db, ADMIN, { feedbackUid }),
      "invalid_feedback_id",
      String(feedbackUid),
    );
  }
  expectEqual(db.calls.begin, 0, "no transaction");
});

Deno.test("random rate/edit/delete sequences keep course and teacher copy exact", async () => {
  const db = world();
  const time = clock();
  const students = Array.from({ length: 12 }, (_, i) => `s${i}`);
  students.forEach((uid) => addStudent(db, uid));
  let state = 2026;
  const random = () => {
    state = (state * 1103515245 + 12345) % 2147483648;
    return state / 2147483648;
  };
  for (let step = 0; step < 400; step++) {
    time.advance();
    const uid = students[Math.floor(random() * students.length)];
    const exists = db.data(feedbackPath(COURSE, uid)) !== null;
    if (exists && random() < 0.3) {
      await remove(db, random() < 0.5 ? uid : ADMIN, { feedbackUid: uid });
    } else {
      await rate(db, uid, { rating: 1 + Math.floor(random() * 5) }, time);
    }
    expectConsistent(db, `step ${step}`);
  }
});

// ---------------------------------------------------------------------------
// HTTP layer
// ---------------------------------------------------------------------------

function handlerWith(
  db: FeedbackStore,
  options: { uid?: string; authFails?: boolean } = {},
) {
  const logged: Array<[string, Record<string, unknown>]> = [];
  let storesCreated = 0;
  const handler = createFeedbackHandler(
    "upsert_course_feedback",
    (store, uid, body) =>
      upsertCourseFeedback(store, uid, body, { sleep: noSleep }),
    {
      authenticate: () =>
        options.authFails
          ? Promise.reject(new Error("unauthorized"))
          : Promise.resolve(options.uid ?? "s1"),
      store: () => {
        storesCreated++;
        return db;
      },
      logError: (event, details) => logged.push([event, details]),
    },
  );
  return { handler, logged, storesCreated: () => storesCreated };
}

const post = (body: BodyInit, headers: Record<string, string> = {}) =>
  new Request("http://localhost/upsert-course-feedback", {
    method: "POST",
    body,
    headers: { "content-type": "application/json", ...headers },
  });

Deno.test("HTTP: CORS preflight, method guard and authentication come first", async () => {
  const db = world();
  const { handler, storesCreated } = handlerWith(db, { authFails: true });

  const preflight = await handler(
    new Request("http://localhost/x", { method: "OPTIONS" }),
  );
  expectEqual(preflight.status, 200, "preflight");
  expectEqual(
    preflight.headers.get("access-control-allow-headers"),
    "authorization, apikey, content-type",
    "cors headers",
  );

  const get = await handler(new Request("http://localhost/x"));
  expectEqual(get.status, 405, "GET");

  const unauthorized = await handler(post(JSON.stringify({ rating: 5 })));
  expectEqual(unauthorized.status, 401, "no token");
  expectEqual((await unauthorized.json()).error.code, "unauthorized", "code");
  expectEqual(storesCreated(), 0, "no Firestore client for anonymous calls");
});

Deno.test("HTTP: success returns the saved feedback and live stats", async () => {
  const db = world();
  addStudent(db, "s1");
  const { handler } = handlerWith(db);
  const response = await handler(
    post(JSON.stringify({ courseId: COURSE, rating: 4, text: "حلو" })),
  );
  expectEqual(response.status, 200, "status");
  expectEqual(
    response.headers.get("content-type"),
    "application/json",
    "type",
  );
  expectEqual(response.headers.get("access-control-allow-origin"), "*", "cors");
  const body = await response.json();
  expectEqual(body.ok, true, "ok");
  expectEqual(body.created, true, "created");
  expectEqual(body.feedback.fedBack, "حلو", "text");
  expectEqual(body.stats.averageRating, 4, "stats");
});

Deno.test("HTTP: domain errors map to their status; internals never leak", async () => {
  const db = world();
  addStudent(db, "s1", { subscribed: false });
  const { handler, logged } = handlerWith(db);
  const forbidden = await handler(
    post(JSON.stringify({ courseId: COURSE, rating: 4 })),
  );
  expectEqual(forbidden.status, 403, "not subscribed");
  expectEqual((await forbidden.json()).error.code, "not_subscribed", "code");
  expectEqual(logged.length, 0, "expected errors are not logged");

  db.failGet = () => new Error("Firestore read failed (500).");
  const failed = await handler(
    post(JSON.stringify({ courseId: COURSE, rating: 4 })),
  );
  expectEqual(failed.status, 500, "internal");
  const text = await failed.text();
  if (text.includes("Firestore") || text.includes(COURSE)) {
    throw new Error(`Internal details leaked: ${text}`);
  }
  expectEqual(logged, [["upsert_course_feedback_failed", {
    reason: "Firestore read failed (500).",
  }]], "logged once, without request data");
});

Deno.test("HTTP: malformed, non-object, invalid UTF-8 and oversized bodies", async () => {
  const db = world();
  addStudent(db, "s1");
  const { handler } = handlerWith(db);
  for (
    const [body, status, code] of [
      ["{not json", 400, "invalid_body"],
      ["[1,2]", 400, "invalid_body"],
      ["null", 400, "invalid_body"],
      [new Uint8Array([0x7b, 0xff, 0xfe, 0x7d]), 400, "invalid_body"],
      ["", 400, "invalid_body"],
    ] as Array<[BodyInit, number, string]>
  ) {
    const response = await handler(post(body));
    expectEqual(response.status, status, `status for ${String(body)}`);
    expectEqual((await response.json()).error.code, code, `code`);
  }

  const declared = await handler(
    post("{}", { "content-length": String(MAX_BODY_BYTES + 1) }),
  );
  expectEqual(declared.status, 413, "declared too large");

  // No content-length: the stream is cut off at the limit, not read fully.
  let chunksPulled = 0;
  const stream = new ReadableStream<Uint8Array>({
    pull(controller) {
      chunksPulled++;
      if (chunksPulled > 1000) controller.close();
      else controller.enqueue(new Uint8Array(1024).fill(0x20));
    },
  });
  const streamed = await handler(
    new Request("http://localhost/x", { method: "POST", body: stream }),
  );
  expectEqual(streamed.status, 413, "streamed too large");
  if (chunksPulled > 40) {
    throw new Error(`Read ${chunksPulled} KB before refusing the body.`);
  }
  expectEqual(db.calls.begin, 0, "no Firestore work for bad bodies");
});

Deno.test("readJsonBody accepts a body exactly at the limit", async () => {
  const padding = " ".repeat(MAX_BODY_BYTES - 2);
  const body = await readJsonBody(post(`{}${padding}`));
  expectEqual(body, {}, "at limit");
});

Deno.test("reusableStore reuses one client per isolate and renews it before token expiry", () => {
  let now = 0;
  let created = 0;
  const factory = reusableStore(
    () => {
      created++;
      return new FakeFirestore();
    },
    1000,
    () => now,
  );
  const a = factory();
  now = 999;
  if (factory() !== a) throw new Error("Not reused within the TTL.");
  now = 1000;
  if (factory() === a) throw new Error("Not renewed after the TTL.");
  expectEqual(created, 2, "created twice");

  let attempts = 0;
  const failing = reusableStore(() => {
    attempts++;
    throw new Error("Missing required server secret: FB_PROJECT_ID");
  });
  for (let i = 0; i < 2; i++) {
    try {
      failing();
    } catch { /* expected */ }
  }
  expectEqual(attempts, 2, "a failed creation is not cached");
});

Deno.test("runInTransaction commits an empty plan and returns its result", async () => {
  const db = new FakeFirestore();
  const result = await runInTransaction(
    db,
    () => Promise.resolve({ writes: [], result: 42 }),
  );
  expectEqual(result, 42, "result");
  expectEqual(db.calls, { begin: 1, get: 0, commit: 1, rollback: 0 }, "calls");
});
