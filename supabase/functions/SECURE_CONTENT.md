# Secure content: tests, files, uploads

The app signs in with Firebase, so Supabase treats every app request as anonymous.
Anything that must not be trusted to the phone runs in these Edge Functions, all
called with the user's Firebase ID token (`verify_jwt = false`, checked in code).

| Function | What it does |
| --- | --- |
| `submit-test-attempt` | Grades a course test on the server and stores the result |
| `create-upload-url` | Returns a one-time signed upload slot at a server-chosen path |
| `get-course-file-url` | Returns a one-hour signed URL for a course file |

Shared policy: `_shared/course_access.ts`. Enrolled students keep access to
lessons, files and tests while a course is published, archived by its teacher,
or back in review after an edit. Only an admin take-down (`Archived`,
`DeletedByAdmin`) removes access. `firestore.rules` in the app repo applies the
same policy to direct reads.

## Tests

- The teacher's app writes two documents per test in one batch:
  - `Courses/{c}/Sections/{s}/Items/{t}`: the questions without `isCorrect` or
    `solutionUrl` (students can read this).
  - `.../Items/{t}/Private/answerKey`: the full questions (teacher and server only).
- `submit-test-attempt` body: `{ courseId, sectionId, testId, answers: { [questionId]: answerText } }`.
  It checks that the caller is an active, enrolled student and that attempts
  remain, then writes in one transaction:
  - `.../Items/{t}/Results/{uid}-attempt-{n}` for the teacher;
  - `Users/{uid}/MyResults/{same id}` (with `teacherId`) for the student,
    without the per-question review when the teacher hides results;
  - `Users/{uid}/MyMistakes/{questionId}` for wrong answers (only when results
    are shown).
  Result IDs are numbered per attempt, so two parallel submissions cannot both
  take the last attempt.
- Tests saved before this change (answers inside the item) are still graded
  from the item. Re-save them from the app to move the answers into the key.

## Files and uploads

- Course files (PDF, Office, text) go to the private `CourseFiles` bucket under
  `{courseId}/{uuid}.{ext}`; the item stores that path in `filePath`.
- Posters, test images, avatars and support images stay in the public
  `Courses`, `Users` and `Support` buckets under `{uid}/{uuid}.{ext}`.
- `create-upload-url` body: `{ purpose, fileName, sizeBytes, courseId? }` with
  purpose `avatar`, `support`, `course_media` or `course_file`. It checks the role,
  course ownership (for `course_file`), file type and size.
- `get-course-file-url` body: `{ courseId, sectionId, itemId }`. Owner, staff and
  enrolled students get a signed URL. Items whose `filePath` is still a full URL
  (uploaded before) are returned unchanged.

## Deploy

```bash
supabase db push            # migrations/20261118000000_lock_storage_buckets.sql
supabase functions deploy submit-test-attempt create-upload-url get-course-file-url get-video-playback-token
```

`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are provided to Edge Functions
by Supabase. The functions also need the existing Firebase service-account
secrets used by the checkout functions.

After `db push`, check Storage > Policies: the four buckets should have no
policies for `anon`, `authenticated` or `public`.

Tests: `deno test --allow-env _shared/`.
