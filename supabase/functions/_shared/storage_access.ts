// Supabase Storage access for the app.
//
// The app signs in with Firebase, so Supabase sees every app request as
// anonymous. Storage therefore has NO client policies: uploads use one-time
// signed upload URLs issued here, and paid course files sit in the private
// `CourseFiles` bucket and are read through short-lived signed URLs.
//
//   create-upload-url    -> { bucket, path, token, contentType, publicUrl? }
//   get-course-file-url  -> { url, expiresAt }

import {
  coursePath,
  decodeFields,
  enrollPath,
  requiredCourseId,
  subscriberPath,
  userPath,
} from "./course_checkout.ts";
import type { FeedbackStore } from "./course_feedback.ts";
import { requiredSecret } from "./firebase.ts";
import {
  canUseCourseContent,
  itemPath,
  pathSegment,
} from "./course_access.ts";
import type { SafeError } from "./authed_handler.ts";

export const PRIVATE_COURSE_FILES_BUCKET = "CourseFiles";
export const SIGNED_FILE_URL_SECONDS = 60 * 60;

export type StorageSigner = {
  signUpload(bucket: string, path: string): Promise<{ token: string }>;
  signDownload(bucket: string, path: string, expiresIn: number): Promise<string>;
  publicUrl(bucket: string, path: string): string;
};

export type StorageStore = Pick<FeedbackStore, "get">;

const IMAGE_TYPES: Record<string, string> = {
  jpg: "image/jpeg",
  jpeg: "image/jpeg",
  png: "image/png",
  webp: "image/webp",
  gif: "image/gif",
  heic: "image/heic",
};

const DOCUMENT_TYPES: Record<string, string> = {
  pdf: "application/pdf",
  doc: "application/msword",
  docx:
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  txt: "text/plain",
  ppt: "application/vnd.ms-powerpoint",
  pptx:
    "application/vnd.openxmlformats-officedocument.presentationml.presentation",
  xls: "application/vnd.ms-excel",
  xlsx: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
};

type Purpose = {
  bucket: string;
  types: Record<string, string>;
  maxBytes: number;
  isPublic: boolean;
};

const MB = 1024 * 1024;

export const UPLOAD_PURPOSES: Record<string, Purpose> = {
  avatar: { bucket: "Users", types: IMAGE_TYPES, maxBytes: 5 * MB, isPublic: true },
  support: { bucket: "Support", types: IMAGE_TYPES, maxBytes: 10 * MB, isPublic: true },
  course_media: { bucket: "Courses", types: IMAGE_TYPES, maxBytes: 10 * MB, isPublic: true },
  course_file: {
    bucket: PRIVATE_COURSE_FILES_BUCKET,
    types: DOCUMENT_TYPES,
    maxBytes: 50 * MB,
    isPublic: false,
  },
};

const text = (value: unknown): string =>
  typeof value === "string" ? value : "";

export function fileExtension(fileName: unknown): string {
  if (typeof fileName !== "string" || fileName.length > 255) {
    throw new Error("invalid_file_name");
  }
  const match = /\.([A-Za-z0-9]{1,8})$/.exec(fileName.trim());
  if (!match) throw new Error("invalid_file_name");
  return match[1].toLowerCase();
}

type Caller = { uid: string; role: string; status: string };

async function activeCaller(db: StorageStore, uid: string): Promise<Caller> {
  if (!/^[A-Za-z0-9_-]{1,160}$/.test(uid)) throw new Error("unauthorized");
  const doc = await db.get(userPath(uid));
  if (!doc) throw new Error("not_found");
  const user = decodeFields(doc.fields);
  const caller = { uid, role: text(user.role), status: text(user.status) };
  if (caller.status !== "Active") throw new Error("inactive_user");
  return caller;
}

const canManageCourses = (role: string) =>
  role === "Admin" || role === "CoursesManager";

export async function createUploadUrl(
  db: StorageStore,
  signer: StorageSigner,
  callerUid: string,
  body: Record<string, unknown>,
  randomId: () => string = () => crypto.randomUUID(),
): Promise<Record<string, unknown>> {
  const purposeName = text(body.purpose);
  const purpose = UPLOAD_PURPOSES[purposeName];
  if (!purpose) throw new Error("invalid_purpose");
  const extension = fileExtension(body.fileName);
  const contentType = purpose.types[extension];
  if (!contentType) throw new Error("unsupported_file_type");
  const size = Number(body.sizeBytes);
  if (!Number.isSafeInteger(size) || size <= 0) {
    throw new Error("invalid_file_size");
  }
  if (size > purpose.maxBytes) throw new Error("file_too_large");

  const caller = await activeCaller(db, callerUid);
  let folder = caller.uid;
  if (purposeName === "course_media") {
    if (caller.role !== "Teacher" && !canManageCourses(caller.role)) {
      throw new Error("forbidden");
    }
  } else if (purposeName === "course_file") {
    const courseId = requiredCourseId(body.courseId);
    const courseDoc = await db.get(coursePath(courseId));
    if (!courseDoc) throw new Error("not_found");
    const course = decodeFields(courseDoc.fields);
    const creator = (course.contentcreaterentity ?? {}) as Record<string, unknown>;
    const owner = caller.role === "Teacher" && creator.id === caller.uid;
    if (!owner && !canManageCourses(caller.role)) throw new Error("forbidden");
    if (owner && course.state === "DeletedByAdmin") {
      throw new Error("course_unavailable");
    }
    folder = courseId;
  }

  const path = `${folder}/${randomId()}.${extension}`;
  const { token } = await signer.signUpload(purpose.bucket, path);
  return {
    bucket: purpose.bucket,
    path,
    token,
    contentType,
    publicUrl: purpose.isPublic ? signer.publicUrl(purpose.bucket, path) : null,
  };
}

