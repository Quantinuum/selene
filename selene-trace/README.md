# Selene Trace

`selene-trace` contains the schemas, documentation, examples, and language
models for Selene's public serialized traces. It has no dependency on the
emulator.

## APIs

| API | Version | Schema | Semantics |
| --- | --- | --- | --- |
| Trace documents (`Trace` and `Traces`) | 0.1.0 | [`schemas/trace/0.1.0.schema.json`](schemas/trace/0.1.0.schema.json) | [`docs/trace/0.1.0.md`](docs/trace/0.1.0.md) |
| Trace (legacy input) | versionless | [`schemas/trace/legacy.schema.json`](schemas/trace/legacy.schema.json) | [`docs/trace/legacy.md`](docs/trace/legacy.md) |

Schemas are also published at their canonical `$id` URLs:

* [Trace documents 0.1.0](https://quantinuum.github.io/selene/schemas/trace/0.1.0.schema.json)
* [Trace (legacy input)](https://quantinuum.github.io/selene/schemas/trace/legacy.schema.json)

Protocol-wide versioning is described in [`docs/versioning.md`](docs/versioning.md).

## Bindings

* Python: [`python/`](python) publishes the `selene-api-models` distribution and is
  imported as `selene_api_models`.
* Rust: [`rust/`](rust) publishes the `selene-api-models` crate.
* TypeScript: [`typescript/`](typescript) publishes the `@quantinuum/selene-api-models`
  package.

The binding release process is described in [`docs/publishing.md`](docs/publishing.md).

## Trace streams

`trace_stream` in the Python and Rust APIs implements gzipped MessagePack trace
streams. This is separate from the complete JSON `Trace` document format, in that
it is designed to be read and written in a sequential manner.

After gzip decompression, the stream consists of consecutive MessagePack objects:

1. A map with `format: "selene.trace.msgpack"`, `format_version: 1`, and
   `schema_version: "0.1.0"`.
2. Zero or more record maps.
3. A single MessagePack nil (`0xc0`) marking successful completion.

Nothing may follow the end marker in the decompressed stream. Readers
reject missing markers, incomplete records, unsupported headers and bad gzip
trailers. Exhaust the iterator to check the whole stream; an error cannot retract
events already yielded.

Event records have the existing `source` and `event` fields. Custom payload tags
use native uint64 values and payload data uses MessagePack binary values, instead
of hex strings or base64 as used in the JSON format.

An event may also contain `instruction: "FutureRead"` or
`instruction: "MeasureLeakedRequest"`. Batch boundaries are separate maps of the
form `{"batch_start": {"start_time": 0, "end_time": 0}}`. These are instruction
metadata, not additional trace events. Event-only readers omit boundaries and
annotations, so materialising a trace doesn't add gates or change snapshots.

Barriers and classical delays use records with `source`, `uint_instruction`,
`value` and `qubits` fields. `uint_instruction` is `GlobalBarrier`, `LocalBarrier`
or `ClassicalDelay`, and `value` is a native uint64. Instruction readers preserve
the full range. Public-event readers and `get_trace()` reject operands above
`2^53 - 1` with an explicit error because the JSON schema cannot represent them.
Smaller operands convert to the same gate events as before.

Native opaque payload encoding belongs to the stream writer's wrappers. Using
serde directly on the public Rust models keeps their ordinary representation,
including hexadecimal tag strings and base64 data, even with a binary serializer.

Rust's `TraceStreamWriter` buffers records between caller-selected checkpoints.
Call `finish()` and check its result before publishing the destination. A failed
append poisons the writer; it cannot subsequently produce a completed stream.
`TraceStreamRecordReader` returns records with metadata, while `TraceStreamReader`
returns public events. The Rust reader adapts native payload fields in memory
before applying the existing model validation; it does not encode or parse JSON
text. The Python reader uses `TypeAdapter.validate_python` directly.

Python's `write_trace_stream` accepts an iterable and creates a new file without
overwriting one. `iter_trace_stream_records` and `iter_trace_stream` read lazily
without caching. Writers use gzip's fast compression setting. Callers own file
lifetime and removal of failed output; readers never copy or delete artifacts.
The conventional suffix is `.msgpack.gz`.
