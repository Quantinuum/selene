# selene-formats for Rust

Rust models for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-formats/`
directory.

Trace types are available from the `selene_formats::trace` module.
`trace::parse_trace_json` accepts both current and versionless legacy trace
documents and upgrades legacy input to the current model. Use
`trace::parse_trace_document_json` when the input may be either a `Trace` or a
`Traces` collection.

`trace::serialize_legacy_trace(&trace)` returns a versionless JSON value with
numeric opaque tags. `trace::serialize_legacy_trace_json(&trace)` returns JSON
text, preserving the full unsigned 64-bit tag range. Both enforce the current
validation rules. Collections have no legacy format.
