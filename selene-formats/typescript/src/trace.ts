/** TypeScript bindings for version 0.2.0 of the Selene trace protocol. */

import { z } from "zod";
import {
  LosslessNumber,
  parse as parseLosslessJson,
} from "lossless-json";

export const SCHEMA_VERSION = "0.2.0" as const;
const SchemaVersionSchema = z.literal(SCHEMA_VERSION);
export type SchemaVersion = z.infer<typeof SchemaVersionSchema>;

/** The largest value representable by an unsigned 64-bit integer. */
export const UINT64_MAX = (1n << 64n) - 1n;
export const MAX_SAFE_INTEGER = Number.MAX_SAFE_INTEGER;

/** A non-negative JSON integer that can be represented exactly by JavaScript. */
const SafeUIntSchema = z
  .number()
  .int()
  .min(0)
  .max(MAX_SAFE_INTEGER);
export type SafeUInt = z.infer<typeof SafeUIntSchema>;

/** A canonical unsigned 64-bit integer encoded as a hexadecimal string. */
const UInt64HexStringSchema = z
  .string()
  .regex(
    /^0x(0|[1-9A-F][0-9A-F]{0,15})(?![\s\S])/,
    "Expected a canonical unsigned hexadecimal string",
  );
export type UInt64HexString = z.infer<typeof UInt64HexStringSchema>;

/** A hexadecimal-string uint64 decoded to a bigint for in-memory use. */
const UInt64Schema = UInt64HexStringSchema.transform((value) => BigInt(value));
export type UInt64 = z.infer<typeof UInt64Schema>;

const PredicateResultSchema = z.object({
  predicate: z.string(),
  result: z.boolean(),
});
export type PredicateResult = z.infer<typeof PredicateResultSchema>;

const UserProgramSourceSchema = z.object({
  kind: z.literal("UserProgram"),
  index: SafeUIntSchema,
});
export type UserProgramSource = z.infer<typeof UserProgramSourceSchema>;
export type UserProgramSourceInput = z.input<typeof UserProgramSourceSchema>;

const RuntimeSourceSchema = z.object({
  kind: z.literal("Runtime"),
  start_time: SafeUIntSchema,
  end_time: SafeUIntSchema,
});
export type RuntimeSource = z.infer<typeof RuntimeSourceSchema>;
export type RuntimeSourceInput = z.input<typeof RuntimeSourceSchema>;

const ErrorModelSourceSchema = z.object({
  kind: z.literal("ErrorModel"),
  index: SafeUIntSchema,
});
export type ErrorModelSource = z.infer<typeof ErrorModelSourceSchema>;
export type ErrorModelSourceInput = z.input<typeof ErrorModelSourceSchema>;

const SimulatorSourceSchema = z.object({
  kind: z.literal("Simulator"),
  index: SafeUIntSchema,
  duration_ns: SafeUIntSchema,
});
export type SimulatorSource = z.infer<typeof SimulatorSourceSchema>;
export type SimulatorSourceInput = z.input<typeof SimulatorSourceSchema>;

const SourceSchema = z.discriminatedUnion("kind", [
  UserProgramSourceSchema,
  RuntimeSourceSchema,
  ErrorModelSourceSchema,
  SimulatorSourceSchema,
]);
export type Source = z.infer<typeof SourceSchema>;
export type SourceInput = z.input<typeof SourceSchema>;

/** Finite numbers whose integer values are exactly representable in JavaScript. */
const SafeNumberSchema = z.number().finite().refine(
  (value) => !Number.isInteger(value) || Number.isSafeInteger(value),
  { message: "Integer-valued numbers must be within JavaScript's safe range" },
);

const GateParameterSchema = z.union([SafeNumberSchema, z.boolean()]);
export type GateParameter = z.infer<typeof GateParameterSchema>;

const GateEventSchema = z.object({
  kind: z.literal("Gate"),
  qubits: z.array(SafeUIntSchema).default([]),
  gate_name: z.string(),
  params: z.array(GateParameterSchema).default([]),
  predicates: z.array(PredicateResultSchema).default([]),
});
export type GateEvent = z.infer<typeof GateEventSchema>;
export type GateEventInput = z.input<typeof GateEventSchema>;

const MeasurementTypeSchema = z.string().min(1);
export type MeasurementType = z.infer<typeof MeasurementTypeSchema>;

