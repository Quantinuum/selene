# selene-formats for Rust

Rust models for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-formats/`
directory.

JSON schema support:

- Parsing helpers read `0.1.0`, `0.2.0`, and versionless legacy traces, normalizing
  them to the current model.
- Versioned models and JSON output use `0.2.0`.
- Measurement types are non-empty strings, and outcomes can be JSON values of
  any shape within the protocol's numeric bounds. Parsing and serialization
  preserve unfamiliar types and outcomes; interpretation requires type-specific
  support.
- Explicit legacy output is supported for traces without `FutureRead` or
  `FutureResult` events. Collections have no legacy format.

Gzipped MessagePack stream readers accept schema versions `0.1.0` and `0.2.0`.
Stream writers emit schema `0.2.0` using transport `format_version: 1`.

See [package and schema compatibility](../docs/versioning.md) for support by
package release.

Trace types are available from the `selene_formats::trace` module.
`trace::parse_trace_json` accepts both current and versionless legacy trace
documents and upgrades legacy input to the current model. Use
`trace::parse_trace_document_json` when the input may be either a `Trace` or a
`Traces` collection.

`trace::serialize_legacy_trace(&trace)` returns a versionless JSON value with
numeric opaque tags. `trace::serialize_legacy_trace_json(&trace)` returns JSON
text, preserving the full unsigned 64-bit tag range. Both enforce the current
validation rules. Collections have no legacy format.

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
