"""The file framing is shared by the Rust and Python APIs, independently of Selene."""

import gzip
import json
from pathlib import Path

import pytest

from selene_api_models.trace import EventRecord, Trace, SCHEMA_VERSION
from selene_api_models.trace_file import (
    BatchStartRecord,
    BatchTiming,
    TraceFileEvent,
    iter_trace_file,
    iter_trace_records,
    write_trace_file,
)

EXAMPLE = Path(__file__).resolve().parents[2] / "rust/tests/fixtures/events.jsonl"


def test_shared_example_and_writer_round_trip(tmp_path):
    source = tmp_path / "example.jsonl.gz"
    source.write_bytes(gzip.compress(EXAMPLE.read_bytes()))
    events = list(iter_trace_file(source))
    assert len(events) == 3
    assert events[0].event.payload.tag == 2**64 - 1
    assert events[0].event.payload.data == b"\x00\xff"
    output = tmp_path / "written.jsonl.gz"
    write_trace_file(output, iter(events))
    assert list(iter_trace_file(output)) == events
    assert list(iter_trace_file(output)) == events
    with pytest.raises(FileExistsError):
        write_trace_file(output, [])
    assert list(iter_trace_file(output)) == events


def test_empty_trace_and_legacy_document(tmp_path):
    path = tmp_path / "empty.jsonl.gz"
    write_trace_file(path, [])
    assert list(iter_trace_file(path)) == []
    legacy = tmp_path / "trace.json"
    legacy.write_text(Trace(schema_version=SCHEMA_VERSION, events=[]).model_dump_json())
    assert list(iter_trace_file(legacy)) == []


def test_event_parsing_is_lazy(tmp_path):
    header, first, *_ = EXAMPLE.read_text().splitlines()
    path = tmp_path / "lazy.jsonl.gz"
    path.write_bytes(gzip.compress(f"{header}\n{first}\nnot json\n".encode()))
    events = iter_trace_file(path)
    assert next(events) == EventRecord.model_validate_json(first)
    with pytest.raises(ValueError, match="lazy.jsonl.gz.*line 3"):
        next(events)


@pytest.mark.parametrize(
    "damage",
    [
        "header",
        "schema",
        "event",
        "newline",
        "truncated_gzip",
        "checksum",
        "header_newline",
    ],
)
def test_invalid_file_has_context(tmp_path, damage):
    lines = EXAMPLE.read_text().splitlines()
    header = json.loads(lines[0])
    if damage == "header":
        header["format_version"] = 99
    if damage == "schema":
        header["schema_version"] = "99.0.0"
    event = "not json" if damage == "event" else lines[1]
    contents = json.dumps(header) + "\n" + event + ("" if damage == "newline" else "\n")
    if damage == "header_newline":
        contents = json.dumps(header)
    data = gzip.compress(contents.encode())
    if damage == "truncated_gzip":
        data = data[:-8]
    if damage == "checksum":
        data = data[:-8] + bytes([data[-8] ^ 1]) + data[-7:]
    path = tmp_path / "damaged.jsonl.gz"
    path.write_bytes(data)
    with pytest.raises(ValueError, match="damaged.jsonl.gz.*line"):
        list(iter_trace_file(path))


def test_writer_consumes_generator_incrementally(tmp_path):
    path = tmp_path / "partial.jsonl.gz"
    event = EventRecord.model_validate_json(EXAMPLE.read_text().splitlines()[1])

    def events():
        # Opening the destination happens before requesting events, so the
        # writer can't be collecting the generator into an intermediate list.
        assert path.exists()
        yield event
        raise RuntimeError("producer failed")

    with pytest.raises(RuntimeError, match="producer failed"):
        write_trace_file(path, events())


def test_instruction_metadata_does_not_change_trace_events(tmp_path):
    event = EventRecord.model_validate(
        {
            "source": {"kind": "UserProgram", "index": 0},
            "event": {"kind": "Measurement", "qubit": 3},
        }
    )
    boundary = BatchStartRecord(batch_start=BatchTiming(start_time=0, end_time=0))
    records = [
        boundary,
        boundary,
        TraceFileEvent(
            source=event.source,
            event=event.event,
            instruction="FutureRead",
        ),
    ]
    path = tmp_path / "metadata.jsonl.gz"
    write_trace_file(path, records)
    assert list(iter_trace_records(path)) == records
    actual = list(iter_trace_file(path))
    assert actual == [event]
    assert actual[0].model_dump() == event.model_dump()
