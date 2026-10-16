import {
  Firestore,
  boolValue,
  createWrite,
  firebaseUid,
  firestoreBoolean,
  firestoreNumber,
  firestoreString,
  getField,
  mapValue,
  numberValue,
  stringValue,
  timestampValue,
  updateWrite,
} from "../_shared/firebase.ts";
import { corsHeaders, error, json } from "../_shared/http.ts";
import { disburse, inquire, PaymobDisbursementRejected } from "../_shared/paymob.ts";

const minimumCents = 10000;
const maximumCents = 100000;
const issuers = new Set(["vodafone", "orange", "etisalat"]);
const userPath = (uid: string) => `Users/${uid}`;
const withdrawalPath = (uid: string, id: string) => `Users/${uid}/Transactions/${id}`;

type CreateInput = { amount: unknown; issuer: unknown; mobileNumber: unknown; idempotencyKey: unknown };

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return error("method_not_allowed", "Use POST.", 405);

  let uid: string;
  try {
    uid = await firebaseUid(request);
  } catch (_) {
    return error("unauthenticated", "A valid Firebase ID token is required.", 401);
  }

  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch (_) {
    return error("invalid_json", "Request body must be JSON.", 400);
  }

  try {
    if (body.action === "reconcile") {
      return await reconcile(uid, body.withdrawalId);
    }
    if (body.action === "create") {
      return await create(uid, body as CreateInput);
    }
    return error("invalid_action", "action must be create or reconcile.", 400);
  } catch (exception) {
    console.error("teacher-withdrawal failed", exception);
    return error("internal_error", "Could not process the withdrawal. No new payout was created.", 500);
  }
});

async function create(uid: string, input: CreateInput): Promise<Response> {
  const amount = parseAmount(input.amount);
  const issuer = parseIssuer(input.issuer);
  const mobileNumber = parseMobile(input.mobileNumber, issuer);
  const id = parseIdempotencyKey(input.idempotencyKey);
  const firestore = new Firestore();

  const reservation = await reserve(firestore, uid, id, amount, issuer, mobileNumber);
  if (reservation.kind === "existing") return json({ ok: true, ...reservation.response });
  if (reservation.kind === "rejected") return error(reservation.code, reservation.message, 422);

  try {
    const payout = await disburse({ amount: amount / 100, mobileNumber, issuer, reference: id });
    await updateAfterPaymob(firestore, uid, id, payout.transactionId, payout.status, payout.raw);
    const finalStatus = await settleIfFinal(firestore, uid, id, payout.status);
    return json({
      ok: true,
      withdrawalId: id,
      paymobTransactionId: payout.transactionId,
      status: finalStatus,
      message: withdrawalMessage(finalStatus),
    }, 202);
  } catch (exception) {
    // Paymob explicitly refused before accepting a payout. The reservation can
    // be safely released because no provider transaction was created.
    if (exception instanceof PaymobDisbursementRejected) {
      await settle(firestore, uid, id, "FAILED", true);
      return json({
        ok: true,
        withdrawalId: id,
        status: "FAILED",
        message: "Paymob rejected the withdrawal. Your reserved balance was restored.",
      }, 202);
    }
    // A network timeout after Paymob receives the request is ambiguous. Do not retry or refund automatically:
    // that could create a duplicate payout or let a paid withdrawal be spent again.
    await markUnknown(firestore, uid, id, exception);
    return json({
      ok: true,
      withdrawalId: id,
      status: "PROCESSING_UNKNOWN",
      message: "The provider response was inconclusive. Funds remain reserved while the payout is reconciled.",
    }, 202);
  }
}

