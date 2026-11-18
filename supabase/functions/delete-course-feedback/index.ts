import { Firestore } from "../_shared/firebase.ts";
import { requireCaller } from "../_shared/course_checkout.ts";
import {
  createFeedbackHandler,
  deleteCourseFeedback,
  reusableStore,
} from "../_shared/course_feedback.ts";

// POST { courseId, feedbackUid?, teacherId? } with a Firebase ID token.
// Students delete their own feedback; admins (dashboard) delete any.
Deno.serve(
  createFeedbackHandler("delete_course_feedback", deleteCourseFeedback, {
    authenticate: requireCaller,
    store: reusableStore(() => new Firestore()),
  }),
);
