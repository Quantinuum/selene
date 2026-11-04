import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

import { trace } from "../dist/index.js";

function opaqueRecord(tag, data = "Zg==") {
  return {
    source: { kind: "UserProgram", index: 0 },
    event: { kind: "Custom", payload: { kind: "OpaquePayload", tag, data } },
  };
}

test("custom event filters preserve other events and the original", () => {
  const document = trace.createTrace([
    { source: { kind: "UserProgram", index: 0 }, event: { kind: "Gate", gate_name: "H", qubits: [0] } },
    opaqueRecord(1n),
    { source: { kind: "UserProgram", index: 2 }, event: { kind: "FutureRead", result_id: 42 } },
    { source: { kind: "UserProgram", index: 3 }, event: { kind: "Custom", payload: { kind: "KeyValuePairPayload", data: { name: "test" } } } },
    { source: { kind: "Runtime", start_time: 5, end_time: 5 }, event: { kind: "FutureResult", result_id: 42, outcome: 1 } },
  ]);
  const original = structuredClone(document);
  assert.deepEqual(trace.stripCustomEvents(document), {
    schema_version: document.schema_version,
    events: [0, 2, 4].map(i => document.events[i]),
  });
  assert.deepEqual(trace.stripOpaqueCustomEvents(document), {
    schema_version: document.schema_version,
    events: [0, 2, 3, 4].map(i => document.events[i]),
  });
  assert.deepEqual(document, original);
});

test("serializers reject invalid mutations to future outcomes", () => {
  const cyclic = {}; cyclic.self = cyclic;
  const serializers = [
    trace.serializeTrace,
    trace.serializeTraceData,
    trace.serializeTraceDocument,
    (document) => trace.serializeTraces({ schema_version: trace.SCHEMA_VERSION, traces: [{ events: document.events }] }),
    (document) => trace.serializeTraceDocument({ schema_version: trace.SCHEMA_VERSION, traces: [{ events: document.events }] }),
  ];
  for (const outcome of [NaN, Infinity, 2 ** 53, -(2 ** 53), undefined, cyclic]) {
    const document = trace.createTrace([{
      source: { kind: "Runtime", start_time: 0, end_time: 0 },
      event: { kind: "FutureResult", result_id: 42, outcome: { value: 1 } },
    }]);
    document.events[0].event.outcome.value = outcome;
    for (const serialize of serializers) assert.throws(() => serialize(document));
  }
});

test("serializers revalidate event fields and document versions", () => {
  for (const mutate of [
    (document) => { document.events[0].source.index = -1; },
    (document) => { document.events[0].event.payload.tag = trace.UINT64_MAX + 1n; },
  ]) {
    const document = trace.createTrace([opaqueRecord(42n)]);
    mutate(document);
    assert.throws(() => trace.serializeTrace(document));
  }
  const document = trace.createTrace();
  document.schema_version = "0.1.0";
  assert.throws(() => trace.serializeTrace(document));
  assert.throws(() => trace.serializeTraces({ schema_version: "0.1.0", traces: [] }));
});

test("serializers use validated outcome copies without hidden toJSON methods", () => {
  const serializers = [
    trace.serializeTrace,
    (document) => ({ schema_version: document.schema_version, ...trace.serializeTraceData(document) }),
    trace.serializeTraceDocument,
    (document) => trace.serializeTraces({ schema_version: document.schema_version, traces: [{ events: document.events }] }),
    (document) => trace.serializeTraceDocument({ schema_version: document.schema_version, traces: [{ events: document.events }] }),
  ];
  for (const target of ["root", "object", "array"]) {
    const document = trace.createTrace([
      opaqueRecord(trace.UINT64_MAX),
      { source: { kind: "Runtime", start_time: 0, end_time: 0 },
        event: { kind: "FutureResult", result_id: 42, outcome: { object: { value: 1 }, array: [1] } } },
    ]);
    const expected = JSON.parse(JSON.stringify(trace.serializeTrace(document)));
    const outcome = document.events[1].event.outcome;
    const original = target === "root" ? outcome : outcome[target];
    let calls = 0;
    const toJSON = () => { calls++; return { value: 2 ** 53 }; };
    Object.defineProperty(original, "toJSON", { value: toJSON });
    for (const serialize of serializers) {
      const serialized = serialize(document);
      const json = JSON.stringify(serialized);
      assert.deepEqual(JSON.parse(json), "traces" in serialized
        ? { schema_version: expected.schema_version, traces: [{ events: expected.events }] }
        : expected);
      assert.deepEqual(trace.parseTraceDocumentJson(json), "traces" in serialized
        ? { schema_version: document.schema_version, traces: [{ events: document.events }] }
        : document);
    }
    assert.equal(calls, 0);
    assert.equal(original.toJSON, toJSON);
  }
});

