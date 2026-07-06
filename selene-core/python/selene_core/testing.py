"""Shared test utilities for debug-info / backtrace metadata validation.

These helpers are used by any runtime plugin test that verifies source-location
metadata is correctly emitted and resolved. They provide:

- Gate-name sets for categorizing Rxy/Rzz operations
- Source-line validation against the expected gate type
- A ``compile_guppy_with_debug`` helper for enabling debug mode during compilation
"""

from __future__ import annotations

from guppylang_internals.debug_mode import turn_on_debug_mode, turn_off_debug_mode
from selene_core.trace import (
    GateEvent,
    MeasurementEvent,
    ResetEvent,
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
