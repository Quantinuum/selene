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
        source: { kind: "UserProgram", index: 0 },
        event: {
          kind: "Custom",
          payload: { kind: "OpaquePayload", tag: 1, data: "not+base64url" },
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
