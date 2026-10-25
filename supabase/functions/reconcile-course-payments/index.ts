import { Firestore } from "../_shared/firebase.ts";
import { error, json } from "../_shared/http.ts";
import { attemptsCollection, createWrite, decodeFields, firestoreDocument, reconcileAttempt, safeError, updateAttempt, updateWrite } from "../_shared/course_checkout.ts";
import { requiredSecret } from "../_shared/firebase.ts";
import { inquireIntention } from "../_shared/paymob_inquiry.ts";

function equalSecret(left: string | null, right: string): boolean {
  if (!left) return false;
  const a = new TextEncoder().encode(left);
  const b = new TextEncoder().encode(right);
  let diff = a.length ^ b.length;
  for (let i = 0; i < Math.max(a.length, b.length); i++) diff |= (a[i] ?? 0) ^ (b[i] ?? 0);
  return diff === 0;
}

Deno.serve(async (request) => {
  if (request.method !== "POST") return error("method_not_allowed", "Use POST.", 405);
  if (!equalSecret(request.headers.get("x-reconciliation-secret"), requiredSecret("COURSE_PAYMENT_RECONCILIATION_SECRET"))) return error("unauthorized", "Reconciliation authentication failed.", 401);
  const db = new Firestore();
  const now = Date.now();
  const counts: Record<string, number> = {};
  try {
    const checkpointPath = "CoursePaymentReconciliation/checkpoint";
    const checkpoint = await db.get(checkpointPath);
    let pageToken: string | undefined = checkpoint ? decodeFields(checkpoint.fields).nextPageToken ?? undefined : undefined;
    let scanned = 0;
    while (scanned < 500) {
      const page = await db.list(attemptsCollection, pageToken);
      for (const doc of page.documents) {
        scanned++;
        const attempt = decodeFields(doc.fields);
        if (!["pending", "creation_unknown", "creating"].includes(String(attempt.status))) continue;
        const createdAt = attempt.createdAt instanceof Date ? attempt.createdAt.getTime() : Date.parse(String(attempt.createdAt ?? ""));
        if (!Number.isFinite(createdAt) || now - createdAt < 2 * 60_000) continue;
        const id = doc.name.split("/").pop()!;
        try {
          const result = await inquireIntention({ orderId: attempt.paymobOrderId ? String(attempt.paymobOrderId) : undefined, merchantReference: id });
          const state = await reconcileAttempt(db, id, result);
          counts[state] = (counts[state] ?? 0) + 1;
        } catch (cause) {
          const code = cause instanceof Error ? cause.message : "unknown";
          console.error("Course payment reconciliation item failed", { attemptId: id, code });
          counts.retryable_error = (counts.retryable_error ?? 0) + 1;
          try {
            await updateAttempt(db, id, { lastReconciledAt: new Date(), reconciliationLastError: code });
          } catch { /* The next scheduled run retries the unresolved attempt. */ }
        }
      }
      pageToken = page.nextPageToken;
      const checkpointTx = await db.beginTransaction();
      const previousCheckpoint = await db.get(checkpointPath, checkpointTx);
      const data = firestoreDocument(db, checkpointPath, { nextPageToken: pageToken ?? null, updatedAt: new Date() });
      await db.commit(checkpointTx, [previousCheckpoint
        ? updateWrite(data, ["nextPageToken", "updatedAt"], previousCheckpoint.updateTime)
        : createWrite(data)]);
      if (!pageToken || page.documents.length === 0) break;
    }
    return json({ ok: true, scanned, outcomes: counts });
  } catch (cause) {
    console.error("Course payment reconciliation batch failed", { message: cause instanceof Error ? cause.message : "unknown" });
    const result = safeError(cause);
    return error(result.code, result.message, result.status);
  }
});
