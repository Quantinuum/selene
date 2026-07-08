"""Shared test utilities for debug-info / backtrace metadata validation.

These helpers are used by any runtime plugin test that verifies source-location
metadata is correctly emitted and resolved. They provide:

- Gate-name sets for categorizing Rxy/Rzz operations
- Source-line validation against the expected gate type
- A ``compile_guppy_with_debug`` helper for enabling debug mode during compilation
- A ``validate_debug_info_trace`` fixture that verifies a raw trace contains
  properly-formed debug info and that resolution produces correct metadata
"""

from __future__ import annotations

from guppylang_internals.debug_mode import turn_on_debug_mode, turn_off_debug_mode
from selene_core.gate_metadata import (
    DEBUG_INFO_TAG,
    DEBUG_MODULE_TAG,
    resolve_debug_info,
)
from selene_core.trace import (
    CustomEvent,
    GateEvent,
    MeasurementEvent,
    OpaquePayload,
    ResetEvent,
    Trace,
)

#: Single-qubit gate function names that compile to Rxy operations.
ONE_QUBIT_GATES: set[str] = {
    "h",
    "x",
    "y",
    "z",
    "s",
    "sdg",
    "t",
    "tdg",
    "v",
    "vdg",
    "ht",
    "rx",
    "ry",
    "rz",
    "phased_x",
}

#: Two-qubit gate function names that compile to Rzz operations.
TWO_QUBIT_GATES: set[str] = {
    "cx",
    "cy",
    "cz",
    "ch",
    "crz",
    "toffoli",
    "zz_phase",
    "zz_max",
}


def validate_event_source_location(record) -> None:
    """Check that the innermost debug info frame points to a source line consistent
    with the type of operation in the record.

    Skips validation when the innermost frame lacks a line number or file name
    (e.g. library frames without debug info).
    """
    frame = record.event.metadata.frames[0]
    if frame.line is None:
        return
    assert frame.line >= 1, f"frame.line must be >= 1, got {frame.line}"
    if frame.file_name is None:
        return
    with open(frame.file_name) as f:
        lines = f.readlines()
    source_line = lines[frame.line - 1]

    event = record.event
    if isinstance(event, MeasurementEvent):
        assert "measure" in source_line, (
            f"Expected 'measure' in source line for MeasurementEvent, got: {source_line!r}"
        )
    elif isinstance(event, ResetEvent):
        assert "qubit(" in source_line, (
            f"Expected 'qubit(' in source line for ResetEvent, got: {source_line!r}"
        )
    elif isinstance(event, GateEvent):
        if event.gate_name == "Rxy":
            assert any(f"{name}(" in source_line for name in ONE_QUBIT_GATES), (
                f"Expected a one-qubit gate call in source line for Rxy, got: {source_line!r}"
            )
        elif event.gate_name == "Rzz":
            assert any(f"{name}(" in source_line for name in TWO_QUBIT_GATES), (
                f"Expected a two-qubit gate call in source line for Rzz, got: {source_line!r}"
            )
        elif event.gate_name == "QAlloc":
            assert "qubit(" in source_line, (
                f"Expected 'qubit(' in source line for QAlloc, got: {source_line!r}"
            )


def compile_guppy_with_debug(program):
    """Compile a Guppy program with debug mode enabled.

    Wraps the compilation in turn_on_debug_mode/turn_off_debug_mode to ensure
    source location metadata is emitted in the HUGR.
    """
    turn_on_debug_mode()
    hugr = program.compile()
    turn_off_debug_mode()
    return hugr


def validate_debug_info_trace(raw_trace: Trace) -> Trace:
    """Validate that a raw trace contains debug info and that resolution works.

    Checks that:
    1. The raw trace contains at least one ``DEBUG_INFO_TAG`` custom event.
    2. After ``resolve_debug_info``, no ``DEBUG_INFO_TAG`` or ``DEBUG_MODULE_TAG``
       custom events remain.
    3. At least one gate/measure/reset event has metadata attached.
    4. All attached metadata has valid structure (non-empty frames with string
       function names, optional file/line/column).
    5. Each event's innermost frame points to a source line consistent with the
       operation type.

    Returns the transformed (resolved) trace for further assertions by the
    caller.
    """
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

    # After resolve_debug_info, no debug events should remain
    transformed_trace = resolve_debug_info(raw_trace)
    remaining_debug_events = [
        r
        for r in transformed_trace.events
        if (
            isinstance(r.event, CustomEvent)
            and isinstance(r.event.payload, OpaquePayload)
            and r.event.payload.tag in (DEBUG_INFO_TAG, DEBUG_MODULE_TAG)
        )
    ]
    assert len(remaining_debug_events) == 0, (
        f"Expected no debug info events after transform, got {len(remaining_debug_events)}"
    )

    # At least some gates/measures/resets should have metadata attached
    events_with_metadata = [
        r
        for r in transformed_trace.events
        if isinstance(r.event, (GateEvent, MeasurementEvent, ResetEvent))
        and r.event.metadata is not None
    ]
    assert len(events_with_metadata) > 0, (
        "Expected at least one gate/measure/reset with metadata after transform"
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
            assert isinstance(frame.file_name, (str, type(None)))
            assert isinstance(frame.line, (int, type(None)))
            assert isinstance(frame.column, (int, type(None)))

    # Validate that innermost frames point to correct source operations
    for record in events_with_metadata:
        validate_event_source_location(record)

    return transformed_trace