export async function getCourseFileUrl(
  db: StorageStore,
  signer: StorageSigner,
  callerUid: string,
  body: Record<string, unknown>,
  now: () => Date = () => new Date(),
): Promise<Record<string, unknown>> {
  const courseId = requiredCourseId(body.courseId);
  const sectionId = pathSegment(body.sectionId, "section_id");
  const itemId = pathSegment(body.itemId, "item_id");
  const caller = await activeCaller(db, callerUid);

  const [courseDoc, itemDoc, subscriberDoc, enrollmentDoc] = await Promise.all([
    db.get(coursePath(courseId)),
    db.get(itemPath(courseId, sectionId, itemId)),
    caller.role === "Student"
      ? db.get(subscriberPath(courseId, caller.uid))
      : Promise.resolve(null),
    caller.role === "Student"
      ? db.get(enrollPath(caller.uid, courseId))
      : Promise.resolve(null),
  ]);
  if (!courseDoc) throw new Error("not_found");
  const course = decodeFields(courseDoc.fields);
  const creator = (course.contentcreaterentity ?? {}) as Record<string, unknown>;
  const allowed = canUseCourseContent({
    role: caller.role,
    status: caller.status,
    owner: creator.id === caller.uid,
    courseState: text(course.state),
    hasEnrollment: enrollmentDoc !== null,
    hasSubscriber: subscriberDoc !== null,
  });
  if (!allowed) {
    throw new Error(caller.role === "Student" ? "not_subscribed" : "forbidden");
  }
  if (!itemDoc) throw new Error("file_not_found");
  const item = decodeFields(itemDoc.fields);
  const filePath = text(item.filePath);
  if (item.type !== "File" || filePath.length === 0) {
    throw new Error("file_not_found");
  }

  const expiresAt = new Date(now().getTime() + SIGNED_FILE_URL_SECONDS * 1000);
  // Files uploaded before the private bucket existed are plain public URLs.
  if (/^https?:\/\//i.test(filePath)) {
    return { url: filePath, expiresAt: null };
  }
  // A teacher can only point an item at files of the same course.
  if (!filePath.startsWith(`${courseId}/`) || filePath.includes("..")) {
    throw new Error("file_not_found");
  }
  const url = await signer.signDownload(
    PRIVATE_COURSE_FILES_BUCKET,
    filePath,
    SIGNED_FILE_URL_SECONDS,
  );
  return { url, expiresAt };
}

const encodePath = (path: string) =>
  path.split("/").map(encodeURIComponent).join("/");

/** Storage REST calls with the service-role key (never sent to clients). */
export class SupabaseStorageSigner implements StorageSigner {
  private readonly base: string;
  private readonly key: string;

  constructor() {
    this.base = `${requiredSecret("SUPABASE_URL").replace(/\/+$/, "")}/storage/v1`;
    this.key = requiredSecret("SUPABASE_SERVICE_ROLE_KEY");
  }

  private headers(): Record<string, string> {
    return {
      authorization: `Bearer ${this.key}`,
      apikey: this.key,
      "content-type": "application/json",
    };
  }

  async signUpload(bucket: string, path: string): Promise<{ token: string }> {
    const response = await fetch(
      `${this.base}/object/upload/sign/${encodePath(bucket)}/${encodePath(path)}`,
      { method: "POST", headers: this.headers(), body: "{}" },
    );
    if (!response.ok) {
      console.error("storage upload signing failed", { status: response.status });
      throw new Error("storage_unavailable");
    }
    const data = await response.json();
    const token = new URL(`${this.base}${data.url}`).searchParams.get("token");
    if (!token) throw new Error("storage_unavailable");
    return { token };
  }

