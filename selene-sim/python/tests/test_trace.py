from textwrap import dedent
import base64
from gzip import compress, decompress
import json
from typing import Literal
import pytest
from pydantic import BaseModel, ConfigDict

from selene_core.trace import Trace, GateEvent, parse_trace, parse_trace_json
from selene_formats.trace import Trace as VersionedTrace

from selene_sim import Stim, DepolarizingErrorModel, SoftRZRuntime
from selene_sim.build import build
from selene_sim.event_hooks import CircuitExtractor
from selene_formats.trace import (
    CustomEvent,
    EventRecord,
    OpaquePayload,
    UserProgramSource,
)
from selene_formats.trace_stream import write_trace_stream


@pytest.mark.parametrize("tag", [42, 2**64 - 1])
@pytest.mark.parametrize("data", [b"", b"\xfb\xff"])
def test_legacy_trace_metadata_round_trip(tmp_path, tag, data):
    class DownstreamTrace(BaseModel):
        model_config = ConfigDict(extra="forbid")
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
    assert set(document) == {"events"}
    assert document["events"][0]["event"]["payload"]["tag"] == tag
    assert type(document["events"][0]["event"]["payload"]["tag"]) is int
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


def test_legacy_trace_constructor_and_helpers():
    trace = Trace(events=[])
    trace.add_user_program_event(
        GateEvent(gate_name="ClassicalDelay", params=[42]), index=0
    )
    trace.add_simulator_event(GateEvent(gate_name="Rz", qubits=[0]), 0, 123)

    assert Trace().model_dump_json() == '{"events":[]}'
    assert Trace.model_validate_json(trace.model_dump_json()) == trace
    assert trace.get_user_program_trace().events[0].event.params == [42]
    cleared = trace.clear_simulator_perf_timing()
    assert cleared.get_simulator_trace().events[0].source.duration_ns == 0
    assert trace.get_simulator_trace().events[0].source.duration_ns == 123
    assert "schema_version" not in cleared.model_dump()
    assert isinstance(trace, VersionedTrace)
    for parsed in [
        parse_trace(trace.model_dump(mode="json")),
        parse_trace_json(trace.model_dump_json()),
    ]:
        assert isinstance(parsed, Trace)
        assert parsed.model_dump_json() == trace.model_dump_json()


def test_selene_trace_retains_strict_validation():
    from pydantic import ValidationError

    with pytest.raises(ValidationError):
        GateEvent(gate_name="ClassicalDelay", params=[2**60])


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
