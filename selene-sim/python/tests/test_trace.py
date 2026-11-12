from textwrap import dedent
import base64
from gzip import compress, decompress
import json
from typing import Literal
import pytest
from pydantic import BaseModel, ConfigDict

from selene_core.trace import (
    SCHEMA_VERSION,
    Trace,
    GateEvent,
    parse_trace,
    parse_trace_json,
)
from selene_formats.trace import Trace as VersionedTrace

from selene_sim import Stim, DepolarizingErrorModel, SimpleRuntime, SoftRZRuntime
from selene_sim.build import build
from selene_sim.event_hooks import CircuitExtractor
from selene_sim.event_hooks.instruction_log import QAlloc, QFree, Source
from selene_sim.interactive import InteractiveFullStack
from selene_formats.trace import (
    CustomEvent,
    EventRecord,
    OpaquePayload,
    UserProgramSource,
)
from selene_formats.trace_stream import write_trace_stream


@pytest.mark.parametrize("tag", [42, 2**64 - 1])
@pytest.mark.parametrize("data", [b"", b"\xfb\xff"])
def test_trace_metadata_round_trip(tmp_path, tag, data):
    class DownstreamTrace(BaseModel):
        model_config = ConfigDict(extra="forbid")
        schema_version: Literal["0.2.0"]
        events: list[dict]

    class Shot(BaseModel):
        index: int
        trace: DownstreamTrace

    class TraceContainer(BaseModel):
        version: Literal[1]
        shots: list[Shot]

    extractor = CircuitExtractor()
    extractor.on_new_shot()
    path = tmp_path / "trace.msgpack.gz"
    write_trace_stream(
        path,
        [
            EventRecord(
                source=UserProgramSource(index=0),
                event=CustomEvent(payload=OpaquePayload(tag=tag, data=data)),
            )
        ],
    )
    extractor.try_invoke("TRACE", [str(path)])
    trace = extractor.shots[0].get_trace()
    stringified_trace = trace.model_dump_json(indent=2)
    metadata = (
        f'{{"version": 1, "shots": [{{"index": 0, "trace": {stringified_trace}}}]}}'
    )

    document = json.loads(stringified_trace)
    assert set(document) == {"schema_version", "events"}
    assert document["events"][0]["event"]["payload"]["tag"] == f"0x{tag:X}"
    assert document["schema_version"] == SCHEMA_VERSION
    container = TraceContainer.model_validate_json(metadata)
    assert (
        base64.urlsafe_b64decode(
            container.shots[0].trace.events[0]["event"]["payload"]["data"]
        )
        == data
    )

    encoded_metadata = metadata.encode("utf-8")
    compressed_metadata = compress(encoded_metadata, compresslevel=9)
    stringified_data = base64.b64encode(compressed_metadata).decode("utf-8")
    recovered = decompress(base64.b64decode(stringified_data))
    assert recovered == encoded_metadata
    assert TraceContainer.model_validate_json(recovered) == container


def test_trace_constructor_and_helpers():
    trace = Trace(schema_version=SCHEMA_VERSION, events=[])
    trace.add_user_program_event(
        GateEvent(gate_name="ClassicalDelay", params=[42]), index=0
    )
    trace.add_simulator_event(GateEvent(gate_name="Rz", qubits=[0]), 0, 123)

    assert Trace(schema_version=SCHEMA_VERSION).model_dump() == {
        "schema_version": SCHEMA_VERSION,
        "events": [],
    }
    assert Trace.model_validate_json(trace.model_dump_json()) == trace
    assert trace.get_user_program_trace().events[0].event.params == [42]
    cleared = trace.clear_simulator_perf_timing()
    assert cleared.get_simulator_trace().events[0].source.duration_ns == 0
    assert trace.get_simulator_trace().events[0].source.duration_ns == 123
    assert cleared.model_dump()["schema_version"] == SCHEMA_VERSION
    assert isinstance(trace, VersionedTrace)
    for parsed in [
        parse_trace(trace.model_dump(mode="json")),
        parse_trace_json(trace.model_dump_json()),
    ]:
        assert isinstance(parsed, Trace)
        assert parsed.model_dump_json() == trace.model_dump_json()


