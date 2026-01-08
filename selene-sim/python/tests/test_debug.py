import pytest

from guppylang import guppy
from guppylang.std.builtins import array
from guppylang.std.debug import state_result
from guppylang.std.quantum import discard, qubit, discard_array, x, h, cx, measure
from hugr.qsystem.result import QsysResult

from selene_sim.build import build
from selene_sim import Quest, QuantumReplay


def test_initial_state():
    @guppy
    def main() -> None:
        q0 = qubit()
        state_result("initial_state", q0)
        discard(q0)

    runner = build(main.compile(), "initial_state")
    got = runner.run(Quest(), n_qubits=1)
    state = Quest.extract_states_dict(got)["initial_state"]
    assert state.get_dirac_notation()[0].probability == 1


def test_array_state():
    @guppy
    def main() -> None:
        qs = array(qubit() for _ in range(2))
        for i in range(2):
            x(qs[i])
        state_result("array_state", qs)
        discard_array(qs)

    runner = build(main.compile(), "array_state")
    plugin = Quest()
    shots = QsysResult(
        runner.run_shots(
            simulator=plugin,
            n_qubits=2,
            n_shots=2,
        )
    )
    for shot in shots.results:
        state = Quest.extract_states_dict(shot.entries)["array_state"]
        assert state.get_density_matrix()[3][3] == 1
        assert len(state.get_single_state()) == 4


def test_array_subscript_state():
    @guppy
    def main() -> None:
        qs = array(qubit() for _ in range(2))
        for i in range(2):
            x(qs[i])
        state_result("array_state", qs[0])
        discard_array(qs)

    runner = build(main.compile(), "array_state")
    plugin = Quest()
    shots = QsysResult(
        runner.run_shots(
            simulator=plugin,
            n_qubits=2,
            n_shots=1,
        )
    )
    for shot in shots.results:
        state = Quest.extract_states_dict(shot.entries)["array_state"]
        assert state.get_density_matrix()[1][1] == 1
        assert state.get_state_vector_distribution()[0].probability == 1


def test_qubit_ordering_state():
    @guppy
    def main() -> None:
        qs = array(qubit() for _ in range(2))
        x(qs[0])
        # expected state is |10> so that qs[0] is the MSB
        state_result("default", qs[0], qs[1])
        # reversed order, expected state is |01>
        state_result("reversed", qs[1], qs[0])
        discard_array(qs)

    runner = build(main.compile())
    plugin = Quest()
    shots = QsysResult(
        runner.run_shots(
            simulator=plugin,
            n_qubits=2,
            n_shots=1,
        )
    )
    for shot in shots.results:
        states = Quest.extract_states_dict(shot.entries)
        state_default = states["default"]
        state_reversed = states["reversed"]
        assert state_default.get_single_state()[2] == 1  # expect |10>
        assert state_reversed.get_single_state()[1] == 1  # expect |01>


def test_quantum_replay_state():
    @guppy
    def main() -> None:
        q0: qubit = qubit()
        q1: qubit = qubit()
        h(q0)
        cx(q0, q1)
        state_result("entangled_state", q0, q1)
        result("c0", measure(q0))
        state_result("post_measurement_state", q1)
        result("c1", measure(q1))

    runner = build(main.compile(), "quantum_replay_state")
    underlying_simulator = Quest(random_seed=1234)
    replay_simulator = QuantumReplay(
        simulator=Quest(random_seed=1234),
        resume_with_measurement=True,
        measurements=[
            [0],  # first qubit measures as 0, quest will handle second
            [1],  # first qubit measures as 1, quest will handle second
        ],
    )
    shots = QsysResult(
        runner.run_shots(
            simulator=replay_simulator,
            n_qubits=2,
            n_shots=2,
        )
    )
    first_shot = shots.results[0]
    second_shot = shots.results[1]
    first_shot_dict = dict(first_shot.entries)
    second_shot_dict = dict(second_shot.entries)
    first_shot_states = Quest.extract_states_dict(first_shot.entries)
    second_shot_states = Quest.extract_states_dict(second_shot.entries)

    # First measurement is correctly replayed
    assert first_shot_dict["c0"] == 0
    assert second_shot_dict["c0"] == 1
    # Second measurement is consistent with entanglement
    assert first_shot_dict["c1"] == first_shot_dict["c0"]
    assert second_shot_dict["c1"] == second_shot_dict["c0"]

    # Initial entangled state is correct
    first_entangled = first_shot_states["entangled_state"].get_single_state()
    second_entangled = second_shot_states["entangled_state"].get_single_state()
    # both should be (1/sqrt(2))[|00> + |11>]
    assert first_entangled[0] == pytest.approx(1 / 2**0.5)
    assert first_entangled[3] == pytest.approx(1 / 2**0.5)
    assert second_entangled[0] == pytest.approx(1 / 2**0.5)
    assert second_entangled[3] == pytest.approx(1 / 2**0.5)

    # Post-measurement states are correct
    first_post_measurement = first_shot_states[
        "post_measurement_state"
    ].get_single_state()
    second_post_measurement = second_shot_states[
        "post_measurement_state"
    ].get_single_state()
    # first shot measured 0 on q0, so q1 should be |0>
    assert first_post_measurement[0] == pytest.approx(1)
    # second shot measured 1 on q0, so q1 should be |1>
    assert second_post_measurement[1] == pytest.approx(1)


@pytest.mark.parametrize("cleanup_param", [True, False, None])
def test_state_cleanup(cleanup_param):
    @guppy
    def main() -> None:
        qs = array(qubit() for _ in range(2))
        for i in range(2):
            x(qs[i])
        state_result("array_state", qs[0])
        discard_array(qs)

    runner = build(main.compile(), "array_state")
    plugin = Quest()
    shots = QsysResult(
        runner.run_shots(
            simulator=plugin,
            n_qubits=2,
            n_shots=1,
        )
    )
    run_directory = runner.runs
    individual_runs = list(run_directory.iterdir())
    assert len(individual_runs) == 1, "Expected only one run directory"
    individual_run = individual_runs[0]
    run_artifact_dir = individual_run / "artifacts"
    assert run_artifact_dir.exists(), "Expected artifacts directory to exist"
    state_files_pre_parse = list(run_artifact_dir.glob("*.state"))
    assert len(state_files_pre_parse) == 1

    for shot in shots.results:
        state_dict = (
            Quest.extract_states_dict(shot.entries)
            if cleanup_param is None
            else Quest.extract_states_dict(shot.entries, cleanup=cleanup_param)
        )
        state = state_dict["array_state"]
        assert state.get_density_matrix()[1][1] == 1
        assert state.get_state_vector_distribution()[0].probability == 1
        state_files_post_parse = list(run_artifact_dir.glob("*.state"))
        if cleanup_param in [True, None]:
            assert len(state_files_post_parse) == 0, (
                "Expected no state files after cleanup"
            )
        else:
            assert state_files_post_parse == state_files_pre_parse, (
                "Expected artifacts to remain unchanged if cleanup is False"
            )
