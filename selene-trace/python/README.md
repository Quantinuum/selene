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

The streaming format lives in `selene_api_models.trace_file`:

```python
from selene_api_models.trace_file import iter_trace_file, write_trace_file

write_trace_file("trace.jsonl.gz", trace.events)
for event in iter_trace_file("trace.jsonl.gz"):
    print(event)
```

Writing also accepts a generator. Reading is lazy and uncached, and reports
filename and line context for malformed input. Keep the file available until
iteration finishes. See the [format contract](../README.md#streaming-trace-files).

`iter_trace_file` yields the original trace events without instruction metadata.
Use `iter_trace_records` when batch boundaries and measurement instruction
distinctions are needed; its records can also be passed to `write_trace_file`.
