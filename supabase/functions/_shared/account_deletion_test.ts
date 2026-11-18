import { decodeFields } from "./course_checkout.ts";
import { FakeFirestore } from "./test_support/fake_firestore.ts";
import {
  accountDeletionSafeError,
  createDeleteAccountHandler,
  DELETED_ACCOUNT_ID,
  DELETED_TEACHER_NAME,
  deleteAccount,
  type DeletionServices,
  type DeletionStore,
  hasPaymentInProgress,
} from "./account_deletion.ts";

type CourseSnapshot = {
  state?: string;
  ownerAccountDeleted?: boolean;
  contentcreaterentity: { name?: string; profileImageUrl?: string; id?: string };
};


function assert(condition: unknown, message = "assertion failed"): asserts condition {
  if (!condition) throw new Error(message);
}

function canonical(value: unknown): string {
  return JSON.stringify(value, (_key, v) =>
    v && typeof v === "object" && !Array.isArray(v) && !(v instanceof Date)
      ? Object.fromEntries(Object.entries(v).sort(([a], [b]) => a.localeCompare(b)))
      : v);
}

function assertEquals(actual: unknown, expected: unknown, message = "") {
  const a = canonical(actual);
  const e = canonical(expected);
  if (a !== e) throw new Error(`${message}\nexpected ${e}\nactual   ${a}`);
}

async function assertRejects(
  run: () => Promise<unknown>,
  _type: unknown,
  code: string,
) {
  try {
    await run();
  } catch (cause) {
    if (cause instanceof Error && cause.message === code) return;
    throw new Error(`expected ${code}, got ${cause instanceof Error ? cause.message : cause}`);
  }
  throw new Error(`expected rejection with ${code}`);
}

const ROOT = "projects/test-project/databases/(default)/documents/";
const NOW = new Date("2026-11-18T12:00:00Z");
const FRESH = { uid: "s1", authTime: NOW.getTime() / 1000 - 30 };

class FakeDeletionStore extends FakeFirestore implements DeletionStore {
  queries: string[] = [];

  private stored(path: string) {
    const doc = this.docs.get(path);
    return doc
      ? { name: ROOT + path, fields: structuredClone(doc.fields), updateTime: `v${doc.version}` }
      : { name: ROOT + path };
  }

  async listPage(collection: string) {
    await Promise.resolve();
    const prefix = `${collection}/`;
    const ids = new Set<string>();
    for (const path of this.docs.keys()) {
      if (path.startsWith(prefix)) ids.add(path.slice(prefix.length).split("/")[0]);
    }
    return { documents: [...ids].sort().map((id) => this.stored(prefix + id)) };
  }

  async listCollectionIds(documentPath: string) {
    await Promise.resolve();
    const prefix = `${documentPath}/`;
    const ids = new Set<string>();
    for (const path of this.docs.keys()) {
      if (!path.startsWith(prefix)) continue;
      const rest = path.slice(prefix.length).split("/");
      if (rest.length >= 2) ids.add(rest[0]);
    }
    return [...ids].sort();
  }

  async queryWhereEqual(input: {
    parent?: string | null;
    collectionId: string;
    fieldPath: string;
    value: string;
    allDescendants?: boolean;
  }) {
    await Promise.resolve();
    this.queries.push(`${input.allDescendants ? "group:" : ""}${input.collectionId}.${input.fieldPath}`);
    const out = [];
    for (const [path, doc] of this.docs) {
      const segments = path.split("/");
      if (segments.length % 2 !== 0) continue;
      if (segments[segments.length - 2] !== input.collectionId) continue;
      const parent = segments.slice(0, -2).join("/");
      if (!input.allDescendants && parent !== (input.parent ?? "")) continue;
      let value: unknown = decodeFields(doc.fields);
      for (const key of input.fieldPath.split(".")) {
        value = value && typeof value === "object"
          ? (value as Record<string, unknown>)[key]
          : undefined;
      }
      if (value === input.value) out.push(this.stored(path));
    }
    return out;
  }

