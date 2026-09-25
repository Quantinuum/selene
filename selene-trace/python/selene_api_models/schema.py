"""Access to the JSON Schema for the installed trace-model version."""

import json
from importlib.resources import files

try:
    from importlib.resources.abc import Traversable  # Python 3.11+
except ImportError:
    from importlib.abc import Traversable  # Python 3.10
from pathlib import Path
from typing import Any


def _get_trace_schema_file(filename: str) -> Traversable:
    schema_file = files("selene_api_models").joinpath(f"schemas/trace/{filename}")
    if not schema_file.is_file():
        # The canonical schema lives outside the Python package in a source
        # checkout and is force-included when building a distribution.
        schema_file = Path(__file__).parents[2] / "schemas" / "trace" / filename
    return schema_file


def get_trace_schema() -> dict[str, Any]:
    """Return a new dictionary containing the current trace JSON Schema."""
    schema_file = _get_trace_schema_file("0.1.0.schema.json")
    return json.loads(schema_file.read_text())


def get_legacy_trace_schema() -> dict[str, Any]:
    """Return a new dictionary containing the versionless legacy trace schema."""
    schema_file = _get_trace_schema_file("legacy.schema.json")
    return json.loads(schema_file.read_text())
