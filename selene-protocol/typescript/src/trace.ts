/** TypeScript bindings for version 0.1.0 of the Selene trace protocol. */

import { z } from "zod";
import { isLosslessNumber, parse as parseLosslessJson } from "lossless-json";

export const SCHEMA_VERSION = "0.1.0" as const;
export const SchemaVersionSchema = z.literal(SCHEMA_VERSION);
export type SchemaVersion = z.infer<typeof SchemaVersionSchema>;

/** The largest value representable by an unsigned 64-bit integer. */
export const UINT64_MAX = (1n << 64n) - 1n;
export const MAX_SAFE_INTEGER = Number.MAX_SAFE_INTEGER;

/** A non-negative JSON integer that can be represented exactly by JavaScript. */
export const SafeUIntSchema = z
  .number()
  .int()
  .min(0)
  .max(MAX_SAFE_INTEGER);
export type SafeUInt = z.infer<typeof SafeUIntSchema>;

/** A canonical unsigned 64-bit integer encoded as a decimal string. */
export const UInt64DecimalStringSchema = z
  .string()
  .regex(/^(0|[1-9][0-9]*)(?![\s\S])/, "Expected a canonical unsigned decimal string")
  .refine((value) => BigInt(value) <= UINT64_MAX, {
    message: "Expected an unsigned 64-bit integer",
  });
export type UInt64DecimalString = z.infer<typeof UInt64DecimalStringSchema>;

/** A decimal-string uint64 decoded to a bigint for in-memory use. */
export const UInt64Schema = UInt64DecimalStringSchema.transform((value) => BigInt(value));
export type UInt64 = z.infer<typeof UInt64Schema>;

export const PredicateResultSchema = z.object({
  predicate: z.string(),
  result: z.boolean(),
});
export type PredicateResult = z.infer<typeof PredicateResultSchema>;

export const UserProgramSourceSchema = z.object({
  kind: z.literal("UserProgram"),
  index: SafeUIntSchema,
});
export type UserProgramSource = z.infer<typeof UserProgramSourceSchema>;
export type UserProgramSourceInput = z.input<typeof UserProgramSourceSchema>;

export const RuntimeSourceSchema = z.object({
  kind: z.literal("Runtime"),
  start_time: SafeUIntSchema,
  end_time: SafeUIntSchema,
});
export type RuntimeSource = z.infer<typeof RuntimeSourceSchema>;
export type RuntimeSourceInput = z.input<typeof RuntimeSourceSchema>;

export const ErrorModelSourceSchema = z.object({
  kind: z.literal("ErrorModel"),
  index: SafeUIntSchema,
});
export type ErrorModelSource = z.infer<typeof ErrorModelSourceSchema>;
export type ErrorModelSourceInput = z.input<typeof ErrorModelSourceSchema>;

export const SimulatorSourceSchema = z.object({
  kind: z.literal("Simulator"),
  index: SafeUIntSchema,
  duration_ns: SafeUIntSchema,
});
export type SimulatorSource = z.infer<typeof SimulatorSourceSchema>;
export type SimulatorSourceInput = z.input<typeof SimulatorSourceSchema>;

export const SourceSchema = z.discriminatedUnion("kind", [
  UserProgramSourceSchema,
  RuntimeSourceSchema,
  ErrorModelSourceSchema,
  SimulatorSourceSchema,
]);
export type Source = z.infer<typeof SourceSchema>;
export type SourceInput = z.input<typeof SourceSchema>;

/** Finite numbers whose integer values are exactly representable in JavaScript. */
export const SafeNumberSchema = z.number().finite().refine(
  (value) => !Number.isInteger(value) || Number.isSafeInteger(value),
  { message: "Integer-valued numbers must be within JavaScript's safe range" },
);

export const GateParameterSchema = z.union([SafeNumberSchema, z.boolean()]);
export type GateParameter = z.infer<typeof GateParameterSchema>;

export const GateEventSchema = z.object({
  kind: z.literal("Gate"),
  qubits: z.array(SafeUIntSchema).default([]),
  gate_name: z.string(),
  params: z.array(GateParameterSchema).default([]),
  predicates: z.array(PredicateResultSchema).default([]),
});
export type GateEvent = z.infer<typeof GateEventSchema>;
export type GateEventInput = z.input<typeof GateEventSchema>;

export const MeasurementEventSchema = z.object({
  kind: z.literal("Measurement"),
  qubit: SafeUIntSchema,
});
export type MeasurementEvent = z.infer<typeof MeasurementEventSchema>;
export type MeasurementEventInput = z.input<typeof MeasurementEventSchema>;

