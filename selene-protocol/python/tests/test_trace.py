import json
from pathlib import Path

import pytest
from pydantic import ValidationError

from selene_api_models.trace import (
    SCHEMA_VERSION,
    ErrorModelSource,
    GateEvent,
    MeasurementEvent,
    OpaquePayload,
    ResetEvent,
    RuntimeSource,
    SimulatorSource,
    Trace,
    UserProgramSource,
)


def test_trace_serializes_its_protocol_version():
    trace = Trace(
        schema_version=SCHEMA_VERSION,
        events=[],
    )

    assert json.loads(trace.model_dump_json()) == {
        "schema_version": SCHEMA_VERSION,
        "events": [],
    }


def test_trace_requires_a_supported_protocol_version():
    with pytest.raises(ValidationError):
        Trace(events=[])


def test_trace_requires_source_and_event_discriminators():
    with pytest.raises(ValidationError):
        Trace.model_validate(
            {
                "schema_version": SCHEMA_VERSION,
                "events": [
                    {
                        "source": {"start_time": 0, "end_time": 1},
                        "event": {"gate_name": "H"},
                    }
                ],
            }
        )


@pytest.mark.parametrize(
    ("model", "value"),
    [
        (UserProgramSource, {"index": -1}),
        (RuntimeSource, {"start_time": -1, "end_time": 0}),
        (RuntimeSource, {"start_time": 0, "end_time": -1}),
        (ErrorModelSource, {"index": -1}),
        (SimulatorSource, {"index": -1, "duration_ns": 0}),
        (SimulatorSource, {"index": 0, "duration_ns": -1}),
        (GateEvent, {"gate_name": "H", "qubits": [-1]}),
        (MeasurementEvent, {"qubit": -1}),
        (ResetEvent, {"qubit": -1}),
        (OpaquePayload, {"tag": -1, "data": b"trace"}),
    ],
)
def test_unsigned_trace_values_reject_negative_integers(model, value):
    with pytest.raises(ValidationError):
        model.model_validate(value)


@pytest.mark.parametrize("value", [True, 1.0])
def test_unsigned_trace_values_require_integers(value):
    with pytest.raises(ValidationError):
        UserProgramSource(index=value)


def test_opaque_payload_serializes_its_uint64_tag_as_a_decimal_string():
    tag = 11616494188317837126
    payload = OpaquePayload(tag=tag, data=b"trace")

    assert payload.tag == tag
    assert json.loads(payload.model_dump_json())["tag"] == str(tag)
    assert (
        OpaquePayload.model_validate_json(
            '{"kind":"OpaquePayload","tag":"11616494188317837126","data":"dHJhY2U="}'
        ).tag
        == tag
    )
    assert (
        OpaquePayload.model_validate(
            {"kind": "OpaquePayload", "tag": str(tag), "data": "dHJhY2U="}
        ).tag
        == tag
    )


@pytest.mark.parametrize("tag", [0, "-1", "01", "18446744073709551616"])
def test_opaque_payload_rejects_noncanonical_uint64_json_tags(tag):
    with pytest.raises(ValidationError):
        OpaquePayload.model_validate_json(
            json.dumps({"kind": "OpaquePayload", "tag": tag, "data": "dHJhY2U="})
        )


def test_uint64_trace_fields_serialize_as_decimal_strings():
    trace = Trace(
        schema_version=SCHEMA_VERSION,
        events=[
            {
                "source": {"kind": "Runtime", "start_time": 0, "end_time": 1},
                "event": {"kind": "Gate", "gate_name": "H", "qubits": [0, 1]},
            }
        ],
    )

    serialized = json.loads(trace.model_dump_json())
    assert serialized["events"][0] == {
        "source": {"kind": "Runtime", "start_time": "0", "end_time": "1"},
        "event": {
            "kind": "Gate",
            "qubits": ["0", "1"],
            "gate_name": "H",
            "params": [],
            "predicates": [],
        },
    }


@pytest.mark.parametrize("example_name", ["minimal.json", "all-event-types.json"])
def test_examples_conform_to_python_model(example_name: str):
    example_path = Path(__file__).parents[2] / "examples" / "trace" / example_name
    trace = Trace.model_validate_json(example_path.read_text())

    assert trace.schema_version == SCHEMA_VERSION
    if example_name == "minimal.json":
        assert trace.events[0].source == UserProgramSource(index=0)
        assert trace.events[0].event == GateEvent(
            gate_name="RXY", qubits=[0], params=[0.5, 0]
        )
