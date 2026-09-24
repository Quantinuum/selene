import json
from pathlib import Path

import pytest
from jsonschema import Draft202012Validator
from jsonschema.exceptions import ValidationError
from pydantic import TypeAdapter
from selene_api_models import get_legacy_trace_schema, get_trace_schema
from selene_api_models.trace import TraceDocument


def test_checked_in_schema_matches_the_python_model_with_required_discriminators():
    schema_path = Path(__file__).parents[2] / "schemas" / "trace" / "0.1.0.schema.json"
    checked_in_schema = json.loads(schema_path.read_text())
    checked_in_schema.pop("$schema")
    checked_in_schema.pop("$id")

    python_schema = TypeAdapter(TraceDocument).json_schema()
    python_schema["oneOf"] = python_schema.pop("anyOf")
    for definition in python_schema["$defs"].values():
        if "kind" in definition.get("properties", {}):
            definition["required"] = ["kind", *definition.get("required", [])]

    assert checked_in_schema == python_schema


def test_installed_schema_matches_the_canonical_schema():
    schema_path = Path(__file__).parents[2] / "schemas" / "trace" / "0.1.0.schema.json"

    assert get_trace_schema() == json.loads(schema_path.read_text())


def test_installed_legacy_schema_matches_the_canonical_schema():
    schema_path = Path(__file__).parents[2] / "schemas" / "trace" / "legacy.schema.json"

    assert get_legacy_trace_schema() == json.loads(schema_path.read_text())


def test_legacy_example_conforms_to_the_legacy_schema():
    schema = get_legacy_trace_schema()
    example_path = Path(__file__).parents[2] / "examples" / "trace" / "legacy.json"

    Draft202012Validator.check_schema(schema)
    Draft202012Validator(schema).validate(json.loads(example_path.read_text()))


@pytest.mark.parametrize(
    "example_name", ["minimal.json", "all-event-types.json", "traces.json"]
)
def test_current_examples_conform_to_the_current_schema(example_name: str):
    schema = get_trace_schema()
    example_path = Path(__file__).parents[2] / "examples" / "trace" / example_name

    Draft202012Validator.check_schema(schema)
    Draft202012Validator(schema).validate(json.loads(example_path.read_text()))


def test_legacy_schema_rejects_a_versioned_trace():
    with pytest.raises(ValidationError):
        Draft202012Validator(get_legacy_trace_schema()).validate(
            {"schema_version": "0.1.0", "events": []}
        )
