import json

import pytest
from jsonschema import Draft202012Validator
from pydantic import TypeAdapter, ValidationError

from selene_formats import get_trace_schema
from selene_formats.trace import (
    SCHEMA_VERSION,
    Event,
    EventRecord,
    FutureReadEvent,
    FutureResultEvent,
    FutureResultValue,
    MeasurementEvent,
    RuntimeSource,
    UserProgramSource,
    Trace,
    parse_trace,
    parse_trace_document,
)
from selene_formats.trace_stream import iter_trace_stream, write_trace_stream


@pytest.mark.parametrize(
    "outcome,valid",
    [
        (0, True),
        (1, True),
        (2, True),
        (3, True),
        (-1, True),
        (True, True),
        (1.0, True),
        (None, True),
        ([True, 0.5, None], True),
        ({"value": [1, False, {"units": 2}]}, True),
        ("unknown", True),
        ([True, 0.5, None, "value"], True),
        ({"value": [1, False, {"units": "custom"}]}, True),
        ({"kind": "OpaquePayload", "tag": "arbitrary", "data": "literal"}, True),
        ({"value": [2**53]}, False),
        ({"value": [-(2**53)]}, False),
        ({"value": [float("inf")]}, False),
        (float("nan"), False),
    ],
)
def test_future_outcomes_agree_with_schema(outcome, valid):
    event = {"kind": "FutureResult", "result_id": 42, "outcome": outcome}
    document = {
        "schema_version": SCHEMA_VERSION,
        "events": [
            {
                "source": {"kind": "Runtime", "start_time": 5, "end_time": 5},
                "event": event,
            }
        ],
    }
    try:
        json.dumps(document, allow_nan=False)
    except ValueError:
        pass
    else:
        assert Draft202012Validator(get_trace_schema()).is_valid(document) == valid
    if valid:
        parsed = TypeAdapter(Event).validate_python(event)
        assert parsed.outcome == outcome
        assert parsed.model_dump() == event
    else:
        with pytest.raises(ValidationError):
            TypeAdapter(Event).validate_python(event)


def test_measurements_and_results_round_trip_json_and_stream(tmp_path):
    source = RuntimeSource(start_time=5, end_time=5)
    events = [
        EventRecord(
            source=UserProgramSource(index=0)
            if isinstance(event, FutureReadEvent)
            else source,
            event=event,
        )
        for event in [
            MeasurementEvent(qubit=3, result_id=42, measurement_type="Leaked"),
            FutureReadEvent(result_id=42),
            FutureResultEvent(result_id=42, outcome=2),
            FutureReadEvent(result_id=42),
            FutureResultEvent(result_id=42, outcome=2),
        ]
    ]
    trace = Trace(schema_version=SCHEMA_VERSION, events=events)
    assert parse_trace(json.loads(trace.model_dump_json())) == trace
    path = tmp_path / "measurements.msgpack.gz"
    write_trace_stream(path, events)
    assert list(iter_trace_stream(path)) == events
    with pytest.raises(ValueError, match="FutureResult"):
        trace.as_legacy().model_dump_json()


@pytest.mark.parametrize("collection", [False, True])
def test_previous_schema_measurements_have_unknown_result_ids(collection):
    data = {
        "events": [
            {
                "source": {"kind": "Runtime", "start_time": 0, "end_time": 1},
                "event": {"kind": "Measurement", "qubit": 3},
            }
        ]
    }
    document = {
        "schema_version": "0.1.0",
        **({"traces": [data]} if collection else data),
    }
    parsed = parse_trace_document(document)
    events = parsed.traces[0].events if collection else parsed.events
    assert parsed.schema_version == SCHEMA_VERSION
    assert events[0].event.result_id is None
    assert document["schema_version"] == "0.1.0"


@pytest.mark.parametrize("result_id", [-1, True, 1.5, 2**53])
def test_invalid_result_ids(result_id):
    with pytest.raises(ValidationError):
        MeasurementEvent(qubit=0, result_id=result_id)
    with pytest.raises(ValidationError):
        FutureResultEvent(result_id=result_id, outcome=0)
    with pytest.raises(ValidationError):
        FutureReadEvent(result_id=result_id)


@pytest.mark.parametrize("version", [None, "0.1.0"])
@pytest.mark.parametrize("kind", ["FutureRead", "FutureResult"])
def test_future_events_require_current_schema(version, kind):
    document = {
        "events": [
            {
                "source": {"kind": "Runtime", "start_time": 0, "end_time": 0},
                "event": {
                    "kind": kind,
                    "result_id": 42,
                    **({"outcome": 0} if kind == "FutureResult" else {}),
                },
            }
        ]
    }
    if version is not None:
        document["schema_version"] = version
    with pytest.raises(ValueError, match=kind):
        parse_trace(document)


@pytest.mark.parametrize("kind", ["Measurement", "FutureRead", "FutureResult"])
def test_previous_stream_schema(tmp_path, kind):
    import gzip
    import msgpack

    event = (
        {"kind": "Measurement", "qubit": 3}
        if kind == "Measurement"
        else {
            "kind": kind,
            "result_id": 42,
            **({"outcome": 0} if kind == "FutureResult" else {}),
        }
    )
    objects = [
        {
            "format": "selene.trace.msgpack",
            "format_version": 1,
            "schema_version": "0.1.0",
        },
        {"source": {"kind": "Runtime", "start_time": 0, "end_time": 0}, "event": event},
        None,
    ]
    path = tmp_path / "previous.msgpack.gz"
    path.write_bytes(gzip.compress(b"".join(msgpack.packb(obj) for obj in objects)))
    if kind != "Measurement":
        with pytest.raises(ValueError, match=kind):
            list(iter_trace_stream(path))
    else:
        assert list(iter_trace_stream(path))[0].event.result_id is None


