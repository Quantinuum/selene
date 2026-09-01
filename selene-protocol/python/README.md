# selene-api-models for Python

Python models for the versioned, serializable Selene trace protocol. See the
protocol documentation and JSON Schema in the repository's `selene-protocol/`
directory.

```python
from selene_api_models.trace import SCHEMA_VERSION, Trace

trace = Trace(schema_version=SCHEMA_VERSION, events=[])
```
