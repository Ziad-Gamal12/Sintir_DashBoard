// Course tests: server-side grading.
//
// The answer key lives in
//   Courses/{c}/Sections/{s}/Items/{t}/Private/answerKey   (teacher + server only)
// while the test item the student can read holds the questions without
// `isCorrect` or explanation images. A student submits only the selected
// answers; this module checks enrollment and the attempt limit, grades, and
// writes in one transaction:
//   Courses/{c}/Sections/{s}/Items/{t}/Results/{resultId}   teacher's copy
//   Users/{uid}/MyResults/{resultId}                         student's copy
//   Users/{uid}/MyMistakes/{questionId}                      wrong answers
// Result IDs are `{uid}-attempt-{n}` when attempts are limited, so two
// concurrent submissions cannot both take the last attempt.

import {
  coursePath,
  decodeFields,
  encode,
  enrollPath,
  requiredCourseId,
  subscriberPath,
  userPath,
} from "./course_checkout.ts";
import { type FeedbackStore, runInTransaction } from "./course_feedback.ts";
import { createWrite, updateWrite } from "./firebase.ts";
import {
  ADMIN_BLOCKED_STATES,
  answerKeyPath,
  canUseCourseContent,
  itemPath,
  pathSegment,
} from "./course_access.ts";
import type { SafeError } from "./authed_handler.ts";

export const MAX_QUESTIONS = 500;
export const MAX_ANSWER_LENGTH = 4000;
export const SUBMIT_MAX_BODY_BYTES = 256 * 1024;

export type AttemptStore = FeedbackStore & {
  /** How many documents in `{parentPath}/{collectionId}` have field == value (at most `limit`). */
  countMatching(
    parentPath: string,
    collectionId: string,
    fieldPath: string,
    value: string,
    limit: number,
  ): Promise<number>;
};

export type KeySolution = { answer: string; isCorrect: boolean };
export type KeyQuestion = {
  questionId: string;
  questionTitle: string;
  imageUrl: string | null;
  solutionUrl: string | null;
  solutions: KeySolution[];
};

export type GradedQuestion = {
  isCorrect: boolean;
  question: Record<string, unknown>;
};

export type Grade = {
  score: number;
  total: number;
  solved: number;
  isPassed: boolean;
  solvedQuestions: GradedQuestion[];
  wrongQuestions: GradedQuestion[];
};

const text = (value: unknown): string =>
  typeof value === "string" ? value : "";
const optionalText = (value: unknown): string | null =>
  typeof value === "string" && value.length > 0 ? value : null;

/** Reads questions (with `isCorrect`) from an answer key or a legacy test item. */
export function parseKeyQuestions(raw: unknown): KeyQuestion[] {
  if (!Array.isArray(raw)) return [];
  const questions: KeyQuestion[] = [];
  for (const entry of raw.slice(0, MAX_QUESTIONS)) {
    if (!entry || typeof entry !== "object") continue;
    const q = entry as Record<string, unknown>;
    const questionId = text(q.questionId);
    if (questionId.length === 0) continue;
    const solutions = Array.isArray(q.solutions)
      ? q.solutions
        .filter((s) => s && typeof s === "object")
        .map((s) => {
          const solution = s as Record<string, unknown>;
          return {
            answer: text(solution.answer),
            isCorrect: solution.isCorrect === true,
          };
        })
      : [];
    questions.push({
      questionId,
      questionTitle: text(q.questionTitle),
      imageUrl: optionalText(q.imageUrl),
      solutionUrl: optionalText(q.solutionUrl),
      solutions,
    });
  }
  return questions;
}

/** Body field `answers`: `{ [questionId]: selectedAnswerText }`. */
export function parseAnswers(raw: unknown): Map<string, string> {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new Error("invalid_answers");
  }
  const entries = Object.entries(raw as Record<string, unknown>);
  if (entries.length > MAX_QUESTIONS) throw new Error("invalid_answers");
  const answers = new Map<string, string>();
  for (const [questionId, value] of entries) {
    if (value === null || value === undefined) continue;
    if (typeof value !== "string" || value.length > MAX_ANSWER_LENGTH) {
      throw new Error("invalid_answers");
    }
    if (value.length > 0) answers.set(questionId, value);
  }
  return answers;
}

export function attemptsLimit(raw: unknown): number | null {
  return typeof raw === "number" && Number.isInteger(raw) && raw > 0
    ? raw
    : null;
}

