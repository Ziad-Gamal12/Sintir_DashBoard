export type WithdrawalRequestIdentity = {
  amountCents: number;
  issuer: string;
  mobileNumber: string;
};

export function idempotencyPayloadMatches(
  stored: WithdrawalRequestIdentity,
  requested: WithdrawalRequestIdentity,
): boolean {
  return stored.amountCents === requested.amountCents
    && stored.issuer === requested.issuer
    && stored.mobileNumber === requested.mobileNumber;
}

export function isFinalPayoutStatus(status: string): boolean {
  return ["FAILED", "REJECTED", "CANCELLED", "SUCCESS", "SUCCESSFUL", "COMPLETED", "APPROVED"].includes(status.toUpperCase());
}

export function payoutDisposition(status: string): "restore" | "consume" | "retain" {
  const normalized = status.toUpperCase();
  if (["FAILED", "REJECTED", "CANCELLED"].includes(normalized)) return "restore";
  if (["SUCCESS", "SUCCESSFUL", "COMPLETED", "APPROVED"].includes(normalized)) return "consume";
  return "retain";
}

export function providerResponseMatches(
  result: Record<string, unknown>,
  expected: { transactionId?: string; amount?: number; issuer: string; mobileNumber: string; reference: string },
): boolean {
  const id = result.transaction_id;
  const amount = result.amount;
  const issuer = result.issuer;
  const mobile = result.msisdn;
  const reference = result.reference ?? result.client_reference_id;
  const amountNumber = typeof amount === "number" || typeof amount === "string" ? Number(amount) : Number.NaN;
  return id != null && String(id) === expected.transactionId
    && Number.isFinite(amountNumber) && amountNumber === expected.amount
    && issuer === expected.issuer
    && mobile === expected.mobileNumber
    && (reference == null || reference === expected.reference);
}

/** Manual resolution must have a complete provider identity, not a partial match. */
export function providerResponseMatchesForManualResolution(
  result: Record<string, unknown>,
  expected: { transactionId: string; amount: number; issuer: string; mobileNumber: string; reference: string },
): boolean {
  const amountNumber = typeof result.amount === "number" || typeof result.amount === "string"
    ? Number(result.amount)
    : Number.NaN;
  return String(result.transaction_id ?? "") === expected.transactionId
    && Number.isFinite(amountNumber) && amountNumber === expected.amount
    && result.issuer === expected.issuer
    && result.msisdn === expected.mobileNumber
    && (result.reference ?? result.client_reference_id) === expected.reference;
}