  async commitWrites(writes: unknown[]) {
    if (writes.length === 0) return;
    const transaction = await this.beginTransaction();
    await this.commit(transaction, writes);
  }

  paths(): string[] {
    return [...this.docs.keys()].sort();
  }
}

function fakeServices() {
  const calls = {
    authDeleted: [] as string[],
    folders: [] as string[],
    urls: [] as unknown[],
    videos: [] as string[],
  };
  const services: DeletionServices = {
    deleteAuthUser: (uid) => {
      calls.authDeleted.push(uid);
      return Promise.resolve();
    },
    removeStorageFolder: (bucket, folder) => {
      calls.folders.push(`${bucket}/${folder}`);
      return Promise.resolve(1);
    },
    removeStorageUrl: (url) => {
      if (typeof url === "string" && url.length > 0) calls.urls.push(url);
      return Promise.resolve(typeof url === "string" && url.length > 0 ? 1 : 0);
    },
    deleteVideoAsset: (assetId) => {
      calls.videos.push(assetId);
      return Promise.resolve();
    },
    now: () => NOW,
    logError: () => {},
  };
  return { services, calls };
}

const teacherEntity = { id: "t1", name: "Mr T", profileImageUrl: "https://x/t.png", title: "Math" };

function seedStudentWorld(db: FakeDeletionStore) {
  db.seed("Users/s1", {
    uid: "s1", role: "Student", status: "Active", firstName: "Sara",
    profilePicurl: "https://project.supabase.co/storage/v1/object/public/Users/s1/a.png",
  });
  db.seed("Users/s1/Courses/c1", { id: "c1", contentcreaterentity: teacherEntity, myRating: 4 });
  db.seed("Users/s1/MyResults/r1", { result: 3, teacherId: "t1" });
  db.seed("Users/s1/MyMistakes/q1", { q: "x" });
  db.seed("Users/s1/Favorites/c9", { id: "c9" });
  db.seed("Users/s1/Transactions/tx1", { transaction_id: "tx1", mobile: "0100" });
  db.seed("Courses/c1", {
    id: "c1", state: "Published", contentcreaterentity: teacherEntity, studentsCount: 3,
    ratingsSum: 9, ratingsCount: 2, averageRating: 4.5,
    ratingDistribution: { "1": 0, "2": 0, "3": 0, "4": 1, "5": 1 }, feedBacksCount: 2,
  });
  db.seed("Courses/c1/Subscribers/s1", { id: "s1", name: "Sara", phone: "0100" });
  db.seed("Courses/c1/Subscribers/s2", { id: "s2", name: "Other" });
  db.seed("Courses/c1/Feedbacks/s1", {
    uid: "s1", name: "Sara", fedBack: "good", rating: 4,
    datePosted: new Date("2026-10-01T00:00:00Z"),
  });
  db.seed("Courses/c1/Feedbacks/s2", {
    uid: "s2", name: "Other", fedBack: "great", rating: 5,
    datePosted: new Date("2026-10-02T00:00:00Z"),
  });
  db.seed("Courses/c1/Sections/a", { id: "a" });
  db.seed("Courses/c1/Sections/a/Items/v1", { id: "v1", type: "Video" });
  db.seed("Courses/c1/Sections/a/Items/v1/JoinedBy/s1", { uid: "s1" });
  db.seed("Courses/c1/Sections/a/Items/v1/JoinedBy/s2", { uid: "s2" });
  db.seed("Courses/c1/Sections/a/Items/v1/VideoNotes/n1", { user: { uid: "s1" }, note: "hi" });
  db.seed("Courses/c1/Sections/a/Items/t1/Results/s1-attempt-1", { joinedby: { uid: "s1" }, result: 3 });
  db.seed("Courses/c1/Reports/rep1", { reporterId: "s1", status: "open", description: "bad audio" });
  db.seed("Courses/c1/Transactions/tx1", { transaction_id: "tx1", mobile: "0100", amount: 100 });
  db.seed("Transactions/tx1", { transaction_id: "tx1", mobile: "0100", amount: 100 });
  db.seed("CoursePaymentAttempts/at1", {
    uid: "s1", courseId: "c1", status: "succeeded", paymobTransactionId: "tx1",
    createdAt: new Date("2026-10-01T00:00:00Z"),
  });
  db.seed("Tickets/k1", { id: "k1", sender: { uid: "s1" } });
  db.seed("Tickets/k1/Messages/m1", { sender: { uid: "s1" }, text: "help" });
  db.seed("Tickets/k2", { id: "k2", sender: { uid: "s2" } });
  db.seed("ReviewReports/c1_s2_s1", { reportedBy: "s1", reviewUid: "s2", status: "open" });
}

