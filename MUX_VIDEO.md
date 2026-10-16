# Sintir Mux video delivery

## Architecture and authorization

Flutter authenticates with Firebase Auth and sends its Firebase ID token to Supabase Edge Functions. Functions set `verify_jwt = false` because the gateway expects Supabase JWTs; authenticated handlers verify Firebase tokens with the existing `_shared/firebase.ts` helper. That helper also provides the existing service-account Firestore REST adapter. Mux credentials and playback signing keys stay in Edge Function secrets.

Course ownership uses `Courses/{courseId}.contentcreaterentity.id`. Student access requires an active Firebase account with role `Student`, a `Published` course, and both existing enrollment records: `Users/{uid}/Courses/{courseId}` and `Courses/{courseId}/Subscribers/{uid}`.

## Upload and processing

1. Flutter calls `create-video-upload` with course/section/title/file metadata and the Firebase ID token.
2. The function verifies ownership, creates a Mux Direct Upload with `playback_policies: ["signed"]`, and writes the initial item to `Courses/{courseId}/Sections/{sectionId}/Items/{videoId}`. It also creates `MuxVideoIndex/{videoId}` for webhook lookup.
3. Flutter streams 5 MiB file ranges directly to the Mux upload URL with `Content-Range`; video bytes never pass through an Edge Function. Transfer retry retains the current session in memory.
4. Mux calls `mux-webhook`, which verifies `Mux-Signature` against the raw request body and records event IDs under `MuxWebhookEvents/{eventId}` with each metadata update. Asset-created events set `processing`; `video.asset.ready` stores the signed playback ID, duration, dimensions, and available renditions; `video.asset.errored` sets `failed`.

## Playback

Flutter requests playback only for a Mux video in `ready` state. `get-video-playback-token` resolves the playback ID from Firestore after owner/enrollment checks, signs an RS256 token on the backend, and returns an HLS `.m3u8` URL. The token is held in memory and never stored in Firestore. Better Player reads available renditions from the HLS master manifest; Auto uses adaptive bitrate selection.

Legacy records without `videoProvider: "mux"` continue using `vedioUrl`. New Mux records keep `vedioUrl` empty. Supabase Storage remains available for non-video files.

## Firestore record

Video items include `id`, `title`, `description`, `type`, `videoProvider`, `muxUploadId`, `muxAssetId`, `muxPlaybackId`, `status`, `durationSeconds`, `sourceWidth`, `sourceHeight`, `availableQualities`, `courseId`, `sectionId`, `createdBy`, `createdAt`, and `updatedAt`. Lifecycle values are `uploading`, `processing`, `ready`, `failed`, and `cancelled`. Edge Functions own Mux fields; Flutter merges only Sintir item fields when attaching an item to a section.

## Edge Functions and secrets

- `create-video-upload`: ownership check, metadata creation, signed-policy Mux upload session.
- `resume-video-upload`: checks whether Mux still considers the upload `waiting`.
- `cancel-video-upload`: cancels a waiting upload or deletes its asset, then marks the item cancelled.
- `get-video-playback-token`: course authorization and backend-only JWT signing.
- `mux-webhook`: signature verification and duplicate-safe event processing without a user JWT.

Configure these Supabase Edge Function secrets: `FB_PROJECT_ID`, `FB_CLIENT_EMAIL`, `FB_PRIVATE_KEY`, `MUX_TOKEN_ID`, `MUX_TOKEN_SECRET`, `MUX_WEBHOOK_SECRET`, `MUX_SIGNING_KEY_ID`, and `MUX_SIGNING_KEY_PRIVATE_BASE64`. Base64-encode the PEM private key before setting it. Configure the webhook at `https://<project-ref>.supabase.co/functions/v1/mux-webhook` and subscribe to upload-created/cancelled and asset-created/ready/errored events. Never put secrets in Flutter source or assets.

## Local testing and deployment

Use the dashboard repository and Supabase CLI. Put local secrets in `supabase/functions/.env` (never commit it), then run `supabase functions serve --env-file supabase/functions/.env`. Deploy each function with `supabase functions deploy <function-name> --no-verify-jwt`; handlers verify Firebase tokens and the webhook verifies Mux signatures. Set production secrets first with `supabase secrets set`. Exercise authorization failures, invalid signatures, duplicate webhooks, and each processing state in a non-production environment.

## Migration and remaining configuration

No migration runs at app startup and no legacy Supabase object is deleted. Existing `vedioUrl` records remain playable. Legacy-to-Mux migration requires an explicit reviewed backfill; no automatic migration command is included.

Mux returns the signed upload URL only when the upload session is created. The resume function can check status but cannot mint a replacement upload URL. Flutter retries in the active in-memory session; after app termination or URL expiry, create a new upload and cancel the previous session if possible. Never persist or log the signed upload URL.

Neither repository contains the deployed Firestore rules source. Before production rollout, update the authoritative Firebase rules to deny client writes to Mux-managed fields and `MuxVideoIndex`/`MuxWebhookEvents`, while preserving existing Sintir permissions. This implementation cannot safely replace the missing complete ruleset.