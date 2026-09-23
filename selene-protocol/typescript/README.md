# @quantinuum/selene-api-models

TypeScript types for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-protocol/`
directory.

Trace types, Zod schemas, and helpers are exported from the `trace` namespace:

```ts
import { trace } from "@quantinuum/selene-api-models";

const document = trace.parseTrace(value); // Throws ZodError if invalid.
const fromJson = trace.parseTraceJson(jsonText); // Also handles legacy traces.
const result = trace.safeParseTrace(value); // Non-throwing validation result.
const jsonReady = trace.serializeTrace(document);
```

Each `*Schema` has a normalized inferred type, such as `trace.Trace`, and an
`*Input` type for values which rely on protocol defaults, such as
`trace.TraceInput`. Indices, times, durations, and qubit IDs are safe
non-negative JavaScript numbers. Opaque-payload tags are decoded to `bigint`;
use `serializeTrace` before passing a trace to `JSON.stringify`.

Pass legacy JSON text directly to `parseTraceJson` when it may contain an
opaque tag larger than `Number.MAX_SAFE_INTEGER`. Calling `JSON.parse` first
would lose precision before validation can occur.

From the repository root, build the package with the project-managed tooling:

```sh
devenv shell -- pnpm --dir selene-protocol/typescript build
```

Run the package tests with:

```sh
devenv shell -- pnpm --dir selene-protocol/typescript test
```
