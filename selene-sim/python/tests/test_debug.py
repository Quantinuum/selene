import pytest
from textwrap import dedent

from hugr.qsystem.result import QsysResult
import numpy as np

from selene_sim.build import build
from selene_sim import Quest, Stim, QuantumReplay


@pytest.mark.parametrize("simulator_plugin", [Quest, Stim])
def test_initial_state(simulator_plugin, compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, discard
        from guppylang.std.debug import state_result

        @guppy
        def main() -> None:
            q0 = qubit()
            state_result("initial_state", q0)
            discard(q0)
        """
    )

    llvm_file = compiled_guppy(
        program_name="initial_state",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)
    got = runner.run(simulator_plugin(), n_qubits=1)
    state = simulator_plugin.extract_states_dict(got)["initial_state"]
    assert state.get_dirac_notation()[0].probability == 1


@pytest.mark.parametrize("simulator_plugin", [Quest, Stim])
def test_array_state(simulator_plugin, compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, x, discard_array
        from guppylang.std.builtins import array
        from guppylang.std.debug import state_result

        @guppy
        def main() -> None:
            qs = array(qubit() for _ in range(2))
            for i in range(2):
                x(qs[i])
            state_result("array_state", qs)
            discard_array(qs)
        """
    )

    llvm_file = compiled_guppy(
        program_name="array_state",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)
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
def test_array_subscript_state(simulator_plugin, compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, x, discard_array
        from guppylang.std.builtins import array
        from guppylang.std.debug import state_result

        @guppy
        def main() -> None:
            qs = array(qubit() for _ in range(2))
            for i in range(2):
                x(qs[i])
            state_result("array_state", qs[0])
            discard_array(qs)
        """
    )

    llvm_file = compiled_guppy(
        program_name="array_subscript_state",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)
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
def test_qubit_ordering_state(simulator_plugin, compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, x, discard_array
        from guppylang.std.builtins import array
        from guppylang.std.debug import state_result


        @guppy
        def main() -> None:
            qs = array(qubit() for _ in range(2))
            x(qs[0])
            # expected state is |10> so that qs[0] is the MSB
            state_result("default", qs[0], qs[1])
            # reversed order, expected state is |01>
            state_result("reversed", qs[1], qs[0])
            discard_array(qs)
        """
    )

    llvm_file = compiled_guppy(
        program_name="qubit_ordering_state",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)
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
def test_quantum_replay_state(simulator_plugin, first_measurement, compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, h, cx, measure
        from guppylang.std.builtins import result
        from guppylang.std.debug import state_result

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
        """
    )

    llvm_file = compiled_guppy(
        program_name="quantum_replay_state",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)
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


@pytest.mark.parametrize("platform", ["helios", "sol"])
@pytest.mark.parametrize("gate", ["rx", "ry", "rz"])
def test_stim_gate_implementations_single_qubit(platform, gate, compiled_guppy):
    import random

    random.seed(1234)
    all_quarter_turns = [
        i / 2 for i in range(-8, 9)
    ]  # from -4pi to 4pi in pi/2 increments
    params = [random.choice(all_quarter_turns) for _ in range(1000)]

    guppy_source = dedent(
        f"""
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, {gate}, discard
        from guppylang.std.debug import state_result
        from guppylang.std.angles import pi
        from guppylang.std.qsystem.utils import get_current_shot

        params = {params}

        @guppy
        def main() -> None:
            q0: qubit = qubit()
            angle = comptime(params)[get_current_shot()]
            {gate}(q0, pi * angle)
            state_result("entangled_state", q0)
            discard(q0)
        """
    )

    llvm_file = compiled_guppy(
        program_name=f"stim_gate_implementation_{gate}",
        guppy_source=guppy_source,
        qis_platform=platform,
    )

    runner = build(llvm_file, platform=platform)

    stim_shots = QsysResult(
        runner.run_shots(
            simulator=Stim(
                angle_threshold=1e-2,  # reduce threshold to catch more errors
            ),
            n_qubits=2,
            n_shots=len(params),
        )
    )
    quest_shots = QsysResult(
        runner.run_shots(
            simulator=Quest(),
            n_qubits=2,
            n_shots=len(params),
        )
    )
    for shot, (stim_shot, quest_shot) in enumerate(
        zip(stim_shots.results, quest_shots.results)
    ):
        stim_state = Stim.extract_states_dict(stim_shot.entries)["entangled_state"]
        stim_statevector = stim_state.get_single_state()
        quest_state = Quest.extract_states_dict(quest_shot.entries)["entangled_state"]
        quest_statevector = quest_state.get_single_state()
        print(f"Shot {shot}:")
        print(f"   gate: {gate}(pi * {params[shot]})")
        print("   Stim state:", stim_statevector)
        print("   Quest state:", quest_statevector)
        print("   Stabilizers", stim_state.get_reduced_stabilizers())
        np.testing.assert_allclose(stim_statevector, quest_statevector)


@pytest.mark.parametrize("platform", ["helios", "sol"])
def test_stim_gate_implementations_single_qubit_triples(compiled_guppy, platform):
    import random

    random.seed(1234)
    all_quarter_turns = [
        i / 2 for i in range(-8, 9)
    ]  # from -4pi to 4pi in pi/2 increments
    params = [[random.choice(all_quarter_turns) for _ in range(3)] for _ in range(1000)]

    guppy_source = dedent(
        f"""
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, ry, rz, rx, discard
        from guppylang.std.debug import state_result
        from guppylang.std.angles import pi
        from guppylang.std.qsystem.utils import get_current_shot

        params = {params}

        @guppy
        def main() -> None:
            q0: qubit = qubit()
            angles = comptime(params)[get_current_shot()]
            rx(q0, pi * angles[0])
            ry(q0, pi * angles[1])
            rz(q0, pi * angles[2])
            state_result("entangled_state", q0)
            discard(q0)
        """
    )

    llvm_file = compiled_guppy(
        program_name="stim_gate_implementation_triples",
        guppy_source=guppy_source,
        qis_platform=platform,
    )

    runner = build(llvm_file, platform=platform)
    stim_shots = QsysResult(
        runner.run_shots(
            simulator=Stim(
                angle_threshold=1e-2,  # reduce threshold to catch more errors
            ),
            n_qubits=2,
            n_shots=len(params),
        )
    )
    quest_shots = QsysResult(
        runner.run_shots(
            simulator=Quest(),
            n_qubits=2,
            n_shots=len(params),
        )
    )
    for shot, (stim_shot, quest_shot) in enumerate(
        zip(stim_shots.results, quest_shots.results)
    ):
        stim_state = Stim.extract_states_dict(stim_shot.entries)["entangled_state"]
        stim_statevector = stim_state.get_single_state()
        quest_state = Quest.extract_states_dict(quest_shot.entries)["entangled_state"]
        quest_statevector = quest_state.get_single_state()
        print(f"Shot {shot}:")
        print(
            f"   gate: rx(pi * {params[shot][0]}); ry(pi * {params[shot][1]}); rz(pi * {params[shot][2]})"
        )
        print("   Stim state:", stim_statevector)
        print("   Quest state:", quest_statevector)
        print("   Stabilizers", stim_state.get_reduced_stabilizers())
        np.testing.assert_allclose(stim_statevector, quest_statevector)


@pytest.mark.parametrize("simulator_plugin", [Quest, Stim])
@pytest.mark.parametrize("cleanup_param", [True, False, None])
def test_state_cleanup(simulator_plugin, cleanup_param, compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, x, discard_array
        from guppylang.std.builtins import array
        from guppylang.std.debug import state_result

        @guppy
        def main() -> None:
            qs = array(qubit() for _ in range(2))
            for i in range(2):
                x(qs[i])
            state_result("array_state", qs[0])
            discard_array(qs)
        """
    )

    llvm_file = compiled_guppy(
        program_name="array_state_cleanup",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)
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
