import json
from pathlib import Path

import pytest
from pydantic import ValidationError

from selene_api_models.trace import SCHEMA_VERSION, GateEvent, Trace, UserProgramSource


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
