# Traces

Traces record the operations observed during an emulation shot, from user
requests through runtime scheduling, error modeling, and simulator calls. Each
record contains a `source` and an `event`. Selene generates schema 0.2.0 traces;
the language bindings also read schema 0.1.0 and versionless legacy traces.

## Documents and sources

A `Trace` contains an ordered `events` array. A `Traces` collection contains a
`traces` array of objects with an `events` field. Both top-level documents carry
`schema_version`; collection members inherit it. Attach that version when
extracting a member as a standalone trace. Collections may be empty.

| Source | Fields |
| --- | --- |
| `UserProgram` | `index`: zero-based event index within this source |
| `Runtime` | `start_time`, `end_time`: nanoseconds in the runtime's shot timeline |
| `ErrorModel` | `index`: zero-based event index within this source |
| `Simulator` | `index`: zero-based event index; `duration_ns`: wall-clock time spent in the call |

Events retain observation order. Indices are local to each source; sources need
not have equal event counts. Indices, qubit IDs, result IDs, timestamps, and
durations are non-negative integers no larger than `9007199254740991`.

Gate `params` are booleans or numbers interpreted according to `gate_name`.
Numbers must be finite. Integer-valued numbers in gate parameters and
`KeyValuePairPayload` values, including arrays, must lie between
`-9007199254740991` and `9007199254740991`, inclusive. This includes floating-point
notation such as `1e20`, which is outside the bounds. Fractional numbers are
supported. `KeyValuePairPayload` contains structured custom metadata.

In versioned JSON, `OpaquePayload.tag` is a full-range uint64 encoded as a
canonical hexadecimal string: lowercase `0x`, uppercase hexadecimal digits, and
no leading zeroes except in `"0x0"`. Its maximum is `"0xFFFFFFFFFFFFFFFF"`.
`OpaquePayload.data` uses base64url with optional padding; unused bits in the
final Base64 character must be zero.

For binary transport, see [trace streams](../README.md#trace-streams). For
binding support, see [package compatibility](versioning.md).

## Reading and writing

Parsing helpers normalize legacy and 0.1.0 input to the current model; direct
construction and deserialization require 0.2.0. Missing measurement identity or
type information cannot be reconstructed. Stream readers accept 0.1.0 and
0.2.0 headers; writers use schema 0.2.0 and transport format version 1.

## Version 0.2.0

Schema: [0.2.0.schema.json](../schemas/trace/0.2.0.schema.json).

Adds measurement types, result identities, and future read/result events to 0.1.0.

### Measurements and future results

`Measurement` gains `measurement_type` and `result_id`:

```json
{"kind": "Measurement", "qubit": 0, "measurement_type": "Leaked", "result_id": 42}
```

`measurement_type` is a nonempty string defined by Selene, defaulting to
`Standard`. `Leaked` means the measurement checks for leakage, not that leakage
occurred. Bindings preserve unfamiliar names. For measurement results,
`Standard` uses integer `0` or `1`; `Leaked` also permits integer `2` for leakage.

`result_id` identifies a runtime future within one shot, not a qubit. Match
runtime measurements and results within that scope; IDs from simulator
operations do not necessarily identify runtime futures. Generated measurements
include an ID. Imported measurements may omit it or use null, preventing result
correlation. Defaulting an imported measurement's type to `Standard` does not
establish whether the original operation checked for leakage.

The new `FutureRead` event records each user read attempt; `FutureResult` records
each successful response, including repeated and eager reads:

```json
{"source": {"kind": "UserProgram", "index": 7}, "event": {"kind": "FutureRead", "result_id": 42}}
{"source": {"kind": "Runtime", "start_time": 120, "end_time": 120}, "event": {"kind": "FutureResult", "result_id": 42, "outcome": 2}}
```

These events apply to any runtime future, which need not have a corresponding
measurement or qubit. Failed reads have no result event; unread futures have
neither event. If a read forces pending operations to execute, those operations
appear between the read and its result. Reading a future adds no measurement to
an extracted quantum circuit.

`FutureResult` requires `result_id` and `outcome`, including when the outcome is
null. `FutureResultValue` accepts strings, finite numbers, booleans, null,
arrays, and objects with string keys, recursively. Integer-valued numbers at
every depth use the bounds above. Selene encodes unsigned runtime results above
`9007199254740991` as decimal strings. The originating operation defines the
value's meaning; structured outcomes can carry values such as
`{"parity": true, "confidence": 0.875}`.

A result has Runtime source and equal start and end times. Its timestamp is the
greatest end time of runtime batches processed so far in the shot, or zero if
none have been processed. It excludes classical processing and delivery latency.
Repeated reads may share a timestamp; observation order resolves ties.

Schema and binding validation check structure and numeric bounds, not whether
an outcome matches its measurement type or has a corresponding measurement.
Traces may be filtered or split across files. Semantic validation can correlate
runtime IDs within a shot and check outcomes against the originating operation.
Additional measurement types and result shapes within this contract do not
require a new schema version.

## Version 0.1.0

Schema: [0.1.0.schema.json](../schemas/trace/0.1.0.schema.json).

Changes from the versionless legacy format:

- Requires the top-level `schema_version` field and every `kind` discriminator.
- Adds the `Traces` collection document alongside singular `Trace` documents.
- Encodes `OpaquePayload.tag` as a canonical hexadecimal string instead of a
  JSON integer.
- Restricts `OpaquePayload.data` to base64url rather than accepting both Base64
  alphabets.

## Legacy (versionless)

Schema: [legacy.schema.json](../schemas/trace/legacy.schema.json).

A missing `schema_version` identifies a legacy singular trace. There is no
legacy collection format. Measurements contain only `kind` and `qubit`, and
there are no future-read or future-result events.

Legacy JSON encodes opaque tags as unsigned integers and accepts either the
standard or URL-safe Base64 alphabet for payload data, with optional padding
and zero unused bits. Other integer-valued fields retain the safe bounds above;
traces outside those bounds cannot be upgraded by the adapters.

TypeScript users must pass original JSON text to `parseTraceJson` to preserve
tags above the safe-integer limit. Parsing them with `JSON.parse` first loses
precision.

Legacy output is available explicitly through compatibility serializers and
`selene_core.trace.Trace`. It omits `schema_version` and uses numeric opaque
tags. Serialization rejects traces containing `FutureRead` or `FutureResult`;
use versioned output for those traces.
