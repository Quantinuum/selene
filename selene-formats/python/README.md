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

For trace streams, use the MessagePack API rather than the JSON document parser:

```python
from selene_formats.trace_stream import iter_trace_stream, write_trace_stream

write_trace_stream("trace.msgpack.gz", trace.events)
for event in iter_trace_stream("trace.msgpack.gz"):
    print(event)
```

Use `iter_trace_stream_records` to include instruction metadata. Reads are lazy
and uncached, so keep the source file available until iteration finishes. See
the [stream format](../README.md#trace-streams) for framing and error handling.
