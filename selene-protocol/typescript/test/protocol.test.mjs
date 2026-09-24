import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

import { trace } from "../dist/index.js";

test("gate parameters and key-value numbers enforce signed safe integer bounds", () => {
  for (const [value, valid] of [
    [Number.MAX_SAFE_INTEGER, true], [-Number.MAX_SAFE_INTEGER, true],
    [Number.MAX_SAFE_INTEGER + 1, false], [-Number.MAX_SAFE_INTEGER - 1, false],
    [1e20, false], [-1e20, false], [0, true], [0.5, true], [-1.5, true],
    [true, true], [Infinity, false], [NaN, false],
  ]) {
    assert.equal(trace.GateParameterSchema.safeParse(value).success, valid);
    assert.equal(trace.KeyValueSchema.safeParse(value).success, valid);
    assert.equal(trace.KeyValueSchema.safeParse([value]).success, valid);
  }
  assert.equal(trace.KeyValueSchema.safeParse("large integers as text").success, true);
});

test("createTrace emits the current protocol version", () => {
  assert.deepEqual(trace.createTrace(), {
    schema_version: trace.SCHEMA_VERSION,
    events: [],
  });
});

test("createTraces versions unversioned trace data once", () => {
  assert.deepEqual(trace.createTraces([trace.createTraceData()]), {
    schema_version: trace.SCHEMA_VERSION,
    traces: [{ events: [] }],
  });
});

test("shared protocol examples identify the current protocol version", () => {
  for (const exampleName of ["minimal.json", "all-event-types.json"]) {
    const exampleUrl = new URL(
      `../../examples/trace/${exampleName}`,
      import.meta.url,
    );
    const exampleJson = readFileSync(exampleUrl, "utf8");
    const exampleTrace = JSON.parse(exampleJson);

    const parsed = trace.parseTrace(exampleTrace);
    const parsedJson = trace.parseTraceJson(exampleJson);
    assert.equal(parsed.schema_version, trace.SCHEMA_VERSION, exampleName);
    assert.ok(Array.isArray(parsed.events), `${exampleName} must contain events`);
    assert.deepEqual(trace.serializeTrace(parsed), exampleTrace, exampleName);
    assert.deepEqual(trace.serializeTrace(parsedJson), exampleTrace, exampleName);
  }
});

test("the shared traces example parses as a collection document", () => {
  const exampleUrl = new URL("../../examples/trace/traces.json", import.meta.url);
  const exampleJson = readFileSync(exampleUrl, "utf8");
  const exampleDocument = JSON.parse(exampleJson);

  const parsed = trace.parseTraceDocument(exampleDocument);
  const parsedJson = trace.parseTraceDocumentJson(exampleJson);
  assert.equal(parsed.schema_version, trace.SCHEMA_VERSION);
  assert.equal(parsed.traces.length, 2);
  assert.deepEqual(trace.serializeTraceDocument(parsed), exampleDocument);
  assert.deepEqual(trace.serializeTraceDocument(parsedJson), exampleDocument);
});

test("trace-document validation distinguishes singular and collection documents", () => {
  const singular = trace.parseTraceDocument({
    schema_version: trace.SCHEMA_VERSION,
    events: [],
  });
  const collection = trace.parseTraceDocument({
    schema_version: trace.SCHEMA_VERSION,
    traces: [],
  });

  assert.ok("events" in singular);
  assert.ok("traces" in collection);
});

test("trace-document validation rejects a versionless collection", () => {
  assert.equal(trace.safeParseTraceDocument({ traces: [] }).success, false);
});

test("validation rejects documents with an unsupported schema version", () => {
  const parsed = trace.safeParseTrace({ schema_version: "1.0.0" });

  assert.equal(parsed.success, false);
});

test("validation rejects malformed base64url data", () => {
  const parsed = trace.safeParseTrace({
    schema_version: trace.SCHEMA_VERSION,
    events: [
      {
        source: { kind: "UserProgram", index: 0 },
        event: {
          kind: "Custom",
          payload: { kind: "OpaquePayload", tag: "1", data: "not+base64url" },
        },
      },
    ],
  });

  assert.equal(parsed.success, false);
});

test("validation supplies defaults for collection fields", () => {
  const parsed = trace.parseTrace({
    schema_version: trace.SCHEMA_VERSION,
    events: [
      {
        source: { kind: "UserProgram", index: 0 },
        event: { kind: "Gate", gate_name: "H" },
      },
    ],
  });

  assert.deepEqual(parsed.events[0], {
    source: { kind: "UserProgram", index: 0 },
    event: {
      kind: "Gate",
      qubits: [],
      gate_name: "H",
      params: [],
      predicates: [],
    },
  });
});

test("validation requires source and event discriminator fields", () => {
  const parsed = trace.safeParseTrace({
    schema_version: trace.SCHEMA_VERSION,
    events: [{ source: { index: 0 }, event: { gate_name: "H" } }],
  });

  assert.equal(parsed.success, false);
});

