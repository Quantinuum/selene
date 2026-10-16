# Selene Formats

`selene-formats` contains the schemas, documentation, examples, and language
models for Selene's public serialized traces. It has no dependency on the
emulator.

Selene's `extractor.shots[index].get_trace()` output uses the versionless legacy format and
`selene_core.trace` models, which use the Python binding's `LegacyTrace` wrapper.
The language bindings use protocol 0.1.0 and provide adapters for reading and
serializing legacy traces with the current validation rules.

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

* Python: [`python/`](python) publishes the `selene-formats` distribution and is
  imported as `selene_formats`.
* Rust: [`rust/`](rust) publishes the `selene-formats` crate.
* TypeScript: [`typescript/`](typescript) publishes the `@quantinuum/selene-formats`
  package.

The binding release process is described in [`docs/publishing.md`](docs/publishing.md).
