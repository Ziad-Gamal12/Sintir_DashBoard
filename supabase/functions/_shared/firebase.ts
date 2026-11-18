import { createRemoteJWKSet, importPKCS8, jwtVerify, SignJWT } from "npm:jose@5.10.0";

type FirestoreValue = Record<string, unknown>;
type FirestoreDocument = { name: string; fields?: Record<string, FirestoreValue>; updateTime?: string };

function encodeDocumentPath(path: string): string {
  return path.split("/").map((segment) => encodeURIComponent(segment)).join("/");
}

const tokenKeys = createRemoteJWKSet(
  new URL("https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"),
);

export type FirebaseIdentity = { uid: string; authTime: number | null };

/** Verifies the caller's Firebase ID token. `authTime` is the last sign-in, in seconds. */
export async function firebaseIdentity(request: Request): Promise<FirebaseIdentity> {
  const authorization = request.headers.get("authorization");
  const token = authorization?.match(/^Bearer\s+(.+)$/i)?.[1];
  if (!token) throw new Error("Missing Firebase ID token.");

  const projectId = requiredSecret("FB_PROJECT_ID");
  const { payload } = await jwtVerify(token, tokenKeys, {
    audience: projectId,
    issuer: `https://securetoken.google.com/${projectId}`,
  });
  if (typeof payload.sub !== "string" || payload.sub.length === 0) {
    throw new Error("Firebase token has no subject.");
  }
  const authTime = typeof payload.auth_time === "number" ? payload.auth_time : null;
  return { uid: payload.sub, authTime };
}

export async function firebaseUid(request: Request): Promise<string> {
  return (await firebaseIdentity(request)).uid;
}