@pytest.mark.parametrize(
    "measurement_type,valid",
    [
        ("Standard", True),
        ("Leaked", True),
        ("com.example/Parity", True),
        ("future-kind", True),
        ("", False),
        (None, False),
        (1, False),
        (True, False),
    ],
)
def test_open_measurement_types(measurement_type, valid):
    value = {
        "kind": "Measurement",
        "qubit": 3,
        "result_id": 42,
        "measurement_type": measurement_type,
    }
    schema = get_trace_schema()
    document = {
        "schema_version": SCHEMA_VERSION,
        "events": [
            {
                "source": {"kind": "Runtime", "start_time": 0, "end_time": 1},
                "event": value,
            }
        ],
    }
    assert Draft202012Validator(schema).is_valid(document) == valid
    if valid:
        assert (
            MeasurementEvent.model_validate(value).measurement_type == measurement_type
        )
    else:
        with pytest.raises(ValidationError):
            MeasurementEvent.model_validate(value)


@pytest.mark.parametrize(
    "outcome",
    [
        None,
        True,
        -3,
        0.25,
        "text",
        "0",
        {"kind": "OpaquePayload", "tag": "arbitrary", "data": "literal"},
        [1, None, {"value": False}],
        {"kind": 1, "tag": 42, "data": [True, None]},
        {"nested": {"kind": 1, "tag": 42, "data": [True, None]}},
        {"__proto__": {"x": 1}, "constructor": True},
    ],
)
def test_extension_values_survive_json_and_streams(tmp_path, outcome):
    measurement = EventRecord(
        source=RuntimeSource(start_time=0, end_time=1),
        event=MeasurementEvent(
            qubit=3, result_id=42, measurement_type="com.example/Custom"
        ),
    )
    result = EventRecord(
        source=RuntimeSource(start_time=1, end_time=1),
        event=FutureResultEvent(result_id=42, outcome=outcome),
    )
    trace = Trace(schema_version=SCHEMA_VERSION, events=[measurement, result])
    recovered = parse_trace(json.loads(trace.model_dump_json()))
    assert recovered.events == trace.events
    assert recovered.events[1].event.outcome == outcome
    path = tmp_path / "extension.msgpack.gz"
    write_trace_stream(path, trace.events)
    assert list(iter_trace_stream(path)) == trace.events


@pytest.mark.parametrize(
    "outcome", [b"bytes", (1, 2), {1: "non-string key"}, {"nested": object()}]
)
def test_outcomes_require_json_values(outcome):
    with pytest.raises(ValidationError):
        FutureResultEvent(result_id=42, outcome=outcome)


def test_outcome_is_required_even_though_null_is_valid():
    with pytest.raises(ValidationError):
        FutureResultEvent.model_validate({"result_id": 42})
    assert FutureResultEvent(result_id=42, outcome=None).model_dump()["outcome"] is None


@pytest.mark.parametrize(
    "outcome",
    ["0", "text", ["text"], {"value": "text"}, {"value": [1, {"nested": "text"}]}],
)
def test_string_values_survive_models_json_and_streams(tmp_path, outcome):
    import gzip
    import msgpack

    record = {
        "source": {"kind": "Runtime", "start_time": 0, "end_time": 0},
        "event": {"kind": "FutureResult", "result_id": 42, "outcome": outcome},
    }
    document = {"schema_version": SCHEMA_VERSION, "events": [record]}
    assert Draft202012Validator(get_trace_schema()).is_valid(document)
    assert FutureResultEvent(result_id=42, outcome=outcome).outcome == outcome
    assert parse_trace(document).events[0].event.outcome == outcome
    path = tmp_path / "strings.msgpack.gz"
    objects = [
        {
            "format": "selene.trace.msgpack",
            "format_version": 1,
            "schema_version": SCHEMA_VERSION,
        },
        record,
        None,
    ]
    path.write_bytes(gzip.compress(b"".join(msgpack.packb(value) for value in objects)))
    assert list(iter_trace_stream(path))[0].event.outcome == outcome


def test_non_measurement_future_results_round_trip(tmp_path):
    value = {"ready": True, "values": [7, None, 0.5]}
    assert TypeAdapter(FutureResultValue).validate_python(value) == value
    records = [
        EventRecord(
            source=UserProgramSource(index=0), event=FutureReadEvent(result_id=123)
        ),
        EventRecord(
            source=RuntimeSource(start_time=0, end_time=0),
            event=FutureResultEvent(result_id=123, outcome=value),
        ),
    ]
    trace = Trace(schema_version=SCHEMA_VERSION, events=records)
    assert parse_trace(json.loads(trace.model_dump_json())) == trace
    path = tmp_path / "runtime-future.msgpack.gz"
    write_trace_stream(path, records)
    assert list(iter_trace_stream(path)) == records
