import pytest
import gzip
import json

from selene_api_models.trace import (
    SCHEMA_VERSION,
    Trace,
    CustomEvent,
    OpaquePayload,
    GateEvent,
    UserProgramSource,
    RuntimeSource,
    ErrorModelSource,
    SimulatorSource,
    EventRecord,
)
from selene_sim.event_hooks import TraceStore, CircuitExtractor
from selene_sim.event_hooks.instruction_log import CustomOperation, QAlloc, BatchStart
from selene_api_models.trace_file import (
    TraceFileEvent,
    iter_trace_file,
    write_trace_file,
)


def write_trace(path, trace):
    write_trace_file(path, trace.events)


@pytest.mark.parametrize("data", [b"", b"\xff", b"\x00\x03\xff", b"x" * 70000])
@pytest.mark.parametrize(
    "source",
    [
        UserProgramSource(index=0),
        RuntimeSource(start_time=10, end_time=20),
        ErrorModelSource(index=0),
        SimulatorSource(index=0, duration_ns=123),
    ],
)
def test_custom_trace_files(tmp_path, data, source):
    trace = Trace(
        schema_version=SCHEMA_VERSION,
        events=[
            EventRecord(
                source=source,
                event=CustomEvent(payload=OpaquePayload(tag=2**64 - 1, data=data)),
            ),
            EventRecord(
                source=source,
                event=GateEvent(gate_name="QAlloc", qubits=[7], params=[]),
            ),
        ],
    )
    path = tmp_path / "trace.jsonl.gz"
    write_trace(path, trace)
    store = TraceStore()
    extractor = CircuitExtractor(store)
    extractor.on_new_shot()
    assert extractor.try_invoke("TRACE", [str(path)])
    shot = extractor.shots[0]
    assert shot.trace is store.shots[0]
    assert shot.get_trace() == trace
    instructions = [
        entry for entry in shot if not isinstance(entry.operation, BatchStart)
    ]
    assert instructions[0].operation == CustomOperation(tag=2**64 - 1, data=data)
    assert instructions[1].operation == QAlloc(qubit=7)
    # The store owns a compressed copy, so we can still load the trace after
    # the backend artifacts have been removed.
    path.unlink()
    assert shot.get_trace() == trace


def test_trace_chunks_and_shots_are_separate(tmp_path):
    store = TraceStore()
    store.on_new_shot()
    for index in range(2):
        trace = Trace(
            schema_version=SCHEMA_VERSION,
            events=[
                EventRecord(
                    source=UserProgramSource(index=index),
                    event=GateEvent(gate_name="QAlloc", qubits=[index]),
                )
            ],
        )
        path = tmp_path / f"{index}.jsonl.gz"
        write_trace(path, trace)
        assert store.try_invoke("TRACE", [str(path)])
    store.on_new_shot()
    assert [len(list(trace.iter_events())) for trace in store.shots] == [2, 0]
    assert [event.source.index for event in store.shots[0].iter_events()] == [0, 1]


@pytest.mark.parametrize(
    "contents", [None, "not json", '{"schema_version":"99.0.0","events":[]}']
)
def test_unreadable_trace_has_filename_context(tmp_path, contents):
    path = tmp_path / "broken.json"
    if contents is not None:
        path.write_text(contents)
    store = TraceStore()
    store.on_new_shot()
    with pytest.raises(ValueError, match="broken.json"):
        store.try_invoke("TRACE", [str(path)])
        list(store.shots[0].iter_events())


def test_interactive_trace_store():
    from selene_sim import Quest
    from selene_sim.interactive import InteractiveFullStack

    store = TraceStore()
    stack = InteractiveFullStack(simulator=Quest(), n_qubits=1, event_hook=store)
    first_trace = store.shots[0]
    q = stack.qalloc()
    stack.reset(q)
    assert stack.measure(q) is False
    stack.qfree(q)

    # Each interactive call flushes metadata. Those files should contain new
    # events, not repeated copies of the whole shot, and the stored trace should
    # grow in place as we make more calls.
    assert first_trace is store.shots[0]
    assert [
        record.source.index
        for record in first_trace.iter_events()
        if record.source.kind == "UserProgram"
    ] == list(range(5))
    files = sorted(stack.artifact_dir.glob("trace-*.jsonl.gz"))
    assert len(files) > 1
    assert sum(len(list(iter_trace_file(path))) for path in files) == len(
        list(first_trace.iter_events())
    )
    stack.next_shot()
    assert len(store.shots) == 2
    assert list(store.shots[1].iter_events()) == []
    assert store.shots[0] is first_trace