export const ResetEventSchema = z.object({
  kind: z.literal("Reset"),
  qubit: SafeUIntSchema,
});
export type ResetEvent = z.infer<typeof ResetEventSchema>;
export type ResetEventInput = z.input<typeof ResetEventSchema>;

function isBase64Url(value: string): boolean {
  if (!/^[A-Za-z0-9_-]*={0,2}$/.test(value) || value.length % 4 === 1) {
    return false;
  }

  const paddingIndex = value.indexOf("=");
  return paddingIndex === -1 || value.length % 4 === 0;
}

/** A base64url-encoded byte sequence. */
export const Base64UrlSchema = z.string().refine(isBase64Url, {
  message: "Expected a base64url-encoded string",
});

export const OpaquePayloadSchema = z.object({
  kind: z.literal("OpaquePayload"),
  tag: UInt64Schema,
  /** Base64url-encoded bytes. */
  data: Base64UrlSchema,
});
export type OpaquePayload = z.infer<typeof OpaquePayloadSchema>;
export type OpaquePayloadInput = z.input<typeof OpaquePayloadSchema>;

export const KeyValueSchema = z.union([
  z.string(),
  SafeNumberSchema,
  z.boolean(),
  z.array(z.string()),
  z.array(SafeNumberSchema),
  z.array(z.boolean()),
]);
export type KeyValue = z.infer<typeof KeyValueSchema>;

export const KeyValuePairPayloadSchema = z.object({
  kind: z.literal("KeyValuePairPayload"),
  data: z.record(KeyValueSchema),
});
export type KeyValuePairPayload = z.infer<typeof KeyValuePairPayloadSchema>;
export type KeyValuePairPayloadInput = z.input<typeof KeyValuePairPayloadSchema>;

export const CustomPayloadSchema = z.discriminatedUnion("kind", [
  OpaquePayloadSchema,
  KeyValuePairPayloadSchema,
]);
export type CustomPayload = z.infer<typeof CustomPayloadSchema>;
export type CustomPayloadInput = z.input<typeof CustomPayloadSchema>;

export const CustomEventSchema = z.object({
  kind: z.literal("Custom"),
  payload: CustomPayloadSchema,
});
export type CustomEvent = z.infer<typeof CustomEventSchema>;
export type CustomEventInput = z.input<typeof CustomEventSchema>;

export const EventSchema = z.discriminatedUnion("kind", [
  GateEventSchema,
  MeasurementEventSchema,
  ResetEventSchema,
  CustomEventSchema,
]);
export type Event = z.infer<typeof EventSchema>;
export type EventInput = z.input<typeof EventSchema>;

export const EventRecordSchema = z.object({
  source: SourceSchema,
  event: EventSchema,
});
export type EventRecord = z.infer<typeof EventRecordSchema>;
export type EventRecordInput = z.input<typeof EventRecordSchema>;

export const TraceDataSchema = z.object({
  events: z.array(EventRecordSchema).default([]),
}).strict();
export type TraceData = z.infer<typeof TraceDataSchema>;
export type TraceDataInput = z.input<typeof TraceDataSchema>;

export const TraceSchema = z.object({
  schema_version: SchemaVersionSchema,
  events: z.array(EventRecordSchema).default([]),
}).strict();
export type Trace = z.infer<typeof TraceSchema>;
export type TraceInput = z.input<typeof TraceSchema>;

export const TracesSchema = z.object({
  schema_version: SchemaVersionSchema,
  traces: z.array(TraceDataSchema),
}).strict();
export type Traces = z.infer<typeof TracesSchema>;
export type TracesInput = z.input<typeof TracesSchema>;

export const TraceDocumentSchema = z.union([TraceSchema, TracesSchema]);
export type TraceDocument = z.infer<typeof TraceDocumentSchema>;
export type TraceDocumentInput = z.input<typeof TraceDocumentSchema>;

