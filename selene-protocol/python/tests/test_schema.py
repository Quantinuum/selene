import json
from pathlib import Path

from selene_api_models import get_trace_schema
from selene_api_models.trace import Trace


def test_checked_in_schema_matches_the_python_model():
    schema_path = Path(__file__).parents[2] / "schemas" / "trace" / "0.1.0.schema.json"
    checked_in_schema = json.loads(schema_path.read_text())
    checked_in_schema.pop("$schema")
    checked_in_schema.pop("$id")

    assert checked_in_schema == Trace.model_json_schema()


def test_installed_schema_matches_the_canonical_schema():
    schema_path = Path(__file__).parents[2] / "schemas" / "trace" / "0.1.0.schema.json"

    assert get_trace_schema() == json.loads(schema_path.read_text())
