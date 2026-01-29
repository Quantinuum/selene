import pytest

from guppylang import guppy
from guppylang.std.builtins import array
from guppylang.std.debug import state_result
from guppylang.std.quantum import discard, qubit, discard_array, x, h, cx, measure
from hugr.qsystem.result import QsysResult
import numpy as np

from selene_sim.build import build
from selene_sim import Quest, Stim, QuantumReplay


@pytest.mark.parametrize("simulator_plugin", [Quest, Stim])
def test_initial_state(simulator_plugin):
    @guppy
    def main() -> None:
        q0 = qubit()
        state_result("initial_state", q0)
        discard(q0)

    runner = build(main.compile(), "initial_state")
    got = runner.run(simulator_plugin(), n_qubits=1)
    state = simulator_plugin.extract_states_dict(got)["initial_state"]
    assert state.get_dirac_notation()[0].probability == 1


@pytest.mark.parametrize("simulator_plugin", [Quest, Stim])
def test_array_state(simulator_plugin):
    @guppy
    def main() -> None:
        qs = array(qubit() for _ in range(2))
        for i in range(2):
            x(qs[i])
        state_result("array_state", qs)
        discard_array(qs)

    runner = build(main.compile(), "array_state")
    plugin = simulator_plugin()
    shots = QsysResult(
        runner.run_shots(
            simulator=plugin,
            n_qubits=2,
            n_shots=2,
        )
    )
    for shot in shots.results:
        state = simulator_plugin.extract_states_dict(shot.entries)["array_state"]
        assert state.get_density_matrix()[3][3] == 1
        assert len(state.get_single_state()) == 4


@pytest.mark.parametrize("simulator_plugin", [Quest, Stim])
def test_array_subscript_state(simulator_plugin):
    @guppy
    def main() -> None:
        qs = array(qubit() for _ in range(2))
        for i in range(2):
            x(qs[i])
        state_result("array_state", qs[0])
        discard_array(qs)

    runner = build(main.compile(), "array_state")
    plugin = simulator_plugin()
    shots = QsysResult(
        runner.run_shots(
            simulator=plugin,
            n_qubits=2,
            n_shots=1,
        )
    )
    for shot in shots.results:
        state = simulator_plugin.extract_states_dict(shot.entries)["array_state"]
        assert state.get_density_matrix()[1][1] == 1
        assert state.get_state_vector_distribution()[0].probability == 1


@pytest.mark.parametrize("simulator_plugin", [Quest, Stim])
def test_qubit_ordering_state(simulator_plugin):
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
    plugin = simulator_plugin()
    shots = QsysResult(
        runner.run_shots(
            simulator=plugin,
            n_qubits=2,
            n_shots=1,
        )
    )
    for shot in shots.results:
        states = simulator_plugin.extract_states_dict(shot.entries)
        state_default = states["default"]
        state_reversed = states["reversed"]
        assert state_default.get_single_state()[2] == 1  # expect |10>
        assert state_reversed.get_single_state()[1] == 1  # expect |01>


@pytest.mark.parametrize("simulator_plugin", [Quest, Stim])
@pytest.mark.parametrize("first_measurement", [0, 1])
def test_quantum_replay_state(simulator_plugin, first_measurement):
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
    underlying_simulator = simulator_plugin(random_seed=1234)
    replay_simulator = QuantumReplay(
        simulator=underlying_simulator,
        resume_with_measurement=True,
        measurements=[
            [
                first_measurement
            ],  # first qubit measures as requested, simulator will handle the second
        ],
    )
    shots = QsysResult(
        runner.run_shots(
            simulator=replay_simulator,
            n_qubits=2,
            n_shots=1,
        )
    )
    shot = shots.results[0]
    shot_dict = dict(shot.entries)
    shot_states = simulator_plugin.extract_states_dict(shot.entries)

    # First measurement is correctly replayed
    assert shot_dict["c0"] == first_measurement
    # Second measurement is consistent with entanglement
    assert shot_dict["c1"] == first_measurement

    # Initial entangled state is correct
    entangled = shot_states["entangled_state"].get_single_state()
    # both should be (1/sqrt(2))[|00> + |11>]
    np.testing.assert_allclose(entangled, np.array([1, 0, 0, 1]) / np.sqrt(2))

    # Post-measurement states are correct
    post_measurement = shot_states["post_measurement_state"].get_single_state()
    # first shot measured 0 on q0, so q1 should be |0>
    expected = np.array([1, 0]) if first_measurement == 0 else np.array([0, 1])
    np.testing.assert_allclose(post_measurement, expected)


@pytest.mark.parametrize("simulator_plugin", [Quest, Stim])
@pytest.mark.parametrize("cleanup_param", [True, False, None])
def test_state_cleanup(simulator_plugin, cleanup_param):
    @guppy
    def main() -> None:
        qs = array(qubit() for _ in range(2))
        for i in range(2):
            x(qs[i])
        state_result("array_state", qs[0])
        discard_array(qs)

    runner = build(main.compile(), "array_state")
    plugin = simulator_plugin()
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
            simulator_plugin.extract_states_dict(shot.entries)
            if cleanup_param is None
            else simulator_plugin.extract_states_dict(
                shot.entries, cleanup=cleanup_param
            )
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
