import { Firestore } from "../_shared/firebase.ts";
import { requireCaller } from "../_shared/course_checkout.ts";
import { reusableStore } from "../_shared/course_feedback.ts";
import { createAuthedHandler } from "../_shared/authed_handler.ts";
import {
  type AttemptStore,
  SUBMIT_MAX_BODY_BYTES,
  submitTestAttempt,
  testAttemptSafeError,
} from "../_shared/test_attempts.ts";

// POST { courseId, sectionId, testId, answers: { [questionId]: answerText } }
// with a Firebase ID token. Grades on the server and stores the result.
Deno.serve(
  createAuthedHandler(
    "submit_test_attempt",
    (store: AttemptStore, uid, body) => submitTestAttempt(store, uid, body),
    testAttemptSafeError,
    {
      authenticate: requireCaller,
      store: reusableStore<AttemptStore>(() => new Firestore()),
      maxBodyBytes: SUBMIT_MAX_BODY_BYTES,
    },
  ),
);
