import { Firestore } from "../_shared/firebase.ts";
import { requireCaller } from "../_shared/course_checkout.ts";
import { reusableStore } from "../_shared/course_feedback.ts";
import { createAuthedHandler } from "../_shared/authed_handler.ts";
import {
  createUploadUrl,
  storageSafeError,
  SupabaseStorageSigner,
} from "../_shared/storage_access.ts";

// POST { purpose: "avatar" | "support" | "course_media" | "course_file",
//        fileName, sizeBytes, courseId? } with a Firebase ID token.
// Returns a one-time signed upload URL token for a server-chosen path.
let signer: SupabaseStorageSigner | null = null;
const storageSigner = () => signer ??= new SupabaseStorageSigner();
Deno.serve(
  createAuthedHandler(
    "create_upload_url",
    (store: Firestore, uid, body) => createUploadUrl(store, storageSigner(), uid, body),
    storageSafeError,
    {
      authenticate: requireCaller,
      store: reusableStore(() => new Firestore()),
    },
  ),
);
