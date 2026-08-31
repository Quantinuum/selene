/** TypeScript bindings for version 0.1.0 of the Selene trace protocol. */

import { z } from "zod";

export const SCHEMA_VERSION = "0.1.0" as const;
export const SchemaVersionSchema = z.literal(SCHEMA_VERSION);
export type SchemaVersion = z.infer<typeof SchemaVersionSchema>;

export const PredicateResultSchema = z.object({
  predicate: z.string(),
  result: z.boolean(),
});
export type PredicateResult = z.infer<typeof PredicateResultSchema>;

export const UserProgramSourceSchema = z.object({
  kind: z.literal("UserProgram"),
  index: z.number().int(),
});
export type UserProgramSource = z.infer<typeof UserProgramSourceSchema>;
export type UserProgramSourceInput = z.input<typeof UserProgramSourceSchema>;

export const RuntimeSourceSchema = z.object({
  kind: z.literal("Runtime"),
  start_time: z.number().int(),
  end_time: z.number().int(),
});
export type RuntimeSource = z.infer<typeof RuntimeSourceSchema>;
export type RuntimeSourceInput = z.input<typeof RuntimeSourceSchema>;

export const ErrorModelSourceSchema = z.object({
  kind: z.literal("ErrorModel"),
  index: z.number().int(),
});
export type ErrorModelSource = z.infer<typeof ErrorModelSourceSchema>;
export type ErrorModelSourceInput = z.input<typeof ErrorModelSourceSchema>;

export const SimulatorSourceSchema = z.object({
  kind: z.literal("Simulator"),
  index: z.number().int(),
  duration_ns: z.number().int(),
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
  qubits: z.array(z.number().int()).default([]),
  gate_name: z.string(),
  params: z.array(GateParameterSchema).default([]),
  predicates: z.array(PredicateResultSchema).default([]),
});
export type GateEvent = z.infer<typeof GateEventSchema>;
export type GateEventInput = z.input<typeof GateEventSchema>;

export const MeasurementEventSchema = z.object({
  kind: z.literal("Measurement"),
  qubit: z.number().int(),
});
export type MeasurementEvent = z.infer<typeof MeasurementEventSchema>;
export type MeasurementEventInput = z.input<typeof MeasurementEventSchema>;

export const ResetEventSchema = z.object({
  kind: z.literal("Reset"),
  qubit: z.number().int(),
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
  tag: z.number().int(),
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

/** Parse and validate a JSON-compatible value as a Selene trace. */
export function parseTrace(value: unknown): Trace {
  return TraceSchema.parse(value);
}

/** Validate a JSON-compatible value as a Selene trace without throwing. */
export function safeParseTrace(value: unknown): z.SafeParseReturnType<unknown, Trace> {
  return TraceSchema.safeParse(value);
}