def test_selene_trace_retains_strict_validation():
    from pydantic import ValidationError
    from pydantic_core import PydanticSerializationError

    with pytest.raises(ValidationError):
        GateEvent(gate_name="ClassicalDelay", params=[2**60])

    trace = Trace(schema_version=SCHEMA_VERSION)
    gate = GateEvent(gate_name="ClassicalDelay", params=[0])
    trace.add_user_program_event(gate, index=0)
    gate.params.append(2**53)
    with pytest.raises(PydanticSerializationError, match="ValidationError"):
        trace.model_dump_json()


@pytest.mark.parametrize("runtime", [SimpleRuntime, SoftRZRuntime])
@pytest.mark.parametrize("tracing", [False, True])
def test_exhausted_allocation_with_tracing(runtime, tracing):
    extractor = CircuitExtractor() if tracing else None
    stack = InteractiveFullStack(
        simulator=Stim(), runtime=runtime(), n_qubits=1, event_hook=extractor
    )
    try:
        qubit = stack.qalloc()
        assert qubit.id == 0
        # We've used the only qubit, so the runtime should return its failure
        # sentinel. Enabling tracing shouldn't turn this into a writing error.
        assert stack.qalloc().id == 2**64 - 1

        # The failed allocation doesn't stop us from freeing the first qubit
        # and allocating it again. We should see all four requests in the
        # trace, but the failed allocation should have an empty qubit list.
        stack.qfree(qubit)
        assert stack.qalloc().id == 0
        stack.close()
        if extractor is not None:
            shot = extractor.shots[0]
            events = shot.get_trace().get_user_program_trace().events
            assert [record.source.index for record in events] == [0, 1, 2, 3]
            assert [record.event for record in events] == [
                GateEvent(gate_name="QAlloc", qubits=[0]),
                GateEvent(gate_name="QAlloc", qubits=[]),
                GateEvent(gate_name="QFree", qubits=[0]),
                GateEvent(gate_name="QAlloc", qubits=[0]),
            ]
            # The instruction view uses None for the failed request, so we
            # can inspect it without adding a qubit to the extracted circuit.
            operations = [
                instruction.operation
                for instruction in shot
                if instruction.source == Source.USER
            ]
            assert operations == [QAlloc(0), QAlloc(None), QFree(0), QAlloc(0)]
            assert operations[1].to_dict() == {"op": "QAlloc", "qubit": None}
            assert shot.get_user_circuit().n_qubits == 1
    finally:
        stack.delete_run_directory()


