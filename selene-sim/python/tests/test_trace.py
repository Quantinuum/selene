from textwrap import dedent
import pytest

from selene_sim import Stim, DepolarizingErrorModel, SoftRZRuntime
from selene_sim.build import build
from selene_sim.event_hooks import CircuitExtractor, TraceStore


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

    # TraceStore can also be used on its own. Run several shots across workers
    # so we check that each file is loaded into the right shot and that the
    # backend starts its event indices again for each shot.
    store = TraceStore()
    shots = [
        list(shot)
        for shot in runner.run_shots(
            simulator=simulator,
            runtime=runtime,
            n_qubits=10,
            n_shots=3,
            n_processes=2,
            event_hook=store,
            seed_mode=seed_mode,
        )
    ]
    assert len(shots) == len(store.shots) == 3
    for stored_trace in store.shots:
        user_events = [
            record
            for record in stored_trace.iter_events()
            if record.source.kind == "UserProgram"
        ]
        assert user_events
        assert [record.source.index for record in user_events] == list(
            range(len(user_events))
        )
    assert store.shots[0] is not store.shots[1]