test("constructors compose wire inputs and normalized opaque events", () => {
  for (const tag of [0n, 0x11A12517n, trace.UINT64_MAX]) {
    const wire = opaqueRecord(`0x${tag.toString(16).toUpperCase()}`);
    const data = trace.createTraceData([wire]);
    assert.equal(data.events[0].event.payload.tag, tag);
    assert.deepEqual(trace.createTraceData(data.events), data);
    assert.deepEqual(trace.createTrace(data.events).events, data.events);
    const collection = trace.createTraces([data, { events: [wire] }, {}]);
    assert.deepEqual(collection.traces, [data, data, { events: [] }]);
    assert.deepEqual(trace.parseTraceDocument(trace.serializeTraces(collection)), collection);
    assert.equal(trace.safeParseTrace(trace.createTrace(data.events)).success, false);
    assert.equal(trace.safeParseTraceDocument(collection).success, false);
  }
  const mixed = [opaqueRecord("0x1"), opaqueRecord(2n)];
  assert.deepEqual(trace.createTrace(mixed).events, trace.createTraceData(mixed).events);
  assert.deepEqual(trace.createTraces([{ events: mixed }]).traces[0], trace.createTraceData(mixed));
});

test("constructors validate normalized tags and other event fields", () => {
  for (const record of [
    opaqueRecord(-1n), opaqueRecord(trace.UINT64_MAX + 1n),
    opaqueRecord(1n, "Zh=="),
    { ...opaqueRecord(1n), source: { kind: "UserProgram", index: -1 } },
  ]) {
    assert.throws(() => trace.createTrace([record]));
    assert.throws(() => trace.createTraceData([record]));
    assert.throws(() => trace.createTraces([{ events: [record] }]));
  }
  assert.throws(() => trace.createTraces([{ events: [], schema_version: "0.2.0" }]));
  assert.throws(() => trace.createTraces([{ events: null }]));
});

test("invalid tag strings return safe parse failures without throwing", () => {
  for (const tag of ["abc", "0x", "0xG", "0x10000000000000000"]) {
    const document = { schema_version: trace.SCHEMA_VERSION, events: [opaqueRecord(tag)] };
    assert.equal(trace.safeParseTrace(document).success, false);
    assert.equal(trace.safeParseTraceDocument(document).success, false);
  }
});

test("Base64 schemas and parsers require zero pad bits with optional padding", () => {
  for (const legacy of [false, true]) {
    const schema = JSON.parse(readFileSync(
      new URL(`../../schemas/trace/${legacy ? "legacy" : "0.2.0"}.schema.json`, import.meta.url), "utf8",
    ));
    const pattern = new RegExp(schema.$defs.OpaquePayload.properties.data.pattern);
    for (const [data, valid] of [
      ["", true], ["YWJj", true], ["Zg", true], ["Zg==", true],
      ["Zm8", true], ["Zm8=", true], ["-_8", true], ["-_8=", true],
      ["Zh", false], ["Zh==", false], ["Zm9", false], ["Zm9=", false],
      ["-_9", false], ["-_9=", false], ["Zg=", false], ["Zg===", false],
      ["Zm8==", false], ["Zg==\n", false],
      ["+/8=", legacy], ["+/9", false], ["+/9=", false],
    ]) {
      const document = { events: [opaqueRecord(legacy ? 1 : "0x1", data)] };
      if (!legacy) document.schema_version = trace.SCHEMA_VERSION;
      assert.equal(pattern.test(data), valid, data);
      assert.equal(trace.safeParseTrace(document).success, valid, data);
    }
  }
});

