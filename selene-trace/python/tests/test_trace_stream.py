"""Trace streams preserve models without using JSON as an intermediate format."""

import gzip
import json
from pathlib import Path

import msgpack
import pytest

from selene_api_models.trace import (
    CustomEvent,
    EventRecord,
    OpaquePayload,
    UserProgramSource,
)
from selene_api_models.trace_stream import (
    BatchStartRecord,
    BatchTiming,
    FORMAT,
    FORMAT_VERSION,
    TraceStreamEvent,
    iter_trace_stream,
    iter_trace_stream_records,
    write_trace_stream,
)


def header():
    return {
        "format": FORMAT,
        "format_version": FORMAT_VERSION,
        "schema_version": "0.1.0",
    }


@pytest.mark.parametrize("start,end", [(0, 0), (1, 1), (0, 2**64 - 1)])
def test_batch_timing_accepts_ordered_boundaries(start, end):
    assert BatchTiming(start_time=start, end_time=end).end_time == end


def test_reversed_batch_timing_is_rejected(tmp_path):
    with pytest.raises(ValueError, match="end_time"):
        BatchTiming(start_time=2, end_time=1)
    path = tmp_path / "reversed.msgpack.gz"
    with gzip.open(path, "wb") as output:
        for item in [header(), {"batch_start": {"start_time": 2, "end_time": 1}}, None]:
            output.write(msgpack.packb(item))
    with pytest.raises(ValueError, match="(?s)record 1.*end_time"):
        list(iter_trace_stream_records(path))


@pytest.mark.parametrize("location", ["header", "record", "nested"])
def test_duplicate_map_keys_are_rejected(tmp_path, location):
    pack = msgpack.packb

    def map_pairs(pairs):
        return msgpack.Packer().pack_map_header(len(pairs)) + b"".join(
            pack(k) + v for k, v in pairs
        )

    head = pack(header())
    record = pack({"batch_start": {"start_time": 0, "end_time": 1}})
    if location == "header":
        head = map_pairs(
            [(k, pack(v)) for k, v in header().items()] + [("format", pack(FORMAT))]
        )
    elif location == "record":
        record = map_pairs(
            [("batch_start", pack({"start_time": 0, "end_time": 1}))] * 2
        )
    else:
        record = map_pairs(
            [
                (
                    "batch_start",
                    map_pairs(
                        [
                            ("start_time", pack(0)),
                            ("end_time", pack(0)),
                            ("end_time", pack(1)),
                        ]
                    ),
                )
            ]
        )
    path = tmp_path / "duplicate.msgpack.gz"
    path.write_bytes(gzip.compress(head + record + pack(None)))
    with pytest.raises(ValueError, match="Duplicate map key"):
        list(iter_trace_stream_records(path))


def event(data=b"\x00\xff", tag=2**64 - 1):
    return EventRecord(
        source=UserProgramSource(index=0),
        event=CustomEvent(payload=OpaquePayload(tag=tag, data=data)),
    )


@pytest.mark.parametrize(
    "data", [b"", b"\x00\xff", b"x" * 70000], ids=["empty", "binary", "70kb"]
)
def test_native_payloads_and_repeatable_round_trip(tmp_path, data):
    path = tmp_path / "trace.msgpack.gz"
    original = event(data)
    write_trace_stream(path, [original])
    with gzip.open(path, "rb") as source:
        objects = list(msgpack.Unpacker(source, raw=False))
    assert objects[0] == header()
    assert objects[1]["event"]["payload"] == {
        "kind": "OpaquePayload",
        "tag": 2**64 - 1,
        "data": data,
    }
    assert objects[2] is None
    assert list(iter_trace_stream(path)) == [original]
    assert list(iter_trace_stream(path)) == [original]
    with pytest.raises(FileExistsError):
        write_trace_stream(path, [])


