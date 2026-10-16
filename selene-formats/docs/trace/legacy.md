# Legacy trace format

Schema: [`../../schemas/trace/legacy.schema.json`](../../schemas/trace/legacy.schema.json)

Selene currently emits trace documents without a `schema_version` through
`CircuitExtractor` and `selene_core.trace`. These documents use JSON integers
for indices, qubit IDs, timestamps, durations, and `OpaquePayload.tag`.

A missing `schema_version` identifies this format. Producers using the
`selene-formats` packages emit the versioned format by default and also support
legacy serialization for singular traces. Their adapters validate legacy input
and upgrade it to the current in-memory model. Legacy output omits
`schema_version` and serializes opaque tags as JSON integers; current validation
bounds still apply. Collections have no legacy format.

`OpaquePayload.data` accepts the standard or URL-safe Base64 alphabet, with
optional padding. Unused bits in the final Base64 character must be zero.

The supported legacy schema applies the current JavaScript-safe bounds to
integer-valued gate parameters and key-value payload values, including arrays:
`-9007199254740991` through `9007199254740991`. Fractional numbers remain
supported. Historical traces with values outside those bounds cannot be
upgraded by these adapters.

Legacy opaque tags may exceed JavaScript's safe integer range. TypeScript
consumers must pass the original JSON text to `parseTraceJson` to preserve such
tags; parsing them first with `JSON.parse` loses information irreversibly.
