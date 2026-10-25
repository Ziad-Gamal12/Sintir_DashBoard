# Course checkout deployment

Course, user, enrollment, coupon, subscriber, transaction, and wallet data remain in the existing Firestore collections. The new top-level collections are `CoursePaymentAttempts` and `CourseCheckoutLocks`. No SQL migration is required.

## Checkout failure diagnostics

`create-course-payment` writes one structured log event for each completed stage and a `checkout_failed` event with the failed stage, safe error metadata, and whether a payment attempt or Paymob intention may exist. Each response includes a generated `requestId` in the error envelope when it fails and an `x-checkout-request-id` response header. Use that ID to match the client diagnostic to the Edge Function logs. Logs omit Firebase tokens, private keys, Paymob credentials, checkout secrets, and billing payloads; provider response bodies are not logged.

The client invokes the `course-checkout-quote`, `create-course-payment`, `get-course-payment-status`, and `check-course-subscription` functions with its Firebase ID token. Supabase gateway JWT verification is disabled for those functions because the token is a Firebase token; each handler verifies it against Firebase Secure Token JWKS and checks its project audience and issuer. `paymob-webhook` accepts no user token and validates the Paymob transaction HMAC before reading or changing payment data.

Configure these Edge Function secrets in Supabase (use the Firebase service account that has the minimum Firestore read/write access needed for `Courses`, `Users`, `Transactions`, and `CoursePaymentAttempts`):

- `FB_PROJECT_ID`, `FB_CLIENT_EMAIL`, `FB_PRIVATE_KEY`
- `PAYMOB_SECRET_KEY`, `PAYMOB_PUBLIC_KEY`, `PAYMOB_WEBHOOK_HMAC_SECRET`
- `PAYMOB_API_KEY` (transaction inquiry authentication)
- `PAYMOB_WALLET_INTEGRATION_ID`, `PAYMOB_ONLINE_CARD_INTEGRATION_ID`, `PAYMOB_ACCEPT_KIOSK_INTEGRATION_ID`, `PAYMOB_CASH_COLLECTION_INTEGRATION_ID`
- `COURSE_PAYMENT_RECONCILIATION_SECRET` (long random secret shared only with the scheduled caller)

For **each** enabled Payment Integration ID in the Paymob dashboard, configure its transaction-processed callback to `https://<project-ref>.supabase.co/functions/v1/paymob-webhook`. Current Paymob docs say intention `notification_url` is supported only with card integration IDs, so its presence in the intention request is a card override, not coverage for wallet/kiosk/cash methods. The app uses the hosted Unified Checkout URL; redirect parameters only resume status polling and never fulfill a payment. The reconciliation fallback uses Paymob's transaction inquiry by order ID or merchant reference for all enabled IDs.

## Scheduled reconciliation

Deploy `reconcile-course-payments` with the other functions. It requires `COURSE_PAYMENT_RECONCILIATION_SECRET` in function secrets and validates the exact `x-reconciliation-secret` header. It scans at most 500 Firestore attempts per run using a persisted page cursor and checks attempts at least two minutes old. Pending, missing, auth-only, refunded, voided, mismatched, or temporarily unavailable inquiry results retain the lock and coupon reservation. Only a transaction inquiry response that matches the attempt's reference/order, integration, EGP currency, and exact cents can fulfill. A single `pending=false, success=false` transaction is **not** sufficient to release the attempt because Unified Checkout may allow another payment try against the same order; automatic release currently occurs only when the order itself is explicitly cancelled in the inquiry response. A response with refund/void flags is recorded for review, never treated as a new payment. Paymob inquiry returns the latest transaction for an order/reference, so audit the merchant's Paymob transaction history for multiple payments or payment actions that supersede earlier state.

The SQL migration schedules a request every five minutes using Supabase Cron, `pg_net`, and Vault. Before applying `supabase/migrations/20261025000000_schedule_course_payment_reconciliation.sql`, create these Vault secrets in the Supabase SQL editor (replace the values with your project URL and server-only credentials):

```sql
select vault.create_secret('https://<project-ref>.supabase.co', 'course_checkout_project_url');
select vault.create_secret('<service-role-key>', 'course_checkout_service_role_key');
select vault.create_secret('<same random value as COURSE_PAYMENT_RECONCILIATION_SECRET>', 'course_checkout_reconciliation_secret');
```

Apply the migration with `supabase db push` from this dashboard repository. Confirm the job in Supabase Database > Cron and inspect its `net._http_response` outcomes. `pg_net` queues the HTTP request asynchronously; this SQL job does not retry a failed HTTP response itself. The next five-minute invocation retries a batch failure from the last persisted page cursor, while per-attempt inquiry failures are recorded and retried when pagination wraps to the beginning. A page cursor advances only after its page has been processed; interruption before checkpoint commit replays that page, and fulfillment is idempotent. It does not contact Paymob until there are unresolved attempts. Never put the secrets in the migration or Flutter app.

