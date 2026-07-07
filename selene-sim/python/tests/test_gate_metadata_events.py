from selene_core import Gate, GateValue, MetadataValue, RZ
from selene_sim.event_hooks.instruction_log import GateInstruction


def test_gate_instruction_exposes_metadata_in_dict_and_trace():
    gate = Gate(
        RZ.semantic_id,
        [GateValue.qubit(0), GateValue.f64(0.25)],
        {
            "source": "compiler",
            "logical_id": MetadataValue.u64(42),
            "payload": b"abc",
        },
    )
    instruction = GateInstruction.from_iterator(iter([gate.serialize()]))

    assert instruction.to_dict()["metadata"] == {
        "source": "compiler",
        "logical_id": 42,
        "payload": b"abc",
    }

    trace_event = instruction.to_trace_event()
    assert trace_event.metadata == {
        "source": "compiler",
        "logical_id": 42,
        "payload": b"abc",
    }


def test_gate_instruction_omits_empty_metadata_from_dict():
    gate = Gate(RZ.semantic_id, [GateValue.qubit(0), GateValue.f64(0.25)])
    instruction = GateInstruction.from_iterator(iter([gate.serialize()]))

    assert "metadata" not in instruction.to_dict()
    assert instruction.to_trace_event().metadata == {}
