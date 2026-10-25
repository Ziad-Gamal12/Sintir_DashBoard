# Teacher withdrawal recovery

## Provider reference and automatic reconciliation

Each accepted app request is keyed by its Firestore withdrawal UUID. Before any Paymob request, the function also generates and stores a distinct UUID in `client_reference_id`, then sends that stable provider reference with the payout. A retry with the app key returns the saved withdrawal and does not submit another payout. Mobile wallet payouts use the Egypt Payout API and are expected to return a final status in the disbursement response; unresolved requests with a saved Paymob transaction ID are polled by the scheduled reconciler.

The API's documented inquiry-by-reference route is `GET /api/secure/transaction/inquire/by-reference/` with a JSON body. Deno Fetch does not support a GET body. This implementation therefore does not call that route or invent a query-string/POST variant. Requests where Paymob may have accepted the payout but no transaction ID was saved stay reserved and are surfaced for manual review.

## Admin resolution when a Paymob transaction exists

An operator must use the Paymob Payout portal or official Paymob report to find the payout using the stored `client_reference_id`, then submit the provider transaction ID to the authenticated `teacher-withdrawal` function:

```json
{
  "action": "admin_manual_resolve",
  "teacherUid": "<teacher Firebase UID>",
  "withdrawalId": "<app withdrawal UUID>",
  "paymobTransactionId": "<Paymob transaction ID>"
}
```

The caller must be a Firebase user whose `Users/{uid}` document has `role: "Admin"` and `status: "Active"`. The server queries Paymob by transaction ID and requires the returned transaction ID, amount, issuer, mobile number, and custom reference to exactly match the reserved withdrawal. Only a provider terminal success consumes the reservation; only a terminal failure restores it. Pending or mismatched responses remain reserved. The transaction document records the operator UID, decision, provider transaction ID, and time. A second request cannot repeat settlement because the Firestore transaction checks `isReconciled` and atomically updates both the wallet and withdrawal.

## No Paymob transaction ID was returned

Keep the withdrawal reserved. An authorized operator should search the Paymob portal/report using the stored custom reference, contact Paymob support if the portal cannot establish the outcome, and retain the report or support case reference with the incident. Do not retry the payout and do not restore the wallet from elapsed time or an operator assertion alone. If Paymob later identifies a transaction, use `admin_manual_resolve`; its API inquiry must verify the transaction identity and amount before settlement.

If Paymob confirms that it created no transaction and cannot provide a transaction ID, this app has no automatic release path. The documented by-reference API cannot currently be called safely from Deno Fetch, and an audited no-payout wallet release is intentionally not exposed. This leaves funds reserved until a supported provider verification path is confirmed and implemented. There is no production-ready resolution for that edge case in this revision.

## Operational controls

- Restrict `Users/{uid}.role` and `status` writes to trusted administrators in the production Firestore rules. The role check in this Edge Function reads those server-side fields, but Firestore rules for this project have not been verified or deployed here.
- Configure the Supabase secret `TEACHER_WITHDRAWAL_RECONCILIATION_SECRET` and the scheduled migration only after reviewing the target project and test environment.
- Use only Paymob staging credentials for integration checks. Never replay a withdrawal against live credentials to test recovery.
- Review `PROCESSING_UNKNOWN`, `REVIEW_REQUIRED`, and missing-reference records as held liabilities; do not treat them as failed withdrawals.