async function reserve(firestore: Firestore, uid: string, id: string, amountCents: number, issuer: string, mobileNumber: string) {
  const transaction = await firestore.beginTransaction();
  const [user, existing] = await Promise.all([
    firestore.get(userPath(uid), transaction),
    firestore.get(withdrawalPath(uid, id), transaction),
  ]);
  if (existing) {
    return { kind: "existing" as const, response: {
      withdrawalId: id,
      paymobTransactionId: firestoreString(getField(existing.fields, ["paymob_transaction_id"])),
      status: firestoreString(getField(existing.fields, ["status"])) ?? "PENDING",
      message: "This withdrawal request was already received.",
    }};
  }
  if (!user) return { kind: "rejected" as const, code: "teacher_not_found", message: "Teacher account was not found." };

  const role = firestoreString(getField(user.fields, ["role"]));
  const accountStatus = firestoreString(getField(user.fields, ["status"]));
  const walletStatus = firestoreString(getField(user.fields, ["teacherExtraData", "wallet", "status"]));
  const balance = firestoreNumber(getField(user.fields, ["teacherExtraData", "wallet", "balance"]));
  // Read legacy camelCase only as a temporary migration fallback. Every new
  // write below keeps the canonical Firestore schema in snake_case only.
  const pending = Math.max(
    firestoreNumber(getField(user.fields, ["teacherExtraData", "wallet", "payoutPending"])) ?? 0,
    firestoreNumber(getField(user.fields, ["teacherExtraData", "wallet", "payout_pending"])) ?? 0,
  );
  if (role !== "Teacher" || accountStatus !== "Active" || walletStatus !== "active") {
    return { kind: "rejected" as const, code: "wallet_not_eligible", message: "Only active teacher wallets can withdraw." };
  }
  if (balance === null || Math.round(balance * 100) < amountCents) {
    return { kind: "rejected" as const, code: "insufficient_balance", message: "Insufficient available balance." };
  }

  const now = new Date();
  const walletUpdate = firestore.document(userPath(uid), {
    teacherExtraData: mapValue({ wallet: mapValue({
      balance: numberValue((Math.round(balance * 100) - amountCents) / 100),
      payout_pending: numberValue((Math.round(pending * 100) + amountCents) / 100),
      last_transaction_id: stringValue(id),
      updated_at: timestampValue(now),
    }) }),
  });
  const transactionDocument = firestore.document(withdrawalPath(uid, id), {
    transaction_id: stringValue(id),
    amount: numberValue(amountCents / 100),
    amount_cents: numberValue(amountCents),
    currency: stringValue("EGP"),
    issuer: stringValue(issuer),
    mobile: stringValue(mobileNumber),
    method: stringValue("PayOut"),
    status: stringValue("RESERVED"),
    isReconciled: boolValue(false),
    client_reference_id: stringValue(id),
    created_at: timestampValue(now),
    updated_at: timestampValue(now),
  });
  await firestore.commit(transaction, [
    updateWrite(walletUpdate, [
      "teacherExtraData.wallet.balance", "teacherExtraData.wallet.payout_pending",
      "teacherExtraData.wallet.last_transaction_id", "teacherExtraData.wallet.updated_at",
      // Field paths included in the mask but absent in the update document are
      // deleted. This removes legacy duplicates atomically with the reservation.
      "teacherExtraData.wallet.payoutPending", "teacherExtraData.wallet.lastTransactionId",
      "teacherExtraData.wallet.updatedAt",
    ], user.updateTime),
    createWrite(transactionDocument),
  ]);
  return { kind: "reserved" as const };
}

function providerDetails(result: Record<string, unknown>) {
  const code = result.transaction_status_code ?? result.status_code;
  const description = result.transaction_status_description ?? result.status_description ?? result.error_description;
  return {
    code: code == null ? undefined : String(code),
    description: typeof description === "string" ? description.slice(0, 500) : undefined,
  };
}

async function updateAfterPaymob(
  firestore: Firestore,
  uid: string,
  id: string,
  paymobTransactionId: string,
  status: string,
  result: Record<string, unknown> = {},
) {
  const transaction = await firestore.beginTransaction();
  const doc = await firestore.get(withdrawalPath(uid, id), transaction);
  if (!doc) throw new Error("Reserved withdrawal was not found.");
  // A terminal reconciliation is immutable. In particular, a delayed or
  // duplicate provider lookup must never turn SUCCESS/FAILED back into
  // PENDING after the wallet was settled.
  if (firestoreBoolean(getField(doc.fields, ["isReconciled"])) === true) return;
  const provider = providerDetails(result);
  const update = firestore.document(withdrawalPath(uid, id), {
    paymob_transaction_id: stringValue(paymobTransactionId),
    status: stringValue(status),
    ...(provider.code ? { provider_status_code: stringValue(provider.code) } : {}),
    ...(provider.description ? { provider_status_description: stringValue(provider.description) } : {}),
    updated_at: timestampValue(),
  });
  const fields = ["paymob_transaction_id", "status", "updated_at"];
  if (provider.code) fields.push("provider_status_code");
  if (provider.description) fields.push("provider_status_description");
  await firestore.commit(transaction, [updateWrite(update, fields, doc.updateTime)]);
}

