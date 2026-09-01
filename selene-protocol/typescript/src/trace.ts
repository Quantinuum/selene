/** TypeScript bindings for version 0.1.0 of the Selene trace protocol. */

import { z } from "zod";

export const SCHEMA_VERSION = "0.1.0" as const;
export const SchemaVersionSchema = z.literal(SCHEMA_VERSION);
export type SchemaVersion = z.infer<typeof SchemaVersionSchema>;

/** The largest value representable by an unsigned 64-bit integer. */
export const UINT64_MAX = (1n << 64n) - 1n;

/** A canonical unsigned 64-bit integer encoded as a decimal string. */
export const UInt64DecimalStringSchema = z
  .string()
  .regex(/^(0|[1-9][0-9]*)$/, "Expected a canonical unsigned decimal string")
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
  index: UInt64Schema,
});
export type UserProgramSource = z.infer<typeof UserProgramSourceSchema>;
export type UserProgramSourceInput = z.input<typeof UserProgramSourceSchema>;

export const RuntimeSourceSchema = z.object({
  kind: z.literal("Runtime"),
  start_time: UInt64Schema,
  end_time: UInt64Schema,
});
export type RuntimeSource = z.infer<typeof RuntimeSourceSchema>;
export type RuntimeSourceInput = z.input<typeof RuntimeSourceSchema>;

export const ErrorModelSourceSchema = z.object({
  kind: z.literal("ErrorModel"),
  index: UInt64Schema,
});
export type ErrorModelSource = z.infer<typeof ErrorModelSourceSchema>;
export type ErrorModelSourceInput = z.input<typeof ErrorModelSourceSchema>;

export const SimulatorSourceSchema = z.object({
  kind: z.literal("Simulator"),
  index: UInt64Schema,
  duration_ns: UInt64Schema,
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

export const GateParameterSchema = z.union([z.number(), z.boolean()]);
export type GateParameter = z.infer<typeof GateParameterSchema>;

export const GateEventSchema = z.object({
  kind: z.literal("Gate"),
  qubits: z.array(UInt64Schema).default([]),
  gate_name: z.string(),
  params: z.array(GateParameterSchema).default([]),
  predicates: z.array(PredicateResultSchema).default([]),
});
export type GateEvent = z.infer<typeof GateEventSchema>;
export type GateEventInput = z.input<typeof GateEventSchema>;

export const MeasurementEventSchema = z.object({
  kind: z.literal("Measurement"),
  qubit: UInt64Schema,
});
export type MeasurementEvent = z.infer<typeof MeasurementEventSchema>;
export type MeasurementEventInput = z.input<typeof MeasurementEventSchema>;

export const ResetEventSchema = z.object({
  kind: z.literal("Reset"),
  qubit: UInt64Schema,
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
  z.number(),
  z.boolean(),
  z.array(z.string()),
  z.array(z.number()),
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

export const TraceSchema = z.object({
  schema_version: SchemaVersionSchema,
  events: z.array(EventRecordSchema).default([]),
});
export type Trace = z.infer<typeof TraceSchema>;
export type TraceInput = z.input<typeof TraceSchema>;

/** Create a trace document with the protocol version set correctly. */
export function createTrace(events: EventRecordInput[] = []): Trace {
  return TraceSchema.parse({ schema_version: SCHEMA_VERSION, events });
}

/** Parse a JSON-compatible trace; opaque-payload tags are decoded to bigint. */
export function parseTrace(value: unknown): Trace {
  return TraceSchema.parse(value);
}

/** Validate a JSON-compatible value as a Selene trace without throwing. */
export function safeParseTrace(value: unknown): z.SafeParseReturnType<unknown, Trace> {
  return TraceSchema.safeParse(value);
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
      return { ...event, qubits: event.qubits.map((qubit) => qubit.toString()) };
    case "Measurement":
    case "Reset":
      return { ...event, qubit: event.qubit.toString() };
    case "Custom":
      return { ...event, payload: serializeCustomPayload(event.payload) };
  }
}

function serializeSource(source: Source): SourceInput {
  switch (source.kind) {
    case "UserProgram":
    case "ErrorModel":
      return { ...source, index: source.index.toString() };
    case "Runtime":
      return {
        ...source,
        start_time: source.start_time.toString(),
        end_time: source.end_time.toString(),
      };
    case "Simulator":
      return {
        ...source,
        index: source.index.toString(),
        duration_ns: source.duration_ns.toString(),
      };
  }
}

/** Convert a parsed trace to its JSON-compatible representation. */
export function serializeTrace(trace: Trace): TraceInput {
  return {
    schema_version: trace.schema_version,
    events: trace.events.map(({ source, event }) => ({
      source: serializeSource(source),
      event: serializeEvent(event),
    })),
  };
}
