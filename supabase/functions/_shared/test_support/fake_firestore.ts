// In-memory stand-in for the REST Firestore client in ../firebase.ts, for
// tests only (never imported by a function). It mirrors the behaviour the
// feedback functions rely on:
// - transactions: a commit fails with 409 if any document read in the
//   transaction changed since it was read (contention);
// - write preconditions: exists / updateTime (400 when violated);
// - updateMask semantics: masked fields absent from the document are removed;
// - one write per document per commit.
// It also counts calls and groups reads into "waves" (a wave starts when no
// read is in flight) so tests can assert round trips.

import { decodeFields, encode } from "../course_checkout.ts";
import type { FeedbackStore } from "../course_feedback.ts";

type Value = Record<string, unknown>;
type Fields = Record<string, Value>;
type Doc = { fields: Fields; version: number };
type Write = {
  update?: { name: string; fields?: Fields };
  updateMask?: { fieldPaths: string[] };
  delete?: string;
  currentDocument?: { exists?: boolean; updateTime?: string };
};
export type CommittedWrite = {
  path: string;
  kind: "create" | "update" | "delete";
  mask?: string[];
};

const ROOT = "projects/test-project/databases/(default)/documents/";
const commitFailure = (status: number) =>
  new Error(`Firestore transaction could not commit (${status}).`);

export class FakeFirestore implements FeedbackStore {
  private docs = new Map<string, Doc>();
  private clock = 0;
  private transactions = 0;
  private open = new Map<string, Map<string, number | null>>();
  private inFlight = 0;

  readonly calls = { begin: 0, get: 0, commit: 0, rollback: 0 };
  readonly commits: CommittedWrite[][] = [];
  readonly readWaves: string[][] = [];

  /** Simulated network latency per call, in ms. */
  latency: () => number = () => 0;
  /** Runs right before a commit is validated (e.g. to simulate contention). */
  beforeCommit?: (commitNumber: number) => void;
  /** Return an Error to make a read fail. */
  failGet?: (path: string) => Error | null;

  seed(path: string, data: Record<string, unknown>): void {
    this.docs.set(path, {
      fields: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, encode(v)]),
      ),
      version: ++this.clock,
    });
  }

  data(path: string): Record<string, unknown> | null {
    const doc = this.docs.get(path);
    return doc ? decodeFields(structuredClone(doc.fields)) : null;
  }

  version(path: string): number | null {
    return this.docs.get(path)?.version ?? null;
  }

  /** Removes a document outside any transaction (test setup). */
  drop(path: string): void {
    this.docs.delete(path);
  }

  /** Simulates a write by someone else. */
  touch(path: string): void {
    const doc = this.docs.get(path);
    if (doc) doc.version = ++this.clock;
  }

  /** Direct children of a collection path, decoded. */
  list(collection: string): Array<Record<string, unknown>> {
    const prefix = `${collection}/`;
    return [...this.docs.entries()]
      .filter(([path]) =>
        path.startsWith(prefix) && !path.slice(prefix.length).includes("/")
      )
      .map(([path]) => this.data(path)!);
  }

  resetCounters(): void {
    this.calls.begin =
      this.calls.get =
      this.calls.commit =
      this.calls.rollback =
        0;
    this.commits.length = 0;
    this.readWaves.length = 0;
  }

  get openTransactions(): number {
    return this.open.size;
  }

  document(path: string, fields: Fields) {
    return { name: ROOT + path, fields };
  }

  async beginTransaction(): Promise<string> {
    this.calls.begin++;
    await this.wait();
    const id = `tx-${++this.transactions}`;
    this.open.set(id, new Map());
    return id;
  }

  async get(path: string, transaction?: string) {
    this.calls.get++;
    if (this.inFlight === 0) this.readWaves.push([]);
    this.readWaves[this.readWaves.length - 1].push(path);
    this.inFlight++;
    try {
      const reads = transaction === undefined
        ? null
        : this.open.get(transaction);
      if (reads === undefined) throw new Error("Firestore read failed (400).");
      const failure = this.failGet?.(path);
      if (failure) throw failure;
      await this.wait();
      const doc = this.docs.get(path);
      if (reads && !reads.has(path)) reads.set(path, doc?.version ?? null);
      return doc
        ? {
          name: ROOT + path,
          fields: structuredClone(doc.fields),
          updateTime: `v${doc.version}`,
        }
        : null;
    } finally {
      this.inFlight--;
    }
  }

  async commit(transaction: string, writes: unknown[]): Promise<void> {
    this.calls.commit++;
    const reads = this.open.get(transaction);
    this.open.delete(transaction); // a commit ends the transaction either way
    if (reads === undefined) throw commitFailure(400);
    await this.wait();
    this.beforeCommit?.(this.calls.commit);

    for (const [path, version] of reads) {
      if ((this.docs.get(path)?.version ?? null) !== version) {
        throw commitFailure(409);
      }
    }

    const next = new Map(this.docs);
    const log: CommittedWrite[] = [];
    for (const write of writes as Write[]) {
      const name = write.update?.name ?? write.delete;
      if (!name?.startsWith(ROOT)) throw commitFailure(400);
      const path = name.slice(ROOT.length);
      if (log.some((entry) => entry.path === path)) throw commitFailure(400);

      const current = this.docs.get(path);
      const pre = write.currentDocument;
      if (pre?.exists === true && !current) throw commitFailure(400);
      if (pre?.exists === false && current) throw commitFailure(400);
      if (
        pre?.updateTime !== undefined &&
        (!current || `v${current.version}` !== pre.updateTime)
      ) throw commitFailure(400);

      if (write.delete) {
        next.delete(path);
        log.push({ path, kind: "delete" });
        continue;
      }
      const fields = write.update!.fields ?? {};
      if (write.updateMask) {
        const mask = write.updateMask.fieldPaths;
        if (Object.keys(fields).some((key) => !mask.includes(key))) {
          throw new Error("fake: document has fields outside its updateMask");
        }
        if (mask.some((key) => key.includes("."))) {
          throw new Error("fake: nested mask paths are not used here");
        }
        const merged: Fields = { ...(current?.fields ?? {}) };
        for (const key of mask) {
          if (key in fields) merged[key] = structuredClone(fields[key]);
          else delete merged[key];
        }
        next.set(path, { fields: merged, version: ++this.clock });
        log.push({ path, kind: "update", mask: [...mask].sort() });
      } else {
        next.set(path, {
          fields: structuredClone(fields),
          version: ++this.clock,
        });
        log.push({ path, kind: "create" });
      }
    }
    this.docs = next;
    this.commits.push(log);
  }

  async rollback(transaction: string): Promise<void> {
    this.calls.rollback++;
    await this.wait();
    this.open.delete(transaction);
  }

  private wait(): Promise<void> {
    const ms = this.latency();
    return ms > 0
      ? new Promise((resolve) => setTimeout(resolve, ms))
      : Promise.resolve();
  }
}
