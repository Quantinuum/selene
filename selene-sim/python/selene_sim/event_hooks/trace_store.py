"""Track backend trace streams and read their events only when requested."""

from collections.abc import Iterator
from pathlib import Path

from selene_api_models.trace import EventRecord, Trace
from selene_api_models.trace_stream import (
    TraceStreamEvent,
    TraceStreamRecord,
    iter_trace_stream_records,
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
            if isinstance(record, TraceStreamEvent):
                yield record.as_event()

    def get_trace(self) -> Trace:
        """Materialise a trace without keeping an implicit in-memory cache."""
        return Trace(schema_version="0.1.0", events=list(self.iter_events()))


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
