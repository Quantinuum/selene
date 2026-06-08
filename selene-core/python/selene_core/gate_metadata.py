"""
Utilities for working with gate metadata in the Selene trace.

Currently, this metadata includes:
- Source code location (optionally w/ multiple bt frames)
"""

import msgpack

from .trace import (
    CustomEvent,
    EventRecord,
    SrcLocation,
    GateMetadata,
    GateEvent,
    MeasurementEvent,
    OpaquePayload,
    ResetEvent,
    Trace,
)

#: Tag value used to identify custom operations carrying backtrace metadata.
#: Must match ``selene_core::metadata::DEBUG_INFO_TAG`` in the Rust crate.
DEBUG_INFO_TAG: int = 0x6FCFC512E44136EB


def _is_debug_info_event(record: EventRecord) -> bool:
    """Return True if *record* is a DEBUG_INFO_TAG custom event."""
    return (
        isinstance(record.event, CustomEvent)
        and isinstance(record.event.payload, OpaquePayload)
        and record.event.payload.tag == DEBUG_INFO_TAG
    )


def _parse_int_or_none(value: str) -> int | None:
    """Parse an integer from a string, returning None for '<none>' or unparseable values."""
    try:
        return int(value)
    except (ValueError, TypeError):
        return None


def _parse_debug_info(record: EventRecord) -> GateMetadata:
    """Deserialise a DEBUG_INFO_TAG custom event payload into a :class:`GateMetadata`."""
    assert isinstance(record.event, CustomEvent)
    assert isinstance(record.event.payload, OpaquePayload)
    raw = msgpack.unpackb(record.event.payload.data, raw=False)
    frames = [
        SrcLocation(
            function_name=frame["function_name"],
            file_name=frame["file_name"],
            line=_parse_int_or_none(frame["line"]),
            column=_parse_int_or_none(frame["column"]),
        )
        for frame in raw["frames"]
    ]
    return GateMetadata(frames=frames)


def resolve_debug_info(trace: Trace) -> Trace:
    """Transform a :class:`~selene_core.trace.Trace` by moving debug info into gate metadata.

    For each ``DEBUG_INFO_TAG`` custom event that immediately precedes a
    gate/measure/reset event, the debug info is deserialised and attached as
    the ``metadata`` field on the following event.  The debug info custom
    event is removed from the output.

    :raises ValueError: if two consecutive debug info events are encountered
        (which would indicate a malformed stream).
    """
    output_events: list[EventRecord] = []
    pending_metadata: GateMetadata | None = None

    for record in trace.events:
        if _is_debug_info_event(record):
            if pending_metadata is not None:
                raise ValueError(
                    "Two adjacent debug info events encountered in trace; "
                    "expected a gate/measure/reset between debug info entries."
                )
            pending_metadata = _parse_debug_info(record)
            continue

        if pending_metadata is not None:
            if isinstance(record.event, (GateEvent, MeasurementEvent, ResetEvent)):
                new_event = record.event.model_copy(
                    update={"metadata": pending_metadata}
                )
                output_events.append(EventRecord(source=record.source, event=new_event))
            else:
                # Debug info preceded a non-gate event; discard metadata and keep the event.
                output_events.append(record)
            pending_metadata = None
        else:
            output_events.append(record)

    return Trace(events=output_events)
