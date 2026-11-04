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
)


@pytest.mark.parametrize("mode", ["python", "json", "json_text", "nested"])
@pytest.mark.parametrize("mutation", ["index", "params", "qubits", "tag", "version"])
def test_serialization_revalidates_mutations(mode, mutation):
    trace = Trace(schema_version=SCHEMA_VERSION)
    gate = GateEvent(gate_name="H", qubits=[0], params=[0])
    payload = OpaquePayload(tag=42, data=b"")
    trace.add_user_program_event(gate, 0)
    trace.add_user_program_event(CustomEvent(payload=payload), 1)
    if mutation == "index":
        trace.events[0].source.index = -1
    elif mutation == "params":
        gate.params.append(2**53)
    elif mutation == "qubits":
        gate.qubits[0] = -1
    elif mutation == "tag":
        payload.tag = 2**64
    else:
        trace.schema_version = "0.1.0"

    class Container(BaseModel):
        trace: Trace

    with pytest.raises(PydanticSerializationError, match="ValidationError"):
        if mode == "json_text":
            trace.model_dump_json()
        elif mode == "nested":
            Container(trace=trace).model_dump_json()
        else:
            trace.model_dump(mode=mode)


def test_serialization_validates_before_applying_exclusions():
    trace = Trace(schema_version=SCHEMA_VERSION)
    trace.add_user_program_event(GateEvent(gate_name="H"), 0)
    trace.events[0].source.index = -1
    with pytest.raises(PydanticSerializationError, match="ValidationError"):
        trace.model_dump(mode="json", exclude={"events"})


def test_valid_mutations_and_exclusions_preserve_versioned_output():
    trace = Trace(schema_version=SCHEMA_VERSION)
    trace.add_user_program_event(GateEvent(gate_name="H", params=[0]), 0)
    trace.events[0].event.params.append(0.5)
    document = json.loads(trace.model_dump_json())
    assert document["schema_version"] == SCHEMA_VERSION
    assert Trace.model_validate(document) == trace
    assert trace.model_dump(exclude={"events"}) == {"schema_version": SCHEMA_VERSION}


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
