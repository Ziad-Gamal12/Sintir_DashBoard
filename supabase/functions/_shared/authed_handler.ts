// POST JSON handler for functions called by the app with a Firebase ID token.
// Authentication happens before the body is read or any client is created.

import { parseBody } from "./course_checkout.ts";
import { corsHeaders, error, json } from "./http.ts";

export type SafeError = { code: string; status: number; message: string };

export type AuthedHandlerDeps<S> = {
  authenticate: (request: Request) => Promise<string>;
  store: () => S;
  maxBodyBytes?: number;
  logError?: (event: string, details: Record<string, unknown>) => void;
};

const defaultLogError = (event: string, details: Record<string, unknown>) =>
  console.error(event, details);

export async function readCappedJson(
  request: Request,
  maxBytes: number,
): Promise<Record<string, unknown>> {
  const declared = Number(request.headers.get("content-length") ?? "0");
  if (declared > maxBytes) throw new Error("payload_too_large");
  if (!request.body) throw new Error("invalid_body");
  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let size = 0;
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    size += value.byteLength;
    if (size > maxBytes) {
      await reader.cancel().catch(() => {});
      throw new Error("payload_too_large");
    }
    chunks.push(value);
  }
  const bytes = new Uint8Array(size);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.byteLength;
  }
  try {
    return parseBody(
      JSON.parse(new TextDecoder("utf-8", { fatal: true }).decode(bytes)),
    );
  } catch {
    throw new Error("invalid_body");
  }
}

export function createAuthedHandler<S, T extends Record<string, unknown>>(
  name: string,
  action: (store: S, uid: string, body: Record<string, unknown>) => Promise<T>,
  toSafeError: (cause: unknown) => SafeError,
  deps: AuthedHandlerDeps<S>,
): (request: Request) => Promise<Response> {
  return async (request) => {
    if (request.method === "OPTIONS") {
      return new Response("ok", { headers: corsHeaders });
    }
    if (request.method !== "POST") {
      return error("method_not_allowed", "Use POST.", 405);
    }
    try {
      const uid = await deps.authenticate(request);
      const body = await readCappedJson(request, deps.maxBodyBytes ?? 16 * 1024);
      const result = await action(deps.store(), uid, body);
      return json({ ok: true, ...result });
    } catch (cause) {
      const safe = toSafeError(cause);
      if (safe.status >= 500) {
        (deps.logError ?? defaultLogError)(`${name}_failed`, {
          reason: cause instanceof Error ? cause.message : typeof cause,
        });
      }
      return error(safe.code, safe.message, safe.status);
    }
  };
}