/** Same scoring the app used: one point per question whose selected answer is a correct one. */
export function gradeAttempt(
  questions: KeyQuestion[],
  answers: Map<string, string>,
): Grade {
  const solvedQuestions: GradedQuestion[] = [];
  const wrongQuestions: GradedQuestion[] = [];
  let score = 0;
  for (const q of questions) {
    const selected = answers.get(q.questionId);
    if (selected === undefined) continue;
    const isCorrect = q.solutions.some((s) =>
      s.isCorrect && s.answer === selected
    );
    if (isCorrect) score++;
    const graded = {
      isCorrect,
      question: {
        questionId: q.questionId,
        questionTitle: q.questionTitle,
        imageUrl: q.imageUrl,
        solutionUrl: q.solutionUrl,
        isOpened: false,
        selectedSolution: selected,
        solutions: q.solutions.map((s) => ({
          answer: s.answer,
          isCorrect: s.isCorrect,
        })),
      },
    };
    solvedQuestions.push(graded);
    if (!isCorrect) wrongQuestions.push(graded);
  }
  const total = questions.length;
  return {
    score,
    total,
    solved: solvedQuestions.length,
    isPassed: total > 0 && score >= total / 2,
    solvedQuestions,
    wrongQuestions,
  };
}

/** Questions as the student may read them: no correct flags, no explanation images. */
export function publicQuestions(
  questions: Array<Record<string, unknown>>,
): Array<Record<string, unknown>> {
  return questions.map((q) => {
    const solutions = Array.isArray(q.solutions) ? q.solutions : [];
    return {
      questionId: text(q.questionId),
      questionTitle: text(q.questionTitle),
      imageUrl: optionalText(q.imageUrl),
      isOpened: false,
      selectedSolution: null,
      solutions: solutions
        .filter((s) => s && typeof s === "object")
        .map((s) => ({ answer: text((s as Record<string, unknown>).answer) })),
    };
  });
}

const MISTAKE_ID = /^[A-Za-z0-9_-]{1,160}$/;

function mistakeDocument(
  graded: GradedQuestion,
  courseId: string,
  sectionId: string,
  courseSubject: string,
  previous: Record<string, unknown> | null,
  now: Date,
): Record<string, unknown> {
  const progress = (previous?.progress ?? {}) as Record<string, unknown>;
  const wrongCount = typeof progress.wrongCount === "number"
    ? progress.wrongCount + 1
    : 1;
  return {
    question: graded,
    courseId,
    sectionId,
    courseSubject,
    progress: {
      questionId: graded.question.questionId,
      wrongCount,
      correctStreak: 0,
      lastAnsweredAt: now,
      status: "active",
    },
  };
}

function displayName(user: Record<string, unknown>): string {
  const full = text(user.fullName).trim();
  if (full.length > 0) return full;
  return `${text(user.firstName)} ${text(user.lastName)}`.trim();
}

export type SubmitOptions = {
  now?: () => Date;
  maxAttempts?: number;
  sleep?: (ms: number) => Promise<void>;
  random?: () => number;
};

