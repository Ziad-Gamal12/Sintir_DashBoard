import {
  deleteFirebaseAuthUser,
  firebaseIdentity,
  Firestore,
  requiredSecret,
} from "../_shared/firebase.ts";
import { reusableStore } from "../_shared/course_feedback.ts";
import {
  createDeleteAccountHandler,
  type DeletionServices,
  type DeletionStore,
} from "../_shared/account_deletion.ts";
import {
  storageObjectFromUrl,
  SupabaseStorageCleaner,
} from "../_shared/storage_access.ts";
import { deleteMuxAsset } from "../_shared/video.ts";

let cleaner: SupabaseStorageCleaner | null = null;
const storage = () => (cleaner ??= new SupabaseStorageCleaner());

const services = (): DeletionServices => ({
  deleteAuthUser: deleteFirebaseAuthUser,
  removeStorageFolder: (bucket, folder) => storage().removeFolder(bucket, folder),
  removeStorageUrl: async (url) => {
    const target = storageObjectFromUrl(url, requiredSecret("SUPABASE_URL"));
    if (!target) return 0;
    await storage().removeObjects(target.bucket, [target.path]);
    return 1;
  },
  deleteVideoAsset: deleteMuxAsset,
});

// POST { acknowledgeBalance?: boolean } with a Firebase ID token from a
// sign-in in the last five minutes. Deletes the caller's account.
Deno.serve(
  createDeleteAccountHandler({
    identify: firebaseIdentity,
    store: reusableStore<DeletionStore>(() => new Firestore()),
    services,
  }),
);
