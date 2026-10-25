import { corsHeaders } from "./http.ts";

export type CheckoutStage =
  | "request_received"
  | "firestore_client_initialization"
  | "firebase_identity_verification"
  | "firebase_identity_verified"
  | "request_parsing"
  | "request_validated"
  | "idempotency_lookup"
  | "idempotency_checked"
  | "course_quote_loading"
  | "course_loaded"
  | "coupon_validated"
  | "billing_data_validation"
  | "billing_validated"
  | "paymob_configuration"
  | "configuration_validated"
  | "checkout_reservation"
  | "checkout_reservation_created"
  | "free_enrollment_fulfillment"
  | "paymob_intention_requested"
  | "paymob_intention_responded"
  | "paymob_response_parsing"
  | "paymob_intention_created"
  | "attempt_failure_persistence"
  | "payment_attempt_persistence"
  | "payment_attempt_persisted"
  | "checkout_response_ready"
  | "checkout_failed";

export function checkoutRequestId(): string {
  return crypto.randomUUID();
}

function redactDiagnosticText(value: string): string {
  return value
    .replace(/-----BEGIN [^-]+-----[\s\S]*?-----END [^-]+-----/gi, "[redacted-key]")
    .replace(/\b(Bearer|Token)\s+[^\s,;"']+/gi, "$1 [redacted]")
    .replace(/((?:client[_-]?secret|api[_-]?key|secret[_-]?key|access[_-]?token|refresh[_-]?token|password|private[_-]?key)\s*[=:]\s*)[^\s,;"']+/gi, "$1[redacted]")
    .replace(/([?&](?:clientSecret|client_secret|token|api_key|secret)=)[^&#\s]+/gi, "$1[redacted]")
    .slice(0, 1200);
}

export function diagnosticError(cause: unknown): { name: string; message: string; stack?: string } {
  if (!(cause instanceof Error)) {
    return { name: typeof cause, message: redactDiagnosticText(String(cause)) };
  }
  return {
    name: redactDiagnosticText(cause.name || "Error").slice(0, 100),
    message: redactDiagnosticText(cause.message || "Unknown error"),
    ...(cause.stack ? { stack: redactDiagnosticText(cause.stack).split("\n").slice(0, 8).join("\n") } : {}),
  };
}

export function logCheckoutEvent(
  requestId: string,
  stage: CheckoutStage,
  details: Record<string, unknown> = {},
): void {
  console.info(JSON.stringify({ function: "create-course-payment", requestId, stage, ...details }));
}

export function checkoutResponse(body: unknown, requestId: string, status = 200): Response {
  const headers = new Headers({ ...corsHeaders, "content-type": "application/json" });
  headers.set("x-checkout-request-id", requestId);
  return new Response(JSON.stringify(body), { status, headers });
}

export function checkoutErrorResponse(
  code: string,
  message: string,
  status: number,
  requestId: string,
): Response {
  return checkoutResponse({ ok: false, error: { code, message, requestId } }, requestId, status);
}