const MeasurementEventSchema = z.object({
  kind: z.literal("Measurement"),
  qubit: SafeUIntSchema,
  measurement_type: MeasurementTypeSchema.default("Standard"),
  result_id: SafeUIntSchema.nullable().default(null),
});
export type MeasurementEvent = z.infer<typeof MeasurementEventSchema>;
export type MeasurementEventInput = z.input<typeof MeasurementEventSchema>;

const FutureReadEventSchema = z.object({
  kind: z.literal("FutureRead"),
  result_id: SafeUIntSchema,
});
export type FutureReadEvent = z.infer<typeof FutureReadEventSchema>;
export type FutureReadEventInput = z.input<typeof FutureReadEventSchema>;

/** A runtime future result with string, numeric, boolean, null, array, or object values. */
export type FutureResultValue = string | number | boolean | null | FutureResultValue[] | { [key: string]: FutureResultValue };
function isFutureResultValue(value: unknown, ancestors = new Set<object>()): value is FutureResultValue {
  if (value === null || typeof value === "string" || typeof value === "boolean") return true;
  if (typeof value === "number") {
    return Number.isFinite(value) && (!Number.isInteger(value) || Number.isSafeInteger(value));
  }
  if (typeof value !== "object" || ancestors.has(value)) return false;
  if (!Array.isArray(value) && Object.getPrototypeOf(value) !== Object.prototype && Object.getPrototypeOf(value) !== null) return false;
  if (Object.getOwnPropertySymbols(value).length !== 0) return false;
  ancestors.add(value);
  try {
    const children = Array.isArray(value) ? Array.from(value) : Object.values(value);
    return children.every((child) => isFutureResultValue(child, ancestors));
  } finally {
    ancestors.delete(value);
  }
}

function cloneFutureResultValue(value: FutureResultValue): FutureResultValue {
  if (Array.isArray(value)) return value.map(cloneFutureResultValue);
  if (value !== null && typeof value === "object") {
    const result: { [key: string]: FutureResultValue } = {};
    for (const [key, child] of Object.entries(value)) {
      Object.defineProperty(result, key, {
        value: cloneFutureResultValue(child), enumerable: true, configurable: true, writable: true,
      });
    }
    return result;
  }
  return value;
}

const FutureResultValueSchema: z.ZodType<FutureResultValue, FutureResultValue> = z.custom<FutureResultValue>(
  (value) => isFutureResultValue(value),
  { message: "Expected a future result value with finite, safe-integer numbers" },
).transform(cloneFutureResultValue);

const FutureResultEventSchema = z.object({
  kind: z.literal("FutureResult"),
  result_id: SafeUIntSchema,
  outcome: FutureResultValueSchema,
});
export type FutureResultEvent = z.infer<typeof FutureResultEventSchema>;
export type FutureResultEventInput = z.input<typeof FutureResultEventSchema>;

const ResetEventSchema = z.object({
  kind: z.literal("Reset"),
  qubit: SafeUIntSchema,
});
export type ResetEvent = z.infer<typeof ResetEventSchema>;
export type ResetEventInput = z.input<typeof ResetEventSchema>;

/** A base64url-encoded byte sequence. */
const Base64UrlSchema = z.string().regex(
  // Final-character sets restrict unused bits to zero for one- and two-byte tails.
  /^(?:[A-Za-z0-9_-]{4})*(?:[A-Za-z0-9_-][AQgw](?:==)?|[A-Za-z0-9_-]{2}[AEIMQUYcgkosw048]=?)?(?![\s\S])/,
  "Expected base64url data with zero unused pad bits",
);

const OpaquePayloadSchema = z.object({
  kind: z.literal("OpaquePayload"),
  tag: UInt64Schema,
  /** Base64url-encoded bytes. */
  data: Base64UrlSchema,
});
export type OpaquePayload = z.infer<typeof OpaquePayloadSchema>;
export type OpaquePayloadInput = z.input<typeof OpaquePayloadSchema>;

const KeyValueSchema = z.union([
  z.string(),
  SafeNumberSchema,
  z.boolean(),
  z.array(z.string()),
  z.array(SafeNumberSchema),
  z.array(z.boolean()),
]);
export type KeyValue = z.infer<typeof KeyValueSchema>;

