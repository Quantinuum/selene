from textwrap import dedent
import struct
import pytest

from selene_sim import Stim, DepolarizingErrorModel, SoftRZRuntime
from selene_sim.build import build
from selene_sim.event_hooks import CircuitExtractor
from selene_sim.event_hooks.instruction_log import CustomOperation, QAlloc, Source
from selene_sim.result_handling.data_stream import FileStream
from selene_sim.result_handling.result_stream import ResultStream


@pytest.mark.parametrize("data", [b"", b"\xff", b"\x00\x03\xff"])
@pytest.mark.parametrize("source", list(Source))
def test_custom_trace_with_optional_data(tmp_path, data, source):
    def uint(value):
        return struct.pack("<HHQ", ResultStream.UINT_TAG, 0, value)

    prefix = uint(source.value)
    if source == Source.SIMULATOR:
        prefix += uint(123)
    tag = b"INSTRUCTIONLOG"
    record = struct.pack("<QHH", 0, ResultStream.STR_TAG, len(tag)) + tag
    record += prefix + uint(9) + uint(42)
    record += struct.pack("<HHB", ResultStream.BIT_TAG, 0, bool(data))
    if data:
        record += struct.pack("<HH", ResultStream.BYTE_TAG, len(data)) + data
    # We follow the custom op with an allocation so reading a nonexistent
    # payload would steal its source and break the next instruction.
    record += prefix + uint(1) + uint(7)
    record += struct.pack("<HHQ", 0, 0, ResultStream.EOS)
    recording = tmp_path / "custom-trace.bin"
    recording.write_bytes(record)
    transport = FileStream(recording)
    extractor = CircuitExtractor()
    extractor.on_new_shot()
    try:
        for entry in ResultStream(transport):
            assert extractor.try_invoke(entry.tag, entry.values)
    finally:
        transport.handle.close()

    custom, allocation = list(extractor.shots[0])
    assert custom.source == allocation.source == source
    assert custom.operation == CustomOperation(tag=42, data=data)
    assert allocation.operation == QAlloc(qubit=7)


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
