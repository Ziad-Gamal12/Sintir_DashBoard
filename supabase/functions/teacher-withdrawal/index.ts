import {
  boolValue,
  createWrite,
  firebaseUid,
  Firestore,
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
import {
  disburse,
  inquire,
  PaymobDisbursementRejected,
  payoutConfigurationReady,
} from "../_shared/paymob.ts";
import {
  idempotencyPayloadMatches,
  isFinalPayoutStatus,
  payoutDisposition,
  providerResponseMatches,
  providerResponseMatchesForManualResolution,
} from "../_shared/withdrawal_logic.ts";

const minimumCents = 10000;
const maximumCents = 100000;
const issuers = new Set(["vodafone", "orange", "etisalat"]);
const userPath = (uid: string) => `Users/${uid}`;
const withdrawalPath = (uid: string, id: string) =>
  `Users/${uid}/Transactions/${id}`;

type CreateInput = {
  amount: unknown;
  issuer: unknown;
  mobileNumber: unknown;
  idempotencyKey: unknown;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return error("method_not_allowed", "Use POST.", 405);
  }

  // Supabase Cron may reconcile unresolved withdrawals that already have a
  // Paymob transaction ID. This secret is separate from Firebase user auth.
  const reconciliationSecret = Deno.env.get(
    "TEACHER_WITHDRAWAL_RECONCILIATION_SECRET",
  );
  if (
    reconciliationSecret &&
    equalSecret(
      request.headers.get("x-withdrawal-reconciliation-secret"),
      reconciliationSecret,
    )
  ) {
    return await reconcileDueWithdrawals();
  }

  let uid: string;
  try {
    uid = await firebaseUid(request);
  } catch (_) {
    return error(
      "unauthenticated",
      "A valid Firebase ID token is required.",
      401,
    );
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
    if (body.action === "admin_manual_resolve") {
      return await adminManualResolve(uid, body);
    }
    if (body.action === "create") {
      return await create(uid, body as CreateInput);
    }
    return error("invalid_action", "action must be create or reconcile.", 400);
  } catch (exception) {
    console.error("teacher-withdrawal failed", exception);
    return error(
      "internal_error",
      "Could not process the withdrawal. No new payout was created.",
      500,
    );
  }
});

function equalSecret(left: string | null, right: string): boolean {
  if (!left) return false;
  const a = new TextEncoder().encode(left);
  const b = new TextEncoder().encode(right);
  let diff = a.length ^ b.length;
  for (let i = 0; i < Math.max(a.length, b.length); i++) {
    diff |= (a[i] ?? 0) ^ (b[i] ?? 0);
  }
  return diff === 0;
}

