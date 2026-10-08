# Versioning

Public schemas use semantic versioning. A document's `schema_version` identifies
its schema contract, not a Selene release. Schema files use their full version
in their filenames.

The only exception is the versionless legacy trace format. A trace with no
`schema_version` is interpreted as that legacy format and may be upgraded by
the model packages. New schemas and producers must always include a version.