Deno.test("deleting a student removes their data and keeps anonymous records", async () => {
  const db = new FakeDeletionStore();
  seedStudentWorld(db);
  const { services, calls } = fakeServices();

  const result = await deleteAccount(db, services, FRESH, {});

  assertEquals(result.deleted, true);
  const left = db.paths();
  for (const path of left) {
    assert(!path.startsWith("Users/s1"), `left behind: ${path}`);
  }
  assertEquals(db.data("Courses/c1/Subscribers/s1"), null);
  assert(db.data("Courses/c1/Subscribers/s2"));
  assertEquals(db.data("Courses/c1")!.studentsCount, 2);
  assertEquals(db.data("Courses/c1/Feedbacks/s1"), null);
  assertEquals(db.data("Courses/c1")!.ratingsCount, 1);
  assertEquals(db.data("Courses/c1")!.ratingsSum, 5);
  assertEquals(db.data("Courses/c1/Sections/a/Items/v1/JoinedBy/s1"), null);
  assert(db.data("Courses/c1/Sections/a/Items/v1/JoinedBy/s2"));
  assertEquals(db.data("Courses/c1/Sections/a/Items/v1/VideoNotes/n1"), null);
  assertEquals(db.data("Courses/c1/Sections/a/Items/t1/Results/s1-attempt-1"), null);
  assertEquals(db.data("Courses/c1/Reports/rep1")!.reporterId, DELETED_ACCOUNT_ID);
  assertEquals(db.data("ReviewReports/c1_s2_s1")!.reportedBy, DELETED_ACCOUNT_ID);
  assertEquals(db.data("Tickets/k1"), null);
  assertEquals(db.data("Tickets/k1/Messages/m1"), null);
  assert(db.data("Tickets/k2"));
  for (const path of ["Transactions/tx1", "Courses/c1/Transactions/tx1"]) {
    const record = db.data(path)!;
    assertEquals(record.amount, 100);
    assertEquals("mobile" in record, false);
    assertEquals(record.accountDeleted, true);
  }
  assert(db.data("CoursePaymentAttempts/at1"));
  assertEquals(db.data("DeletedAccounts/s1")!.role, "Student");
  assertEquals(calls.authDeleted, ["s1"]);
  assert(calls.folders.includes("Users/s1"));
  assert(calls.folders.includes("Support/s1"));
  assertEquals(calls.urls.length, 1);
});

