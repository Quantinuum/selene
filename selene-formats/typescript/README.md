# @quantinuum/selene-formats

TypeScript types for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-formats/`
directory.

JSON schema support:

- Parsing helpers read `0.1.0`, `0.2.0`, and versionless legacy traces, normalizing
  them to the current model.
- Versioned models and JSON output use `0.2.0`.
- Measurement types are non-empty strings. `FutureResultValue` accepts strings,
  numbers, booleans, nulls, arrays, and objects within the protocol's numeric
  bounds. Object keys are strings, and values follow these rules recursively.
  Parsing and serialization preserve unfamiliar types and supported result
  shapes; interpretation requires type-specific support.
- Explicit legacy output is supported for traces without `FutureRead` or
  `FutureResult` events. Collections have no legacy format.

`FutureRead` and `FutureResult` describe runtime future reads in general.
Measurement futures can be linked to their `Measurement` event and qubit through
`result_id`. Other runtime futures do not require a measurement or qubit reference.

See [package and schema compatibility](../docs/versioning.md) for support by
package release.

Trace types and helpers are exported from the `trace` namespace:

```ts
import { trace } from "@quantinuum/selene-formats";

const document = trace.parseTrace(value); // Throws an error if invalid.
const fromJson = trace.parseTraceJson(jsonText); // Also handles legacy traces.
const result = trace.safeParseTrace(value); // Non-throwing validation result.
const jsonReady = trace.serializeTrace(document);
const collection = trace.createTraces([trace.createTraceData(document.events)]);
const eitherShape = trace.parseTraceDocument(value);
```

Normalized types, such as `trace.Trace`, describe parsed values. The corresponding
`*Input` types describe values which rely on protocol defaults, such as
`trace.TraceInput`. Indices, times, durations, and qubit IDs are safe
non-negative JavaScript numbers. Opaque-payload tags use canonical `0x`-prefixed
uppercase hexadecimal strings in JSON and are decoded to `bigint`;
use `serializeTrace` or `serializeTraceDocument` before passing a document to
`JSON.stringify`.

The `safeParseTrace` and `safeParseTraceDocument` helpers return a `ParseResult<T>`: either
`{ success: true, data: T }` or `{ success: false, error: Error }`.

The `createTrace`, `createTraceData`, and `createTraces` constructors accept
both wire inputs and normalized values. Wire parsers require hexadecimal
strings for opaque tags.

Pass legacy JSON text directly to `parseTraceJson` when it may contain an
opaque tag larger than `Number.MAX_SAFE_INTEGER`. Calling `JSON.parse` first
would lose precision before validation can occur.

Use `serializeLegacyTraceJson(document, 2)` to emit versionless JSON with numeric
opaque tags, preserving the full unsigned 64-bit range. `serializeLegacyTrace`
returns legacy data with `bigint` tags; pass it to a lossless JSON encoder rather
than `JSON.stringify`. Both helpers enforce current validation rules. Collections
have no legacy format.

From the repository root, build the package with the project-managed tooling:

```sh
devenv shell -- pnpm --dir selene-formats/typescript build
```

Run the package tests with:

```sh
devenv shell -- pnpm --dir selene-formats/typescript test
```
