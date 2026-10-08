# selene-api-models for Python

Python models for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-trace/`
directory.

```python
from selene_api_models.trace import (
    SCHEMA_VERSION,
    Trace,
    TraceData,
    Traces,
    parse_trace_json,
)

trace = Trace(schema_version=SCHEMA_VERSION, events=[])
traces = Traces(schema_version=SCHEMA_VERSION, traces=[TraceData(events=[])])
upgraded = parse_trace_json(versionless_trace_json)
```

For trace streams, use the MessagePack API rather than the JSON document parser:

```python
from selene_api_models.trace_stream import iter_trace_stream, write_trace_stream

write_trace_stream("trace.msgpack.gz", trace.events)
for event in iter_trace_stream("trace.msgpack.gz"):
    print(event)
```

Use `iter_trace_stream_records` to include instruction metadata. Reads are lazy
and uncached, so keep the source file available until iteration finishes. See
the [stream format](../README.md#trace-streams) for framing and error handling.
