import json

import pytest
from pydantic import BaseModel, Field
from pydantic_core import PydanticSerializationError

from selene_formats.trace import (
    SCHEMA_VERSION,
    CustomEvent,
    GateEvent,
    OpaquePayload,
    Trace,
    TraceData,
    Traces,
)


class TraceContainer(BaseModel):
    trace: Trace


class TracesContainer(BaseModel):
    trace: Traces


def as_document(trace, collection):
    if collection:
        return Traces(
            schema_version=SCHEMA_VERSION, traces=[TraceData(events=trace.events)]
        )
    return trace


@pytest.mark.parametrize("collection", [False, True])
@pytest.mark.parametrize("mode", ["python", "json", "json_text", "nested"])
@pytest.mark.parametrize("mutation", ["index", "params", "qubits", "tag", "version"])
def test_serialization_revalidates_mutations(collection, mode, mutation):
    trace = Trace(schema_version=SCHEMA_VERSION)
    gate = GateEvent(gate_name="H", qubits=[0], params=[0])
    payload = OpaquePayload(tag=42, data=b"")
    trace.add_user_program_event(gate, 0)
    trace.add_user_program_event(CustomEvent(payload=payload), 1)
    document = as_document(trace, collection)
    if mutation == "index":
        trace.events[0].source.index = -1
    elif mutation == "params":
        gate.params.append(2**53)
    elif mutation == "qubits":
        gate.qubits[0] = -1
    elif mutation == "tag":
        payload.tag = 2**64
    else:
        document.schema_version = "0.1.0"

    with pytest.raises(PydanticSerializationError, match="ValidationError"):
        if mode == "json_text":
            document.model_dump_json()
        elif mode == "nested":
            container = TracesContainer if collection else TraceContainer
            container(trace=document).model_dump_json()
        else:
            document.model_dump(mode=mode)


@pytest.mark.parametrize("collection", [False, True])
def test_serialization_validates_before_applying_exclusions(collection):
    trace = Trace(schema_version=SCHEMA_VERSION)
    trace.add_user_program_event(GateEvent(gate_name="H"), 0)
    trace.events[0].source.index = -1
    document = as_document(trace, collection)
    with pytest.raises(PydanticSerializationError, match="ValidationError"):
        document.model_dump(mode="json", exclude={"traces" if collection else "events"})


@pytest.mark.parametrize(
    "exclude",
    [
        {"traces": {0: {"events"}}},
        {"traces": {0: {"events": {0: {"source": {"index"}}}}}},
    ],
)
def test_collection_validates_excluded_nested_fields(exclude):
    trace = Trace(schema_version=SCHEMA_VERSION)
    trace.add_user_program_event(GateEvent(gate_name="H"), 0)
    document = as_document(trace, True)
    document.traces[0].events[0].source.index = -1
    with pytest.raises(PydanticSerializationError, match="ValidationError"):
        document.model_dump_json(exclude=exclude)


def test_collection_validates_excluded_version():
    document = Traces(schema_version=SCHEMA_VERSION, traces=[])
    document.schema_version = "0.1.0"
    with pytest.raises(PydanticSerializationError, match="ValidationError"):
        document.model_dump_json(exclude={"schema_version"})


@pytest.mark.parametrize("collection", [False, True])
def test_valid_mutations_and_exclusions_preserve_versioned_output(collection):
    trace = Trace(schema_version=SCHEMA_VERSION)
    trace.add_user_program_event(GateEvent(gate_name="H", params=[0]), 0)
    trace.events[0].event.params.append(0.5)
    document = as_document(trace, collection)
    serialized = json.loads(document.model_dump_json())
    assert serialized["schema_version"] == SCHEMA_VERSION
    assert type(document).model_validate(serialized) == document
    assert document.model_dump(exclude={"traces" if collection else "events"}) == {
        "schema_version": SCHEMA_VERSION
    }


def test_subclass_metadata_does_not_interfere_with_trace_validation():
    class NamedTrace(Trace):
        name: str = Field(exclude=True)

    class Container(BaseModel):
        trace: NamedTrace

    trace = NamedTrace(schema_version=SCHEMA_VERSION, name="shot-0")
    expected = {"schema_version": SCHEMA_VERSION, "events": []}
    assert trace.model_dump() == expected
    assert json.loads(trace.model_dump_json()) == expected
    assert json.loads(Container(trace=trace).model_dump_json()) == {"trace": expected}
    trace.add_user_program_event(GateEvent(gate_name="H"), 0)
    trace.events[0].source.index = -1
    with pytest.raises(PydanticSerializationError, match="ValidationError"):
        trace.model_dump_json()


def test_collection_subclass_metadata_does_not_interfere_with_validation():
    class NamedTraces(Traces):
        name: str = Field(exclude=True)

    document = NamedTraces(schema_version=SCHEMA_VERSION, traces=[], name="batch-0")
    assert json.loads(document.model_dump_json()) == {
        "schema_version": SCHEMA_VERSION,
        "traces": [],
    }
