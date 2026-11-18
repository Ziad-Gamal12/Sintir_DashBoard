import { Firestore } from "../_shared/firebase.ts";
import { requireCaller } from "../_shared/course_checkout.ts";
import { reusableStore } from "../_shared/course_feedback.ts";
import { createAuthedHandler } from "../_shared/authed_handler.ts";
import {
  getCourseFileUrl,
  storageSafeError,
  SupabaseStorageSigner,
} from "../_shared/storage_access.ts";

// POST { courseId, sectionId, itemId } with a Firebase ID token.
// Returns a one-hour signed URL for a course file the caller may open.
let signer: SupabaseStorageSigner | null = null;
const storageSigner = () => signer ??= new SupabaseStorageSigner();
Deno.serve(
  createAuthedHandler(
    "get_course_file_url",
    (store: Firestore, uid, body) => getCourseFileUrl(store, storageSigner(), uid, body),
    storageSafeError,
    {
      authenticate: requireCaller,
      store: reusableStore(() => new Firestore()),
    },
  ),
);