const KeyValuePairPayloadSchema = z.object({
  kind: z.literal("KeyValuePairPayload"),
  data: z.record(z.string(), KeyValueSchema),
});
export type KeyValuePairPayload = z.infer<typeof KeyValuePairPayloadSchema>;
export type KeyValuePairPayloadInput = z.input<typeof KeyValuePairPayloadSchema>;

const CustomPayloadSchema = z.discriminatedUnion("kind", [
  OpaquePayloadSchema,
  KeyValuePairPayloadSchema,
]);
export type CustomPayload = z.infer<typeof CustomPayloadSchema>;
export type CustomPayloadInput = z.input<typeof CustomPayloadSchema>;

const CustomEventSchema = z.object({
  kind: z.literal("Custom"),
  payload: CustomPayloadSchema,
});
export type CustomEvent = z.infer<typeof CustomEventSchema>;
export type CustomEventInput = z.input<typeof CustomEventSchema>;

const EventSchema = z.discriminatedUnion("kind", [
  GateEventSchema,
  MeasurementEventSchema,
  FutureReadEventSchema,
  FutureResultEventSchema,
  ResetEventSchema,
  CustomEventSchema,
]);
export type Event = z.infer<typeof EventSchema>;
export type EventInput = z.input<typeof EventSchema>;

const EventRecordSchema = z.object({
  source: SourceSchema,
  event: EventSchema,
});
export type EventRecord = z.infer<typeof EventRecordSchema>;
export type EventRecordInput = z.input<typeof EventRecordSchema>;

const TraceDataSchema = z.object({
  events: z.array(EventRecordSchema).default([]),
}).strict();
export type TraceData = z.infer<typeof TraceDataSchema>;
export type TraceDataInput = z.input<typeof TraceDataSchema>;

const TraceSchema = z.object({
  schema_version: SchemaVersionSchema,
  events: z.array(EventRecordSchema).default([]),
}).strict();
export type Trace = z.infer<typeof TraceSchema>;
export type TraceInput = z.input<typeof TraceSchema>;

const TracesSchema = z.object({
  schema_version: SchemaVersionSchema,
  traces: z.array(TraceDataSchema),
}).strict();
export type Traces = z.infer<typeof TracesSchema>;
export type TracesInput = z.input<typeof TracesSchema>;

const TraceDocumentSchema = z.union([TraceSchema, TracesSchema]);
export type TraceDocument = z.infer<typeof TraceDocumentSchema>;
export type TraceDocumentInput = z.input<typeof TraceDocumentSchema>;

const UInt64BigIntSchema = z.bigint().min(0n).max(UINT64_MAX);

