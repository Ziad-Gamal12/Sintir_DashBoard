# Account deletion (`delete-account`)

Required by Google Play and the App Store: a user can delete their account and its
data from inside the app.

## Request

`POST /functions/v1/delete-account` with `Authorization: Bearer <Firebase ID token>`
and body `{ "acknowledgeBalance": boolean }`.

The ID token must come from a sign-in in the last 5 minutes (`auth_time`). The app
signs the user in again (password, Google or Facebook) right before calling.

## What happens

| Data | Result |
| --- | --- |
| `Users/{uid}` and every subcollection | deleted |
| Reviews written by the user | deleted, course rating stats updated |
| Enrollments (`Courses/*/Subscribers/{uid}`) | deleted, `studentsCount` - 1 |
| Progress (`JoinedBy`), video notes, test results | deleted |
| Support tickets and their messages | deleted |
| Files in `Users/{uid}/`, `Support/{uid}/`, profile photo | deleted |
| Course reports the user filed | kept, `reporterId` = `deleted-account` |
| Review reports the user filed | kept, `reportedBy` = `deleted-account` |
| Payment records (`Transactions`, course copies) | kept for accounting, `mobile` removed |
| Teacher payouts (`Users/{uid}/Transactions` with `method: PayOut`) | copied to `ArchivedWithdrawals/{uid}_{id}` without `mobile` |
| Teacher course with at least one subscriber | kept for its students: state `DeletedByTeacher`, `ownerAccountDeleted: true`, teacher name and photo replaced, coupons deleted |
| Teacher course with no subscriber | deleted with sections, items, answer keys, files and Mux videos |
| Firebase Auth account | deleted last |
| `DeletedAccounts/{uid}` | audit record without personal data |

## Refusals

| Code | When |
| --- | --- |
| `requires_recent_login` | sign-in older than 5 minutes |
| `staff_account` | Admin, CoursesManager, UsersManager, Support |
| `payout_pending` | teacher wallet has `payout_pending > 0` |
| `balance_remaining` | teacher wallet has a balance and `acknowledgeBalance` is not `true` |
| `payment_in_progress` | a checkout attempt in `creating`, `creation_unknown` or `pending` from the last 2 hours |
| `deletion_incomplete` (503) | anything failed part-way; the account stays in status `Deleting` and the same call continues it |

## Deploy

1. Deploy the Firestore indexes first (collection-group field overrides for
   `JoinedBy.uid`, `VideoNotes.user.uid`, `Results.joinedby.uid`, `Feedbacks.uid`,
   `Reports.reporterId`). Without them the function answers `deletion_incomplete`.
   From the `Sintir` folder: `firebase deploy --only firestore:indexes --project sintir-2f0be`.
2. `npx supabase functions deploy delete-account --project-ref lsblauupczaxktmrpsmv`.
3. The Firebase service account (`FB_CLIENT_EMAIL`) needs the
   "Firebase Authentication Admin" role (the default `firebase-adminsdk` account has it).
4. Mux and Supabase secrets are the ones the other functions already use.
