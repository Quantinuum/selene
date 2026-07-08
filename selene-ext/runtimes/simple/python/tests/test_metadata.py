"""Tests the backtrace metadata emitted by the simple runtime.

These tests do not use the `compile_guppy` fixture because they always need to have
access to the source code at its compiled location.
"""

from guppylang.decorator import guppy
from guppylang.std.quantum import qubit, measure, h, cx
from guppylang.std.builtins import result


from selene_sim import Coinflip, build
from selene_sim.event_hooks import CircuitExtractor
from selene_core.trace import (
    GateEvent,
    MeasurementEvent,
    ResetEvent,
)
from selene_core.testing import (
    compile_guppy_with_debug,
    validate_debug_info_trace,
)

from selene_simple_runtime_plugin import SimpleRuntimePlugin


def validate_debug_info(hugr):
    """
    Verify that debug info custom ops are emitted and point to correct-looking source
    lines.
    """
    runner = build(hugr, emit_debug=True)
    extractor = CircuitExtractor()
    _results = list(
        runner.run(
            simulator=Coinflip(random_seed=0),
            runtime=SimpleRuntimePlugin(),
            verbose=False,
            n_qubits=4,
            event_hook=extractor,
        )
    )

    raw_trace = extractor.shots[0].get_trace()
    transformed_trace = validate_debug_info_trace(raw_trace)

    # Additional SimpleRuntime-specific checks: QAlloc and QFree must carry metadata.
    for gate_name in ("QAlloc", "QFree"):
        alloc_free_events = [
            r
            for r in transformed_trace.events
            if isinstance(r.event, GateEvent) and r.event.gate_name == gate_name
        ]
        assert len(alloc_free_events) > 0, (
            f"Expected at least one {gate_name} event in trace"
        )
        for record in alloc_free_events:
            assert record.event.metadata is not None, (
                f"Expected {gate_name} event to have backtrace metadata"
            )
            assert len(record.event.metadata.frames) > 0, (
                f"Expected {gate_name} metadata to have at least one frame"
            )

    # Validate that the innermost frame (user code) has full source info
    events_with_metadata = [
        r
        for r in transformed_trace.events
        if isinstance(r.event, (GateEvent, MeasurementEvent, ResetEvent))
        and r.event.metadata is not None
    ]
    for record in events_with_metadata:
        innermost = record.event.metadata.frames[0]
        assert isinstance(innermost.file_name, str), (
            f"Innermost frame should have file_name, got {innermost}"
        )
        assert isinstance(innermost.line, int), (
            f"Innermost frame should have line, got {innermost}"
        )


def test_metadata_simple():
    @guppy
    def main() -> None:
        q0 = qubit()
        q1 = qubit()
        h(q0)
        cx(q1, q0)
        h(q1)
        result("c0", measure(q0).read())
        result("c1", measure(q1).read())

    hugr = compile_guppy_with_debug(main)
    validate_debug_info(hugr)
