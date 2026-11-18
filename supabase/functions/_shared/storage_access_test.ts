import { FakeFirestore } from "./test_support/fake_firestore.ts";
import {
  createUploadUrl,
  getCourseFileUrl,
  type StorageSigner,
  storageSafeError,
} from "./storage_access.ts";

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

class FakeSigner implements StorageSigner {
  uploads: string[] = [];
  downloads: string[] = [];
  signUpload(bucket: string, path: string) {
    this.uploads.push(`${bucket}/${path}`);
    return Promise.resolve({ token: "upload-token" });
  }
  signDownload(bucket: string, path: string, expiresIn: number) {
    this.downloads.push(`${bucket}/${path}@${expiresIn}`);
    return Promise.resolve(`https://storage.test/sign/${bucket}/${path}?token=t`);
  }
  publicUrl(bucket: string, path: string) {
    return `https://storage.test/public/${bucket}/${path}`;
  }
}

const COURSE = "math-101";
const ITEM = `Courses/${COURSE}/Sections/s1/Items/f1`;

function seed(db: FakeFirestore) {
  db.seed("Users/teacher1", { role: "Teacher", status: "Active" });
  db.seed("Users/teacher2", { role: "Teacher", status: "Active" });
  db.seed("Users/student1", { role: "Student", status: "Active" });
  db.seed("Users/student2", { role: "Student", status: "Active" });
  db.seed("Users/blocked", { role: "Student", status: "Blocked" });
  db.seed("Users/manager", { role: "CoursesManager", status: "Active" });
  db.seed(`Courses/${COURSE}`, {
    state: "Published",
    contentcreaterentity: { id: "teacher1" },
  });
  db.seed(`Courses/${COURSE}/Subscribers/student1`, { id: "student1" });
  db.seed(`Users/student1/Courses/${COURSE}`, { id: COURSE });
  db.seed(ITEM, { id: "f1", type: "File", filePath: `${COURSE}/abc.pdf` });
}

const fileBody = { courseId: COURSE, sectionId: "s1", itemId: "f1" };

Deno.test("teachers get upload slots only for their own course files", async () => {
  const db = new FakeFirestore();
  seed(db);
  const signer = new FakeSigner();
  const slot = await createUploadUrl(db, signer, "teacher1", {
    purpose: "course_file",
    courseId: COURSE,
    fileName: "Lesson 1.PDF",
    sizeBytes: 2048,
  }, () => "uuid");
  assertEquals(slot, {
    bucket: "CourseFiles",
    path: `${COURSE}/uuid.pdf`,
    token: "upload-token",
    contentType: "application/pdf",
    publicUrl: null,
  }, "private slot");
  await rejectsWith(
    createUploadUrl(db, signer, "teacher2", {
      purpose: "course_file",
      courseId: COURSE,
      fileName: "x.pdf",
      sizeBytes: 10,
    }),
    "forbidden",
  );
  await rejectsWith(
    createUploadUrl(db, signer, "student1", {
      purpose: "course_media",
      fileName: "poster.png",
      sizeBytes: 10,
    }),
    "forbidden",
  );
});

Deno.test("uploads are typed, sized and placed by the server", async () => {
  const db = new FakeFirestore();
  seed(db);
  const signer = new FakeSigner();
  const avatar = await createUploadUrl(db, signer, "student1", {
    purpose: "avatar",
    fileName: "me.jpg",
    sizeBytes: 1000,
  }, () => "id1");
  assertEquals(avatar.path, "student1/id1.jpg", "own folder");
  assertEquals(
    avatar.publicUrl,
    "https://storage.test/public/Users/student1/id1.jpg",
    "public url",
  );
  await rejectsWith(
    createUploadUrl(db, signer, "student1", {
      purpose: "avatar",
      fileName: "script.html",
      sizeBytes: 10,
    }),
    "unsupported_file_type",
  );
  await rejectsWith(
    createUploadUrl(db, signer, "student1", {
      purpose: "avatar",
      fileName: "big.png",
      sizeBytes: 50 * 1024 * 1024,
    }),
    "file_too_large",
  );
  await rejectsWith(
    createUploadUrl(db, signer, "blocked", {
      purpose: "avatar",
      fileName: "me.png",
      sizeBytes: 10,
    }),
    "inactive_user",
  );
});

Deno.test("course files open only for the owner, enrolled students and staff", async () => {
  const db = new FakeFirestore();
  seed(db);
  const signer = new FakeSigner();
  for (const uid of ["teacher1", "student1", "manager"]) {
    const response = await getCourseFileUrl(db, signer, uid, fileBody);
    assertEquals(
      response.url,
      `https://storage.test/sign/CourseFiles/${COURSE}/abc.pdf?token=t`,
      `${uid} gets a signed url`,
    );
  }
  await rejectsWith(getCourseFileUrl(db, signer, "student2", fileBody), "not_subscribed");
  await rejectsWith(getCourseFileUrl(db, signer, "teacher2", fileBody), "forbidden");
});

Deno.test("enrolled students lose file access only when an admin takes the course down", async () => {
  const db = new FakeFirestore();
  seed(db);
  const signer = new FakeSigner();
  db.seed(`Courses/${COURSE}`, {
    state: "Pending",
    contentcreaterentity: { id: "teacher1" },
  });
  await getCourseFileUrl(db, signer, "student1", fileBody);
  db.seed(`Courses/${COURSE}`, {
    state: "Archived",
    contentcreaterentity: { id: "teacher1" },
  });
  await rejectsWith(getCourseFileUrl(db, signer, "student1", fileBody), "not_subscribed");
});

Deno.test("an item cannot point at another course's file", async () => {
  const db = new FakeFirestore();
  seed(db);
  db.seed(ITEM, { id: "f1", type: "File", filePath: "other-course/secret.pdf" });
  await rejectsWith(
    getCourseFileUrl(db, new FakeSigner(), "teacher1", fileBody),
    "file_not_found",
  );
});

Deno.test("legacy public file URLs are returned unchanged", async () => {
  const db = new FakeFirestore();
  seed(db);
  db.seed(ITEM, {
    id: "f1",
    type: "File",
    filePath: "https://old.example/storage/v1/object/public/Courses/a.pdf",
  });
  const response = await getCourseFileUrl(db, new FakeSigner(), "student1", fileBody);
  assertEquals(response.expiresAt, null, "no expiry for legacy urls");
});

Deno.test("storage errors are mapped to safe responses", () => {
  assertEquals(storageSafeError(new Error("file_too_large")).status, 413, "size");
  assertEquals(storageSafeError(new Error("boom")).code, "internal_error", "unknown");
});
