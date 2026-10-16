# selene-formats for Python

Python models for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-formats/`
directory.

```python
from selene_formats.trace import (
    SCHEMA_VERSION,
    Trace,
    TraceData,
    Traces,
    parse_trace_json,
)

trace = Trace(schema_version=SCHEMA_VERSION, events=[])
traces = Traces(schema_version=SCHEMA_VERSION, traces=[TraceData(events=[])])
upgraded = parse_trace_json(versionless_trace_json)
legacy_json = trace.as_legacy().model_dump_json(indent=2)
```

`as_legacy()` returns a `LegacyTrace` sharing the current event models and
validation rules. Its `model_dump()` and `model_dump_json()` omit
`schema_version` and keep opaque tags numeric. `LegacyTrace` also accepts
versionless input and defaults its internal version to `0.1.0`. Filtering and
timing helpers retain legacy serialization. Collections have no legacy format.
