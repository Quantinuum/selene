# selene-api-models for Python

Python models for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-protocol/`
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