const LegacyOpaquePayloadSchema = OpaquePayloadSchema.extend({
  // Normalize either legacy alphabet before validating as base64url.
  data: z.string()
    .transform((value) => value.replace(/\+/g, "-").replace(/\//g, "_"))
    .pipe(Base64UrlSchema),
  tag: z.union([
    z.number().int().nonnegative().safe().transform((value) => BigInt(value)),
    UInt64BigIntSchema,
  ]),
});

const LegacyCustomPayloadSchema = z.discriminatedUnion("kind", [
  LegacyOpaquePayloadSchema,
  KeyValuePairPayloadSchema,
]);

const LegacyCustomEventSchema = CustomEventSchema.extend({
  payload: LegacyCustomPayloadSchema,
});

const LegacyEventSchema = z.discriminatedUnion("kind", [
  GateEventSchema,
  MeasurementEventSchema,
  ResetEventSchema,
  LegacyCustomEventSchema,
]);

const LegacyEventRecordSchema = EventRecordSchema.extend({
  event: LegacyEventSchema,
});

/** The versionless trace representation emitted before protocol versioning. */
const LegacyTraceSchema = z.object({
  events: z.array(LegacyEventRecordSchema).default([]),
}).passthrough().refine((value) => !("schema_version" in value), {
  message: "Legacy trace documents must not contain schema_version",
}).refine((value) => !("traces" in value), {
  message: "Versionless trace collections are not supported",
});

function constructorEvents(events: (EventRecordInput | EventRecord)[] = []) {
  return events.map((record) => {
    if (record.event.kind !== "Custom") return record;
    const payload = record.event.payload;
    if (payload.kind !== "OpaquePayload" || typeof payload.tag !== "bigint") return record;
    return {
      ...record,
      event: {
        ...record.event,
        payload: serializeCustomPayload({
          ...payload,
          tag: UInt64BigIntSchema.parse(payload.tag),
        }),
      },
    };
  });
}

/** Create a versioned trace from wire inputs or normalized events. */
export function createTrace(events: (EventRecordInput | EventRecord)[] = []): Trace {
  return TraceSchema.parse({
    schema_version: SCHEMA_VERSION,
    events: constructorEvents(events),
  });
}

/** Create unversioned trace data from wire inputs or normalized events. */
export function createTraceData(events: (EventRecordInput | EventRecord)[] = []): TraceData {
  return TraceDataSchema.parse({ events: constructorEvents(events) });
}

/** Create a versioned collection from wire inputs or normalized trace data. */
export function createTraces(traces: (TraceDataInput | TraceData)[]): Traces {
  return TracesSchema.parse({
    schema_version: SCHEMA_VERSION,
    traces: traces.map((data) => ({ ...data, events: constructorEvents(data.events) })),
  });
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/** Upgrade a validated versionless trace into the current in-memory model. */
export function upgradeLegacyTrace(value: unknown): Trace {
  const legacy = LegacyTraceSchema.parse(value);
  return {
    schema_version: SCHEMA_VERSION,
    events: legacy.events as EventRecord[],
  };
}

function upgradeVersion(value: unknown): unknown {
  if (isObject(value) && value.schema_version === "0.1.0") {
    const documents = Array.isArray(value.traces) ? value.traces : [value];
    for (const document of documents) {
      if (!isObject(document) || !Array.isArray(document.events)) continue;
      for (const record of document.events) {
        if (isObject(record) && isObject(record.event) && (record.event.kind === "FutureRead" || record.event.kind === "FutureResult")) {
          throw new z.ZodError([{ code: "custom", path: ["events"], message: "FutureRead and FutureResult require trace schema 0.2.0" }]);
        }
      }
    }
    return { ...value, schema_version: SCHEMA_VERSION };
  }
  return value;
}

/** Parse a JSON-compatible current or versionless legacy trace value. */
export function parseTrace(value: unknown): Trace {
  if (isObject(value) && !("schema_version" in value)) {
    return upgradeLegacyTrace(value);
  }
  return TraceSchema.parse(upgradeVersion(value));
}

/** Parse either current trace-document shape, or a versionless legacy trace. */
export function parseTraceDocument(value: unknown): TraceDocument {
  if (isObject(value) && !("schema_version" in value)) {
    return upgradeLegacyTrace(value);
  }
  return TraceDocumentSchema.parse(upgradeVersion(value));
}

function normalizeLosslessJson(value: unknown): unknown {
  if (value instanceof LosslessNumber) {
    const converted = value.valueOf();
    if (typeof converted === "bigint") {
      return Number(converted);
    }
    return converted;
  }

  if (Array.isArray(value)) {
    return value.map((item) => normalizeLosslessJson(item));
  }

  if (!isObject(value)) {
    return value;
  }

  const normalized: Record<string, unknown> = Object.create(null);
  for (const [key, child] of Object.entries(value)) {
    normalized[key] = normalizeLosslessJson(child);
  }
  return normalized;
}

function normalizeTraceJson(value: unknown): unknown {
  if (isObject(value) && !("schema_version" in value) && Array.isArray(value.events)) {
    for (const record of value.events) {
      if (
        !isObject(record) ||
        !isObject(record.event) ||
        record.event.kind !== "Custom"
      ) {
        continue;
      }
      const payload = record.event.payload;
      if (
        !isObject(payload) ||
        payload.kind !== "OpaquePayload" ||
        !(payload.tag instanceof LosslessNumber)
      ) {
        continue;
      }
      const decimal = payload.tag.toString();
      if (!/^(0|[1-9][0-9]*)$/.test(decimal)) {
        throw new RangeError("legacy OpaquePayload.tag must be an unsigned JSON integer");
      }
      const tag = BigInt(decimal);
      if (tag > UINT64_MAX) {
        throw new RangeError("legacy OpaquePayload.tag exceeds the uint64 range");
      }
      payload.tag = tag;
    }
  }
  return normalizeLosslessJson(value);
}

function parseTraceJsonValue(json: string): unknown {
  // Protect object keys from the lossless parser's property-assignment semantics.
  const stringTokens = /"(?:[^"\\]|\\.)*"\s*:?/g;
  const keys = new Set<string>();
  for (const match of json.matchAll(stringTokens)) {
    if (match[0].endsWith(":")) keys.add(JSON.parse(match[0].slice(0, -1)) as string);
  }
  if (!keys.has("__proto__")) return parseLosslessJson(json);
  let escapedKey = "__selene_proto__";
  while (keys.has(escapedKey)) escapedKey += "_";
  const protectedJson = json.replace(stringTokens, (token) =>
    token.endsWith(":") && JSON.parse(token.slice(0, -1)) === "__proto__"
      ? `${JSON.stringify(escapedKey)}:` : token,
  );
  const parsed = parseLosslessJson(protectedJson);
  const restore = (value: unknown): void => {
    if (value instanceof LosslessNumber) return;
    if (Array.isArray(value)) { value.forEach(restore); return; }
    if (!isObject(value)) return;
    for (const [key, child] of Object.entries(value)) {
      restore(child);
      if (key === escapedKey) {
        Object.defineProperty(value, "__proto__", { value: child, enumerable: true, configurable: true, writable: true });
        delete value[key];
      }
    }
  };
  restore(parsed);
  return parsed;
}

/** Parse trace JSON while preserving a legacy numeric opaque-payload tag. */
export function parseTraceJson(json: string): Trace {
  const parsed = parseTraceJsonValue(json);
  return parseTrace(normalizeTraceJson(parsed));
}

/** Parse trace-document JSON while preserving a legacy numeric opaque tag. */
export function parseTraceDocumentJson(json: string): TraceDocument {
  const parsed = parseTraceJsonValue(json);
  return parseTraceDocument(normalizeTraceJson(parsed));
}

/** The result of validation, with a parsed value or an error describing the failure. */
export type ParseResult<T> =
  | { success: true; data: T }
  | { success: false; error: Error };

/** Validate a JSON-compatible value as a Selene trace without throwing. */
export function safeParseTrace(
  value: unknown,
): ParseResult<Trace> {
  try {
    return { success: true, data: parseTrace(value) };
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, error };
    }
    throw error;
  }
}

