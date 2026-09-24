import json
from pathlib import Path

import pytest
from pydantic import ValidationError
from selene_api_models.trace import (
    MAX_SAFE_INTEGER,
    SCHEMA_VERSION,
    ErrorModelSource,
    GateEvent,
    MeasurementEvent,
    OpaquePayload,
    ResetEvent,
    RuntimeSource,
    SimulatorSource,
    Trace,
    TraceData,
    Traces,
    UserProgramSource,
    parse_trace,
    parse_trace_document,
    parse_trace_document_json,
    parse_trace_json,
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


def test_traces_versions_unversioned_trace_data_once():
    document = Traces(
        schema_version=SCHEMA_VERSION,
        traces=[TraceData(events=[])],
    )

    assert json.loads(document.model_dump_json()) == {
        "schema_version": SCHEMA_VERSION,
        "traces": [{"events": []}],
    }


def test_trace_document_parser_accepts_both_document_shapes():
    singular = parse_trace_document({"schema_version": SCHEMA_VERSION, "events": []})
    collection = parse_trace_document_json(
        json.dumps(
            {
                "schema_version": SCHEMA_VERSION,
                "traces": [{"events": []}],
            }
        )
    )

    assert isinstance(singular, Trace)
    assert isinstance(collection, Traces)


def test_trace_document_parser_rejects_a_versionless_collection():
    with pytest.raises(ValueError, match="versionless trace collections"):
        parse_trace_document({"traces": []})


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


def test_opaque_payload_round_trips_base64url():
    payload = OpaquePayload.model_validate_json(
        json.dumps({"kind": "OpaquePayload", "tag": "1", "data": "-_8="})
    )

    assert payload.data == b"\xfb\xff"
    serialized = payload.model_dump_json()
    assert json.loads(serialized)["data"] == "-_8="
    assert OpaquePayload.model_validate_json(serialized) == payload
    assert OpaquePayload(tag=1, data=b"\xfb\xff").model_dump_json() == serialized


@pytest.mark.parametrize("encoded", ["+w==", "/w==", "+/8="])
def test_current_payload_rejects_standard_base64(encoded):
    payload = {"kind": "OpaquePayload", "tag": "1", "data": encoded}
    with pytest.raises(ValidationError):
        OpaquePayload.model_validate(payload)
    with pytest.raises(ValidationError):
        OpaquePayload.model_validate_json(json.dumps(payload))


@pytest.mark.parametrize("encoded", ["-_8=", "+/8="])
def test_legacy_base64_is_normalized_only_during_upgrade(encoded):
    document = {
        "events": [
            {
                "source": {"kind": "UserProgram", "index": 0},
                "event": {
                    "kind": "Custom",
                    "payload": {
                        "kind": "OpaquePayload",
                        "tag": 1,
                        "data": encoded,
                    },
                },
            }
        ]
    }
    parsed = parse_trace_json(json.dumps(document))
    assert parsed == parse_trace(document)
    assert parsed.events[0].event.payload.data == b"\xfb\xff"
    output = json.loads(parsed.model_dump_json())
    assert output["events"][0]["event"]["payload"]["data"] == "-_8="
    assert parse_trace_json(json.dumps(output)) == parsed
    assert document["events"][0]["event"]["payload"]["data"] == encoded

    output["events"][0]["event"]["payload"]["data"] = "+/8="
    with pytest.raises(ValidationError):
        parse_trace_json(json.dumps(output))
    with pytest.raises(ValidationError):
        parse_trace_document(
            {
                "schema_version": SCHEMA_VERSION,
                "traces": [{"events": output["events"]}],
            }
        )


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


def test_safe_unsigned_trace_fields_serialize_as_json_integers():
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
        "source": {"kind": "Runtime", "start_time": 0, "end_time": 1},
        "event": {
            "kind": "Gate",
            "qubits": [0, 1],
            "gate_name": "H",
            "params": [],
            "predicates": [],
        },
    }


@pytest.mark.parametrize("value", [-1, MAX_SAFE_INTEGER + 1])
def test_safe_unsigned_trace_fields_enforce_javascript_range(value):
    with pytest.raises(ValidationError):
        UserProgramSource(index=value)


def test_versionless_legacy_trace_is_upgraded():
    trace = parse_trace(
        {
            "events": [
                {
                    "source": {"kind": "UserProgram", "index": 0},
                    "event": {"kind": "Measurement", "qubit": 1},
                }
            ]
        }
    )

    assert trace.schema_version == SCHEMA_VERSION
    assert trace.events[0].source == UserProgramSource(index=0)
    assert trace.events[0].event == MeasurementEvent(qubit=1)


def test_legacy_json_preserves_a_numeric_uint64_opaque_payload_tag():
    example_path = Path(__file__).parents[2] / "examples" / "trace" / "legacy.json"
    trace = parse_trace_json(example_path.read_text())

    assert trace.schema_version == SCHEMA_VERSION
    assert isinstance(trace.events[1].event.payload, OpaquePayload)
    assert trace.events[1].event.payload.tag == 11616494188317837126
    assert (
        json.loads(trace.model_dump_json())["events"][1]["event"]["payload"]["tag"]
        == "11616494188317837126"
    )


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