async function markUnknown(firestore: Firestore, uid: string, id: string, exception: unknown) {
  const transaction = await firestore.beginTransaction();
  const doc = await firestore.get(withdrawalPath(uid, id), transaction);
  if (!doc) return;
  const update = firestore.document(withdrawalPath(uid, id), {
    status: stringValue("PROCESSING_UNKNOWN"),
    provider_error: stringValue(exception instanceof Error ? exception.message.slice(0, 250) : "Unknown provider error"),
    updated_at: timestampValue(),
  });
  await firestore.commit(transaction, [updateWrite(update, ["status", "provider_error", "updated_at"], doc.updateTime)]);
}

async function reconcile(uid: string, rawId: unknown): Promise<Response> {
  if (typeof rawId !== "string" || !/^[a-f0-9-]{36}$/i.test(rawId)) return error("invalid_withdrawal_id", "withdrawalId must be a UUID.", 400);
  const firestore = new Firestore();
  const current = await firestore.get(withdrawalPath(uid, rawId));
  if (!current) return error("not_found", "Withdrawal was not found.", 404);
  if (firestoreBoolean(getField(current.fields, ["isReconciled"])) === true) {
    const status = firestoreString(getField(current.fields, ["status"])) ?? "UNKNOWN";
    return json({
      ok: true,
      withdrawalId: rawId,
      paymobTransactionId: firestoreString(getField(current.fields, ["paymob_transaction_id"])),
      status,
      message: withdrawalMessage(status),
    });
  }
  const externalId = firestoreString(getField(current.fields, ["paymob_transaction_id"]));
  if (!externalId) {
    // Never refund a legacy/ambiguous reservation without a provider ID: Paymob
    // may have accepted the payout even though its response was lost.
    return error(
      "provider_reference_missing",
      "This withdrawal has no Paymob transaction ID, so it cannot be reconciled safely. Funds remain reserved; contact an administrator to verify it in Paymob before any refund.",
      409,
    );
  }

  const result = await inquire(externalId);
  const rawStatus = result.disbursement_status ?? result.status ?? result.transaction_status;
  const status = typeof rawStatus === "string" ? rawStatus.toUpperCase() : "PENDING";
  // Save Paymob's exact result before settlement. This keeps the provider's
  // diagnostic code/description visible even when the final status is mapped
  // to our canonical SUCCESS or FAILED value below.
  await updateAfterPaymob(firestore, uid, rawId, externalId, status, result);
  const finalStatus = await settleIfFinal(firestore, uid, rawId, status);
  return json({
    ok: true,
    withdrawalId: rawId,
    paymobTransactionId: externalId,
    status: finalStatus,
    message: withdrawalMessage(finalStatus),
  });
}

async function settleIfFinal(firestore: Firestore, uid: string, id: string, status: string): Promise<string> {
  if (["FAILED", "REJECTED", "CANCELLED"].includes(status)) {
    await settle(firestore, uid, id, "FAILED", true);
    return "FAILED";
  }
  if (["SUCCESS", "SUCCESSFUL", "COMPLETED", "APPROVED"].includes(status)) {
    await settle(firestore, uid, id, "SUCCESS", false);
    return "SUCCESS";
  }
  return status;
}

function isFinal(status: string): boolean {
  return ["FAILED", "REJECTED", "CANCELLED", "SUCCESS", "SUCCESSFUL", "COMPLETED", "APPROVED"].includes(status);
}

function withdrawalMessage(status: string): string {
  if (status === "SUCCESS") return "Withdrawal completed successfully.";
  if (status === "FAILED") return "Withdrawal failed. Your reserved balance was restored.";
  return "Withdrawal is pending. Your balance is reserved until Paymob confirms the final result.";
}

