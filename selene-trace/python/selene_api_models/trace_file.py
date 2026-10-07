"""Read and write the gzipped JSON Lines trace transport.

The framing version is separate from the EventRecord schema version. Reading
is lazy: exhaust the iterator to validate all events and the gzip checksum.
"""

from collections.abc import Iterable, Iterator
import gzip
import json
from pathlib import Path
from typing import Literal
import zlib
from pydantic import BaseModel, ConfigDict, Field, TypeAdapter

from .trace import SCHEMA_VERSION, EventRecord, parse_trace_json

FORMAT = "selene.trace.jsonl"
FORMAT_VERSION = 1


class TraceFileEvent(EventRecord):
    """An event with optional instruction metadata, outside the trace schema."""

    instruction: Literal["FutureRead", "MeasureLeakedRequest"] | None = None

    def as_event(self) -> EventRecord:
        return EventRecord(source=self.source, event=self.event)


class BatchTiming(BaseModel):
    model_config = ConfigDict(extra="forbid")
    start_time: int = Field(strict=True, ge=0, le=2**64 - 1)
    end_time: int = Field(strict=True, ge=0, le=2**64 - 1)


class BatchStartRecord(BaseModel):
    """A file-level boundary, not a gate or an EventRecord."""

    model_config = ConfigDict(extra="forbid")
    batch_start: BatchTiming


TraceRecord = TraceFileEvent | BatchStartRecord
_record_adapter: TypeAdapter[TraceRecord] = TypeAdapter(TraceRecord)


def _header() -> dict:
    return {
        "format": FORMAT,
        "format_version": FORMAT_VERSION,
        "schema_version": SCHEMA_VERSION,
    }


def iter_trace_records(path: str | Path) -> Iterator[TraceRecord]:
    """Read file records, including instruction metadata when present."""
    path = Path(path)
    line_number = 0
    try:
        if path.suffix != ".gz":
            for record in parse_trace_json(path.read_bytes()).events:
                yield TraceFileEvent(source=record.source, event=record.event)
            return
        with gzip.open(path, "rb") as source:
            line_number = 1
            header_line = source.readline()
            if not header_line.endswith(b"\n"):
                raise ValueError("Incomplete trace header")
            header = json.loads(header_line)
            if (
                not isinstance(header, dict)
                or header != _header()
                or type(header.get("format_version")) is not int
            ):
                raise ValueError(f"Unsupported trace file header: {header!r}")
            for line_number, line in enumerate(source, start=2):
                if not line.endswith(b"\n"):
                    raise ValueError("Incomplete event line")
                yield _record_adapter.validate_json(line)
    except (OSError, EOFError, ValueError, TypeError, zlib.error) as error:
        raise ValueError(
            f"Could not read trace file {str(path)!r} at line {line_number}: {error}"
        ) from error


def iter_trace_file(path: str | Path) -> Iterator[EventRecord]:
    """Read public trace events, excluding file-level instruction metadata."""
    for record in iter_trace_records(path):
        if isinstance(record, TraceFileEvent):
            yield record.as_event()


def write_trace_file(
    path: str | Path, events: Iterable[EventRecord | BatchStartRecord]
) -> None:
    """Write events incrementally to a new .jsonl.gz file.

    Existing files are never overwritten. Callers should only publish the path
    after this returns successfully, and remove the partial file if it fails.
    The event iterable is not collected or cached.
    """
    with gzip.open(path, "xb", compresslevel=1) as output:
        output.write((json.dumps(_header()) + "\n").encode())
        for event in events:
            output.write(event.model_dump_json(exclude_none=True).encode())
            output.write(b"\n")
