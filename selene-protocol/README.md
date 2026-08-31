# Selene Protocol

`selene-protocol` contains Selene's public, serializable interoperability
protocols. It intentionally has no dependency on the emulator. Each protocol
has its own versioned JSON Schema, documentation, examples, and bindings.

## APIs

| API | Version | Schema | Semantics |
| --- | --- | --- | --- |
| Trace | 0.1.0 | [`schemas/trace/0.1.0.schema.json`](schemas/trace/0.1.0.schema.json) | [`docs/trace/0.1.0.md`](docs/trace/0.1.0.md) |

Protocol-wide versioning is described in [`docs/versioning.md`](docs/versioning.md).

## Bindings

* Python: [`python/`](python) publishes the `selene-api-models` distribution and is
  imported as `selene_api_models`.
* Rust: [`rust/`](rust) publishes the `selene-api-models` crate.
* TypeScript: [`typescript/`](typescript) publishes the `@quantinuum/selene-api-models`
  package.

The trace API is currently the only protocol. Future APIs belong in their own
directories under `schemas/`, `examples/`, and language-specific modules.