@pytest.mark.parametrize("data", [[], [42], ["a.json", "b.json"]])
def test_trace_record_requires_one_filename(data):
    store = TraceStore()
    store.on_new_shot()
    with pytest.raises(ValueError, match="one filename"):
        store.try_invoke("TRACE", data)


def test_instruction_metadata_is_not_a_gate(tmp_path):
    from selene_api_models.trace import MeasurementEvent
    from selene_api_models.trace_file import BatchStartRecord, BatchTiming
    from selene_sim.event_hooks.instruction_log import FutureRead, MeasureLeakedRequest

    boundary = BatchStartRecord(batch_start=BatchTiming(start_time=0, end_time=0))
    read = TraceFileEvent(
        source=UserProgramSource(index=0),
        event=MeasurementEvent(qubit=3),
        instruction="FutureRead",
    )
    leaked = TraceFileEvent(
        source=UserProgramSource(index=1),
        event=MeasurementEvent(qubit=4),
        instruction="MeasureLeakedRequest",
    )
    path = tmp_path / "instructions.jsonl.gz"
    write_trace_file(path, [boundary, boundary, read, leaked])
    with TraceStore() as store:
        extractor = CircuitExtractor(store)
        extractor.on_new_shot()
        extractor.try_invoke("TRACE", [str(path)])
        shot = extractor.shots[0]
        assert [instruction.operation for instruction in shot] == [
            BatchStart(0, 0),
            BatchStart(0, 0),
            FutureRead(3),
            MeasureLeakedRequest(4),
        ]
        # The instruction view needs the distinctions, but the public trace
        # must match the old representation: just two measurement events.
        assert shot.get_trace() == Trace(
            schema_version=SCHEMA_VERSION, events=[read.as_event(), leaked.as_event()]
        )


def test_loading_is_lazy_and_iteration_is_repeatable(tmp_path, monkeypatch):
    record = EventRecord(
        source=UserProgramSource(index=0),
        event=GateEvent(gate_name="QAlloc", qubits=[0]),
    )
    path = tmp_path / "lazy.jsonl.gz"
    write_trace(path, Trace(schema_version=SCHEMA_VERSION, events=[record, record]))
    validate = TraceFileEvent.as_event
    calls = []

    def counted_validate(data):
        calls.append(data)
        return validate(data)

    monkeypatch.setattr(TraceFileEvent, "as_event", counted_validate)
    with TraceStore() as store:
        store.on_new_shot()
        store.try_invoke("TRACE", [str(path)])
        assert calls == []
        shot = store.shots[0]
        events = shot.iter_events()
        assert next(events) == record
        assert len(calls) == 1
        events.close()
        assert list(shot.iter_events()) == [record, record]
        assert len(calls) == 3
        assert shot.get_trace() == shot.get_trace()
        assert len(calls) == 7
        saved = shot._files[0][0]
    assert not saved.exists()
    with pytest.raises(ValueError, match="lazy.jsonl.gz"):
        list(shot.iter_events())


@pytest.mark.parametrize(
    "damage", ["header", "schema", "event", "newline", "truncated_gzip", "checksum"]
)
def test_bad_compressed_trace_has_context(tmp_path, damage):
    path = tmp_path / "damaged.jsonl.gz"
    header = {
        "format": "selene.trace.jsonl",
        "format_version": 1,
        "schema_version": SCHEMA_VERSION,
    }
    if damage == "header":
        header["format_version"] = 99
    if damage == "schema":
        header["schema_version"] = "99.0.0"
    record = EventRecord(
        source=UserProgramSource(index=0),
        event=GateEvent(gate_name="QAlloc", qubits=[0]),
    )
    event = "not json" if damage == "event" else record.model_dump_json()
    contents = json.dumps(header) + "\n" + event + ("" if damage == "newline" else "\n")
    data = gzip.compress(contents.encode())
    if damage == "truncated_gzip":
        data = data[:-8]
    if damage == "checksum":
        data = data[:-8] + bytes([data[-8] ^ 1]) + data[-7:]
    path.write_bytes(data)
    with TraceStore() as store:
        store.on_new_shot()
        # Capturing a filename doesn't decode its contents. Errors should be
        # raised when we read the trace, with the original filename attached.
        store.try_invoke("TRACE", [str(path)])
        with pytest.raises(ValueError, match="damaged.jsonl.gz.*line"):
            list(store.shots[0].iter_events())