const LegacyOpaquePayloadSchema = OpaquePayloadSchema.extend({
  // Normalize either legacy alphabet before validating as base64url.
  data: z.string()
    .transform((value) => value.replace(/\+/g, "-").replace(/\//g, "_"))
    .pipe(Base64UrlSchema),
  tag: z.union([
    z.number().int().nonnegative().safe().transform((value) => BigInt(value)),
    z.bigint().min(0n).max(UINT64_MAX),
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
export const LegacyTraceSchema = z.object({
  events: z.array(LegacyEventRecordSchema).default([]),
}).passthrough().refine((value) => !("schema_version" in value), {
  message: "Legacy trace documents must not contain schema_version",
}).refine((value) => !("traces" in value), {
  message: "Versionless trace collections are not supported",
});
export type LegacyTrace = z.infer<typeof LegacyTraceSchema>;

/** Create a trace document with the protocol version set correctly. */
export function createTrace(events: EventRecordInput[] = []): Trace {
  return TraceSchema.parse({ schema_version: SCHEMA_VERSION, events });
}

/** Create the unversioned contents of one emulation trace. */
export function createTraceData(events: EventRecordInput[] = []): TraceData {
  return TraceDataSchema.parse({ events });
}

/** Create a trace collection with the protocol version set correctly. */
export function createTraces(traces: TraceDataInput[]): Traces {
  return TracesSchema.parse({ schema_version: SCHEMA_VERSION, traces });
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

/** Parse a JSON-compatible current or versionless legacy trace value. */
export function parseTrace(value: unknown): Trace {
  if (isObject(value) && !("schema_version" in value)) {
    return upgradeLegacyTrace(value);
  }
  return TraceSchema.parse(value);
}

/** Parse either current trace-document shape, or a versionless legacy trace. */
export function parseTraceDocument(value: unknown): TraceDocument {
  if (isObject(value) && !("schema_version" in value)) {
    return upgradeLegacyTrace(value);
  }
  return TraceDocumentSchema.parse(value);
}

function normalizeLosslessJson(value: unknown, legacy: boolean): unknown {
  if (isLosslessNumber(value)) {
    const converted = value.valueOf();
    if (typeof converted === "bigint") {
      return Number(converted);
    }
    return converted;
  }

  if (Array.isArray(value)) {
    return value.map((item) => normalizeLosslessJson(item, legacy));
  }

  if (!isObject(value)) {
    return value;
  }

  const normalized: Record<string, unknown> = {};
  for (const [key, child] of Object.entries(value)) {
    if (
      legacy &&
      value.kind === "OpaquePayload" &&
      key === "tag" &&
      isLosslessNumber(child)
    ) {
      const decimal = child.toString();
      if (!/^(0|[1-9][0-9]*)$/.test(decimal)) {
        throw new RangeError("legacy OpaquePayload.tag must be an unsigned JSON integer");
      }
      const tag = BigInt(decimal);
      if (tag > UINT64_MAX) {
        throw new RangeError("legacy OpaquePayload.tag exceeds the uint64 range");
      }
      normalized[key] = tag;
    } else {
      normalized[key] = normalizeLosslessJson(child, legacy);
    }
  }
  return normalized;
}

/** Parse trace JSON while preserving a legacy numeric opaque-payload tag. */
export function parseTraceJson(json: string): Trace {
  const parsed = parseLosslessJson(json);
  const legacy = isObject(parsed) && !("schema_version" in parsed);
  return parseTrace(normalizeLosslessJson(parsed, legacy));
}

/** Parse trace-document JSON while preserving a legacy numeric opaque tag. */
export function parseTraceDocumentJson(json: string): TraceDocument {
  const parsed = parseLosslessJson(json);
  const legacy = isObject(parsed) && !("schema_version" in parsed);
  return parseTraceDocument(normalizeLosslessJson(parsed, legacy));
}

/** Validate a JSON-compatible value as a Selene trace without throwing. */
export function safeParseTrace(value: unknown): z.SafeParseReturnType<unknown, Trace> {
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
): z.SafeParseReturnType<unknown, TraceDocument> {
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
    return { ...payload, tag: payload.tag.toString() };
  }

  return payload;
}

function serializeEvent(event: Event): EventInput {
  switch (event.kind) {
    case "Gate":
      return event;
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
  return {
    events: trace.events.map(({ source, event }) => ({
      source: serializeSource(source),
      event: serializeEvent(event),
    })),
  };
}

/** Convert a parsed trace to its JSON-compatible representation. */
export function serializeTrace(trace: Trace): TraceInput {
  return {
    schema_version: trace.schema_version,
    ...serializeTraceData(trace),
  };
}

/** Convert a parsed trace collection to its JSON-compatible representation. */
export function serializeTraces(traces: Traces): TracesInput {
  return {
    schema_version: traces.schema_version,
    traces: traces.traces.map(serializeTraceData),
  };
}

/** Convert either parsed trace-document shape to a JSON-compatible value. */
export function serializeTraceDocument(document: TraceDocument): TraceDocumentInput {
  return "traces" in document ? serializeTraces(document) : serializeTrace(document);
}