Teacher withdrawals are handled separately by `teacher-withdrawal`, which authenticates a Firebase ID token, reserves the server-side balance, and reconciles by Paymob transaction ID. The app supports mobile wallet payouts only; Paymob documents these as returning a final status in the disbursement response. Its callbacks are documented for bank and Aman transactions, which are not enabled here. The scheduled fallback checks unresolved records that have a Paymob transaction ID. A request timeout before the ID is stored still needs manual Paymob dashboard verification: Paymob documents lookup by custom reference as GET with a JSON body, which the Edge Runtime `fetch` API cannot send. Never release that reservation based only on age or timeout.

For scheduled payout reconciliation, set the `TEACHER_WITHDRAWAL_RECONCILIATION_SECRET` Edge Function secret and create these Vault values before applying `supabase/migrations/20261025010000_schedule_teacher_withdrawal_reconciliation.sql`:

```sql
select vault.create_secret('https://<project-ref>.supabase.co', 'teacher_withdrawal_project_url');
select vault.create_secret('<service-role-key>', 'teacher_withdrawal_service_role_key');
select vault.create_secret('<same random value as TEACHER_WITHDRAWAL_RECONCILIATION_SECRET>', 'teacher_withdrawal_reconciliation_secret');
```

The job runs every five minutes and pages through teacher accounts. It retries unresolved records with a Paymob transaction ID; page-level failures do not advance the cursor, and per-withdrawal failures are retried on later scans. Records without a provider ID remain reserved for manual review. Inspect Cron and `net._http_response` after applying the migration.

The scheduler does not infer failure from age or a timeout. If Paymob has no transaction inquiry record, or reports a failed transaction while the order remains open, the attempt remains reserved for manual review; this avoids duplicate charging but can hold a coupon/checkout lock indefinitely. Automatic failure is currently limited to a final cancelled order state (`is_cancel`, `is_canceled`, `CANCELLED`, or `CANCELED`). The current account's intention expiration behavior and an authoritative expiry status were not available to verify, so an aged or apparently expired order remains held until an operator confirms it cannot still settle.

## Callback support and test matrix

| Payment method | Intention `notification_url` | Dashboard callback | Inquiry fallback | Required test |
| --- | --- | --- | --- | --- |
| Online card | Supported by current Paymob intention docs | Configure for its integration ID | Yes | success, decline, auth-only then capture, refund, void |
| Wallet | Not supported as an intention override | Configure the integration ID; verify delivery with Paymob's webhook tester | Yes; poll while pending | success, decline, delayed status, duplicate, refund/void |
| Accept kiosk | Not supported as an intention override | Configure the integration ID; verify whether this account sends processed callbacks | Yes; poll during cash-pending lifecycle | pending before payment, later paid, cancelled/declined, duplicate |
| Cash collection | Not supported as an intention override | Configure the integration ID and verify callback behavior with Paymob for this account | Yes; poll until a definitive inquiry result | pending, later paid, cancelled/declined, duplicate |

For every method, test signed success/failure, invalid HMAC, incorrect amount/currency/integration/order, exact duplicate callbacks, delayed callbacks, refund and void action callbacks, and unexpected state transitions. The repository cannot verify your account-specific integration IDs or dashboard callback configuration without access to that Paymob account. The current docs explicitly scope `notification_url` to card IDs; dashboard callback configuration is needed per ID and must be exercised in test mode before enabling a method.

## Firestore rules status

The Flutter repository has Firebase app configuration but no Firestore rules file or deployment target, and the currently deployed rules are not available here. The separate `firestore.rules.proposed` file in the Flutter repository is a focused draft for checkout-owned records and financial fields; it is not production verified and is not wired into `firebase.json`. Dashboard code loads staff roles and active status from `Users/{uid}`; no Firebase custom admin-claim setup was found. The draft therefore checks an active `Admin` user document. It remains unverified against actual deployed rules and all administrative workflows. The legacy Flutter wallet setter and transaction reconciliation repository have no active call sites and now fail closed; withdrawals use the authenticated `teacher-withdrawal` Edge Function, while course earnings are credited by shared payment fulfillment. Edge Function service-account writes bypass client rules. The teacher signup client still creates a wallet with zero balances and a suspended status; the proposed rules constrain that initialization and deny later client wallet mutations.

From the dashboard repository, deploy with:

```powershell
supabase secrets set --env-file supabase/functions/.env
supabase functions deploy course-checkout-quote
supabase functions deploy create-course-payment
supabase functions deploy get-course-payment-status
supabase functions deploy check-course-subscription
supabase functions deploy paymob-webhook
supabase functions deploy reconcile-course-payments
supabase functions deploy teacher-withdrawal
```

