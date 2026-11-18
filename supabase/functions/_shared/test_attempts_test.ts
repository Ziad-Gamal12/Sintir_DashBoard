import { FakeFirestore } from "./test_support/fake_firestore.ts";
import {
  type AttemptStore,
  gradeAttempt,
  parseAnswers,
  parseKeyQuestions,
  publicQuestions,
  submitTestAttempt,
  testAttemptSafeError,
} from "./test_attempts.ts";
import { canUseCourseContent } from "./course_access.ts";

class FakeAttemptStore extends FakeFirestore implements AttemptStore {
  countMatching(
    parentPath: string,
    collectionId: string,
    fieldPath: string,
    value: string,
    limit: number,
  ): Promise<number> {
    const [outer, inner] = fieldPath.split(".");
    const count = this.list(`${parentPath}/${collectionId}`).filter((doc) => {
      const field = doc[outer] as Record<string, unknown> | string | undefined;
      const actual = inner === undefined
        ? field
        : (field as Record<string, unknown> | undefined)?.[inner];
      return actual === value;
    }).length;
    return Promise.resolve(Math.min(count, limit));
  }
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

function assertEquals(actual: unknown, expected: unknown, message: string) {
  const a = JSON.stringify(actual);
  const e = JSON.stringify(expected);
  if (a !== e) throw new Error(`${message}\nexpected ${e}\nactual   ${a}`);
}

async function rejectsWith(promise: Promise<unknown>, code: string) {
  try {
    await promise;
  } catch (error) {
    assertEquals((error as Error).message, code, "error code");
    return;
  }
  throw new Error(`expected rejection with ${code}`);
}

const NOW = new Date("2026-11-18T10:00:00.000Z");
const COURSE = "math-101";
const SECTION = "s1";
const TEST = "t1";
const ITEM = `Courses/${COURSE}/Sections/${SECTION}/Items/${TEST}`;
const KEY = `${ITEM}/Private/answerKey`;

const keyQuestions = [
  {
    questionId: "q1",
    questionTitle: "2 + 2",
    imageUrl: null,
    solutionUrl: "https://example.com/why.png",
    isOpened: false,
    solutions: [
      { answer: "3", isCorrect: false },
      { answer: "4", isCorrect: true },
    ],
  },
  {
    questionId: "q2",
    questionTitle: "3 x 3",
    imageUrl: null,
    solutionUrl: null,
    isOpened: false,
    solutions: [
      { answer: "6", isCorrect: false },
      { answer: "9", isCorrect: true },
    ],
  },
  {
    questionId: "q3",
    questionTitle: "10 / 2",
    imageUrl: null,
    solutionUrl: null,
    isOpened: false,
    solutions: [
      { answer: "5", isCorrect: true },
      { answer: "2", isCorrect: false },
    ],
  },
];

function seedCourse(
  db: FakeAttemptStore,
  options: {
    state?: string;
    numberOfAttempts?: number | null;
    showResult?: boolean;
    enrolled?: boolean;
    withKey?: boolean;
    role?: string;
  } = {},
) {
  db.seed("Users/student1", {
    role: options.role ?? "Student",
    status: "Active",
    fullName: "Sara Ali",
    profilePicurl: "https://example.com/sara.png",
  });
  db.seed(`Courses/${COURSE}`, {
    state: options.state ?? "Published",
    subject: "Math",
    contentcreaterentity: { id: "teacher1", name: "Mr T" },
  });
  if (options.enrolled ?? true) {
    db.seed(`Courses/${COURSE}/Subscribers/student1`, { id: "student1" });
    db.seed(`Users/student1/Courses/${COURSE}`, { id: COURSE });
  }
  db.seed(ITEM, {
    id: TEST,
    type: "Test",
    title: "Quiz 1",
    durationTime: 10,
    showResult: options.showResult ?? true,
    numberOfAttempts: options.numberOfAttempts === undefined
      ? 2
      : options.numberOfAttempts,
    questions: publicQuestions(keyQuestions),
  });
  if (options.withKey ?? true) db.seed(KEY, { questions: keyQuestions });
}

const body = (answers: Record<string, string | null>) => ({
  courseId: COURSE,
  sectionId: SECTION,
  testId: TEST,
  answers,
});
const opts = { now: () => NOW, sleep: () => Promise.resolve() };

Deno.test("grading counts only correct selected answers", () => {
  const grade = gradeAttempt(
    parseKeyQuestions(keyQuestions),
    parseAnswers({ q1: "4", q2: "6", q3: null }),
  );
  assertEquals(grade.score, 1, "score");
  assertEquals(grade.total, 3, "total");
  assertEquals(grade.solved, 2, "solved");
  assertEquals(grade.isPassed, false, "1 of 3 is not a pass");
  assertEquals(
    grade.wrongQuestions.map((q) => q.question.questionId),
    ["q2"],
    "wrong questions",
  );
});

Deno.test("public questions never carry correct flags or explanations", () => {
  const visible = publicQuestions(keyQuestions);
  const serialized = JSON.stringify(visible);
  assert(!serialized.includes("isCorrect"), "isCorrect leaked");
  assert(!serialized.includes("solutionUrl"), "solutionUrl leaked");
  assertEquals(visible[0].solutions, [{ answer: "3" }, { answer: "4" }], "answers kept");
});

Deno.test("answers must be a small map of strings", () => {
  for (const bad of [null, [], "x", { q1: 5 }, { q1: "a".repeat(5000) }]) {
    let failed = false;
    try {
      parseAnswers(bad);
    } catch (error) {
      failed = (error as Error).message === "invalid_answers";
    }
    assert(failed, `accepted ${JSON.stringify(bad)}`);
  }
});

Deno.test("enrolled student gets a server-graded result in both copies", async () => {
  const db = new FakeAttemptStore();
  seedCourse(db);
  const response = await submitTestAttempt(
    db,
    "student1",
    body({ q1: "4", q2: "9", q3: "2" }),
    opts,
  );
  const result = response.result as Record<string, unknown>;
  assertEquals(result.result, 2, "score");
  assertEquals(result.isPassed, true, "2 of 3 passes");
  assertEquals(result.serialNumber, "student1-attempt-1", "attempt id");
  assertEquals(result.teacherId, "teacher1", "teacher id for rules");
  const teacherCopy = db.data(`${ITEM}/Results/student1-attempt-1`)!;
  const studentCopy = db.data("Users/student1/MyResults/student1-attempt-1")!;
  assertEquals(teacherCopy.result, 2, "teacher copy score");
  assertEquals(studentCopy.result, 2, "student copy score");
  assertEquals(
    (studentCopy.joinedby as Record<string, unknown>).name,
    "Sara Ali",
    "student name from the profile, not the request",
  );
  const mistake = db.data("Users/student1/MyMistakes/q3")!;
  assertEquals(
    (mistake.progress as Record<string, unknown>).wrongCount,
    1,
    "wrong answer becomes a mistake",
  );
});

Deno.test("a second wrong answer increments the stored mistake", async () => {
  const db = new FakeAttemptStore();
  seedCourse(db);
  await submitTestAttempt(db, "student1", body({ q1: "3" }), opts);
  await submitTestAttempt(db, "student1", body({ q1: "3" }), opts);
  const mistake = db.data("Users/student1/MyMistakes/q1")!;
  assertEquals(
    (mistake.progress as Record<string, unknown>).wrongCount,
    2,
    "wrong count",
  );
});

Deno.test("attempt limit is enforced", async () => {
  const db = new FakeAttemptStore();
  seedCourse(db, { numberOfAttempts: 1 });
  await submitTestAttempt(db, "student1", body({ q1: "4" }), opts);
  await rejectsWith(
    submitTestAttempt(db, "student1", body({ q1: "4" }), opts),
    "max_attempts_reached",
  );
});

Deno.test("unlimited tests get time-based result ids", async () => {
  const db = new FakeAttemptStore();
  seedCourse(db, { numberOfAttempts: null });
  const response = await submitTestAttempt(db, "student1", body({}), opts);
  assertEquals(
    (response.result as Record<string, unknown>).serialNumber,
    `student1-${NOW.getTime()}`,
    "result id",
  );
});

Deno.test("hidden results keep the review out of the student's copy", async () => {
  const db = new FakeAttemptStore();
  seedCourse(db, { showResult: false });
  const response = await submitTestAttempt(
    db,
    "student1",
    body({ q1: "3" }),
    opts,
  );
  assertEquals(response.resultHidden, true, "flag");
  const studentCopy = db.data("Users/student1/MyResults/student1-attempt-1")!;
  assertEquals(studentCopy.questionsSolvedList, [], "no review for the student");
  const teacherCopy = db.data(`${ITEM}/Results/student1-attempt-1`)!;
  assertEquals(
    (teacherCopy.questionsSolvedList as unknown[]).length,
    1,
    "teacher still sees the details",
  );
  assertEquals(db.data("Users/student1/MyMistakes/q1"), null, "no mistakes leak answers");
});

Deno.test("only enrolled active students can submit", async () => {
  const notEnrolled = new FakeAttemptStore();
  seedCourse(notEnrolled, { enrolled: false });
  await rejectsWith(
    submitTestAttempt(notEnrolled, "student1", body({ q1: "4" }), opts),
    "not_subscribed",
  );

  const teacher = new FakeAttemptStore();
  seedCourse(teacher, { role: "Teacher" });
  await rejectsWith(
    submitTestAttempt(teacher, "student1", body({ q1: "4" }), opts),
    "not_student",
  );

  const takenDown = new FakeAttemptStore();
  seedCourse(takenDown, { state: "DeletedByAdmin" });
  await rejectsWith(
    submitTestAttempt(takenDown, "student1", body({ q1: "4" }), opts),
    "course_unavailable",
  );
});

Deno.test("enrolled students keep access while an edited course is in review", async () => {
  const db = new FakeAttemptStore();
  seedCourse(db, { state: "Pending" });
  const response = await submitTestAttempt(db, "student1", body({ q1: "4" }), opts);
  assertEquals((response.result as Record<string, unknown>).result, 1, "graded");
});

Deno.test("legacy tests without an answer key are still graded", async () => {
  const db = new FakeAttemptStore();
  seedCourse(db, { withKey: false });
  db.seed(ITEM, {
    id: TEST,
    type: "Test",
    title: "Old quiz",
    showResult: true,
    numberOfAttempts: null,
    questions: keyQuestions,
  });
  const response = await submitTestAttempt(db, "student1", body({ q1: "4" }), opts);
  assertEquals((response.result as Record<string, unknown>).result, 1, "graded");
});

Deno.test("bad ids and unknown failures map to safe errors", async () => {
  const db = new FakeAttemptStore();
  await rejectsWith(
    submitTestAttempt(db, "student1", { ...body({}), sectionId: "a/b" }, opts),
    "invalid_section_id",
  );
  assertEquals(testAttemptSafeError(new Error("boom")).status, 500, "unknown");
  assertEquals(
    testAttemptSafeError(new Error("max_attempts_reached")).status,
    409,
    "known",
  );
});

Deno.test("content access policy", () => {
  const base = {
    role: "Student",
    status: "Active",
    owner: false,
    courseState: "Published",
    hasEnrollment: true,
    hasSubscriber: true,
  };
  assert(canUseCourseContent(base), "enrolled student");
  assert(canUseCourseContent({ ...base, courseState: "DeletedByTeacher" }), "archived by teacher");
  assert(!canUseCourseContent({ ...base, courseState: "Archived" }), "hidden by admin");
  assert(!canUseCourseContent({ ...base, hasSubscriber: false }), "no subscriber doc");
  assert(!canUseCourseContent({ ...base, status: "Blocked" }), "blocked");
  assert(canUseCourseContent({ ...base, role: "Teacher", owner: true }), "owner");
  assert(!canUseCourseContent({ ...base, role: "Teacher" }), "other teacher");
  assert(canUseCourseContent({ ...base, role: "CoursesManager", hasEnrollment: false }), "staff");
});