export function requiredSecret(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing required server secret: ${name}`);
  return value;
}

const DATASTORE_SCOPE = "https://www.googleapis.com/auth/datastore";
const AUTH_ADMIN_SCOPE =
  "https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/identitytoolkit";

async function firebaseAccessToken(scope = DATASTORE_SCOPE): Promise<string> {
  const clientEmail = requiredSecret("FB_CLIENT_EMAIL");
  const privateKey = requiredSecret("FB_PRIVATE_KEY").replace(/\\n/g, "\n");
  const now = Math.floor(Date.now() / 1000);
  const key = await importPKCS8(privateKey, "RS256");
  const assertion = await new SignJWT({ scope })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(clientEmail)
    .setSubject(clientEmail)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(key);

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  if (!response.ok) throw new Error("Could not obtain Firebase service-account access token.");
  const data = await response.json();
  if (typeof data.access_token !== "string") throw new Error("Firebase returned no access token.");
  return data.access_token;
}

export class Firestore {
  private readonly base: string;
  private readonly documentResourceBase: string;
  private token?: string;

  constructor() {
    const projectId = requiredSecret("FB_PROJECT_ID");
    this.base = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;
    // Firestore REST endpoints use the full API URL, but Document.name in a
    // commit payload must be a resource name beginning with `projects/`.
    this.documentResourceBase = `projects/${projectId}/databases/(default)/documents`;
  }

  private async headers(): Promise<Record<string, string>> {
    this.token ??= await firebaseAccessToken();
    return { authorization: `Bearer ${this.token}`, "content-type": "application/json" };
  }

  async get(path: string, transaction?: string): Promise<FirestoreDocument | null> {
    const url = new URL(`${this.base}/${encodeDocumentPath(path)}`);
    if (transaction) url.searchParams.set("transaction", transaction);
    const response = await fetch(url, { headers: await this.headers() });
    if (response.status === 404) return null;
    if (!response.ok) throw new Error(`Firestore read failed (${response.status}).`);
    return await response.json();
  }

  async list(
    collection: string,
    pageToken?: string,
    options: { showMissing?: boolean; pageSize?: number } = {},
  ): Promise<{ documents: FirestoreDocument[]; nextPageToken?: string }> {
    const url = new URL(`${this.base}/${encodeDocumentPath(collection)}`);
    url.searchParams.set("pageSize", String(options.pageSize ?? 100));
    if (pageToken) url.searchParams.set("pageToken", pageToken);
    if (options.showMissing) url.searchParams.set("showMissing", "true");
    const response = await fetch(url, { headers: await this.headers() });
    if (!response.ok) throw new Error(`Firestore list failed (${response.status}).`);
    const data = await response.json();
    return { documents: data.documents ?? [], nextPageToken: data.nextPageToken };
  }

  /** One page of a collection, including documents that only have subcollections. */
  listPage(
    collection: string,
    pageToken?: string,
  ): Promise<{ documents: FirestoreDocument[]; nextPageToken?: string }> {
    return this.list(collection, pageToken, { showMissing: true, pageSize: 300 });
  }

  /** IDs of the subcollections directly under a document. */
  async listCollectionIds(documentPath: string): Promise<string[]> {
    const ids: string[] = [];
    let pageToken: string | undefined;
    do {
      const response = await fetch(
        `${this.base}/${encodeDocumentPath(documentPath)}:listCollectionIds`,
        {
          method: "POST",
          headers: await this.headers(),
          body: JSON.stringify({ pageSize: 100, ...(pageToken ? { pageToken } : {}) }),
        },
      );
      if (!response.ok) throw new Error(`Firestore list failed (${response.status}).`);
      const data = await response.json();
      ids.push(...(data.collectionIds ?? []));
      pageToken = data.nextPageToken;
    } while (pageToken);
    return ids;
  }

  /**
   * Every document whose string field equals `value`, in pages ordered by name.
   * `parent` null means the database root; `allDescendants` makes it a
   * collection-group query (needs the single-field index exemption).
   */
  async queryWhereEqual(input: {
    parent?: string | null;
    collectionId: string;
    fieldPath: string;
    value: string;
    allDescendants?: boolean;
    pageSize?: number;
  }): Promise<FirestoreDocument[]> {
    const pageSize = input.pageSize ?? 300;
    const url = input.parent
      ? `${this.base}/${encodeDocumentPath(input.parent)}:runQuery`
      : `${this.base}:runQuery`;
    const documents: FirestoreDocument[] = [];
    let cursor: string | null = null;
    while (true) {
      const response = await fetch(url, {
        method: "POST",
        headers: await this.headers(),
        body: JSON.stringify({
          structuredQuery: {
            from: [{ collectionId: input.collectionId, allDescendants: input.allDescendants === true }],
            where: {
              fieldFilter: {
                field: { fieldPath: input.fieldPath },
                op: "EQUAL",
                value: { stringValue: input.value },
              },
            },
            orderBy: [{ field: { fieldPath: "__name__" }, direction: "ASCENDING" }],
            ...(cursor ? { startAt: { values: [{ referenceValue: cursor }], before: false } } : {}),
            limit: pageSize,
          },
        }),
      });
      if (response.status === 400 || response.status === 412) {
        throw new Error("query_index_missing");
      }
      if (!response.ok) throw new Error(`Firestore query failed (${response.status}).`);
      const rows = await response.json();
      const page: FirestoreDocument[] = Array.isArray(rows)
        ? rows.map((row) => row.document).filter(Boolean)
        : [];
      documents.push(...page);
      if (page.length < pageSize) return documents;
      cursor = page[page.length - 1].name;
    }
  }

  /** Commits writes atomically without a transaction (no read checks). */
  async commitWrites(writes: unknown[]): Promise<void> {
    if (writes.length === 0) return;
    const response = await fetch(`${this.base}:commit`, {
      method: "POST",
      headers: await this.headers(),
      body: JSON.stringify({ writes }),
    });
    if (!response.ok) {
      console.error("Firestore batch commit rejected", { status: response.status });
      throw new Error(`Firestore batch could not commit (${response.status}).`);
    }
  }

  async queryEqual(collection: string, filters: Record<string, string>): Promise<FirestoreDocument[]> {
    const whereFilters = Object.entries(filters).map(([fieldPath, value]) => ({
      fieldFilter: { field: { fieldPath }, op: "EQUAL", value: { stringValue: value } },
    }));
    const where = whereFilters.length === 1
      ? whereFilters[0]
      : { compositeFilter: { op: "AND", filters: whereFilters } };
    const response = await fetch(`${this.base}:runQuery`, {
      method: "POST",
      headers: await this.headers(),
      body: JSON.stringify({ structuredQuery: { from: [{ collectionId: collection }], where } }),
    });
    if (!response.ok) throw new Error(`Firestore query failed (${response.status}).`);
    const rows = await response.json();
    return Array.isArray(rows) ? rows.map((row) => row.document).filter(Boolean) : [];
  }

  /** Counts (up to `limit`) documents in a subcollection whose string field equals `value`. */
  async countMatching(
    parentPath: string,
    collectionId: string,
    fieldPath: string,
    value: string,
    limit: number,
  ): Promise<number> {
    const response = await fetch(`${this.base}/${encodeDocumentPath(parentPath)}:runQuery`, {
      method: "POST",
      headers: await this.headers(),
      body: JSON.stringify({
        structuredQuery: {
          from: [{ collectionId }],
          where: {
            fieldFilter: { field: { fieldPath }, op: "EQUAL", value: { stringValue: value } },
          },
          select: { fields: [{ fieldPath: "__name__" }] },
          limit,
        },
      }),
    });
    if (!response.ok) throw new Error(`Firestore query failed (${response.status}).`);
    const rows = await response.json();
    return Array.isArray(rows) ? rows.filter((row) => row.document).length : 0;
  }

  async beginTransaction(): Promise<string> {
    const response = await fetch(`${this.base}:beginTransaction`, {
      method: "POST", headers: await this.headers(), body: "{}",
    });
    if (!response.ok) throw new Error(`Firestore transaction could not start (${response.status}).`);
    const data = await response.json();
    return data.transaction as string;
  }

  async commit(transaction: string, writes: unknown[]): Promise<void> {
    const response = await fetch(`${this.base}:commit`, {
      method: "POST", headers: await this.headers(),
      body: JSON.stringify({ transaction, writes }),
    });
    if (!response.ok) {
      // Keep provider bodies out of logs; the status and checkout stage identify
      // the failure class without exposing document or account details.
      console.error("Firestore commit rejected", { status: response.status });
      throw new Error(`Firestore transaction could not commit (${response.status}).`);
    }
  }

  async rollback(transaction: string): Promise<void> {
    const response = await fetch(`${this.base}:rollback`, {
      method: "POST",
      headers: await this.headers(),
      body: JSON.stringify({ transaction }),
    });
    if (!response.ok && response.status !== 404 && response.status !== 409) {
      console.error("Firestore rollback rejected", { status: response.status });
      throw new Error(`Firestore transaction could not roll back (${response.status}).`);
    }
  }

  document(path: string, fields: Record<string, FirestoreValue>): FirestoreDocument {
    return { name: `${this.documentResourceBase}/${path}`, fields };
  }
}

export function getField(fields: Record<string, FirestoreValue> | undefined, path: string[]): FirestoreValue | undefined {
  let current: FirestoreValue | undefined = { mapValue: { fields } };
  for (const segment of path) {
    const map = current?.mapValue as { fields?: Record<string, FirestoreValue> } | undefined;
    current = map?.fields?.[segment];
  }
  return current;
}

export function firestoreNumber(value: FirestoreValue | undefined): number | null {
  const raw = value?.doubleValue ?? value?.integerValue;
  const number = typeof raw === "string" ? Number(raw) : raw;
  return typeof number === "number" && Number.isFinite(number) ? number : null;
}

export function firestoreString(value: FirestoreValue | undefined): string | null {
  return typeof value?.stringValue === "string" ? value.stringValue : null;
}

export function firestoreBoolean(value: FirestoreValue | undefined): boolean | null {
  return typeof value?.booleanValue === "boolean" ? value.booleanValue : null;
}

export function stringValue(value: string): FirestoreValue { return { stringValue: value }; }
export function numberValue(value: number): FirestoreValue { return { doubleValue: value }; }
export function boolValue(value: boolean): FirestoreValue { return { booleanValue: value }; }
export function timestampValue(date = new Date()): FirestoreValue { return { timestampValue: date.toISOString() }; }
export function mapValue(fields: Record<string, FirestoreValue>): FirestoreValue { return { mapValue: { fields } }; }

export function updateWrite(document: FirestoreDocument, fieldPaths: string[], updateTime?: string): unknown {
  return {
    update: document,
    updateMask: { fieldPaths },
    currentDocument: updateTime ? { updateTime } : { exists: true },
  };
}

export function createWrite(document: FirestoreDocument): unknown {
  return { update: document, currentDocument: { exists: false } };
}

/** Creates or replaces the whole document. */
export function upsertWrite(document: FirestoreDocument): unknown {
  return { update: document };
}

/** Deletes the Firebase Auth account. A missing account counts as deleted. */
export async function deleteFirebaseAuthUser(uid: string): Promise<void> {
  const projectId = requiredSecret("FB_PROJECT_ID");
  const token = await firebaseAccessToken(AUTH_ADMIN_SCOPE);
  const response = await fetch(
    `https://identitytoolkit.googleapis.com/v1/projects/${encodeURIComponent(projectId)}/accounts:delete`,
    {
      method: "POST",
      headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
      body: JSON.stringify({ localId: uid }),
    },
  );
  if (response.ok) return;
  const body = await response.text().catch(() => "");
  if (response.status === 400 && body.includes("USER_NOT_FOUND")) return;
  console.error("Firebase Auth delete rejected", { status: response.status });
  throw new Error("auth_delete_failed");
}

export function deleteWrite(document: FirestoreDocument, updateTime?: string): unknown {
  return { delete: document.name, ...(updateTime ? { currentDocument: { updateTime } } : {}) };
}
