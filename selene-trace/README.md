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

## Streaming trace files

The Rust and Python `trace_file` modules own the `.jsonl.gz` transport. It is
separate from the whole-document `Trace` JSON format and reuses its event models.
After gzip decompression, the first line is this header:

```json
{"format":"selene.trace.jsonl","format_version":1,"schema_version":"0.1.0"}
```

Each following line contains an event or optional instruction metadata. All
lines, including the header, end with a newline. An empty trace contains just
the header. The format version describes framing, while the schema version
describes events. Readers reject unsupported headers and versions. The
[uncompressed example](rust/tests/fixtures/events.jsonl) is also used by both
language bindings' tests.

Event lines contain the existing `EventRecord` fields. They can additionally
carry `"instruction":"FutureRead"` or `"instruction":"MeasureLeakedRequest"`
to distinguish measurement instructions for circuit extraction. Batch boundaries
use a separate metadata line such as
`{"batch_start":{"start_time":0,"end_time":0}}`. This also preserves empty
batches and consecutive batches with identical timing. These annotations belong
to the file format, not the public trace schema: event readers omit boundary
lines and strip instruction annotations, leaving the original trace unchanged.

Rust's `TraceWriter` buffers writes and keeps the gzip stream open between
`write_events` calls. Call `finish()` and check its result before publishing the
output. `write_records` also accepts batch boundaries and annotated events.
After an append fails the writer cannot be reused, because part of an
event might already have been written. `TraceReader` validates the header on
construction and yields validated events incrementally, with line context on
errors. `TraceRecordReader` exposes the file records, including metadata.

Python's `write_trace_file` accepts an iterable of events and writes a new gzip
file without collecting the iterable. It does not overwrite existing files.
`iter_trace_file` reads gzip events lazily, or accepts older uncompressed JSON
documents using the existing whole-document parser. `iter_trace_records` exposes
metadata as `TraceFileEvent` and `BatchStartRecord` instances, which
`write_trace_file` can also write. Use a `.gz` suffix for the
compressed transport. Each call creates a fresh iterator without an event cache.

Exhaust readers to validate all events and the gzip checksum. Errors discovered
after earlier events have been yielded cannot retract those events. Callers own
file lifetime and publication: keep unpublished partial output private, remove
it on failure, and retain completed artifacts while lazy readers need them.