Deno.test("a teacher's sold course stays for its students, an unsold one is deleted", async () => {
  const db = new FakeDeletionStore();
  db.seed("Users/t1", {
    uid: "t1", role: "Teacher", status: "Active",
    teacherExtraData: { wallet: { balance: 0, payout_pending: 0 } },
  });
  db.seed("Users/t1/Courses/sold", { id: "sold", contentcreaterentity: teacherEntity });
  db.seed("Users/t1/Transactions/w1", { method: "PayOut", amount: 200, mobile: "0101", status: "SUCCESS" });
  db.seed("Courses/sold", { id: "sold", state: "Published", contentcreaterentity: teacherEntity, studentsCount: 1 });
  db.seed("Courses/sold/Subscribers/s9", { id: "s9" });
  db.seed("Courses/sold/Coupons/OFF10", { code: "OFF10" });
  db.seed("Courses/sold/Sections/a", { id: "a" });
  db.seed("Courses/sold/Sections/a/Items/v1", { id: "v1", muxAssetId: "keep-asset" });
  db.seed("Users/s9", { uid: "s9", role: "Student", status: "Active" });
  db.seed("Users/s9/Courses/sold", { id: "sold", contentcreaterentity: teacherEntity });
  db.seed("Courses/unsold", {
    id: "unsold", state: "Pending", contentcreaterentity: teacherEntity, studentsCount: 0,
    posterUrl: "https://project.supabase.co/storage/v1/object/public/Courses/unsold/p.png",
  });
  db.seed("Courses/unsold/Sections/a", { id: "a" });
  db.seed("Courses/unsold/Sections/a/Items/v1", { id: "v1", muxAssetId: "asset-1" });
  db.seed("Courses/unsold/Sections/a/Items/t1/Private/answerKey", { questions: [] });
  const { services, calls } = fakeServices();

  const result = await deleteAccount(db, services, { uid: "t1", authTime: FRESH.authTime }, {});

  assertEquals(result.coursesKept, 1);
  assertEquals(result.coursesDeleted, 1);
  const sold = db.data("Courses/sold") as CourseSnapshot;
  assertEquals(sold.state, "DeletedByTeacher");
  assertEquals(sold.ownerAccountDeleted, true);
  assertEquals(sold.contentcreaterentity.name, DELETED_TEACHER_NAME);
  assertEquals(sold.contentcreaterentity.profileImageUrl, "");
  assertEquals(sold.contentcreaterentity.id, "t1");
  assert(db.data("Courses/sold/Sections/a/Items/v1"));
  assertEquals(db.data("Courses/sold/Coupons/OFF10"), null);
  assertEquals((db.data("Users/s9/Courses/sold") as CourseSnapshot).contentcreaterentity.name, DELETED_TEACHER_NAME);
  assertEquals(db.paths().filter((p) => p.startsWith("Courses/unsold")), []);
  assertEquals(calls.videos, ["asset-1"]);
  assert(calls.folders.includes("CourseFiles/unsold"));
  assert(calls.folders.includes("Courses/unsold"));
  const archived = db.data("ArchivedWithdrawals/t1_w1")!;
  assertEquals(archived.amount, 200);
  assertEquals(archived.teacherUid, "t1");
  assertEquals("mobile" in archived, false);
  assertEquals(db.paths().filter((p) => p.startsWith("Users/t1")), []);
  assertEquals(calls.authDeleted, ["t1"]);
});

Deno.test("deletion needs a sign-in from the last few minutes", async () => {
  const db = new FakeDeletionStore();
  seedStudentWorld(db);
  const { services, calls } = fakeServices();
  for (const authTime of [null, NOW.getTime() / 1000 - 600]) {
    await assertRejects(
      () => deleteAccount(db, services, { uid: "s1", authTime }, {}),
      Error,
      "requires_recent_login",
    );
  }
  assertEquals(calls.authDeleted, []);
  assertEquals(db.data("Users/s1")!.status, "Active");
});

Deno.test("staff accounts, pending payouts and unacknowledged balances are refused", async () => {
  const { services } = fakeServices();
  const cases: Array<[Record<string, unknown>, Record<string, unknown>, string]> = [
    [{ role: "Admin", status: "Active" }, {}, "staff_account"],
    [{ role: "Support", status: "Active" }, {}, "staff_account"],
    [{ role: "Teacher", status: "Active", teacherExtraData: { wallet: { payout_pending: 50 } } }, {}, "payout_pending"],
    [{ role: "Teacher", status: "Active", teacherExtraData: { wallet: { balance: 80 } } }, {}, "balance_remaining"],
  ];
  for (const [user, body, code] of cases) {
    const db = new FakeDeletionStore();
    db.seed("Users/u1", { uid: "u1", ...user });
    await assertRejects(
      () => deleteAccount(db, services, { uid: "u1", authTime: FRESH.authTime }, body),
      Error,
      code,
    );
    assertEquals(db.data("Users/u1")!.status, "Active");
  }
  const db = new FakeDeletionStore();
  db.seed("Users/u1", { uid: "u1", role: "Teacher", status: "Active", teacherExtraData: { wallet: { balance: 80 } } });
  await deleteAccount(db, services, { uid: "u1", authTime: FRESH.authTime }, { acknowledgeBalance: true });
  assertEquals(db.data("Users/u1"), null);
});

