# Legacy trace format

Schema: [`../../schemas/trace/legacy.schema.json`](../../schemas/trace/legacy.schema.json)

Before trace protocol versioning, Selene emitted trace documents without a
`schema_version`. These documents use JSON integers for indices, qubit IDs,
timestamps, durations, and `OpaquePayload.tag`.

A missing `schema_version` identifies this format. New producers
must emit a versioned format. The Python, Rust, and TypeScript model packages
provide adapters that validate a legacy document and upgrade it to the current
in-memory model.

Legacy opaque tags may exceed JavaScript's safe integer range. TypeScript
consumers must pass the original JSON text to `parseTraceJson` to preserve such
tags; parsing them first with `JSON.parse` loses information irreversibly.