The local `.env` should be created from `.env.example`, filled only with test credentials, and kept untracked. Do not use production credentials for local automated tests.

Normal checkout moves from `creating` to `pending`, then `succeeded` or `failed`; an ambiguous intention response is retained as `creation_unknown` for inquiry/callback recovery. `paid_requires_review` means Paymob reports the order paid but fulfillment cannot be attributed safely (for example, an enrollment already exists or order status conflicts with the latest transaction). Enrollment is not duplicated, and support must resolve the payment/refund. `paymentLifecycleState` and reconciliation diagnostics record later refunds, voids, duplicate successful transactions, and open-order failures without silently reversing wallet or enrollment state. Fulfillment writes enrollment, subscriber, course count, teacher wallet, transaction copies, coupon usage, and the terminal successful attempt status in one Firestore transaction. If Firestore rejects that transaction, the webhook returns a non-2xx response so Paymob can retry.

## Test-mode rollout checklist

1. In Paymob test mode, obtain the test Secret Key, Public Key, HMAC Secret, API Key, and test IDs for the payment methods you will enable. Do not mix test/live Secret or Public Keys with integration IDs.
2. Set function secrets from a local untracked `.env` copied from `.env.example`; include Firebase service-account values, Paymob test credentials, and a generated reconciliation secret. Confirm the Flutter binary has no Paymob secret or API key.
3. Configure the transaction-processed callback URL on every enabled test integration in Paymob. Verify delivery with Paymob's webhook tester. Paymob documents the intention `notification_url` override only for card IDs.
4. In Supabase, create the course and withdrawal Vault secrets described above, deploy all six checkout functions plus `teacher-withdrawal`, then apply both Cron migrations. Verify both jobs are active.
5. With a test course/student, exercise no coupon, partial coupon, exhausted coupon, full-discount coupon, concurrent checkout, already-enrolled, and missing-phone flows. Confirm amounts are cents and the UI only reports success after backend status is `succeeded`.
6. For each enabled integration, complete the callback/inquiry matrix, including failures, delayed updates, duplicates, altered HMAC/amount/currency/integration/order, refund, and void. Confirm unknown or open-order failure states retain the checkout lock and coupon reservation.
7. Inspect Firestore for exactly one enrollment, subscriber, count increment, set of three transaction records, teacher credit, and coupon use per successful Paymob transaction. Verify duplicate delivery does not repeat any side effect; verify a second paid transaction or refund leaves a review marker.
8. With Paymob test payout credentials and an eligible test teacher, verify a withdrawal reserves balance and creates one transaction record; repeat the same idempotency key, then exercise a definitive success/failure and a pending or ambiguous provider response. Confirm failure restores the reserved amount once, while an ambiguous response keeps it reserved until reconciliation. Confirm a retry after client timeout reuses its persisted per-teacher idempotency key, and the scheduled reconciliation resolves pending withdrawals that have a provider ID.
9. Do not deploy the proposed Firestore rules until they are merged with the actual deployed rules, custom admin claim scheme, and teacher payout workflows, then run emulator Rules tests against the complete app ruleset.
# Interrupted checkout recovery

`CourseCheckoutLocks` is resolved from the authenticated Firebase UID and exact course ID before a new quote or payment attempt is reserved. The lock's attempt ID must resolve to a record whose UID and course ID match. Missing or mismatched records are retained for privileged review; age, app closure, a redirect, and an empty Paymob inquiry never clear a lock.

When a lock points to an active attempt, `create-course-payment` inquires by its persisted Paymob order ID and stable `paymobSpecialReference` before returning the original attempt. A confirmed success uses the shared fulfillment transaction. A terminal cancellation/failure releases only that attempt's owned lock and coupon reservation. A pending/open order returns the same attempt, checkout URL, and persisted quote with `resumedExisting` and `requiresConfirmation`; the app displays the original amount/coupon before opening it. An unknown intention without a stored URL returns `verification_required`; the app can poll `get-course-payment-status`, which rate-limits provider inquiries to one per attempt per 30 seconds. Status checks never create intentions.

Attempts persist `providerRequestState` before the external intention request, so recovery knows that a request may have reached Paymob. `creating` and `creation_unknown` remain in scheduled reconciliation; an inquiry miss or provider error leaves the attempt, lock, and reservation intact. Do not manually retry an intention for these attempts unless Paymob has authoritatively established that no payable order exists.

New coupon-backed attempts record `couponReservationState`. Terminal failure cleanup changes `reserved` to `released` in the same transaction as the attempt status and exact lock deletion; successful payment consumes the reservation in the same transaction as fulfillment. Repeated cleanup does not decrement it again. Successful fulfillment keeps a terminal marker in the same lock document, while paid review-required attempts keep their lock, so a new charge cannot start. For older records whose successful path deleted its lock, a single-field Firestore query checks the caller's prior confirmed attempts before allowing a new charge.
