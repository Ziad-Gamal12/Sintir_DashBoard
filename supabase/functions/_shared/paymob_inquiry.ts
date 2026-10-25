import { requiredSecret } from "./firebase.ts";

let cachedToken: { value: string; expiresAt: number } | undefined;

async function authToken(): Promise<string> {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60_000) return cachedToken.value;
  const response = await fetch("https://accept.paymob.com/api/auth/tokens", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ api_key: requiredSecret("PAYMOB_API_KEY") }),
  });
  const body = await response.json().catch(() => ({}));
  const token = body.token ?? body.auth_token;
  if (!response.ok || typeof token !== "string") throw new Error("paymob_inquiry_auth_failed");
  cachedToken = { value: token, expiresAt: Date.now() + 50 * 60_000 };
  return token;
}

/** Retrieve Paymob's latest transaction for this intention's order/reference. */
export async function inquireIntention(input: { orderId?: string; merchantReference: string }): Promise<Record<string, any> | null> {
  const response = await fetch("https://accept.paymob.com/api/ecommerce/orders/transaction_inquiry", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      auth_token: await authToken(),
      order_id: input.orderId || "",
      merchant_order_id: input.merchantReference,
    }),
  });
  const body = await response.json().catch(() => ({}));
  if (response.status === 404 || response.status === 204) return null;
  if (!response.ok) {
    console.error("Paymob transaction inquiry failed", { status: response.status });
    throw new Error("paymob_inquiry_failed");
  }
  return body && typeof body === "object" && Object.keys(body).length ? body : null;
}
