# @quantinuum/selene-formats

TypeScript types for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-formats/`
directory.

Trace types, Zod schemas, and helpers are exported from the `trace` namespace:

```ts
import { trace } from "@quantinuum/selene-formats";

const document = trace.parseTrace(value); // Throws ZodError if invalid.
const fromJson = trace.parseTraceJson(jsonText); // Also handles legacy traces.
const result = trace.safeParseTrace(value); // Non-throwing validation result.
const jsonReady = trace.serializeTrace(document);
const collection = trace.createTraces([trace.createTraceData(document.events)]);
const eitherShape = trace.parseTraceDocument(value);
```

Each `*Schema` has a normalized inferred type, such as `trace.Trace`, and an
`*Input` type for values which rely on protocol defaults, such as
`trace.TraceInput`. Indices, times, durations, and qubit IDs are safe
non-negative JavaScript numbers. Opaque-payload tags use canonical `0x`-prefixed
uppercase hexadecimal strings in JSON and are decoded to `bigint`;
use `serializeTrace` or `serializeTraceDocument` before passing a document to
`JSON.stringify`.

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