test("gate parameters and key-value numbers enforce signed safe integer bounds", () => {
  for (const [value, valid] of [
    [Number.MAX_SAFE_INTEGER, true], [-Number.MAX_SAFE_INTEGER, true],
    [Number.MAX_SAFE_INTEGER + 1, false], [-Number.MAX_SAFE_INTEGER - 1, false],
    [1e20, false], [-1e20, false], [0, true], [0.5, true], [-1.5, true],
    [true, true], [Infinity, false], [NaN, false],
  ]) {
    const source = { kind: "UserProgram", index: 0 };
    assert.equal(trace.safeParseTrace({ events: [{
      source, event: { kind: "Gate", gate_name: "Rz", params: [value] },
    }] }).success, valid);
    for (const data of [{ value }, { value: [value] }]) {
      assert.equal(trace.safeParseTrace({ events: [{
        source, event: { kind: "Custom", payload: { kind: "KeyValuePairPayload", data } },
      }] }).success, valid);
    }
  }
  assert.equal(trace.safeParseTrace({ events: [{
    source: { kind: "UserProgram", index: 0 },
    event: { kind: "Custom", payload: {
      kind: "KeyValuePairPayload", data: { value: "large integers as text" },
    } },
  }] }).success, true);
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
  for (const exampleName of ["minimal.json", "all-event-types.json", "measurement-results.json"]) {
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
          payload: { kind: "OpaquePayload", tag: "0x1", data: "not+base64url" },
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
  for (const source of [
    { kind: "UserProgram", index: -1 },
    { kind: "Runtime", start_time: -1, end_time: 0 },
    { kind: "Runtime", start_time: 0, end_time: -1 },
    { kind: "ErrorModel", index: -1 },
    { kind: "Simulator", index: -1, duration_ns: 0 },
    { kind: "Simulator", index: 0, duration_ns: -1 },
  ]) {
    assert.equal(trace.safeParseTrace({ events: [{
      source, event: { kind: "Gate", gate_name: "H" },
    }] }).success, false);
  }
  for (const event of [
    { kind: "Gate", gate_name: "H", qubits: [-1] },
    { kind: "Measurement", qubit: -1 },
    { kind: "Reset", qubit: -1 },
    opaqueRecord("-1", "dHJhY2U=").event,
  ]) {
    assert.equal(trace.safeParseTrace({ events: [{
      source: { kind: "UserProgram", index: 0 }, event,
    }] }).success, false);
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
            tag: "0xA13613EADE130746",
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
      trace.safeParseTrace({ events: [{
        source: { kind: "UserProgram", index: value },
        event: { kind: "Gate", gate_name: "H" },
      }] }).success,
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
        event: { kind: "Measurement", qubit: 1, measurement_type: "Standard", result_id: null },
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
    "0xA13613EADE130746",
  );
});

for (const parser of [trace.parseTraceJson, trace.parseTraceDocumentJson]) {
  for (const tag of [42, -1]) {
    test(`${parser.name} preserves opaque-looking key-value metadata with tag ${tag}`, () => {
      const data = { kind: "OpaquePayload", tag };
      const input = {
        events: [{
          source: { kind: "UserProgram", index: 0 },
          event: {
            kind: "Custom",
            payload: { kind: "KeyValuePairPayload", data },
          },
        }],
      };
      const parsed = parser(JSON.stringify(input));
      assert.deepEqual(parsed, trace.parseTrace(input));
      assert.deepEqual(parsed.events[0].event.payload.data, data);
    });
  }

  test(`${parser.name} preserves the maximum legacy opaque tag`, () => {
    const json = '{"events":[{"source":{"kind":"UserProgram","index":0},"event":{"kind":"Custom","payload":{"kind":"OpaquePayload","tag":18446744073709551615,"data":""}}}]}';
    assert.equal(parser(json).events[0].event.payload.tag, trace.UINT64_MAX);
  });
}

test("the JSON Schema uint64 pattern enforces the bound in JavaScript", () => {
  const schema = JSON.parse(readFileSync(
    new URL("../../schemas/trace/0.2.0.schema.json", import.meta.url), "utf8",
  ));
  const pattern = new RegExp(schema.$defs.OpaquePayload.properties.tag.pattern);
  for (const [tag, valid] of [
    ["0x0", true], ["0x1", true], ["0x11A12517", true], ["0xFFFFFFFFFFFFFFFF", true],
    ["0x10000000000000000", false], ["1", false], ["0x01", false],
    ["0xabcdef", false], ["0X1", false], ["0x", false], ["0xG", false],
    ["-1", false], ["0x1\n", false], [" 0x1", false],
  ]) {
    assert.equal(pattern.test(tag), valid, tag);
    assert.equal(trace.safeParseTrace({ schema_version: trace.SCHEMA_VERSION, events: [opaqueRecord(tag)] }).success, valid, tag);
  }
});

test("opaque payload tags require canonical uint64 hexadecimal strings", () => {
  for (const tag of [0, "-1", "1", "0x01", "0xabcdef", "0X1", "0x", "0x1\n", "0x10000000000000000"]) {
    const parsed = trace.safeParseTrace({
      schema_version: trace.SCHEMA_VERSION,
      events: [opaqueRecord(tag, "dHJhY2U=")],
    });

    assert.equal(parsed.success, false);
  }
});


test("the public namespace exposes no Zod schemas", () => {
  assert.deepEqual(Object.keys(trace).filter((name) => name.endsWith("Schema")), []);
});

test("safe parse failures provide standard errors", () => {
  for (const parse of [trace.safeParseTrace, trace.safeParseTraceDocument]) {
    const result = parse({ schema_version: "unsupported" });
    assert.equal(result.success, false);
    assert.ok(result.error instanceof Error);
    assert.ok(result.error.message.length > 0);
  }
});


test("measurement results validate and round trip", () => {
  for (const [outcome, valid] of [
    [0, true], [1, true], [2, true], [3, true], [-1, true], [true, true],
  ]) {
    const event = { kind: "FutureResult", result_id: 42, outcome };
    const document = { schema_version: trace.SCHEMA_VERSION, events: [{
      source: { kind: "Runtime", start_time: 5, end_time: 5 }, event,
    }] };
    const parsed = trace.safeParseTrace(document);
    assert.equal(parsed.success, valid);
    if (valid) {
      assert.deepEqual(trace.serializeTrace(parsed.data), document);
    }
  }
});

test("previous schema measurements have unknown result IDs", () => {
  const document = { schema_version: "0.1.0", events: [{
    source: { kind: "Runtime", start_time: 0, end_time: 1 },
    event: { kind: "Measurement", qubit: 3 },
  }] };
  const parsed = trace.parseTrace(document);
  assert.equal(parsed.schema_version, trace.SCHEMA_VERSION);
  assert.equal(parsed.events[0].event.result_id, null);
  assert.equal(document.schema_version, "0.1.0");
});

test("FutureResult requires the current schema", () => {
  for (const version of [undefined, "0.1.0"]) {
    const document = { events: [{
      source: { kind: "Runtime", start_time: 0, end_time: 0 },
      event: { kind: "FutureResult", result_id: 42, outcome: 0 },
    }] };
    if (version !== undefined) document.schema_version = version;
    assert.equal(trace.safeParseTrace(document).success, false);
  }
});


test("FutureRead preserves result identity and requires the current schema", () => {
  const record = { source: { kind: "UserProgram", index: 0 }, event: { kind: "FutureRead", result_id: 42 } };
  const document = { schema_version: trace.SCHEMA_VERSION, events: [record] };
  const parsed = trace.parseTrace(document);
  assert.deepEqual(trace.serializeTrace(parsed), document);
  assert.equal(trace.safeParseTrace({ ...document, schema_version: "0.1.0" }).success, false);
  assert.equal(trace.safeParseTrace({ events: [record] }).success, false);
  for (const result_id of [-1, true, 0.5, Number.MAX_SAFE_INTEGER + 1]) {
    assert.equal(trace.safeParseTrace({ ...document, events: [{ ...record, event: { kind: "FutureRead", result_id } }] }).success, false);
  }
});


test("extension measurement types and JSON outcomes survive round trips", () => {
  for (const outcome of [null, true, -3, 0.25, "text", "0", [1, null, { value: false }],
    { kind: "OpaquePayload", tag: "arbitrary", data: "literal" },
    { kind: 1, tag: 42, data: [true, null] },
    { nested: { kind: 1, tag: 42, data: [true, null] } },
    JSON.parse('{"__proto__":{"x":1},"constructor":true}'),
    JSON.parse('{"__proto__":false,"__selene_proto__":1}'),
    { isLosslessNumber: true, count: 1 },
    { isLosslessNumber: true, valueOf: 1 },
    JSON.parse('{"isLosslessNumber":true,"__proto__":true}'),
  ]) {
    const events = [
      { source: { kind: "Runtime", start_time: 0, end_time: 1 }, event: { kind: "Measurement", qubit: 3, result_id: 42, measurement_type: "com.example/Custom" } },
      { source: { kind: "Runtime", start_time: 1, end_time: 1 }, event: { kind: "FutureResult", result_id: 42, outcome } },
    ];
    const document = { schema_version: trace.SCHEMA_VERSION, events };
    const parsed = trace.parseTrace(document);
    assert.deepEqual(trace.serializeTrace(parsed), document);
    assert.deepEqual(trace.serializeTrace(trace.parseTraceJson(JSON.stringify(document))), document);
  }
  for (const measurement_type of ["", null, 1, true]) {
    assert.throws(() => trace.createTrace([{ source: { kind: "UserProgram", index: 0 }, event: { kind: "Measurement", qubit: 3, measurement_type } }]));
  }
  for (const outcome of [NaN, Infinity, -Infinity, 2n, undefined, { value: [Number.MAX_SAFE_INTEGER + 1] }, { value: [-Number.MAX_SAFE_INTEGER - 1] }, new Date()]) {
    assert.throws(() => trace.createTrace([{ source: { kind: "Runtime", start_time: 0, end_time: 1 }, event: { kind: "FutureResult", result_id: 42, outcome } }]));
  }
  assert.throws(() => trace.createTrace([{ source: { kind: "Runtime", start_time: 0, end_time: 1 }, event: { kind: "FutureResult", result_id: 42 } }]));
});


test("JSON outcomes reject cycles and sparse arrays", () => {
  const cyclic = {}; cyclic.self = cyclic;
  for (const outcome of [cyclic, new Array(2)]) {
    assert.equal(trace.safeParseTrace({ schema_version: trace.SCHEMA_VERSION, events: [{
      source: { kind: "Runtime", start_time: 0, end_time: 1 },
      event: { kind: "FutureResult", result_id: 42, outcome },
    }] }).success, false);
  }
  const json = '{"schema_version":"0.2.0","events":[{"source":{"kind":"Runtime","start_time":0,"end_time":1},"event":{"kind":"FutureResult","result_id":42,"outcome":{"__pr\\u006fto__":true}}}]}';
  assert.deepEqual(trace.parseTraceJson(json).events[0].event.outcome, JSON.parse('{"__proto__":true}'));
});


test("FutureResultValue preserves string values at every depth", () => {
  for (const outcome of ["0", "text", ["text"], { value: "text" }, { value: [1, { nested: "text" }] }]) {
    const document = { schema_version: trace.SCHEMA_VERSION, events: [{
      source: { kind: "Runtime", start_time: 0, end_time: 0 },
      event: { kind: "FutureResult", result_id: 42, outcome },
    }] };
    const parsed = trace.parseTrace(document);
    assert.deepEqual(trace.serializeTrace(parsed), document);
    assert.deepEqual(trace.serializeTrace(trace.parseTraceJson(JSON.stringify(document))), document);
  }
});


test("non-measurement future reads and results round trip", () => {
  const records = [
    { source: { kind: "UserProgram", index: 0 }, event: { kind: "FutureRead", result_id: 123 } },
    { source: { kind: "Runtime", start_time: 0, end_time: 0 }, event: { kind: "FutureResult", result_id: 123, outcome: { ready: true, values: [7, null, 0.5] } } },
  ];
  const document = trace.createTrace(records);
  assert.deepEqual(trace.serializeTrace(document).events, records);
  assert.deepEqual(trace.parseTraceJson(JSON.stringify(trace.serializeTrace(document))), document);
});
