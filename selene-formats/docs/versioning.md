# Versioning

Public schemas use semantic versioning. A document's `schema_version` identifies
its schema contract, not a Selene release. Schema files use their full version
in their filenames.

The only exception is the versionless legacy trace format. A trace with no
`schema_version` is interpreted as that legacy format and may be upgraded by
the model packages. New schemas and producers must always include a version.

The Python, Rust, and TypeScript binding packages share a release version,
independent of the schema version. Their JSON trace compatibility is:

| Package release | Reads legacy | Reads 0.1.0 | Reads 0.2.0 | Default output |
| --- | --- | --- | --- | --- |
| 0.1.1–0.1.2 | Yes | Yes | No | 0.1.0 |
| 0.2.0 | Yes | Yes | Yes | 0.2.0 |

Reading older schemas uses the parsing helpers, which normalize input to the
current in-memory model. Versioned models require the current schema version
for direct construction and deserialization. Versioned serialization emits that current version,
including when the input used an older schema.

Legacy output is available through explicit compatibility serializers. It cannot
represent `FutureRead` or `FutureResult`; serializing a trace containing either
event as legacy raises an error. Reading older measurements cannot reconstruct
missing result IDs or measurement types.

Schema `0.2.0` supports additional Selene measurement types and structured future result values.
New measurement types and result shapes within that contract can be introduced
without changing the schema version. The bindings preserve unfamiliar types and
outcomes when reading or writing.
See the [measurement contract](trace/0.2.0.md#measurements-and-future-results).

For MessagePack stream headers and transport versions, see
[trace streams](../README.md#trace-streams).
