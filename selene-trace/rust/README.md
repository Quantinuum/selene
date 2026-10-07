# selene-api-models for Rust

Rust models for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-trace/`
directory.

Trace types are available from the `selene_api_models::trace` module.
`trace::parse_trace_json` accepts both current and versionless legacy trace
documents and upgrades legacy input to the current model. Use
`trace::parse_trace_document_json` when the input may be either a `Trace` or a
`Traces` collection.

For the streaming `.jsonl.gz` format, use `selene_api_models::trace_file`:

```rust
use selene_api_models::trace_file::{TraceReader, TraceWriter};

let mut writer = TraceWriter::new(Vec::new());
// Append EventRecord slices at checkpoints with writer.write_events(&events)?;
let compressed = writer.finish()?;
let reader = TraceReader::new(compressed.as_slice())?;
for event in reader {
    let event = event?;
    // Process one event at a time without retaining the complete trace.
}
# Ok::<(), std::io::Error>(())
```

The writer accepts any `Write` destination, including a file. Its owner decides
when to publish the output and is responsible for removing failed artifacts.
See the [format contract](../README.md#streaming-trace-files).

`TraceReader` yields the original trace events without instruction metadata.
Use `TraceRecordReader` and `TraceWriter::write_records` when preserving batch
boundaries or measurement instruction distinctions for circuit extraction.
