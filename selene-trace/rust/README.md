# selene-api-models for Rust

Rust models for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-trace/`
directory.

Trace types are available from the `selene_api_models::trace` module.
`trace::parse_trace_json` accepts both current and versionless legacy trace
documents and upgrades legacy input to the current model. Use
`trace::parse_trace_document_json` when the input may be either a `Trace` or a
`Traces` collection.

Gzipped MessagePack trace streams use `selene_api_models::trace_stream`:

```rust
use selene_api_models::trace_stream::{TraceStreamReader, TraceStreamWriter};

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
