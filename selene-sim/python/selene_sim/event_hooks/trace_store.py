"""Keep trace artifacts on disk and read their events only when requested."""

from collections.abc import Iterator
from pathlib import Path
import shutil
from tempfile import TemporaryDirectory

from selene_api_models.trace import SCHEMA_VERSION, EventRecord, Trace
from selene_api_models.trace_file import TraceFileEvent, TraceRecord, iter_trace_records

from .event_hook import EventHook


class ShotTrace:
    """A repeatable, uncached view over one shot's trace files."""

    def __init__(self, directory: TemporaryDirectory) -> None:
        # Keeping the directory alive here allows a shot view to outlive its
        # store. Explicitly closing the store still invalidates its shot views.
        self._directory = directory
        self._files: list[tuple[Path, Path]] = []

    def iter_records(self) -> Iterator[TraceRecord]:
        for saved, original in self._files:
            try:
                yield from iter_trace_records(saved)
            except ValueError as error:
                raise ValueError(
                    f"Trace artifact {str(original)!r}: {error}"
                ) from error

    def iter_events(self) -> Iterator[EventRecord]:
        for record in self.iter_records():
            if isinstance(record, TraceFileEvent):
                yield record.as_event()

    def get_trace(self) -> Trace:
        """Materialise a trace without keeping an implicit in-memory cache."""
        return Trace(schema_version=SCHEMA_VERSION, events=list(self.iter_events()))


class TraceStore(EventHook):
    """Own compressed artifacts per shot, without eagerly decoding their events.

    Files are copied while processing result records so lazy access survives
    removal of the run directory. Call close() to release those copies, or use
    the store as a context manager. Event validation happens during iteration.
    """

    def __init__(self) -> None:
        self._directory = TemporaryDirectory(prefix="selene-traces-")
        self._closed = False
        self.shots: list[ShotTrace] = []
        self._file_index = 0

    def close(self) -> None:
        self._closed = True
        self._directory.cleanup()

    def __enter__(self) -> "TraceStore":
        if self._closed:
            raise ValueError("TraceStore is closed")
        return self

    def __exit__(self, *_args) -> None:
        self.close()

    def get_selene_flags(self) -> list[str]:
        return ["provide_trace"]

    def on_new_shot(self) -> None:
        if self._closed:
            raise ValueError("TraceStore is closed")
        self.shots.append(ShotTrace(self._directory))

    def try_invoke(self, tag: str, data: list) -> bool:
        if tag != "TRACE":
            return False
        if self._closed:
            raise ValueError("TraceStore is closed")
        if len(data) != 1 or not isinstance(data[0], str):
            raise ValueError("Expected TRACE to contain one filename")
        if not self.shots:
            raise ValueError("Received a trace file before the start of a shot")
        original = Path(data[0])
        saved = Path(self._directory.name) / f"{self._file_index}{original.suffix}"
        self._file_index += 1
        try:
            shutil.copyfile(original, saved)
        except OSError as error:
            saved.unlink(missing_ok=True)
            raise ValueError(
                f"Could not copy trace file {str(original)!r}: {error}"
            ) from error
        self.shots[-1]._files.append((saved, original))
        return True