async function reconcileDueWithdrawals(): Promise<Response> {
  const firestore = new Firestore();
  const checkpointPath = "TeacherWithdrawalReconciliation/checkpoint";
  const checkpoint = await firestore.get(checkpointPath);
  let pageToken = getField(checkpoint?.fields, ["usersPageToken"])
    ?.stringValue as string | undefined;
  const users = await firestore.list("Users", pageToken);
  const counts: Record<string, number> = {};
  let scanned = 0;
  for (const user of users.documents) {
    scanned++;
    const uid = user.name.split("/").pop();
    if (
      !uid || firestoreString(getField(user.fields, ["role"])) !== "Teacher"
    ) continue;
    let transactionPage: string | undefined;
    do {
      const page = await firestore.list(
        `Users/${uid}/Transactions`,
        transactionPage,
      );
      for (const withdrawal of page.documents) {
        const fields = withdrawal.fields;
        if (firestoreString(getField(fields, ["method"])) !== "PayOut") {
          continue;
        }
        if (firestoreBoolean(getField(fields, ["isReconciled"])) === true) {
          continue;
        }
        const status = firestoreString(getField(fields, ["status"]))
          ?.toUpperCase();
        if (
          !status ||
          !["RESERVED", "PENDING", "PROCESSING_UNKNOWN"].includes(status)
        ) continue;
        const externalId = firestoreString(
          getField(fields, ["paymob_transaction_id"]),
        );
        if (!externalId) {
          counts.missing_provider_reference =
            (counts.missing_provider_reference ?? 0) + 1;
          continue;
        }
        const updatedAt = getField(fields, ["updated_at"])?.timestampValue;
        const updatedMs = typeof updatedAt === "string"
          ? Date.parse(updatedAt)
          : Number.NaN;
        if (Number.isFinite(updatedMs) && Date.now() - updatedMs < 2 * 60_000) {
          continue;
        }
        const id = withdrawal.name.split("/").pop();
        if (!id) continue;
        try {
          const response = await reconcile(uid, id);
          const key = response.ok ? "reconciled_or_pending" : "retryable_error";
          counts[key] = (counts[key] ?? 0) + 1;
        } catch (cause) {
          console.error("Withdrawal reconciliation item failed", {
            withdrawalId: id,
            message: cause instanceof Error ? cause.message : "unknown",
          });
          counts.retryable_error = (counts.retryable_error ?? 0) + 1;
        }
      }
      transactionPage = page.nextPageToken;
    } while (transactionPage);
  }

  const nextPageToken = users.nextPageToken ?? null;
  const tx = await firestore.beginTransaction();
  const current = await firestore.get(checkpointPath, tx);
  const checkpointDoc = firestore.document(checkpointPath, {
    usersPageToken: nextPageToken
      ? { stringValue: nextPageToken }
      : { nullValue: "NULL_VALUE" },
    updatedAt: timestampValue(),
  });
  await firestore.commit(tx, [
    current
      ? updateWrite(
        checkpointDoc,
        ["usersPageToken", "updatedAt"],
        current.updateTime,
      )
      : createWrite(checkpointDoc),
  ]);
  return json({
    ok: true,
    scannedUsers: scanned,
    nextPage: nextPageToken !== null,
    outcomes: counts,
  });
}

async function create(uid: string, input: CreateInput): Promise<Response> {
  if (!payoutConfigurationReady()) {
    return error(
      "payout_unavailable",
      "The withdrawal service is not configured.",
      503,
    );
  }
  let amount: number;
  let issuer: string;
  let mobileNumber: string;
  let id: string;
  try {
    amount = parseAmount(input.amount);
    issuer = parseIssuer(input.issuer);
    mobileNumber = parseMobile(input.mobileNumber, issuer);
    id = parseIdempotencyKey(input.idempotencyKey);
  } catch (cause) {
    return error(
      "invalid_request",
      cause instanceof Error ? cause.message : "Invalid withdrawal request.",
      400,
    );
  }
  const firestore = new Firestore();

  const providerReference = crypto.randomUUID();
  const reservation = await reserve(
    firestore,
    uid,
    id,
    amount,
    issuer,
    mobileNumber,
    providerReference,
  );
  if (reservation.kind === "existing") {
    return json({ ok: true, ...reservation.response });
  }
  if (reservation.kind === "idempotency_conflict") {
    return error(
      "idempotency_key_reused",
      "This idempotency key was already used for a different withdrawal request.",
      409,
    );
  }
  if (reservation.kind === "rejected") {
    return error(reservation.code, reservation.message, 422);
  }

  try {
    const payout = await disburse({
      amount: amount / 100,
      mobileNumber,
      issuer,
      reference: providerReference,
    });
    if (
      !providerResponseMatches(payout.raw, {
        transactionId: payout.transactionId,
        amount: amount / 100,
        issuer,
        mobileNumber,
        reference: providerReference,
      })
    ) {
      await updateAfterPaymob(
        firestore,
        uid,
        id,
        payout.transactionId,
        "REVIEW_REQUIRED",
        payout.raw,
      );
      return json({
        ok: true,
        withdrawalId: id,
        paymobTransactionId: payout.transactionId,
        status: "REVIEW_REQUIRED",
        message:
          "Paymob returned details that do not match this withdrawal. Funds remain reserved for review.",
      }, 202);
    }
    await updateAfterPaymob(
      firestore,
      uid,
      id,
      payout.transactionId,
      payout.status,
      payout.raw,
    );
    let finalStatus: string;
    try {
      finalStatus = await settleIfFinal(firestore, uid, id, payout.status);
    } catch (cause) {
      await markReviewRequired(firestore, uid, id, cause);
      return json({
        ok: true,
        withdrawalId: id,
        paymobTransactionId: payout.transactionId,
        status: "REVIEW_REQUIRED",
        message:
          "Paymob returned a final result, but the wallet could not be reconciled safely. Funds remain reserved for review.",
      }, 202);
    }
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
      try {
        await settle(firestore, uid, id, "FAILED", true);
      } catch (cause) {
        await markReviewRequired(firestore, uid, id, cause);
        return json({
          ok: true,
          withdrawalId: id,
          status: "REVIEW_REQUIRED",
          message:
            "Paymob rejected the withdrawal, but the wallet could not be restored safely. Funds remain reserved for review.",
        }, 202);
      }
      return json({
        ok: true,
        withdrawalId: id,
        status: "FAILED",
        message:
          "Paymob rejected the withdrawal. Your reserved balance was restored.",
      }, 202);
    }
    // A network timeout after Paymob receives the request is ambiguous. Do not retry or refund automatically:
    // that could create a duplicate payout or let a paid withdrawal be spent again.
    await markUnknown(firestore, uid, id, exception);
    return json({
      ok: true,
      withdrawalId: id,
      status: "PROCESSING_UNKNOWN",
      message:
        "The provider response was inconclusive. Funds remain reserved while the payout is reconciled.",
    }, 202);
  }
}

