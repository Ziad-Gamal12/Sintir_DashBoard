import { Firestore } from "../_shared/firebase.ts";
import { requireCaller } from "../_shared/course_checkout.ts";
import {
  createFeedbackHandler,
  reusableStore,
  upsertCourseFeedback,
} from "../_shared/course_feedback.ts";

// POST { courseId, rating: 1..5, text?, teacherId? } with a Firebase ID token.
Deno.serve(
  createFeedbackHandler("upsert_course_feedback", upsertCourseFeedback, {
    authenticate: requireCaller,
    store: reusableStore(() => new Firestore()),
  }),
);
