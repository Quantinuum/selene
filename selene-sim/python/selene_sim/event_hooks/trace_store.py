"""Track backend trace streams and read their events only when requested."""

from collections.abc import Iterator
from pathlib import Path

from selene_formats.trace import SCHEMA_VERSION, MAX_SAFE_INTEGER, EventRecord, Trace
from selene_formats.trace_stream import (
    TraceStreamEvent,
    UIntInstructionRecord,
    TraceStreamRecord,
    iter_trace_stream_records,
    read_trace_stream_header,
)

from .event_hook import EventHook


class ShotTrace:
    """A repeatable, uncached view over one shot's trace streams."""

    def __init__(self) -> None:
        self._files: list[Path] = []

    def iter_records(self) -> Iterator[TraceStreamRecord]:
        for path in self._files:
            yield from iter_trace_stream_records(path)

    def iter_events(self) -> Iterator[EventRecord]:
        for record in self.iter_records():
            if isinstance(record, (TraceStreamEvent, UIntInstructionRecord)):
                yield record.as_event()

    @property
    def shot(self) -> int | None:
        """Read the shot identity from the available stream headers."""
        numbers = {
            number
            for path in self._files
            if (number := read_trace_stream_header(path).shot) is not None
        }
        if len(numbers) > 1:
            raise ValueError("Trace streams contain inconsistent shot numbers")
        return next(iter(numbers), None)

    def get_trace(self) -> Trace:
        """Materialise a trace without keeping an implicit in-memory cache."""
        shot = self.shot
        if shot is not None and shot > MAX_SAFE_INTEGER:
            raise ValueError(
                f"shot {shot} cannot be represented in trace schema "
                f"{SCHEMA_VERSION}; use the stream metadata instead"
            )
        return Trace(
            schema_version=SCHEMA_VERSION,
            shot=shot,
            events=list(self.iter_events()),
        )


class TraceStore(EventHook):
    """Keep references to each shot's backend trace streams.

    No files are read, copied or deleted when a result record arrives. The run's
    artifacts must remain available while iterating or materialising traces.
    """

    def __init__(self) -> None:
        self.shots: list[ShotTrace] = []

    def get_selene_flags(self) -> list[str]:
        return ["provide_trace"]

    def on_new_shot(self) -> None:
        self.shots.append(ShotTrace())

    def try_invoke(self, tag: str, data: list) -> bool:
        if tag != "TRACE":
            return False
        if len(data) != 1 or not isinstance(data[0], str):
            raise ValueError("Expected TRACE to contain one filename")
        if not self.shots:
            raise ValueError("Received a trace stream before the start of a shot")
        self.shots[-1]._files.append(Path(data[0]))
        return True
