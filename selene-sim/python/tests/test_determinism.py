import yaml
from textwrap import dedent
import pytest

from selene_sim.build import build
from selene_sim import Stim, DepolarizingErrorModel


@pytest.mark.parametrize("seed_mode", ["default", "legacy"])
def test_repetition(snapshot, compiled_guppy, seed_mode):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, h, measure_array
        from guppylang.std.builtins import result, array
        from guppylang.std.qsystem.random import RNG
        from guppylang.std.qsystem.utils import get_current_shot


        @guppy
        def main() -> None:
            qubits = array(qubit() for _ in range(5))
            for i in range(len(qubits)):
                h(qubits[i])
            bits = measure_array(qubits)
            result("a", bits[0].read())
            result("b", bits[1].read())
            result("c", bits[2].read())
            result("d", bits[3].read())
            result("e", bits[4].read())
            result("shot", get_current_shot())
            rng = RNG(get_current_shot())
            result("random_int", rng.random_int())
            result("random_float", rng.random_float())
            rng.discard()
        """
    )
    llvm_file = compiled_guppy(
        program_name="determinism_repetition",
        guppy_source=guppy_source,
    )
    runner = build(llvm_file, "no_results")

    error_model = DepolarizingErrorModel(
        random_seed=194678,
        p_init=0.01,
        p_meas=0.01,
        p_1q=0.01,
        p_2q=0.01,
    )

    simulator = Stim(random_seed=561278)

    full_results = list(
        dict(a)
        for a in runner.run_shots(
            simulator=simulator,
            error_model=error_model,
            n_qubits=5,
            n_shots=1000,
            seed_mode=seed_mode,
        )
    )

    # ensure results agree with the snapshot
    snapshot.assert_match(yaml.dump(full_results), f"full_results_{seed_mode}")

    full_results_again = list(
        dict(a)
        for a in runner.run_shots(
            simulator=simulator,
            error_model=error_model,
            n_qubits=5,
            n_shots=1000,
            seed_mode=seed_mode,
        )
    )

    assert full_results == full_results_again

    offset_results = list(
        dict(a)
        for a in runner.run_shots(
            simulator=simulator,
            error_model=error_model,
            n_qubits=5,
            n_shots=600,  # note: only running 600 shots
            shot_offset=400,  # note: offsetting by 400
            seed_mode=seed_mode,
        )
    )

    assert full_results[400:] == offset_results

    results_ending_in_5 = list(
        dict(a)
        for a in runner.run_shots(
            simulator=simulator,
            error_model=error_model,
            n_qubits=5,
            n_shots=100,
            shot_offset=5,
            shot_increment=10,  # note: incrementing by 10
            seed_mode=seed_mode,
        )
    )

    assert full_results[5::10] == results_ending_in_5

    last_result = dict(
        runner.run(
            simulator=simulator,
            error_model=error_model,
            n_qubits=5,
            shot_offset=999,
            seed_mode=seed_mode,
        )
    )

    assert full_results[-1] == last_result

    # now try some multi-process runs
    results_ending_in_5_but_with_5_processes = list(
        dict(a)
        for a in runner.run_shots(
            simulator=simulator,
            error_model=error_model,
            n_qubits=5,
            n_shots=100,
            shot_offset=5,
            shot_increment=10,  # note: incrementing by 10
            n_processes=5,
            seed_mode=seed_mode,
        )
    )

    assert results_ending_in_5_but_with_5_processes == results_ending_in_5


def test_seed_modes(snapshot, compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, h, measure_array, collect_measurements
        from guppylang.std.builtins import result, array
        from guppylang.std.qsystem.random import RNG
        from guppylang.std.qsystem.utils import get_current_shot


        @guppy
        def main() -> None:
            qs = array(qubit() for _ in range(100))
            for i in range(len(qs)):
                h(qs[i])
            ms = measure_array(qs)
            result("ms", collect_measurements(ms))
        """
    )
    llvm_file = compiled_guppy(
        program_name="determinism_repetition",
        guppy_source=guppy_source,
    )
    runner = build(llvm_file, "no_results")

    error_model = DepolarizingErrorModel(
        p_init=0.01,
        p_meas=0.01,
        p_1q=0.01,
        p_2q=0.01,
    )

    simulator = Stim()

    # The "legacy" seeding mode seeds each component with random_seed+shot_number,
    # making it easy to reproduce runs by seeding within the range of a previous run.
    incremental_seed_results = list(
        tuple(dict(a)["ms"])
        for a in runner.run_shots(
            simulator=simulator,
            error_model=error_model,
            n_qubits=100,
            n_shots=1000,
            seed_mode="legacy",
            random_seed=1234,
        )
    )
    incremental_overlap_results = list(
        tuple(dict(a)["ms"])
        for a in runner.run_shots(
            simulator=simulator,
            error_model=error_model,
            n_qubits=100,
            n_shots=1000,
            seed_mode="legacy",
            random_seed=1734,
        )
    )
    incremental_seed_results_set = set(incremental_seed_results)
    incremental_overlap_results_set = set(incremental_overlap_results)
    overlap = incremental_seed_results_set & incremental_overlap_results_set
    assert len(overlap) == 500
    assert incremental_overlap_results[:500] == incremental_seed_results[500:]

    # This can cause confusion when seeking to compare independent rounds of shots, so the
    # "default" seeding mode seeds each component with seeds that are themselves randomly
    # generated from a pRNG seeded with random_seed.
    default_seed_results = list(
        tuple(dict(a)["ms"])
        for a in runner.run_shots(
            simulator=simulator,
            error_model=error_model,
            n_qubits=100,
            n_shots=1000,
            seed_mode="default",
            random_seed=1234,
        )
    )
    default_overlap_results = list(
        tuple(dict(a)["ms"])
        for a in runner.run_shots(
            simulator=simulator,
            error_model=error_model,
            n_qubits=100,
            n_shots=1000,
            seed_mode="default",
            random_seed=1734,
        )
    )
    default_seed_results_set = set(default_seed_results)
    default_overlap_results_set = set(default_overlap_results)
    overlap = default_seed_results_set & default_overlap_results_set
    assert len(overlap) == 0