def test_empty_stream_and_instruction_metadata(tmp_path):
    path = tmp_path / "empty.msgpack.gz"
    write_trace_stream(path, [])
    assert list(iter_trace_stream_records(path)) == []
    boundary = BatchStartRecord(
        batch_start=BatchTiming(start_time=0, end_time=2**64 - 1)
    )
    record = TraceStreamEvent.model_validate(event().model_dump())
    path = tmp_path / "metadata.msgpack.gz"
    write_trace_stream(path, [boundary, boundary, record])
    assert list(iter_trace_stream_records(path)) == [boundary, boundary, record]
    assert list(iter_trace_stream(path)) == [event()]


@pytest.mark.parametrize(
    "damage",
    [
        "header",
        "version",
        "schema",
        "bool_version",
        "missing_end",
        "partial_record",
        "partial_after_end",
        "after_end",
        "checksum",
        "truncated_gzip",
        "text_payload",
        "extension",
        "event",
    ],
)
def test_invalid_stream_has_path_and_record_context(tmp_path, damage):
    metadata = header()
    record = event().model_dump(mode="python")
    if damage == "header":
        metadata["format"] = "wrong"
    if damage == "version":
        metadata["format_version"] = 99
    if damage == "bool_version":
        metadata["format_version"] = True
    if damage == "schema":
        metadata["schema_version"] = "99.0.0"
    if damage == "text_payload":
        record["event"]["payload"]["data"] = "AP8="
    if damage == "event":
        record = {"source": "wrong"}
    if damage == "extension":
        record = msgpack.ExtType(1, b"x")
    contents = msgpack.packb(metadata) + msgpack.packb(record, use_bin_type=True)
    if damage == "partial_record":
        contents += b"\x81"
    elif damage != "missing_end":
        contents += b"\xc0"
    if damage == "partial_after_end":
        contents += b"\x81"
    if damage == "after_end":
        contents += b"\xc0"
    data = gzip.compress(contents)
    if damage == "checksum":
        data = data[:-8] + bytes([data[-8] ^ 1]) + data[-7:]
    if damage == "truncated_gzip":
        data = data[:-8]
    path = tmp_path / "broken.msgpack.gz"
    path.write_bytes(data)
    with pytest.raises(ValueError, match="broken.msgpack.gz.*record"):
        list(iter_trace_stream_records(path))


def test_event_validation_is_lazy(tmp_path):
    path = tmp_path / "lazy.msgpack.gz"
    path.write_bytes(
        gzip.compress(
            msgpack.packb(header())
            + msgpack.packb(event().model_dump())
            + msgpack.packb({"bad": "record"})
            + b"\xc0"
        )
    )
    events = iter_trace_stream(path)
    assert next(events) == event()
    with pytest.raises(ValueError, match="record 2"):
        next(events)


def test_failed_producer_cannot_leave_a_valid_stream(tmp_path):
    path = tmp_path / "partial.msgpack.gz"

    def events():
        assert path.exists()
        yield event()
        raise RuntimeError("producer failed")

    with pytest.raises(RuntimeError, match="producer failed"):
        write_trace_stream(path, events())
    # gzip's context manager still writes a valid trailer during unwinding.
    # The absent MessagePack end marker tells us this wasn't a complete stream.
    with pytest.raises(ValueError, match="missing end marker"):
        list(iter_trace_stream(path))


@pytest.mark.parametrize("compressed", [False, True])
def test_json_is_not_a_trace_stream(tmp_path, compressed):
    path = tmp_path / "not-a-stream"
    contents = json.dumps({"schema_version": "0.1.0", "events": []}).encode()
    path.write_bytes(gzip.compress(contents) if compressed else contents)
    with pytest.raises(ValueError):
        list(iter_trace_stream(path))


def test_shared_messagepack_fixture(tmp_path):
    fixture = (
        Path(__file__).resolve().parents[2]
        / "rust/tests/fixtures/trace-stream.msgpack.hex"
    )
    contents = bytes.fromhex(fixture.read_text())
    path = tmp_path / "shared.msgpack.gz"
    path.write_bytes(gzip.compress(contents))
    assert list(iter_trace_stream(path)) == [event()]
    written = tmp_path / "written.msgpack.gz"
    write_trace_stream(written, [event()])
    assert gzip.decompress(written.read_bytes()) == contents
