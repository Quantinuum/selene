# selene-formats for Rust

Rust models for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-formats/`
directory.

JSON schema support:

- Parsing helpers read `0.1.0`, `0.2.0`, and versionless legacy traces, normalizing
  them to the current model.
- Versioned models and JSON output use `0.2.0`.
- Measurement types are non-empty strings. `FutureResultValue` accepts numbers,
  booleans, nulls, arrays, and objects within the protocol's numeric bounds.
  Parsing and serialization preserve unfamiliar types and supported result
  shapes; interpretation requires type-specific support.

Gzipped MessagePack stream readers accept schema versions `0.1.0` and `0.2.0`.
Stream writers emit schema `0.2.0` using transport `format_version: 1`.

`FutureRead` and `FutureResult` describe runtime future reads in general.
Measurement futures can be linked to their `Measurement` event and qubit through
`result_id`. Other runtime futures do not require a measurement or qubit reference.

See [package and schema compatibility](../docs/versioning.md) for support by
package release.

Trace types are available from the `selene_formats::trace` module.
`trace::parse_trace_json` accepts both current and versionless legacy trace
documents and upgrades legacy input to the current model. Use
`trace::parse_trace_document_json` when the input may be either a `Trace` or a
`Traces` collection.

Use `serde_json::to_string(&trace)` to serialize the current schema.

Gzipped MessagePack trace streams use `selene_formats::trace_stream`:

```rust
use selene_formats::trace_stream::{TraceStreamReader, TraceStreamWriter};

let mut writer = TraceStreamWriter::new(Vec::new());
// Append EventRecord slices with writer.write_events(&events)? at checkpoints.
let compressed = writer.finish()?;
for event in TraceStreamReader::new(compressed.as_slice())? {
    let event = event?;
}
# Ok::<(), std::io::Error>(())
```

`write_records` and `TraceStreamRecordReader` include instruction metadata.
Check `finish()` before publishing output and exhaust readers to validate its
completion. See the [stream format](../README.md#trace-streams).
