import { isVideoPlaybackAuthorized } from "./video.ts";

const access = (
  overrides: Partial<Parameters<typeof isVideoPlaybackAuthorized>[0]> = {},
) =>
  isVideoPlaybackAuthorized({
    role: "Student",
    status: "Active",
    owner: false,
    courseState: "Published",
    hasEnrollment: true,
    hasSubscriber: true,
    ...overrides,
  });

Deno.test("active enrolled students can request playback for a published course", () => {
  if (!access()) throw new Error("An enrolled student was denied playback.");
});

Deno.test("playback rejects missing enrollment, subscriber, inactive users, and unpublished courses", () => {
  for (
    const overrides of [
      { hasEnrollment: false },
      { hasSubscriber: false },
      { status: "Blocked" },
      { status: "Pending" },
      { courseState: "Archived" },
      { courseState: "DeletedByAdmin" },
    ]
  ) {
    if (access(overrides)) {
      throw new Error(
        `Unauthorized playback was allowed: ${JSON.stringify(overrides)}`,
      );
    }
  }
});

Deno.test("enrolled students keep playback while the course is archived by its teacher or in review", () => {
  for (const courseState of ["DeletedByTeacher", "Pending", "Declined"]) {
    if (!access({ courseState })) {
      throw new Error(`Enrolled student lost playback in ${courseState}.`);
    }
  }
});

Deno.test("active teachers can request playback only for their own course", () => {
  if (!access({ role: "Teacher", owner: true })) {
    throw new Error("Course owner was denied playback.");
  }
  if (access({ role: "Teacher", owner: false })) {
    throw new Error("Non-owner teacher was allowed playback.");
  }
  if (access({ role: "Admin", owner: true })) {
    throw new Error("Unsupported role was allowed playback.");
  }
});
