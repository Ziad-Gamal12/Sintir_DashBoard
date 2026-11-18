// Who may use a course's paid content (lessons, files, tests).
//
// Pure rules shared by the functions that serve paid content. The Firestore
// security rules (Sintir/firestore.rules) apply the same policy to direct
// reads, so keep both in sync.

/** States in which the admin has taken a course down. */
export const ADMIN_BLOCKED_STATES: ReadonlySet<string> = new Set([
  "Archived",
  "DeletedByAdmin",
]);

/** Dashboard staff roles (Sintir_DashBoard BackendEndpoints). */
export const STAFF_ROLES: ReadonlySet<string> = new Set([
  "Admin",
  "CoursesManager",
  "UsersManager",
  "Support",
]);

export type CourseContentAccessInput = {
  role: string;
  status: string;
  owner: boolean;
  courseState: string;
  hasEnrollment: boolean;
  hasSubscriber: boolean;
};

/**
 * A student who paid keeps access while the course is published, archived by
 * its teacher, or back in review after an edit. Only an admin take-down
 * removes access. Teachers see their own courses; staff see everything.
 */
export function canUseCourseContent(input: CourseContentAccessInput): boolean {
  if (input.status !== "Active") return false;
  if (STAFF_ROLES.has(input.role)) return true;
  if (input.role === "Teacher") return input.owner;
  return input.role === "Student" &&
    input.hasEnrollment &&
    input.hasSubscriber &&
    input.courseState.length > 0 &&
    !ADMIN_BLOCKED_STATES.has(input.courseState);
}

/** Path segment check for IDs the app generates (timestamps, UUIDs, codes). */
export function pathSegment(value: unknown, name: string): string {
  if (typeof value !== "string") throw new Error(`invalid_${name}`);
  const trimmed = value.trim();
  if (
    trimmed.length === 0 || trimmed.length > 160 || trimmed === "." ||
    trimmed === ".." || /^__.*__$/.test(trimmed) ||
    /[\/\u0000-\u001F\u007F-\u009F]/u.test(trimmed)
  ) {
    throw new Error(`invalid_${name}`);
  }
  return trimmed;
}

export const itemPath = (courseId: string, sectionId: string, itemId: string) =>
  `Courses/${courseId}/Sections/${sectionId}/Items/${itemId}`;

export const answerKeyPath = (
  courseId: string,
  sectionId: string,
  testId: string,
) => `${itemPath(courseId, sectionId, testId)}/Private/answerKey`;
