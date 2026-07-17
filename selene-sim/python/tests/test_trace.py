from textwrap import dedent

from selene_sim import Stim, DepolarizingErrorModel, SoftRZRuntime
from selene_sim.build import build
from selene_sim.event_hooks import CircuitExtractor


GHZ_GUPPY_SOURCE = dedent(
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


def test_ghz_trace(compiled_guppy, snapshot):
    guppy_source = GHZ_GUPPY_SOURCE

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
        )
    )
    trace = circuit_extractor.shots[0].get_trace()
    # we can't perform a snapshot test on the trace with simulator
    # performance timing included, as each run will differ in exact timing.
    trace = trace.clear_simulator_perf_timing()
    snapshot.assert_match(trace.model_dump_json(indent=2), "trace.json")


class _CountingCircuitExtractor(CircuitExtractor):
    """
    A CircuitExtractor that counts how many times it receives an
    INSTRUCTIONLOG entry over the course of a run, so tests can assert on
    how many times the instruction log was flushed mid-shot.
    """

    def __init__(self, flush_threshold: int = 4096):
        super().__init__(flush_threshold=flush_threshold)
        self.instructionlog_invocations = 0

    def try_invoke(self, tag: str, data: list) -> bool:
        if tag == "INSTRUCTIONLOG":
            self.instructionlog_invocations += 1
        return super().try_invoke(tag, data)


def _run_ghz(compiled_guppy, event_hook, random_seed: int = 10):
    llvm_file = compiled_guppy(
        program_name="trace_test",
        guppy_source=GHZ_GUPPY_SOURCE,
    )
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
            random_seed=random_seed,
            event_hook=event_hook,
        )
    )


def test_instruction_log_delivered_incrementally_during_shot(compiled_guppy):
    """
    Reproduces/verifies the fix: with a small flush_threshold, Selene should
    flush (and thus deliver) the instruction log to the CircuitExtractor
    multiple times over the course of a single shot, rather than only once
    at the very end of the shot.
    """
    circuit_extractor = _CountingCircuitExtractor(flush_threshold=1)
    _run_ghz(compiled_guppy, circuit_extractor)

    assert circuit_extractor.instructionlog_invocations > 1, (
        "Expected multiple incremental INSTRUCTIONLOG deliveries with a "
        "small flush_threshold, but the instruction log was only delivered "
        f"{circuit_extractor.instructionlog_invocations} time(s)."
    )
    # The complete set of instructions should still be assembled correctly.
    assert len(circuit_extractor.shots) == 1
    assert len(circuit_extractor.shots[0].instructions) > 0


def test_instruction_log_flush_threshold_zero_preserves_end_of_shot_only(
    compiled_guppy,
):
    """
    A flush_threshold of 0 disables incremental flushing, restoring the
    original behaviour of only delivering the instruction log once, at the
    end of the shot.
    """
    circuit_extractor = _CountingCircuitExtractor(flush_threshold=0)
    _run_ghz(compiled_guppy, circuit_extractor)

    assert circuit_extractor.instructionlog_invocations == 1


def test_instruction_log_trace_identical_regardless_of_flush_threshold(
    compiled_guppy,
):
    """
    Splitting the instruction log across multiple incremental flushes must
    not lose, duplicate, or reorder instructions: the assembled trace should
    be identical whether the log is flushed incrementally (small threshold)
    or only once at the end of the shot (threshold=0).
    """
    incremental_extractor = CircuitExtractor(flush_threshold=1)
    _run_ghz(compiled_guppy, incremental_extractor, random_seed=42)
    incremental_trace = (
        incremental_extractor.shots[0].get_trace().clear_simulator_perf_timing()
    )

    end_of_shot_extractor = CircuitExtractor(flush_threshold=0)
    _run_ghz(compiled_guppy, end_of_shot_extractor, random_seed=42)
    end_of_shot_trace = (
        end_of_shot_extractor.shots[0].get_trace().clear_simulator_perf_timing()
    )

    assert incremental_trace.model_dump_json(
        indent=2
    ) == end_of_shot_trace.model_dump_json(indent=2)
