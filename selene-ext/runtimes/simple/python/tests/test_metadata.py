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
    CustomEvent,
    GateEvent,
    MeasurementEvent,
    OpaquePayload,
    ResetEvent,
)
from selene_core.gate_metadata import (
    DEBUG_INFO_TAG,
    resolve_debug_info,
)
from selene_core.testing import (
    compile_guppy_with_debug,
    validate_event_source_location,
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

    # Raw trace must contain at least one DEBUG_INFO_TAG custom event
    debug_info_events = [
        r
        for r in raw_trace.events
        if (
            isinstance(r.event, CustomEvent)
            and isinstance(r.event.payload, OpaquePayload)
            and r.event.payload.tag == DEBUG_INFO_TAG
        )
    ]
    assert len(debug_info_events) > 0, (
        "Expected at least one DEBUG_INFO_TAG custom event in raw trace"
    )

    # After resolve_debug_info, no DEBUG_INFO_TAG events should remain
    transformed_trace = resolve_debug_info(raw_trace)
    remaining_debug_events = [
        r
        for r in transformed_trace.events
        if (
            isinstance(r.event, CustomEvent)
            and isinstance(r.event.payload, OpaquePayload)
            and r.event.payload.tag == DEBUG_INFO_TAG
        )
    ]
    assert len(remaining_debug_events) == 0, (
        f"Expected no DEBUG_INFO_TAG events after transform, got {len(remaining_debug_events)}"
    )

    # At least some gates/measures should have metadata attached
    events_with_metadata = [
        r
        for r in transformed_trace.events
        if isinstance(r.event, (GateEvent, MeasurementEvent, ResetEvent))
        and r.event.metadata is not None
    ]
    assert len(events_with_metadata) > 0, (
        "Expected at least one gate/measure/reset with metadata after transform"
    )

    # QAlloc and QFree events must also carry backtrace metadata.
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

    # Validate structure of attached metadata
    for record in events_with_metadata:
        meta = record.event.metadata
        assert len(meta.frames) > 0, "Should not see metadata with no frames"
        assert any(frame.function_name is not None for frame in meta.frames), (
            "Should not see backtrace with no symbol names"
        )
        for frame in meta.frames:
            assert isinstance(frame.function_name, str)
            # file_name and line may be None for frames in libraries without
            # debug info (e.g. selene_helios_run). Only user-code frames are
            # guaranteed to have full source locations.
            assert isinstance(frame.file_name, (str, type(None)))
            assert isinstance(frame.line, (int, type(None)))
            assert isinstance(frame.column, (int, type(None)))

    # Validate that the innermost frame (user code) has full source info
    for record in events_with_metadata:
        innermost = record.event.metadata.frames[0]
        assert isinstance(innermost.file_name, str), (
            f"Innermost frame should have file_name, got {innermost}"
        )
        assert isinstance(innermost.line, int), (
            f"Innermost frame should have line, got {innermost}"
        )

    # Validate that innermost frames point to correct source operations
    for record in events_with_metadata:
        validate_event_source_location(record)


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