test("validation rejects negative unsigned trace values", () => {
  for (const [schema, value] of [
    [trace.UserProgramSourceSchema, { kind: "UserProgram", index: -1 }],
    [trace.RuntimeSourceSchema, { kind: "Runtime", start_time: -1, end_time: 0 }],
    [trace.RuntimeSourceSchema, { kind: "Runtime", start_time: 0, end_time: -1 }],
    [trace.ErrorModelSourceSchema, { kind: "ErrorModel", index: -1 }],
    [trace.SimulatorSourceSchema, { kind: "Simulator", index: -1, duration_ns: 0 }],
    [trace.SimulatorSourceSchema, { kind: "Simulator", index: 0, duration_ns: -1 }],
    [trace.GateEventSchema, { kind: "Gate", gate_name: "H", qubits: [-1] }],
    [trace.MeasurementEventSchema, { kind: "Measurement", qubit: -1 }],
    [trace.ResetEventSchema, { kind: "Reset", qubit: -1 }],
    [trace.OpaquePayloadSchema, { kind: "OpaquePayload", tag: "-1", data: "dHJhY2U=" }],
  ]) {
    assert.equal(schema.safeParse(value).success, false);
  }
});

test("opaque payload tags preserve the full uint64 range", () => {
  const input = {
    schema_version: trace.SCHEMA_VERSION,
    events: [
      {
        source: { kind: "UserProgram", index: 0 },
        event: {
          kind: "Custom",
          payload: {
            kind: "OpaquePayload",
            tag: "11616494188317837126",
            data: "dHJhY2U=",
          },
        },
      },
    ],
  };

  const parsed = trace.parseTrace(input);
  assert.equal(parsed.events[0].event.payload.tag, 11616494188317837126n);
  assert.deepEqual(trace.serializeTrace(parsed), input);
  assert.equal(JSON.stringify(trace.serializeTrace(parsed)), JSON.stringify(input));
});

test("safe integer fields reject values outside JavaScript's exact range", () => {
  for (const value of [-1, Number.MAX_SAFE_INTEGER + 1, 1.5]) {
    assert.equal(
      trace.UserProgramSourceSchema.safeParse({ kind: "UserProgram", index: value }).success,
      false,
    );
  }
});

test("versionless legacy traces are upgraded", () => {
  const parsed = trace.parseTrace({
    events: [
      {
        source: { kind: "UserProgram", index: 0 },
        event: { kind: "Measurement", qubit: 1 },
      },
    ],
  });

  assert.deepEqual(parsed, {
    schema_version: trace.SCHEMA_VERSION,
    events: [
      {
        source: { kind: "UserProgram", index: 0 },
        event: { kind: "Measurement", qubit: 1 },
      },
    ],
  });
});

test("legacy opaque payloads normalize both Base64 alphabets to URL-safe output", () => {
  for (const data of ["+/8=", "-_8=", "+w==", "-w=="]) {
    const input = {
      events: [{
        source: { kind: "UserProgram", index: 0 },
        event: {
          kind: "Custom",
          payload: { kind: "OpaquePayload", tag: 1, data },
        },
      }],
    };
    const parsed = trace.parseTraceJson(JSON.stringify(input));
    assert.deepEqual(trace.parseTrace(input), parsed);
    assert.deepEqual(trace.parseTraceDocumentJson(JSON.stringify(input)), parsed);

    const output = trace.serializeTrace(parsed);
    const encoded = output.events[0].event.payload.data;
    assert.equal(encoded, data.length === 4 && data.endsWith("==") ? "-w==" : "-_8=");
    assert.deepEqual(Buffer.from(encoded, "base64url"), Buffer.from(data, "base64"));
    assert.deepEqual(trace.parseTraceJson(JSON.stringify(output)), parsed);

    output.events[0].event.payload.data = "+/8=";
    assert.throws(() => trace.parseTraceJson(JSON.stringify(output)));
  }
});

test("legacy opaque payload normalization still rejects malformed Base64", () => {
  const input = {
    events: [{
      source: { kind: "UserProgram", index: 0 },
      event: {
        kind: "Custom",
        payload: { kind: "OpaquePayload", tag: 1, data: "+/!= " },
      },
    }],
  };
  assert.throws(() => trace.parseTraceJson(JSON.stringify(input)));
});

test("legacy JSON preserves an unsafe numeric opaque-payload tag", () => {
  const legacyUrl = new URL("../../examples/trace/legacy.json", import.meta.url);
  const parsed = trace.parseTraceJson(readFileSync(legacyUrl, "utf8"));

  assert.equal(parsed.schema_version, trace.SCHEMA_VERSION);
  assert.equal(parsed.events[1].event.payload.tag, 11616494188317837126n);
  assert.equal(
    trace.serializeTrace(parsed).events[1].event.payload.tag,
    "11616494188317837126",
  );
});

test("opaque payload tags require canonical uint64 decimal strings", () => {
  for (const tag of [0, "-1", "01", "18446744073709551616"]) {
    const parsed = trace.OpaquePayloadSchema.safeParse({
      kind: "OpaquePayload",
      tag,
      data: "dHJhY2U=",
    });

    assert.equal(parsed.success, false);
  }
});
