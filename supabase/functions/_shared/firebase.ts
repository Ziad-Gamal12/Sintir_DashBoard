import { createRemoteJWKSet, importPKCS8, jwtVerify, SignJWT } from "npm:jose@5.10.0";

type FirestoreValue = Record<string, unknown>;
type FirestoreDocument = { name: string; fields?: Record<string, FirestoreValue>; updateTime?: string };

const tokenKeys = createRemoteJWKSet(
  new URL("https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"),
);

export async function firebaseUid(request: Request): Promise<string> {
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
  return payload.sub;
}

export function requiredSecret(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing required server secret: ${name}`);
  return value;
}

async function firebaseAccessToken(): Promise<string> {
  const clientEmail = requiredSecret("FB_CLIENT_EMAIL");
  const privateKey = requiredSecret("FB_PRIVATE_KEY").replace(/\\n/g, "\n");
  const now = Math.floor(Date.now() / 1000);
  const key = await importPKCS8(privateKey, "RS256");
  const assertion = await new SignJWT({
    scope: "https://www.googleapis.com/auth/datastore",
  })
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
    const url = new URL(`${this.base}/${path}`);
    if (transaction) url.searchParams.set("transaction", transaction);
    const response = await fetch(url, { headers: await this.headers() });
    if (response.status === 404) return null;
    if (!response.ok) throw new Error(`Firestore read failed (${response.status}).`);
    return await response.json();
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
      // Preserve the Firebase error details in Supabase logs. Do not return this
      // provider payload to the mobile client because it can reveal internals.
      const details = await response.text();
      console.error("Firestore commit rejected", {
        status: response.status,
        details,
      });
      throw new Error(`Firestore transaction could not commit (${response.status}).`);
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
