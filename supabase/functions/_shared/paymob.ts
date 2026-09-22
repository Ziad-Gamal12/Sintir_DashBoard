import { requiredSecret } from "./firebase.ts";

const baseUrl = "https://stagingpayouts.paymobsolutions.com/api/secure/";

/** A non-2xx response means Paymob did not accept this payout request. */
export class PaymobDisbursementRejected extends Error {
  constructor(message: string) {
    super(message);
    this.name = "PaymobDisbursementRejected";
  }
}

function basicAuthorization(): string {
  const credentials = `${requiredSecret("PAYMOB_PAYOUT_CLIENT_ID")}:${requiredSecret("PAYMOB_PAYOUT_CLIENT_SECRET")}`;
  return `Basic ${btoa(credentials)}`;
}

async function accessToken(): Promise<string> {
  const response = await fetch(`${baseUrl}o/token/`, {
    method: "POST",
    headers: {
      authorization: basicAuthorization(),
      "content-type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "password",
      username: requiredSecret("PAYMOB_PAYOUT_USERNAME"),
      password: requiredSecret("PAYMOB_PAYOUT_PASSWORD"),
    }),
  });
  if (!response.ok) throw new Error("Paymob authentication failed.");
  const body = await response.json();
  if (typeof body.access_token !== "string") throw new Error("Paymob returned no access token.");
  return body.access_token;
}

export async function disburse(input: { amount: number; mobileNumber: string; issuer: string; reference: string }) {
  const response = await fetch(`${baseUrl}disburse/`, {
    method: "POST",
    headers: { authorization: `Bearer ${await accessToken()}`, "content-type": "application/json" },
    body: JSON.stringify({
      issuer: input.issuer,
      amount: input.amount,
      msisdn: input.mobileNumber,
      client_reference_id: input.reference,
    }),
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new PaymobDisbursementRejected(
      typeof body.error_description === "string"
        ? body.error_description
        : "Paymob disbursement was rejected.",
    );
  }
  const transactionId = body.transaction_id?.toString();
  if (!transactionId) throw new Error("Paymob response did not include a transaction ID.");
  return { transactionId, status: (body.disbursement_status ?? "PENDING").toString().toUpperCase(), raw: body };
}

export async function inquire(transactionId: string): Promise<Record<string, unknown>> {
  const response = await fetch(`${baseUrl}transaction/inquire/`, {
    method: "GET",
    headers: { authorization: `Bearer ${await accessToken()}`, "content-type": "application/json" },
    body: JSON.stringify({ transactions_ids_list: [transactionId], bank_transactions: false }),
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error("Could not obtain Paymob payout status.");
  return Array.isArray(body.results) ? (body.results[0] ?? {}) : body;
}
