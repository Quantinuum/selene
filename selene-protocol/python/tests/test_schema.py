import json
from pathlib import Path

import pytest
from jsonschema import Draft202012Validator
from jsonschema.exceptions import ValidationError
from pydantic import TypeAdapter
from selene_api_models import get_legacy_trace_schema, get_trace_schema
from selene_api_models.trace import TraceDocument, parse_trace


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


@pytest.mark.parametrize(
    "value,valid",
    [
        (9007199254740991, True),
        (-9007199254740991, True),
        (9007199254740992, False),
        (-9007199254740992, False),
        (10**20, False),
        (1e20, False),
        (-1e20, False),
        (0, True),
        (0.5, True),
        (-1.5, True),
        (True, True),
    ],
)
def test_numeric_values_agree_between_schema_and_python(value, valid):
    for event in [
        {"kind": "Gate", "gate_name": "test", "params": [value]},
        {
            "kind": "Custom",
            "payload": {
                "kind": "KeyValuePairPayload",
                "data": {"scalar": value},
            },
        },
        {
            "kind": "Custom",
            "payload": {
                "kind": "KeyValuePairPayload",
                "data": {"array": [value]},
            },
        },
    ]:
        document = {
            "schema_version": "0.1.0",
            "events": [
                {
                    "source": {"kind": "UserProgram", "index": 0},
                    "event": event,
                }
            ],
        }
        assert Draft202012Validator(get_trace_schema()).is_valid(document) == valid
        if valid:
            parsed = parse_trace(document)
            assert Draft202012Validator(get_trace_schema()).is_valid(
                json.loads(parsed.model_dump_json())
            )
        else:
            with pytest.raises(ValueError):
                parse_trace(document)


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