async function reserve(
  firestore: Firestore,
  uid: string,
  id: string,
  amountCents: number,
  issuer: string,
  mobileNumber: string,
  proposedProviderReference: string,
) {
  const transaction = await firestore.beginTransaction();
  const [user, existing] = await Promise.all([
    firestore.get(userPath(uid), transaction),
    firestore.get(withdrawalPath(uid, id), transaction),
  ]);
  if (existing) {
    const priorAmount = firestoreNumber(
      getField(existing.fields, ["amount_cents"]),
    );
    const priorIssuer = firestoreString(getField(existing.fields, ["issuer"]));
    const priorMobile = firestoreString(getField(existing.fields, ["mobile"]));
    if (
      !idempotencyPayloadMatches(
        {
          amountCents: priorAmount ?? -1,
          issuer: priorIssuer ?? "",
          mobileNumber: priorMobile ?? "",
        },
        { amountCents, issuer, mobileNumber },
      )
    ) {
      return { kind: "idempotency_conflict" as const };
    }
    return {
      kind: "existing" as const,
      response: {
        withdrawalId: id,
        paymobTransactionId: firestoreString(
          getField(existing.fields, ["paymob_transaction_id"]),
        ),
        status: firestoreString(getField(existing.fields, ["status"])) ??
          "PENDING",
        message: "This withdrawal request was already received.",
      },
    };
  }
  if (!user) {
    return {
      kind: "rejected" as const,
      code: "teacher_not_found",
      message: "Teacher account was not found.",
    };
  }

  const role = firestoreString(getField(user.fields, ["role"]));
  const accountStatus = firestoreString(getField(user.fields, ["status"]));
  const walletStatus = firestoreString(
    getField(user.fields, ["teacherExtraData", "wallet", "status"]),
  );
  const balance = firestoreNumber(
    getField(user.fields, ["teacherExtraData", "wallet", "balance"]),
  );
  // Read legacy camelCase only as a temporary migration fallback. Every new
  // write below keeps the canonical Firestore schema in snake_case only.
  const pending = Math.max(
    firestoreNumber(
      getField(user.fields, ["teacherExtraData", "wallet", "payoutPending"]),
    ) ?? 0,
    firestoreNumber(
      getField(user.fields, ["teacherExtraData", "wallet", "payout_pending"]),
    ) ?? 0,
  );
  if (
    role !== "Teacher" || accountStatus !== "Active" ||
    walletStatus !== "active"
  ) {
    return {
      kind: "rejected" as const,
      code: "wallet_not_eligible",
      message: "Only active teacher wallets can withdraw.",
    };
  }
  if (balance === null || Math.round(balance * 100) < amountCents) {
    return {
      kind: "rejected" as const,
      code: "insufficient_balance",
      message: "Insufficient available balance.",
    };
  }

  const now = new Date();
  const walletUpdate = firestore.document(userPath(uid), {
    teacherExtraData: mapValue({
      wallet: mapValue({
        balance: numberValue((Math.round(balance * 100) - amountCents) / 100),
        payout_pending: numberValue(
          (Math.round(pending * 100) + amountCents) / 100,
        ),
        last_transaction_id: stringValue(id),
        updated_at: timestampValue(now),
      }),
    }),
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
    // Distinct from our Firestore/idempotency key; stable before Paymob I/O.
    client_reference_id: stringValue(proposedProviderReference),
    created_at: timestampValue(now),
    updated_at: timestampValue(now),
  });
  await firestore.commit(transaction, [
    updateWrite(walletUpdate, [
      "teacherExtraData.wallet.balance",
      "teacherExtraData.wallet.payout_pending",
      "teacherExtraData.wallet.last_transaction_id",
      "teacherExtraData.wallet.updated_at",
      // Field paths included in the mask but absent in the update document are
      // deleted. This removes legacy duplicates atomically with the reservation.
      "teacherExtraData.wallet.payoutPending",
      "teacherExtraData.wallet.lastTransactionId",
      "teacherExtraData.wallet.updatedAt",
    ], user.updateTime),
    createWrite(transactionDocument),
  ]);
  return { kind: "reserved" as const };
}