Deno.test("a payment that is still going through blocks deletion for a while", async () => {
  const recent = [{ status: "pending", createdAt: new Date(NOW.getTime() - 10 * 60_000) }];
  const old = [{ status: "pending", createdAt: new Date(NOW.getTime() - 3 * 60 * 60_000) }];
  assertEquals(hasPaymentInProgress(recent, NOW), true);
  assertEquals(hasPaymentInProgress(old, NOW), false);
  assertEquals(hasPaymentInProgress([{ status: "succeeded", createdAt: NOW }], NOW), false);

  const db = new FakeDeletionStore();
  seedStudentWorld(db);
  db.seed("CoursePaymentAttempts/at2", { uid: "s1", courseId: "c1", ...recent[0] });
  const { services } = fakeServices();
  await assertRejects(() => deleteAccount(db, services, FRESH, {}), Error, "payment_in_progress");
});

Deno.test("a failed run can be repeated until everything is gone", async () => {
  const db = new FakeDeletionStore();
  seedStudentWorld(db);
  const { services, calls } = fakeServices();
  let failAuth = true;
  services.deleteAuthUser = (uid) => {
    if (failAuth) return Promise.reject(new Error("auth_delete_failed"));
    calls.authDeleted.push(uid);
    return Promise.resolve();
  };
  await assertRejects(() => deleteAccount(db, services, FRESH, {}), Error, "auth_delete_failed");
  failAuth = false;
  const result = await deleteAccount(db, services, FRESH, {});
  assertEquals(result.deleted, true);
  assertEquals(calls.authDeleted, ["s1"]);
  assertEquals(db.data("Courses/c1")!.studentsCount, 2);
});

Deno.test("a half-finished deletion resumes even after the checks would fail", async () => {
  const db = new FakeDeletionStore();
  db.seed("Users/t1", {
    uid: "t1", role: "Teacher", status: "Deleting",
    teacherExtraData: { wallet: { balance: 30 } },
  });
  const { services } = fakeServices();
  const result = await deleteAccount(db, services, { uid: "t1", authTime: FRESH.authTime }, {});
  assertEquals(result.deleted, true);
  assertEquals(db.data("Users/t1"), null);
});

Deno.test("the handler checks the token first and returns stable error codes", async () => {
  const db = new FakeDeletionStore();
  seedStudentWorld(db);
  const { services } = fakeServices();
  const request = (init: RequestInit = {}) =>
    new Request("https://x/delete-account", {
      method: "POST",
      body: "{}",
      headers: { "content-type": "application/json" },
      ...init,
    });

  const anonymous = createDeleteAccountHandler({
    identify: () => Promise.reject(new Error("bad token")),
    store: () => db,
    services: () => services,
  });
  const denied = await anonymous(request());
  assertEquals(denied.status, 401);
  assertEquals((await denied.json()).error.code, "unauthorized");

  const stale = createDeleteAccountHandler({
    identify: () => Promise.resolve({ uid: "s1", authTime: 1 }),
    store: () => db,
    services: () => services,
  });
  const reauth = await stale(request());
  assertEquals((await reauth.json()).error.code, "requires_recent_login");

  const fresh = createDeleteAccountHandler({
    identify: () => Promise.resolve(FRESH),
    store: () => db,
    services: () => services,
  });
  const ok = await fresh(request());
  assertEquals(ok.status, 200);
  assertEquals((await ok.json()).ok, true);

  assertEquals((await fresh(request({ method: "GET", body: undefined }))).status, 405);
  assertEquals((await fresh(new Request("https://x", { method: "OPTIONS" }))).status, 200);
});

Deno.test("unknown failures become a retryable deletion_incomplete", () => {
  assertEquals(accountDeletionSafeError(new Error("Firestore list failed (500).")).code, "deletion_incomplete");
  assertEquals(accountDeletionSafeError(new Error("query_index_missing")).status, 503);
  assertEquals(accountDeletionSafeError(new Error("balance_remaining")).status, 409);
});