async function settle(firestore: Firestore, uid: string, id: string, status: string, restoreBalance: boolean) {
  const transaction = await firestore.beginTransaction();
  const [user, withdrawal] = await Promise.all([firestore.get(userPath(uid), transaction), firestore.get(withdrawalPath(uid, id), transaction)]);
  if (!user || !withdrawal) throw new Error("Settlement documents are missing.");
  if (firestoreBoolean(getField(withdrawal.fields, ["isReconciled"])) === true) return;
  // amount_cents is canonical. The amount fallback is solely for legacy
  // documents created before cents were stored; never settle an invalid value
  // as zero because that would falsely mark the transaction reconciled.
  const storedCents = firestoreNumber(getField(withdrawal.fields, ["amount_cents"]));
  const legacyAmount = firestoreNumber(getField(withdrawal.fields, ["amount"]));
  const amount = storedCents ?? (legacyAmount == null ? null : Math.round(legacyAmount * 100));
  if (amount === null || !Number.isSafeInteger(amount) || amount <= 0) {
    throw new Error("Withdrawal amount is invalid; settlement was not applied.");
  }
  const balance = firestoreNumber(getField(user.fields, ["teacherExtraData", "wallet", "balance"]));
  if (balance === null || balance < 0) {
    throw new Error("Wallet balance is invalid; settlement was not applied.");
  }
  const pending = Math.max(
    firestoreNumber(getField(user.fields, ["teacherExtraData", "wallet", "payoutPending"])) ?? 0,
    firestoreNumber(getField(user.fields, ["teacherExtraData", "wallet", "payout_pending"])) ?? 0,
  );
  const pendingCents = Math.round(pending * 100);
  if (!Number.isSafeInteger(pendingCents) || pendingCents < amount) {
    throw new Error("Wallet pending balance is inconsistent; settlement was not applied.");
  }
  const walletUpdate = firestore.document(userPath(uid), { teacherExtraData: mapValue({ wallet: mapValue({
    balance: numberValue((Math.round(balance * 100) + (restoreBalance ? amount : 0)) / 100),
    payout_pending: numberValue((pendingCents - amount) / 100),
    updated_at: timestampValue(),
  }) }) });
  const withdrawalUpdate = firestore.document(withdrawalPath(uid, id), {
    status: stringValue(status), isReconciled: boolValue(true), reconciled_at: timestampValue(), updated_at: timestampValue(),
  });
  await firestore.commit(transaction, [
    updateWrite(walletUpdate, [
      "teacherExtraData.wallet.balance", "teacherExtraData.wallet.payout_pending", "teacherExtraData.wallet.updated_at",
      "teacherExtraData.wallet.payoutPending", "teacherExtraData.wallet.updatedAt",
      "teacherExtraData.wallet.lastTransactionId",
    ], user.updateTime),
    updateWrite(withdrawalUpdate, ["status", "isReconciled", "reconciled_at", "updated_at"], withdrawal.updateTime),
  ]);
}

function parseAmount(raw: unknown): number {
  const value = typeof raw === "number" ? raw : Number(raw);
  if (!Number.isFinite(value)) throw new Error("Amount must be a number.");
  const cents = Math.round(value * 100);
  if (Math.abs(value * 100 - cents) > 0.000001 || cents < minimumCents || cents > maximumCents) {
    throw new Error("Amount must be between 100 and 1000 EGP with at most two decimal places.");
  }
  return cents;
}
function parseIssuer(raw: unknown): string {
  const issuer = typeof raw === "string" ? raw.trim().toLowerCase() : "";
  if (!issuers.has(issuer)) throw new Error("Unsupported wallet issuer.");
  return issuer;
}
function parseMobile(raw: unknown, issuer: string): string {
  const value = typeof raw === "string" ? raw.replace(/\s+/g, "") : "";
  const prefixes: Record<string, string> = { vodafone: "010", orange: "012", etisalat: "011" };
  if (!/^01\d{9}$/.test(value) || !value.startsWith(prefixes[issuer])) throw new Error("Mobile number does not match the selected issuer.");
  return value;
}
function parseIdempotencyKey(raw: unknown): string {
  if (typeof raw !== "string" || !/^[a-f0-9-]{36}$/i.test(raw)) throw new Error("idempotencyKey must be a UUID.");
  return raw;
}
