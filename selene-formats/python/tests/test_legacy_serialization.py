import json
from pathlib import Path

import pytest
from jsonschema import Draft202012Validator
from pydantic import BaseModel, ValidationError
from pydantic_core import PydanticSerializationError

from selene_formats import get_legacy_trace_schema
from selene_formats.trace import (
    SCHEMA_VERSION,
    MAX_SAFE_INTEGER,
    CustomEvent,
    GateEvent,
    LegacyTrace,
    OpaquePayload,
    Trace,
    parse_trace_json,
)


@pytest.mark.parametrize("tag", [0, 42, 2**53 + 1, 2**64 - 1])
@pytest.mark.parametrize("data", [b"", b"\xfb\xff"])
def test_legacy_serialization_preserves_tags_and_bytes(tag, data):
    trace = Trace(schema_version=SCHEMA_VERSION)
    trace.add_user_program_event(
        CustomEvent(payload=OpaquePayload(tag=tag, data=data)), 0
    )
    original = trace.model_dump_json()
    legacy = trace.as_legacy()
    document = json.loads(legacy.model_dump_json(indent=2))

    assert set(document) == {"events"}
    assert document["events"][0]["event"]["payload"]["tag"] == tag
    assert type(document["events"][0]["event"]["payload"]["tag"]) is int
    Draft202012Validator(get_legacy_trace_schema()).validate(document)
    assert parse_trace_json(legacy.model_dump_json()) == trace
    assert LegacyTrace.model_validate_json(legacy.model_dump_json()) == legacy
    assert legacy.model_dump()["events"][0]["event"]["payload"]["data"] == data
    assert trace.model_dump_json() == original

    class Container(BaseModel):
        trace: LegacyTrace

    assert json.loads(Container(trace=legacy).model_dump_json())["trace"] == document


@pytest.mark.parametrize(
    "example", ["minimal.json", "all-event-types.json", "legacy.json"]
)
def test_legacy_serialization_round_trips_examples(example):
    path = Path(__file__).parents[2] / "examples" / "trace" / example
    trace = parse_trace_json(path.read_text())
    document = trace.as_legacy().model_dump(mode="json")
    Draft202012Validator(get_legacy_trace_schema()).validate(document)
    assert parse_trace_json(json.dumps(document)) == trace


def test_legacy_helpers_preserve_serialization_and_validation():
    legacy = LegacyTrace()
    legacy.add_simulator_event(GateEvent(gate_name="H", qubits=[0]), 0, 123)
    filtered = legacy.get_simulator_trace()
    cleared = legacy.clear_simulator_perf_timing()
    assert isinstance(filtered, LegacyTrace)
    assert isinstance(cleared, LegacyTrace)
    assert "schema_version" not in filtered.model_dump(mode="json")
    assert cleared.events[0].source.duration_ns == 0
    assert legacy.events[0].source.duration_ns == 123
    with pytest.raises(ValidationError):
        legacy.add_user_program_event(GateEvent(gate_name="delay", params=[2**60]), 0)
    with pytest.raises(ValidationError):
        LegacyTrace(
            events=[
                {
                    "source": {"kind": "UserProgram", "index": -1},
                    "event": {"kind": "Reset", "qubit": 0},
                }
            ]
        )


def test_legacy_serialization_respects_field_exclusions():
    trace = Trace(schema_version=SCHEMA_VERSION)
    trace.add_user_program_event(
        CustomEvent(payload=OpaquePayload(tag=42, data=b"")), 0
    )
    document = trace.as_legacy().model_dump(
        mode="json", exclude={"events": {0: {"event": {"payload": {"kind"}}}}}
    )
    assert document["events"][0]["event"]["payload"] == {"tag": 42, "data": ""}


@pytest.mark.parametrize("mode", ["python", "json", "json_text", "nested"])
@pytest.mark.parametrize("mutation", ["index", "params", "qubits", "tag"])
def test_legacy_serialization_revalidates_mutated_models(mode, mutation):
    trace = LegacyTrace()
    gate = GateEvent(gate_name="H", qubits=[0], params=[0])
    payload = OpaquePayload(tag=42, data=b"")
    trace.add_user_program_event(gate, 0)
    trace.add_user_program_event(CustomEvent(payload=payload), 1)

    if mutation == "index":
        trace.events[0].source.index = -1
    elif mutation == "params":
        gate.params.append(MAX_SAFE_INTEGER + 1)
    elif mutation == "qubits":
        gate.qubits[0] = -1
    else:
        payload.tag = 2**64

    class Container(BaseModel):
        trace: LegacyTrace

    with pytest.raises(PydanticSerializationError, match="ValidationError"):
        if mode == "json_text":
            trace.model_dump_json()
        elif mode == "nested":
            Container(trace=trace).model_dump_json()
        else:
            trace.model_dump(mode=mode)


def test_legacy_serialization_validates_excluded_mutated_fields():
    trace = LegacyTrace()
    trace.add_user_program_event(GateEvent(gate_name="H"), 0)
    trace.events[0].source.index = -1

    with pytest.raises(PydanticSerializationError, match="ValidationError"):
        trace.model_dump(mode="json", exclude={"events"})
