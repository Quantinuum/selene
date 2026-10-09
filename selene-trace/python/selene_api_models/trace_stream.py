"""Gzipped MessagePack trace streams, separate from JSON trace documents.

Objects are concatenated without separators: a header, records, and a final
nil. Exhaust the reader to validate the end marker and gzip checksum.
"""

from collections.abc import Iterable, Iterator
import gzip
from pathlib import Path
from typing import Annotated, Literal
import zlib

import msgpack
from pydantic import BaseModel, ConfigDict, Field, TypeAdapter, model_validator

from .trace import SCHEMA_VERSION, MAX_SAFE_INTEGER, EventRecord, GateEvent, Source

FORMAT = "selene.trace.msgpack"
FORMAT_VERSION = 1


class TraceStreamEvent(EventRecord):
    """An event with instruction metadata that isn't part of the public trace."""

    instruction: Literal["FutureRead", "MeasureLeakedRequest"] | None = None

    def as_event(self) -> EventRecord:
        return EventRecord(source=self.source, event=self.event)


class BatchTiming(BaseModel):
    model_config = ConfigDict(extra="forbid")
    start_time: int = Field(strict=True, ge=0, le=2**64 - 1)
    end_time: int = Field(strict=True, ge=0, le=2**64 - 1)

    @model_validator(mode="after")
    def check_boundaries(self):
        if self.end_time < self.start_time:
            raise ValueError(
                "Batch end_time must be greater than or equal to start_time"
            )
        return self


class BatchStartRecord(BaseModel):
    model_config = ConfigDict(extra="forbid")
    batch_start: BatchTiming


class UIntInstructionRecord(BaseModel):
    """Instruction operands that need the full uint64 range, unlike JSON gates."""

    model_config = ConfigDict(extra="forbid")
    source: Source
    uint_instruction: Literal["GlobalBarrier", "LocalBarrier", "ClassicalDelay"]
    value: int = Field(strict=True, ge=0, le=2**64 - 1)
    qubits: list[Annotated[int, Field(strict=True, ge=0, le=2**64 - 1)]] = Field(
        default_factory=list
    )

    def as_event(self) -> EventRecord:
        if self.value > MAX_SAFE_INTEGER:
            raise ValueError(
                f"{self.uint_instruction} operand {self.value} cannot be represented "
                f"in trace schema {SCHEMA_VERSION}; use the instruction records instead"
            )
        return EventRecord(
            source=self.source,
            event=GateEvent(
                gate_name=self.uint_instruction, qubits=self.qubits, params=[self.value]
            ),
        )


TraceStreamRecord = TraceStreamEvent | BatchStartRecord | UIntInstructionRecord
_record_adapter: TypeAdapter[TraceStreamRecord] = TypeAdapter(TraceStreamRecord)


def _header() -> dict:
    return {
        "format": FORMAT,
        "format_version": FORMAT_VERSION,
        "schema_version": SCHEMA_VERSION,
    }


def _unique_map(pairs: list[tuple]) -> dict:
    result = {}
    for key, value in pairs:
        if not isinstance(key, str):
            raise ValueError("Expected a string map key")
        if key in result:
            raise ValueError(f"Duplicate map key: {key!r}")
        result[key] = value
    return result


def iter_trace_stream_records(path: str | Path) -> Iterator[TraceStreamRecord]:
    """Read lazily without caching records or accepting JSON document formats."""
    path = Path(path)
    record_number = 0
    try:
        with gzip.open(path, "rb") as source:
            unpacker = msgpack.Unpacker(
                source, raw=False, object_pairs_hook=_unique_map
            )
            missing = object()
            header = next(unpacker, missing)
            if (
                not isinstance(header, dict)
                or header != _header()
                or type(header.get("format_version")) is not int
            ):
                raise ValueError("Unsupported or incomplete trace stream header")
            while True:
                record_number += 1
                item = next(unpacker, missing)
                if item is missing:
                    raise ValueError(
                        "Incomplete trace stream: missing end marker or partial record"
                    )
                if item is None:
                    # Unpacker can silently stop at a partial trailing object.
                    # Check its buffered bytes as well as the gzip reader so we
                    # reject every trailing byte and still verify the trailer.
                    if unpacker.tell() != source.tell() or source.read(1):
                        raise ValueError("Data after trace stream end marker")
                    return
                payload = (
                    item.get("event", {}).get("payload", {})
                    if isinstance(item, dict) and isinstance(item.get("event"), dict)
                    else {}
                )
                if isinstance(payload, dict) and payload.get("kind") == "OpaquePayload":
                    if type(payload.get("tag")) is not int or not isinstance(
                        payload.get("data"), bytes
                    ):
                        raise ValueError(
                            "OpaquePayload requires a native integer tag and binary data"
                        )
                yield _record_adapter.validate_python(item)
    except FileNotFoundError as error:
        raise ValueError(
            f"Trace stream {str(path)!r} is no longer available. Its run directory "
            "may have been deleted or cleaned up by the operating system. "
            "Keep the run directory until you have finished reading its traces."
        ) from error
    except (
        OSError,
        EOFError,
        ValueError,
        TypeError,
        zlib.error,
        msgpack.UnpackException,
    ) as error:
        raise ValueError(
            f"Could not read trace stream {str(path)!r} at record {record_number}: {error}"
        ) from error


def iter_trace_stream(path: str | Path) -> Iterator[EventRecord]:
    for record in iter_trace_stream_records(path):
        if isinstance(record, (TraceStreamEvent, UIntInstructionRecord)):
            yield record.as_event()


def write_trace_stream(
    path: str | Path,
    events: Iterable[EventRecord | BatchStartRecord | UIntInstructionRecord],
) -> None:
    """Write incrementally to a new file; publish it only after this succeeds.

    If producing or writing a record fails, the caller owns removal of the
    partial output. There will be no successful-completion marker in it.
    """
    packer = msgpack.Packer(use_bin_type=True)
    with gzip.open(path, "xb", compresslevel=1) as output:
        output.write(packer.pack(_header()))
        for event in events:
            output.write(
                packer.pack(event.model_dump(mode="python", exclude_none=True))
            )
        output.write(packer.pack(None))