  async signDownload(
    bucket: string,
    path: string,
    expiresIn: number,
  ): Promise<string> {
    const response = await fetch(
      `${this.base}/object/sign/${encodePath(bucket)}/${encodePath(path)}`,
      {
        method: "POST",
        headers: this.headers(),
        body: JSON.stringify({ expiresIn }),
      },
    );
    if (!response.ok) {
      console.error("storage download signing failed", { status: response.status });
      throw new Error(response.status === 404 || response.status === 400
        ? "file_not_found"
        : "storage_unavailable");
    }
    const data = await response.json();
    const signed = text(data.signedURL ?? data.signedUrl);
    if (!signed) throw new Error("storage_unavailable");
    return `${this.base}${signed}`;
  }

  publicUrl(bucket: string, path: string): string {
    return `${this.base}/object/public/${encodePath(bucket)}/${encodePath(path)}`;
  }
}

/** Removes stored files with the service role (account deletion). */
export class SupabaseStorageCleaner {
  private readonly base: string;
  private readonly key: string;

  constructor() {
    this.base = `${requiredSecret("SUPABASE_URL").replace(/\/+$/, "")}/storage/v1`;
    this.key = requiredSecret("SUPABASE_SERVICE_ROLE_KEY");
  }

  private headers(): Record<string, string> {
    return {
      authorization: `Bearer ${this.key}`,
      apikey: this.key,
      "content-type": "application/json",
    };
  }

  /** Deletes every object under `folder/`, sub-folders included. */
  async removeFolder(bucket: string, folder: string): Promise<number> {
    let removed = 0;
    for (let round = 0; round < 100; round++) {
      const response = await fetch(
        `${this.base}/object/list/${encodePath(bucket)}`,
        {
          method: "POST",
          headers: this.headers(),
          body: JSON.stringify({ prefix: folder, limit: 100, offset: 0 }),
        },
      );
      if (!response.ok) {
        console.error("storage list failed", { status: response.status });
        throw new Error("storage_unavailable");
      }
      const items = await response.json();
      if (!Array.isArray(items) || items.length === 0) return removed;
      const files: string[] = [];
      for (const item of items) {
        const name = typeof item?.name === "string" ? item.name : "";
        if (!name || name === ".emptyFolderPlaceholder") continue;
        if (item.id === null || item.id === undefined) {
          removed += await this.removeFolder(bucket, `${folder}/${name}`);
        } else {
          files.push(`${folder}/${name}`);
        }
      }
      if (files.length === 0) return removed;
      await this.removeObjects(bucket, files);
      removed += files.length;
    }
    return removed;
  }

  async removeObjects(bucket: string, paths: string[]): Promise<void> {
    if (paths.length === 0) return;
    const response = await fetch(`${this.base}/object/${encodePath(bucket)}`, {
      method: "DELETE",
      headers: this.headers(),
      body: JSON.stringify({ prefixes: paths }),
    });
    if (!response.ok) {
      console.error("storage delete failed", { status: response.status });
      throw new Error("storage_unavailable");
    }
  }
}

/**
 * Bucket and object path of a public URL from this project's storage, or
 * null for any other URL.
 */
export function storageObjectFromUrl(
  url: unknown,
  supabaseUrl: string,
): { bucket: string; path: string } | null {
  if (typeof url !== "string" || url.length === 0) return null;
  const base = `${supabaseUrl.replace(/\/+$/, "")}/storage/v1/object/public/`;
  if (!url.startsWith(base)) return null;
  const rest = url.slice(base.length).split("?")[0];
  const slash = rest.indexOf("/");
  if (slash <= 0 || slash === rest.length - 1) return null;
  try {
    return {
      bucket: decodeURIComponent(rest.slice(0, slash)),
      path: rest.slice(slash + 1).split("/").map(decodeURIComponent).join("/"),
    };
  } catch {
    return null;
  }
}

export function storageSafeError(cause: unknown): SafeError {
  const code = cause instanceof Error ? cause.message : "internal_error";
  const known: Record<string, [number, string]> = {
    unauthorized: [401, "Authentication is required."],
    invalid_body: [400, "Request body is invalid."],
    payload_too_large: [413, "Request body is too large."],
    invalid_purpose: [400, "Upload purpose is invalid."],
    invalid_file_name: [400, "File name is invalid."],
    unsupported_file_type: [415, "This file type is not allowed."],
    invalid_file_size: [400, "File size is invalid."],
    file_too_large: [413, "The file is too large."],
    invalid_course_id: [400, "Course ID is invalid."],
    invalid_section_id: [400, "Section ID is invalid."],
    invalid_item_id: [400, "Item ID is invalid."],
    not_found: [404, "Course or user was not found."],
    inactive_user: [403, "Your account is not active."],
    forbidden: [403, "You are not allowed to do this."],
    not_subscribed: [403, "Subscribe to the course to open this file."],
    course_unavailable: [403, "This course is not available."],
    file_not_found: [404, "File was not found."],
    storage_unavailable: [503, "File storage is unavailable. Try again."],
  };
  const [status, message] = known[code] ?? [500, "The file request failed."];
  return { code: known[code] ? code : "internal_error", status, message };
}
