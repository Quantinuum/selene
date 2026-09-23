# selene-api-models for Rust

Rust models for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-protocol/`
directory.

Trace types are available from the `selene_api_models::trace` module.
`trace::parse_trace_json` accepts both current and versionless legacy trace
documents and upgrades legacy input to the current model.