@pytest.mark.parametrize("seed_mode", ["default", "legacy"])
def test_ghz_trace(compiled_guppy, snapshot, seed_mode):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.builtins import array, result
        from guppylang.std.quantum import qubit, h, cx, measure_array, collect_measurements

        @guppy
        def main() -> None:
            qs = array(qubit() for _ in range(10))
            h(qs[0])
            for i in range(9):
                cx(qs[i], qs[i+1])
            result("outcomes", collect_measurements(measure_array(qs)))
        """
    )

    llvm_file = compiled_guppy(
        program_name="trace_test",
        guppy_source=guppy_source,
    )
    circuit_extractor = CircuitExtractor()
    runner = build(llvm_file)
    simulator = Stim()
    runtime = SoftRZRuntime()
    error_model = DepolarizingErrorModel(p_init=0.05, p_meas=0.05, p_1q=0.05, p_2q=0.05)
    _ = dict(
        runner.run(
            simulator=simulator,
            error_model=error_model,
            runtime=runtime,
            n_qubits=10,
            random_seed=10,
            event_hook=circuit_extractor,
            seed_mode=seed_mode,
        )
    )
    trace = circuit_extractor.shots[0].get_trace()
    # we can't perform a snapshot test on the trace with simulator
    # performance timing included, as each run will differ in exact timing.
    trace = trace.clear_simulator_perf_timing()
    snapshot.assert_match(trace.model_dump_json(indent=2), "trace.json")

    numbered = CircuitExtractor()
    for result in runner.run_shots(
        simulator=simulator,
        runtime=SimpleRuntime(),
        n_qubits=10,
        n_shots=3,
        n_processes=2,
        shot_offset=7,
        shot_increment=3,
        event_hook=numbered,
    ):
        list(result)
    assert [shot.get_trace().shot for shot in numbered.shots] == [7, 10, 13]


@pytest.mark.parametrize("runtime", [SimpleRuntime, SoftRZRuntime])
@pytest.mark.parametrize(
    "measurement_type,outcome",
    [
        ("Standard", 0),
        ("Standard", 1),
        ("Leaked", 0),
        ("Leaked", 1),
        ("Leaked", 2),
    ],
)
def test_measurement_identity_and_future_results(runtime, measurement_type, outcome):
    from selene_sim import SimpleLeakageErrorModel
    from selene_formats.trace import (
        MeasurementEvent,
        FutureReadEvent,
        FutureResultEvent,
        RuntimeSource,
    )
    from selene_sim.event_hooks.instruction_log import FutureResult

    extractor = CircuitExtractor()
    stack = InteractiveFullStack(
        simulator=Stim(),
        runtime=runtime(
            duration_ns_rxy=3,
            duration_ns_measure=5,
            duration_ns_measure_leaked=7,
            duration_ns_reset=11,
        ),
        error_model=SimpleLeakageErrorModel(p_leak=1 if outcome == 2 else 0),
        n_qubits=1,
        event_hook=extractor,
    )
    try:
        qubit = stack.qalloc()
        import math

        stack.reset(qubit)
        stack.rxy(qubit, math.pi if outcome == 1 else 0.0, 0.0)
        result_id = (
            stack.lazy_measure_leaked(qubit)
            if measurement_type == "Leaked"
            else stack.lazy_measure(qubit)
        )
        # No result event is emitted until the user actually reads the future.
        assert not any(
            isinstance(r.event, FutureResultEvent)
            for r in extractor.shots[0].get_trace().events
        )
        read = (
            stack.future_read_u64
            if measurement_type == "Leaked"
            else stack.future_read_bool
        )
        assert read(result_id) == outcome
        stack.reset(qubit)
        assert read(result_id) == outcome
        assert read(result_id) == outcome
        eager_outcome = stack.measure(qubit)
        assert eager_outcome is False
        # A failed read must not emit a FutureResult.
        with pytest.raises(Exception):
            stack.future_read_bool(9999)
        stack.close()
        trace = extractor.shots[0].get_trace()
        assert trace.schema_version == "0.2.0"
        measurements = [
            r.event
            for r in trace.get_runtime_trace().events
            if isinstance(r.event, MeasurementEvent)
        ]
        assert measurements[0].result_id == result_id
        assert measurements[0].measurement_type == measurement_type
        results = [r for r in trace.events if isinstance(r.event, FutureResultEvent)]
        assert len(results) == 4
        reads = [r for r in trace.events if isinstance(r.event, FutureReadEvent)]
        assert len(reads) == 5
        assert all(r.source.kind == "UserProgram" for r in reads)
        assert [r.event.result_id for r in reads] == [result_id] * 3 + [
            measurements[1].result_id,
            9999,
        ]
        assert trace.events.index(reads[0]) < trace.events.index(results[0])
        if runtime is SoftRZRuntime:
            execution = next(
                r
                for r in trace.get_runtime_trace().events
                if isinstance(r.event, MeasurementEvent)
            )
            assert (
                trace.events.index(reads[0])
                < trace.events.index(execution)
                < trace.events.index(results[0])
            )
        for record in results[:3]:
            assert isinstance(record.source, RuntimeSource)
            assert record.source.start_time == record.source.end_time
            assert record.event.result_id == result_id
            assert record.event.outcome == outcome
            assert "measurement_type" not in record.event.model_dump()
        assert results[0].source.start_time == (
            21 if measurement_type == "Leaked" else 19
        )
        # SoftRZ may defer reset until the eager measurement forces execution.
        assert results[1].source.start_time >= results[0].source.start_time
        assert results[2].source.start_time == results[1].source.start_time
        assert results[3].event.result_id == measurements[1].result_id
        instructions = list(extractor.shots[0])
        assert sum(isinstance(i.operation, FutureResult) for i in instructions) == 4
        # Reading a future must not add another measurement to the circuit.
        assert (
            extractor.shots[0]
            .get_user_circuit()
            .n_gates_of_type(__import__("pytket").OpType.Measure)
            == 2
        )
    finally:
        stack.delete_run_directory()