export async function submitTestAttempt(
  db: AttemptStore,
  callerUid: string,
  body: Record<string, unknown>,
  options: SubmitOptions = {},
): Promise<Record<string, unknown>> {
  if (!MISTAKE_ID.test(callerUid)) throw new Error("unauthorized");
  const uid = callerUid;
  const courseId = requiredCourseId(body.courseId);
  const sectionId = pathSegment(body.sectionId, "section_id");
  const testId = pathSegment(body.testId, "test_id");
  const answers = parseAnswers(body.answers);
  const clock = options.now ?? (() => new Date());

  return await runInTransaction(db, async (transaction) => {
    const now = clock();
    const [userDoc, courseDoc, subscriberDoc, enrollmentDoc, itemDoc, keyDoc] =
      await Promise.all([
        db.get(userPath(uid), transaction),
        db.get(coursePath(courseId), transaction),
        db.get(subscriberPath(courseId, uid), transaction),
        db.get(enrollPath(uid, courseId), transaction),
        db.get(itemPath(courseId, sectionId, testId), transaction),
        db.get(answerKeyPath(courseId, sectionId, testId), transaction),
      ]);
    if (!userDoc || !courseDoc) throw new Error("not_found");
    const user = decodeFields(userDoc.fields);
    const course = decodeFields(courseDoc.fields);
    const role = text(user.role);
    const status = text(user.status);
    const state = text(course.state);
    if (status !== "Active") throw new Error("inactive_user");
    if (role !== "Student") throw new Error("not_student");
    const enrolled = subscriberDoc !== null && enrollmentDoc !== null;
    if (!enrolled) throw new Error("not_subscribed");
    if (
      !canUseCourseContent({
        role,
        status,
        owner: false,
        courseState: state,
        hasEnrollment: enrollmentDoc !== null,
        hasSubscriber: subscriberDoc !== null,
      })
    ) {
      throw new Error(
        ADMIN_BLOCKED_STATES.has(state) ? "course_unavailable" : "not_subscribed",
      );
    }
    if (!itemDoc) throw new Error("test_not_found");
    const item = decodeFields(itemDoc.fields);
    if (item.type !== "Test") throw new Error("test_not_found");
    const key = keyDoc ? decodeFields(keyDoc.fields) : null;
    const questions = parseKeyQuestions(key ? key.questions : item.questions);
    if (questions.length === 0) throw new Error("test_not_ready");

    const resultsParent = itemPath(courseId, sectionId, testId);
    const limit = attemptsLimit(item.numberOfAttempts);
    let resultId: string;
    if (limit !== null) {
      const previous = await db.countMatching(
        resultsParent,
        "Results",
        "joinedby.uid",
        uid,
        limit,
      );
      if (previous >= limit) throw new Error("max_attempts_reached");
      resultId = `${uid}-attempt-${previous + 1}`;
    } else {
      resultId = `${uid}-${now.getTime()}`;
    }

    const grade = gradeAttempt(questions, answers);
    const showResult = item.showResult !== false;
    const creator = (course.contentcreaterentity ?? {}) as Record<
      string,
      unknown
    >;
    const teacherId = text(creator.id);
    const courseSubject = text(course.subject);
    const result = {
      serialNumber: resultId,
      joinedDate: now,
      totalQuestions: grade.total,
      solvedQuestions: grade.solved,
      joinedby: {
        uid,
        name: displayName(user),
        imageUrl: text(user.profilePicurl),
        joinedDate: now,
      },
      isPassed: grade.isPassed,
      result: grade.score,
      courseId,
      sectionId,
      testId,
      testName: text(item.title),
      courseSubject,
      teacherId,
      resultHidden: !showResult,
      gradedBy: "server",
      questionsSolvedList: grade.solvedQuestions,
    };
    const studentCopy = showResult
      ? result
      : { ...result, questionsSolvedList: [] };

    const writes: unknown[] = [
      createWrite(toDocument(db, `${resultsParent}/Results/${resultId}`, result)),
      createWrite(
        toDocument(db, `Users/${uid}/MyResults/${resultId}`, studentCopy),
      ),
    ];

    if (showResult) {
      const wrong = grade.wrongQuestions.filter((g) =>
        MISTAKE_ID.test(String(g.question.questionId))
      );
      const existing = await Promise.all(
        wrong.map((g) =>
          db.get(`Users/${uid}/MyMistakes/${g.question.questionId}`, transaction)
        ),
      );
      wrong.forEach((graded, index) => {
        const path = `Users/${uid}/MyMistakes/${graded.question.questionId}`;
        const before = existing[index];
        const data = mistakeDocument(
          graded,
          courseId,
          sectionId,
          courseSubject,
          before ? decodeFields(before.fields) : null,
          now,
        );
        const doc = toDocument(db, path, data);
        writes.push(
          before
            ? updateWrite(doc, Object.keys(data), before.updateTime)
            : createWrite(doc),
        );
      });
    }

    return {
      writes,
      result: { result: studentCopy, resultHidden: !showResult },
    };
  }, options);
}

function toDocument(
  db: FeedbackStore,
  path: string,
  data: Record<string, unknown>,
) {
  return db.document(
    path,
    Object.fromEntries(
      Object.entries(data).map(([field, value]) => [field, encode(value)]),
    ),
  );
}

export function testAttemptSafeError(cause: unknown): SafeError {
  const code = cause instanceof Error ? cause.message : "internal_error";
  const known: Record<string, [number, string]> = {
    unauthorized: [401, "Authentication is required."],
    invalid_body: [400, "Request body is invalid."],
    payload_too_large: [413, "Request body is too large."],
    invalid_course_id: [400, "Course ID is invalid."],
    invalid_section_id: [400, "Section ID is invalid."],
    invalid_test_id: [400, "Test ID is invalid."],
    invalid_answers: [400, "Answers are invalid."],
    not_found: [404, "Course or user was not found."],
    inactive_user: [403, "Your account is not active."],
    not_student: [403, "Only students can submit tests."],
    not_subscribed: [403, "Subscribe to the course to take this test."],
    course_unavailable: [403, "This course is not available."],
    test_not_found: [404, "Test was not found."],
    test_not_ready: [409, "This test has no questions yet."],
    max_attempts_reached: [409, "You have used all attempts for this test."],
    busy: [409, "Please submit again."],
  };
  const [status, message] = known[code] ?? [500, "Test could not be submitted."];
  return { code: known[code] ? code : "internal_error", status, message };
}
