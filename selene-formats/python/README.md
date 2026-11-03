# selene-formats for Python

Python models for the versioned, serializable Selene trace protocol. See the
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

Gzipped MessagePack stream readers accept schema versions `0.1.0` and `0.2.0`.
Stream writers emit schema `0.2.0` using transport `format_version: 1`.

`FutureRead` and `FutureResult` describe runtime future reads in general.
Measurement futures can be linked to their `Measurement` event and qubit through
`result_id`. Other runtime futures do not require a measurement or qubit reference.

See [package and schema compatibility](../docs/versioning.md) for support by
package release.

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
json_text = upgraded.model_dump_json(indent=2)
```

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
