# Course feedback and star ratings

Two Edge Functions own every write to course feedback and rating stats. Both take a JSON `POST` with the caller's **Firebase ID token** (`Authorization: Bearer <idToken>`), exactly like `check-course-subscription`; gateway JWT verification is disabled in `config.toml` and each handler verifies the token itself.

Rules live in `_shared/feedback_logic.ts` (pure). Firestore orchestration and the HTTP handler live in `_shared/course_feedback.ts`. Each request runs in **one Firestore transaction**; contention (409) and outages (503) are retried up to 3 attempts with jittered backoff, then the client gets `busy`.

## `upsert-course-feedback`

Create or edit the caller's own feedback.

```json
{ "courseId": "123", "rating": 4, "text": "optional, max 500 chars", "teacherId": "optional hint" }
```

- `rating`: integer 1–5 (required). `text`: optional; trimmed, control characters removed.
- `teacherId`: optional, untrusted hint (the course's `contentcreaterentity.id`). It only lets the function prefetch the teacher's copy in the same read round trip; a wrong value is ignored.
- Allowed for: an **Active Student** with both `Users/{uid}/Courses/{courseId}` and `Courses/{courseId}/Subscribers/{uid}`, on a `Published` course they do not own (same rule as video playback).
- Name and image are taken from `Users/{uid}` (`firstName lastName`, `profilePicurl`); the body cannot set them.
- One save per student per 3 seconds (`too_many_requests`).

`200`:

```json
{
  "ok": true,
  "created": true,
  "feedback": { "uid": "…", "name": "Ziad Gamal", "userImage": "https://…", "fedBack": "…", "rating": 4,
                "datePosted": "2026-11-17T10:00:00.000Z", "updatedAt": "2026-11-17T10:00:00.000Z" },
  "stats": { "ratingsSum": 9, "ratingsCount": 2, "averageRating": 4.5,
             "ratingDistribution": { "1": 0, "2": 0, "3": 0, "4": 1, "5": 1 }, "feedBacksCount": 3 }
}
```

## `delete-course-feedback`

```json
{ "courseId": "123", "feedbackUid": "optional, defaults to the caller", "teacherId": "optional hint" }
```

- A student (Active) may delete only their own feedback. An `Admin` (dashboard) may delete any. Course teachers cannot delete feedback.
- Permission is checked before existence, so students cannot probe other students' feedback.

`200`: `{ "ok": true, "deleted": true, "stats": { … } }` (`stats` is `null` if the course document no longer exists).

## Errors

Every error is `{ "ok": false, "error": { "code": "…", "message": "…" } }`.

| Code | Status | When |
|---|---|---|
| `unauthorized` | 401 | Missing/invalid Firebase ID token |
| `invalid_body`, `payload_too_large` | 400, 413 | Not a JSON object, or over 16 KB |
| `invalid_course_id`, `invalid_feedback_id` | 400 | Unsafe or missing IDs |
| `invalid_rating`, `invalid_text`, `text_too_long` | 400 | Input validation |
| `not_found` / `feedback_not_found` | 404 | Course or user / feedback missing |
| `not_subscribed`, `own_course`, `not_student`, `inactive_user` | 403 | Not allowed to rate |
| `forbidden` | 403 | Not allowed to delete this feedback |
| `course_unavailable` | 409 | Course is not `Published` |
| `busy` | 409 | Contention persisted after 3 attempts: show "try again" |
| `too_many_requests` | 429 | Saved again within 3 seconds |
| `internal_error` | 500 | Logged as `<function>_failed` without request data |

## What one request writes (single commit)

| Document | Upsert | Delete |
|---|---|---|
| `Courses/{c}/Feedbacks/{uid}` | create, or update `rating, fedBack, name, userImage, updatedAt` (never `uid`/`datePosted`) | delete |
| `Courses/{c}` | stats fields, only if they changed | stats fields |
| `Users/{teacherId}/Courses/{c}` | same stats, only if the copy exists | same |
| `Users/{uid}/Courses/{c}` (enrollment) | `myRating`, only if it changed | removes `myRating` |

Stats fields: `ratingsSum, ratingsCount, averageRating, ratingDistribution, feedBacksCount`. Courses without them read as zero. The app should read `averageRating` as `(json['averageRating'] as num?)?.toDouble() ?? 0` because whole averages are stored as integers. Student enrollment snapshots are not updated with stats; read live stats from `Courses/{c}`.

## Deploy

Uses the existing `FB_PROJECT_ID`, `FB_CLIENT_EMAIL`, `FB_PRIVATE_KEY` secrets; nothing new to configure.

```sh
supabase functions deploy upsert-course-feedback
supabase functions deploy delete-course-feedback
```

Tests (from the dashboard repository root):

```sh
deno test --allow-env supabase/functions/_shared/
```

## Security note

The Firestore rules currently deployed allow any signed-in client to write any document, so these functions are the intended writer but not yet the only possible one. Before release, rules must deny client writes to `Courses/{c}/Feedbacks/*` and to the stats fields above.
