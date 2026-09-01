import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

import { trace } from "../dist/index.js";

test("createTrace emits the current protocol version", () => {
  assert.deepEqual(trace.createTrace(), {
    schema_version: trace.SCHEMA_VERSION,
    events: [],
  });
});

test("shared protocol examples identify the current protocol version", () => {
  for (const exampleName of ["minimal.json", "all-event-types.json"]) {
    const exampleUrl = new URL(
      `../../examples/trace/${exampleName}`,
      import.meta.url,
    );
    const exampleTrace = JSON.parse(readFileSync(exampleUrl, "utf8"));

    const parsed = trace.parseTrace(exampleTrace);
    assert.equal(parsed.schema_version, trace.SCHEMA_VERSION, exampleName);
    assert.ok(Array.isArray(parsed.events), `${exampleName} must contain events`);
    assert.deepEqual(trace.serializeTrace(parsed), exampleTrace, exampleName);
  }
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
        source: { kind: "UserProgram", index: "0" },
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
        source: { kind: "UserProgram", index: "0" },
        event: { kind: "Gate", gate_name: "H" },
      },
    ],
  });

  assert.deepEqual(parsed.events[0], {
    source: { kind: "UserProgram", index: 0n },
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
    [trace.UserProgramSourceSchema, { kind: "UserProgram", index: "-1" }],
    [trace.RuntimeSourceSchema, { kind: "Runtime", start_time: "-1", end_time: "0" }],
    [trace.RuntimeSourceSchema, { kind: "Runtime", start_time: "0", end_time: "-1" }],
    [trace.ErrorModelSourceSchema, { kind: "ErrorModel", index: "-1" }],
    [trace.SimulatorSourceSchema, { kind: "Simulator", index: "-1", duration_ns: "0" }],
    [trace.SimulatorSourceSchema, { kind: "Simulator", index: "0", duration_ns: "-1" }],
    [trace.GateEventSchema, { kind: "Gate", gate_name: "H", qubits: ["-1"] }],
    [trace.MeasurementEventSchema, { kind: "Measurement", qubit: "-1" }],
    [trace.ResetEventSchema, { kind: "Reset", qubit: "-1" }],
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
        source: { kind: "UserProgram", index: "0" },
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