function providerDetails(result: Record<string, unknown>) {
  const code = result.transaction_status_code ?? result.status_code;
  const description = result.transaction_status_description ??
    result.status_description ?? result.error_description;
  return {
    code: code == null ? undefined : String(code),
    description: typeof description === "string"
      ? description.slice(0, 500)
      : undefined,
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
  const existingStatus = firestoreString(getField(doc.fields, ["status"]))
    ?.toUpperCase();
  if (existingStatus && isFinal(existingStatus)) return;
  const provider = providerDetails(result);
  const update = firestore.document(withdrawalPath(uid, id), {
    paymob_transaction_id: stringValue(paymobTransactionId),
    status: stringValue(status),
    ...(provider.code
      ? { provider_status_code: stringValue(provider.code) }
      : {}),
    ...(provider.description
      ? { provider_status_description: stringValue(provider.description) }
      : {}),
    updated_at: timestampValue(),
  });
  const fields = ["paymob_transaction_id", "status", "updated_at"];
  if (provider.code) fields.push("provider_status_code");
  if (provider.description) fields.push("provider_status_description");
  await firestore.commit(transaction, [
    updateWrite(update, fields, doc.updateTime),
  ]);
}

async function markUnknown(
  firestore: Firestore,
  uid: string,
  id: string,
  exception: unknown,
) {
  const transaction = await firestore.beginTransaction();
  const doc = await firestore.get(withdrawalPath(uid, id), transaction);
  if (!doc) return;
  const existingStatus = firestoreString(getField(doc.fields, ["status"]))
    ?.toUpperCase();
  if (
    firestoreBoolean(getField(doc.fields, ["isReconciled"])) === true ||
    (existingStatus && isFinal(existingStatus))
  ) return;
  const update = firestore.document(withdrawalPath(uid, id), {
    status: stringValue("PROCESSING_UNKNOWN"),
    provider_error: stringValue(
      exception instanceof Error
        ? exception.message.slice(0, 250)
        : "Unknown provider error",
    ),
    updated_at: timestampValue(),
  });
  await firestore.commit(transaction, [
    updateWrite(
      update,
      ["status", "provider_error", "updated_at"],
      doc.updateTime,
    ),
  ]);
}

async function markReviewRequired(
  firestore: Firestore,
  uid: string,
  id: string,
  exception: unknown,
) {
  const transaction = await firestore.beginTransaction();
  const doc = await firestore.get(withdrawalPath(uid, id), transaction);
  if (
    !doc || firestoreBoolean(getField(doc.fields, ["isReconciled"])) === true
  ) return;
  const update = firestore.document(withdrawalPath(uid, id), {
    status: stringValue("REVIEW_REQUIRED"),
    reconciliation_error: stringValue(
      exception instanceof Error
        ? exception.message.slice(0, 250)
        : "Wallet settlement requires review.",
    ),
    updated_at: timestampValue(),
  });
  await firestore.commit(transaction, [
    updateWrite(
      update,
      ["status", "reconciliation_error", "updated_at"],
      doc.updateTime,
    ),
  ]);
}

async function reconcile(uid: string, rawId: unknown): Promise<Response> {
  if (typeof rawId !== "string" || !/^[a-f0-9-]{36}$/i.test(rawId)) {
    return error("invalid_withdrawal_id", "withdrawalId must be a UUID.", 400);
  }
  const firestore = new Firestore();
  const current = await firestore.get(withdrawalPath(uid, rawId));
  if (!current) return error("not_found", "Withdrawal was not found.", 404);
  if (firestoreBoolean(getField(current.fields, ["isReconciled"])) === true) {
    const status = firestoreString(getField(current.fields, ["status"])) ??
      "UNKNOWN";
    return json({
      ok: true,
      withdrawalId: rawId,
      paymobTransactionId: firestoreString(
        getField(current.fields, ["paymob_transaction_id"]),
      ),
      status,
      message: withdrawalMessage(status),
    });
  }
  const externalId = firestoreString(
    getField(current.fields, ["paymob_transaction_id"]),
  );
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
  const expectedAmount = firestoreNumber(
    getField(current.fields, ["amount_cents"]),
  );
  const expectedIssuer =
    firestoreString(getField(current.fields, ["issuer"])) ?? "";
  const expectedMobile =
    firestoreString(getField(current.fields, ["mobile"])) ?? "";
  if (
    !providerResponseMatches(result, {
      transactionId: externalId,
      amount: expectedAmount === null ? undefined : expectedAmount / 100,
      issuer: expectedIssuer,
      mobileNumber: expectedMobile,
      reference:
        firestoreString(getField(current.fields, ["client_reference_id"])) ??
          rawId,
    })
  ) {
    await updateAfterPaymob(
      firestore,
      uid,
      rawId,
      externalId,
      "REVIEW_REQUIRED",
      result,
    );
    return json({
      ok: true,
      withdrawalId: rawId,
      paymobTransactionId: externalId,
      status: "REVIEW_REQUIRED",
      message:
        "Paymob transaction details do not match this withdrawal. Funds remain reserved for review.",
    }, 202);
  }
  const rawStatus = result.disbursement_status ?? result.status ??
    result.transaction_status;
  const status = typeof rawStatus === "string"
    ? rawStatus.toUpperCase()
    : "PENDING";
  // Save Paymob's exact result before settlement. This keeps the provider's
  // diagnostic code/description visible even when the final status is mapped
  // to our canonical SUCCESS or FAILED value below.
  await updateAfterPaymob(firestore, uid, rawId, externalId, status, result);
  let finalStatus: string;
  try {
    finalStatus = await settleIfFinal(firestore, uid, rawId, status);
  } catch (cause) {
    await markReviewRequired(firestore, uid, rawId, cause);
    return json({
      ok: true,
      withdrawalId: rawId,
      paymobTransactionId: externalId,
      status: "REVIEW_REQUIRED",
      message:
        "Paymob returned a final result, but the wallet could not be reconciled safely. Funds remain reserved for review.",
    }, 202);
  }
  return json({
    ok: true,
    withdrawalId: rawId,
    paymobTransactionId: externalId,
    status: finalStatus,
    message: withdrawalMessage(finalStatus),
  });
}

async function adminManualResolve(
  operatorUid: string,
  body: Record<string, unknown>,
): Promise<Response> {
  if (
    typeof body.teacherUid !== "string" ||
    typeof body.withdrawalId !== "string" ||
    typeof body.paymobTransactionId !== "string"
  ) {
    return error(
      "invalid_request",
      "teacherUid, withdrawalId, and paymobTransactionId are required.",
      400,
    );
  }
  if (
    !/^[a-f0-9-]{36}$/i.test(body.withdrawalId) ||
    body.paymobTransactionId.trim().length < 5 ||
    body.paymobTransactionId.length > 128
  ) {
    return error(
      "invalid_request",
      "Withdrawal or Paymob transaction ID is invalid.",
      400,
    );
  }
  const firestore = new Firestore();
  const operator = await firestore.get(userPath(operatorUid));
  if (
    !operator ||
    firestoreString(getField(operator.fields, ["role"])) !== "Admin" ||
    firestoreString(getField(operator.fields, ["status"])) !== "Active"
  ) {
    return error(
      "forbidden",
      "An active administrator account is required.",
      403,
    );
  }
  const withdrawal = await firestore.get(
    withdrawalPath(body.teacherUid, body.withdrawalId),
  );
  if (!withdrawal) return error("not_found", "Withdrawal was not found.", 404);
  const currentStatus =
    firestoreString(getField(withdrawal.fields, ["status"]))?.toUpperCase() ??
      "";
  if (
    firestoreBoolean(getField(withdrawal.fields, ["isReconciled"])) === true ||
    isFinal(currentStatus)
  ) {
    return json({
      ok: true,
      withdrawalId: body.withdrawalId,
      status: currentStatus,
      message:
        "This withdrawal was already resolved; no financial changes were made.",
    });
  }
  if (
    !["RESERVED", "PENDING", "PROCESSING_UNKNOWN", "REVIEW_REQUIRED"].includes(
      currentStatus,
    )
  ) {
    return error(
      "not_reviewable",
      "This withdrawal is not in a manual-review state.",
      409,
    );
  }
  const expectedCents = firestoreNumber(
    getField(withdrawal.fields, ["amount_cents"]),
  );
  const issuer = firestoreString(getField(withdrawal.fields, ["issuer"]));
  const mobile = firestoreString(getField(withdrawal.fields, ["mobile"]));
  const reference = firestoreString(
    getField(withdrawal.fields, ["client_reference_id"]),
  );
  if (expectedCents === null || !issuer || !mobile || !reference) {
    return error(
      "withdrawal_identity_incomplete",
      "Stored payout identity is incomplete. Funds remain reserved for support review.",
      409,
    );
  }
  let providerResult: Record<string, unknown>;
  try {
    providerResult = await inquire(body.paymobTransactionId.trim());
  } catch (_) {
    return error(
      "provider_inquiry_unavailable",
      "Paymob could not verify this transaction. Funds remain reserved.",
      503,
    );
  }
  if (
    !providerResponseMatchesForManualResolution(providerResult, {
      transactionId: body.paymobTransactionId.trim(),
      amount: expectedCents / 100,
      issuer,
      mobileNumber: mobile,
      reference,
    })
  ) {
    await appendManualReviewAudit(
      firestore,
      body.teacherUid,
      body.withdrawalId,
      operatorUid,
      "provider_identity_mismatch",
      body.paymobTransactionId.trim(),
    );
    return error(
      "provider_identity_mismatch",
      "Paymob transaction details do not match this withdrawal. Funds remain reserved and the mismatch was recorded.",
      409,
    );
  }
  const providerStatusRaw = providerResult.disbursement_status ??
    providerResult.status ?? providerResult.transaction_status;
  const providerStatus = typeof providerStatusRaw === "string"
    ? providerStatusRaw.toUpperCase()
    : "";
  const disposition = payoutDisposition(providerStatus);
  if (disposition === "retain") {
    await appendManualReviewAudit(
      firestore,
      body.teacherUid,
      body.withdrawalId,
      operatorUid,
      `verified_${providerStatus || "nonterminal"}`,
      body.paymobTransactionId.trim(),
    );
    return json({
      ok: true,
      withdrawalId: body.withdrawalId,
      paymobTransactionId: body.paymobTransactionId.trim(),
      status: "REVIEW_REQUIRED",
      message:
        "Paymob verified this transaction, but its status is not final. Funds remain reserved.",
    }, 202);
  }
  await updateAfterPaymob(
    firestore,
    body.teacherUid,
    body.withdrawalId,
    body.paymobTransactionId.trim(),
    providerStatus,
    providerResult,
  );
  try {
    const status = disposition === "consume" ? "SUCCESS" : "FAILED";
    await settle(
      firestore,
      body.teacherUid,
      body.withdrawalId,
      status,
      disposition === "restore",
      {
        operatorUid,
        decision: `provider_verified_${providerStatus}`,
        providerTransactionId: body.paymobTransactionId.trim(),
      },
    );
    return json({
      ok: true,
      withdrawalId: body.withdrawalId,
      paymobTransactionId: body.paymobTransactionId.trim(),
      status,
      message: withdrawalMessage(status),
    });
  } catch (cause) {
    await markReviewRequired(
      firestore,
      body.teacherUid,
      body.withdrawalId,
      cause,
    );
    return error(
      "settlement_requires_review",
      "Provider result was verified, but wallet settlement failed. Funds remain reserved for review.",
      409,
    );
  }
}

async function appendManualReviewAudit(
  firestore: Firestore,
  uid: string,
  id: string,
  operatorUid: string,
  decision: string,
  providerTransactionId: string,
) {
  const transaction = await firestore.beginTransaction();
  const doc = await firestore.get(withdrawalPath(uid, id), transaction);
  if (
    !doc || firestoreBoolean(getField(doc.fields, ["isReconciled"])) === true
  ) return;
  const update = firestore.document(withdrawalPath(uid, id), {
    manual_review_operator_uid: stringValue(operatorUid),
    manual_review_decision: stringValue(decision),
    manual_review_provider_transaction_id: stringValue(providerTransactionId),
    manual_review_at: timestampValue(),
    updated_at: timestampValue(),
  });
  await firestore.commit(transaction, [
    updateWrite(update, [
      "manual_review_operator_uid",
      "manual_review_decision",
      "manual_review_provider_transaction_id",
      "manual_review_at",
      "updated_at",
    ], doc.updateTime),
  ]);
}

async function settleIfFinal(
  firestore: Firestore,
  uid: string,
  id: string,
  status: string,
): Promise<string> {
  const disposition = payoutDisposition(status);
  if (disposition === "restore") {
    await settle(firestore, uid, id, "FAILED", true);
    return "FAILED";
  }
  if (disposition === "consume") {
    await settle(firestore, uid, id, "SUCCESS", false);
    return "SUCCESS";
  }
  return status;
}

function isFinal(status: string): boolean {
  return isFinalPayoutStatus(status);
}

function withdrawalMessage(status: string): string {
  if (status === "SUCCESS") return "Withdrawal completed successfully.";
  if (status === "FAILED") {
    return "Withdrawal failed. Your reserved balance was restored.";
  }
  if (status === "REVIEW_REQUIRED") {
    return "This withdrawal needs review. Its reserved balance has not been released.";
  }
  return "Withdrawal is pending. Your balance is reserved until Paymob confirms the final result.";
}

async function settle(
  firestore: Firestore,
  uid: string,
  id: string,
  status: string,
  restoreBalance: boolean,
  manualAudit?: {
    operatorUid: string;
    decision: string;
    providerTransactionId: string;
  },
) {
  const transaction = await firestore.beginTransaction();
  const [user, withdrawal] = await Promise.all([
    firestore.get(userPath(uid), transaction),
    firestore.get(withdrawalPath(uid, id), transaction),
  ]);
  if (!user || !withdrawal) {
    throw new Error("Settlement documents are missing.");
  }
  if (
    firestoreBoolean(getField(withdrawal.fields, ["isReconciled"])) === true
  ) return;
  // amount_cents is canonical. The amount fallback is solely for legacy
  // documents created before cents were stored; never settle an invalid value
  // as zero because that would falsely mark the transaction reconciled.
  const storedCents = firestoreNumber(
    getField(withdrawal.fields, ["amount_cents"]),
  );
  const legacyAmount = firestoreNumber(getField(withdrawal.fields, ["amount"]));
  const amount = storedCents ??
    (legacyAmount == null ? null : Math.round(legacyAmount * 100));
  if (amount === null || !Number.isSafeInteger(amount) || amount <= 0) {
    throw new Error(
      "Withdrawal amount is invalid; settlement was not applied.",
    );
  }
  const balance = firestoreNumber(
    getField(user.fields, ["teacherExtraData", "wallet", "balance"]),
  );
  if (balance === null || balance < 0) {
    throw new Error("Wallet balance is invalid; settlement was not applied.");
  }
  const pending = Math.max(
    firestoreNumber(
      getField(user.fields, ["teacherExtraData", "wallet", "payoutPending"]),
    ) ?? 0,
    firestoreNumber(
      getField(user.fields, ["teacherExtraData", "wallet", "payout_pending"]),
    ) ?? 0,
  );
  const pendingCents = Math.round(pending * 100);
  if (!Number.isSafeInteger(pendingCents) || pendingCents < amount) {
    throw new Error(
      "Wallet pending balance is inconsistent; settlement was not applied.",
    );
  }
  const walletUpdate = firestore.document(userPath(uid), {
    teacherExtraData: mapValue({
      wallet: mapValue({
        balance: numberValue(
          (Math.round(balance * 100) + (restoreBalance ? amount : 0)) / 100,
        ),
        payout_pending: numberValue((pendingCents - amount) / 100),
        updated_at: timestampValue(),
      }),
    }),
  });
  const withdrawalUpdate = firestore.document(withdrawalPath(uid, id), {
    status: stringValue(status),
    isReconciled: boolValue(true),
    reconciled_at: timestampValue(),
    updated_at: timestampValue(),
    ...(manualAudit
      ? {
        manual_review_operator_uid: stringValue(manualAudit.operatorUid),
        manual_review_decision: stringValue(manualAudit.decision),
        manual_review_provider_transaction_id: stringValue(
          manualAudit.providerTransactionId,
        ),
        manual_review_at: timestampValue(),
      }
      : {}),
  });
  const withdrawalFields = [
    "status",
    "isReconciled",
    "reconciled_at",
    "updated_at",
  ];
  if (manualAudit) {
    withdrawalFields.push(
      "manual_review_operator_uid",
      "manual_review_decision",
      "manual_review_provider_transaction_id",
      "manual_review_at",
    );
  }
  await firestore.commit(transaction, [
    updateWrite(walletUpdate, [
      "teacherExtraData.wallet.balance",
      "teacherExtraData.wallet.payout_pending",
      "teacherExtraData.wallet.updated_at",
      "teacherExtraData.wallet.payoutPending",
      "teacherExtraData.wallet.updatedAt",
      "teacherExtraData.wallet.lastTransactionId",
    ], user.updateTime),
    updateWrite(withdrawalUpdate, withdrawalFields, withdrawal.updateTime),
  ]);
}

function parseAmount(raw: unknown): number {
  const value = typeof raw === "number" ? raw : Number(raw);
  if (!Number.isFinite(value)) throw new Error("Amount must be a number.");
  const cents = Math.round(value * 100);
  if (
    Math.abs(value * 100 - cents) > 0.000001 || cents < minimumCents ||
    cents > maximumCents
  ) {
    throw new Error(
      "Amount must be between 100 and 1000 EGP with at most two decimal places.",
    );
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
  const prefixes: Record<string, string> = {
    vodafone: "010",
    orange: "012",
    etisalat: "011",
  };
  if (!/^01\d{9}$/.test(value) || !value.startsWith(prefixes[issuer])) {
    throw new Error("Mobile number does not match the selected issuer.");
  }
  return value;
}
function parseIdempotencyKey(raw: unknown): string {
  if (typeof raw !== "string" || !/^[a-f0-9-]{36}$/i.test(raw)) {
    throw new Error("idempotencyKey must be a UUID.");
  }
  return raw;
}
