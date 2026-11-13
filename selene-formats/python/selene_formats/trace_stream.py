"""Gzipped MessagePack trace streams, separate from JSON trace documents.

Objects are concatenated without separators: a header, records, and a final
nil. Exhaust the reader to validate the end marker and gzip checksum.
"""

from collections.abc import Generator, Iterable, Iterator
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


class TraceStreamHeader(BaseModel):
    """Stream metadata; shot numbers retain the full unsigned 64-bit range."""

    model_config = ConfigDict(extra="forbid")
    format: Literal["selene.trace.msgpack"] = "selene.trace.msgpack"
    format_version: Literal[1] = 1
    schema_version: Literal["0.1.0", "0.2.0"] = SCHEMA_VERSION
    shot: Annotated[int, Field(strict=True, ge=0, le=2**64 - 1)] | None = None

    @model_validator(mode="before")
    @classmethod
    def check_header(cls, value):
        if (
            not isinstance(value, dict)
            or not {"format", "format_version", "schema_version"} <= value.keys()
            or type(value.get("format_version")) is not int
            or ("shot" in value and type(value["shot"]) is not int)
        ):
            raise ValueError("Unsupported or incomplete trace stream header")
        return value


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


def _iter_trace_stream(
    path: str | Path,
) -> Generator[TraceStreamHeader | TraceStreamRecord, None, None]:
    path = Path(path)
    record_number = 0
    try:
        with gzip.open(path, "rb") as source:
            unpacker = msgpack.Unpacker(
                source, raw=False, object_pairs_hook=_unique_map
            )
            missing = object()
            header = next(unpacker, missing)
            metadata = TraceStreamHeader.model_validate(header)
            yield metadata
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
                record = _record_adapter.validate_python(item)
                if (
                    metadata.schema_version == "0.1.0"
                    and isinstance(record, TraceStreamEvent)
                    and record.event.kind in ("FutureRead", "FutureResult")
                ):
                    raise ValueError(
                        "FutureRead and FutureResult require trace schema 0.2.0"
                    )
                yield record
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


def read_trace_stream_header(path: str | Path) -> TraceStreamHeader:
    """Read only the metadata; this does not validate the rest of the stream."""
    stream = _iter_trace_stream(path)
    try:
        metadata = next(stream)
        assert isinstance(metadata, TraceStreamHeader)
        return metadata
    finally:
        stream.close()


def iter_trace_stream_records(path: str | Path) -> Iterator[TraceStreamRecord]:
    """Read lazily without caching records or accepting JSON document formats."""
    for record in _iter_trace_stream(path):
        if not isinstance(record, TraceStreamHeader):
            yield record


def iter_trace_stream(path: str | Path) -> Iterator[EventRecord]:
    for record in iter_trace_stream_records(path):
        if isinstance(record, (TraceStreamEvent, UIntInstructionRecord)):
            yield record.as_event()


def write_trace_stream(
    path: str | Path,
    events: Iterable[EventRecord | BatchStartRecord | UIntInstructionRecord],
    *,
    shot: int | None = None,
) -> None:
    """Write incrementally to a new file; publish it only after this succeeds.

    If producing or writing a record fails, the caller owns removal of the
    partial output. There will be no successful-completion marker in it.
    """
    metadata = _header()
    if shot is not None:
        metadata["shot"] = shot
    TraceStreamHeader.model_validate(metadata)
    packer = msgpack.Packer(use_bin_type=True)
    with gzip.open(path, "xb", compresslevel=1) as output:
        output.write(packer.pack(metadata))
        for event in events:
            record = event.model_dump(mode="python")
            if isinstance(event, TraceStreamEvent) and event.instruction is None:
                record.pop("instruction", None)
            output.write(packer.pack(record))
        output.write(packer.pack(None))