/** Validate either trace-document shape without throwing. */
export function safeParseTraceDocument(
  value: unknown,
): ParseResult<TraceDocument> {
  try {
    return { success: true, data: parseTraceDocument(value) };
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, error };
    }
    throw error;
  }
}

function serializeCustomPayload(payload: CustomPayload): CustomPayloadInput {
  if (payload.kind === "OpaquePayload") {
    return { ...payload, tag: `0x${payload.tag.toString(16).toUpperCase()}` };
  }

  return payload;
}

function serializeEvent(event: Event): EventInput {
  switch (event.kind) {
    case "Gate":
      return event;
    case "FutureRead":
    case "FutureResult":
    case "Measurement":
    case "Reset":
      return event;
    case "Custom":
      return { ...event, payload: serializeCustomPayload(event.payload) };
  }
}

function serializeSource(source: Source): SourceInput {
  return source;
}

/** Convert parsed trace data to its JSON-compatible representation. */
export function serializeTraceData(trace: TraceData): TraceDataInput {
  const serialized = {
    events: trace.events.map(({ source, event }) => ({
      source: serializeSource(source),
      event: serializeEvent(event),
    })),
  };
  TraceDataSchema.parse(serialized);
  return serialized;
}

/** Convert a parsed trace to its JSON-compatible representation. */
export function serializeTrace(trace: Trace): TraceInput {
  return {
    schema_version: SchemaVersionSchema.parse(trace.schema_version),
    ...serializeTraceData(trace),
  };
}

/** Convert a parsed trace collection to its JSON-compatible representation. */
export function serializeTraces(traces: Traces): TracesInput {
  return {
    schema_version: SchemaVersionSchema.parse(traces.schema_version),
    traces: traces.traces.map(serializeTraceData),
  };
}

/** Convert either parsed trace-document shape to a JSON-compatible value. */
export function serializeTraceDocument(document: TraceDocument): TraceDocumentInput {
  return "traces" in document ? serializeTraces(document) : serializeTrace(document);
}
