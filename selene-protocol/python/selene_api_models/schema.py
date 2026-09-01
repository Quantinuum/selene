"""Access to the JSON Schema for the installed trace-model version."""

import json
from importlib.resources import files
from pathlib import Path
from typing import Any


def get_trace_schema() -> dict[str, Any]:
    """Return a new dictionary containing the canonical trace JSON Schema."""
    schema_file = files("selene_api_models").joinpath("schemas/trace/0.1.0.schema.json")
    if not schema_file.is_file():
        # The canonical schema lives outside the Python package in a source
        # checkout and is force-included when building a distribution.
        schema_file = (
            Path(__file__).parents[2] / "schemas" / "trace" / "0.1.0.schema.json"
        )
    return json.loads(schema_file.read_text())
