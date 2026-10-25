import { idempotencyPayloadMatches, isFinalPayoutStatus, payoutDisposition, providerResponseMatches, providerResponseMatchesForManualResolution } from "./withdrawal_logic.ts";

Deno.test("same idempotency key replays only the same withdrawal payload", () => {
  const request = { amountCents: 12500, issuer: "vodafone", mobileNumber: "01012345678" };
  if (!idempotencyPayloadMatches(request, { ...request })) throw new Error("Identical retry was rejected.");
  if (idempotencyPayloadMatches(request, { ...request, amountCents: 13000 })) throw new Error("Changed amount was accepted.");
  if (idempotencyPayloadMatches(request, { ...request, mobileNumber: "01087654321" })) throw new Error("Changed recipient was accepted.");
});

Deno.test("delayed pending response can advance, while final states stay terminal", () => {
  if (isFinalPayoutStatus("pending")) throw new Error("Pending was treated as final.");
  if (!isFinalPayoutStatus("successful") || !isFinalPayoutStatus("failed")) throw new Error("Provider terminal status was not recognized.");
  if (payoutDisposition("pending") !== "retain" || payoutDisposition("PROCESSING_UNKNOWN") !== "retain") throw new Error("An unresolved payout would release reserved funds.");
  if (payoutDisposition("successful") !== "consume") throw new Error("A successful payout would restore its reserved balance.");
  if (payoutDisposition("failed") !== "restore") throw new Error("A definitive payout failure would not restore its reserved balance.");
});

Deno.test("provider result must correlate to the reserved request before settlement", () => {
  const expected = { transactionId: "tx-1", amount: 125, issuer: "vodafone", mobileNumber: "01012345678", reference: "request-1" };
  if (!providerResponseMatches({ transaction_id: "tx-1", amount: 125, issuer: "vodafone", msisdn: "01012345678", reference: "request-1" }, expected)) {
    throw new Error("Matching provider result was rejected.");
  }
  if (providerResponseMatches({ transaction_id: "tx-2", amount: 125, issuer: "vodafone", msisdn: "01012345678" }, expected)) {
    throw new Error("Different provider transaction was accepted.");
  }
  if (providerResponseMatches({ transaction_id: "tx-1", amount: 126, issuer: "vodafone", msisdn: "01012345678" }, expected)) {
    throw new Error("Different payout amount was accepted.");
  }
});

Deno.test("manual resolution requires complete provider transaction identity", () => {
  const expected = { transactionId: "tx-1", amount: 125, issuer: "vodafone", mobileNumber: "01012345678", reference: "provider-ref-1" };
  const matching = { transaction_id: "tx-1", amount: 125, issuer: "vodafone", msisdn: "01012345678", reference: "provider-ref-1" };
  if (!providerResponseMatchesForManualResolution(matching, expected)) throw new Error("Complete matching provider identity was rejected.");
  if (!providerResponseMatchesForManualResolution({ ...matching, amount: "125" }, expected)) throw new Error("Vodafone's documented string amount was rejected.");
  if (providerResponseMatchesForManualResolution({ ...matching, amount: undefined }, expected)) throw new Error("Manual review accepted a missing amount.");
  if (providerResponseMatchesForManualResolution({ ...matching, reference: "other-ref" }, expected)) throw new Error("Manual review accepted a mismatched provider reference.");
});
