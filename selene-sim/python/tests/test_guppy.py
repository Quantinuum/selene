import datetime
import sys
from pathlib import Path

import pytest
import yaml
from conftest import qis_file
from hugr.qsystem.result import QsysResult
from selene_sim import ClassicalReplay, Coinflip, Quest, Stim, SimpleLeakageErrorModel
from selene_sim.build import build
from selene_sim.event_hooks import CircuitExtractor, MetricStore, MeasurementExtractor
from selene_sim.exceptions import SelenePanicError, SeleneRuntimeError


def test_no_results():
    runner = build(qis_file("no_results"))
    # time limits aren't necessary in general, but they are helpful in testing
    got = list(
        runner.run(Coinflip(), n_qubits=1, timeout=datetime.timedelta(seconds=1))
    )
    assert len(got) == 0, f"expected no results, got {got}"


def test_flip_some():
    runner = build(qis_file("flip_n4"))
    expected = {"c0": 1, "c1": 0, "c2": 1, "c3": 1}
    # run the simulation on Quest and Stim
    for simulator in [Quest(), Stim()]:
        got = dict(runner.run(simulator, verbose=True, n_qubits=4))
        assert got == expected, f"{simulator}: expected {expected}, got {got}"

    # the coinflip simulator should reliably produce identical results across platforms.
    # note that a change in the runtime optimiser might reorder the evaluation of measurements,
    # resulting in a permutation.
    got = dict(runner.run(Coinflip(), random_seed=249, n_qubits=4))
    assert got == {
        "c0": 1,
        "c1": 0,
        "c2": 0,
        "c3": 1,
    }, f"Coinflip test: expected {expected}, got {got}"
    # and the replay simulator should produce the same results as the input.
    # for this program this results in trivial behaviour, but it's useful to
    # verify the basics.
    # the input is a list (over shots) of lists (over measurements) of bools
    replay_measurements = [[c == 1 for c in got.values()]]
    got_replay = dict(
        runner.run(
            ClassicalReplay(measurements=replay_measurements),
            n_qubits=4,
            timeout=datetime.timedelta(seconds=1),
        )
    )
    assert got == got_replay, "Classical Replay failed to produce input results"


def test_print_array():
    runner = build(qis_file("flip_n4_arr"))
    expected = {
        "cs": [1, 0, 1, 1, 0, 0, 0, 0, 0, 1],
        "is": list(range(100)),
        "fs": list(i * 0.0625 for i in range(100)),
    }

    # run the simulation on Quest and Stim
    for simulator in [Quest(), Stim()]:
        got = dict(runner.run(simulator, verbose=True, n_qubits=10))
        assert got == expected, f"{simulator}: expected {expected}, got {got}"


def test_exit():
    """
    This test verifies the behaviour of exit(), which should stop the shot
    and add the error message to the result stream, but should then resume
    further shots.
    """

    runner = build(qis_file("exit"))
    # some should have measurements of 0, some should have no measurements.
    n_1 = 0
    n_0 = 0
    n_exit = 0
    for shot in runner.run_shots(
        Quest(random_seed=0),
        n_qubits=1,
        n_shots=100,
        timeout=datetime.timedelta(seconds=1),
        verbose=True,
    ):
        shot = list(shot)
        if shot == [("exit: Postselection failed", 42)]:
            n_exit += 1
        elif shot[0][1] == 1:
            n_1 += 1
        else:
            n_0 += 1
    # no shots should have provided a result of 1
    assert n_1 == 0
    # some shots should have provided a result of 0
    assert n_0 > 0
    # some shots should have exited
    assert n_exit > 0
    # we still have 100 shots total
    assert n_0 + n_exit == 100


def test_panic():
    """
    This test verifies the behaviour of panic(), which should stop the shot
    and should not allow any further shots to be performed. On the python
    client side, this should result in an Exception rather than being added
    into the results.
    """

    runner = build(qis_file("panic"))
    with pytest.raises(
        SelenePanicError, match="Postselection failed"
    ) as exception_info:
        shots = QsysResult(
            runner.run_shots(
                Quest(),
                n_qubits=1,
                n_shots=100,
                random_seed=0,
            )
        )


def test_measure_leaked(snapshot):
    simulator = Stim(random_seed=0)
    error_model = SimpleLeakageErrorModel(
        p_leak=0.01, leak_measurement_bias=0.8, random_seed=0
    )

    runner = build(qis_file("leak_from_head"))
    shots = [
        list(shot)
        for shot in runner.run_shots(
            simulator=simulator,
            error_model=error_model,
            n_qubits=40,
            n_shots=50,
        )
    ]
    snapshot.assert_match(
        yaml.dump(shots),
        "measure_leaked_from_head",
    )
    runner = build(qis_file("leak_within_tail"))
    shots = [
        list(shot)
        for shot in runner.run_shots(
            simulator=simulator,
            error_model=error_model,
            n_qubits=40,
            n_shots=50,
        )
    ]
    snapshot.assert_match(
        yaml.dump(shots),
        "measure_leaked_within_tail",
    )


def test_rus():
    runner = build(qis_file("repeat_until_success"))
    shots = QsysResult(
        runner.run_shots(
            Quest(random_seed=0),
            n_qubits=4,
            n_shots=10,
            timeout=datetime.timedelta(seconds=1),
        )
    )
    measured = "".join(shots.register_bitstrings()["result"])
    # TODO: try to get emulators to match RNG behaviour
    #      across OSes. This is primarily in the hands
    #      of upstream deps, but if there's a way we can
    #      force it to behave the same then we should.
    if sys.platform in ["win32", "cygwin"]:
        assert measured == "0001000010"
    else:
        assert measured == "1000100100"


def test_get_current_shot():
    runner = build(qis_file("current_shot"))
    n_shots = 100
    shots = list(dict(shot) for shot in runner.run_shots(Quest(), 1, n_shots=n_shots))
    shot_ids = [shot["shot"] for shot in shots]
    assert shot_ids == list(range(n_shots))


def test_rng(snapshot):
    runner = build(qis_file("rng"))
    shots = list(
        dict(shot) for shot in runner.run_shots(Quest(), 1, n_shots=10, verbose=True)
    )
    # we are seeding with a constant value, so assert that it's the same
    # across each shot
    for shot in shots[1:]:
        assert shot == shots[0]

    # and check that they match the snapshot (i.e. no change between commits)
    snapshot.assert_match(yaml.dump(shots[0]), "rng")


def test_rng_advance(snapshot):
    runner = build(qis_file("rng_advance"))
    shots = list(
        dict(shot) for shot in runner.run_shots(Quest(), 1, n_shots=10, verbose=True)
    )
    for shot in shots:
        assert shot["rint"] == shot["rint2"], (
            f"Expected rint to be the same after advancing, got {shot['rint']} and {shot['rint2']}"
        )
        assert shot["rfloat"] == shot["rfloat2"], (
            f"Expected rfloat to be the same after advancing, got {shot['rfloat']} and {shot['rfloat2']}"
        )


def test_sim_restriction():
    """
    Demonstrate the propagation of panic-inducing messages from
    simulators to user-facing SelenePanicError exceptions.

    In this example, we try to use a non-Clifford operation in Stim,
    which, as a stabilizer simulator, cannot represent non-Clifford
    operations. This should result in a panic, which should be
    caught and re-raised as an SelenePanicError.
    """

    runner = build(qis_file("nonclifford"))
    with pytest.raises(SelenePanicError, match="not representable") as exception_info:
        shots = QsysResult(
            runner.run_shots(
                Stim(), n_qubits=3, n_shots=10, timeout=datetime.timedelta(seconds=1)
            )
        )


def test_corrupted_plugin():
    """
    On the python side, we only check that plugin files exist.
    They can still fail when we invoke the selene binary, so demand
    that this is detected and reports back to the user in a
    reasonable way.
    """
    from selene_core import Runtime

    class CorruptedPlugin(Runtime):
        def __init__(self):
            import tempfile

            directory = Path(tempfile.mkdtemp())
            dest = directory / "broken_plugin.so"
            with open(dest, "w") as f:
                f.write("this is not a shared object")
            self.path = dest

        def get_init_args(self):
            return []

        @property
        def library_file(self):
            return self.path

        def __del__(self):
            self.path.unlink(missing_ok=True)

    runner = build(qis_file("broken_plugin"))
    with pytest.raises(
        SeleneRuntimeError, match=r"Failed to load runtime plugin"
    ) as exception_info:
        shots = QsysResult(
            runner.run_shots(
                Quest(),
                n_qubits=1,
                n_shots=10,
                runtime=CorruptedPlugin(),
                timeout=datetime.timedelta(seconds=1),
            )
        )


def test_metrics(snapshot):
    runner = build(qis_file("metrics"))
    metric_store = MetricStore()
    shots = QsysResult(
        runner.run_shots(
            Quest(),
            n_qubits=3,
            n_shots=10,
            event_hook=metric_store,
        )
    )
    # as there is no control flow in our program, user and runtime
    # metrics should be identical
    assert len(metric_store.shots) == 10
    first_shot_metrics = metric_store.shots[0]
    for shot_metrics in metric_store.shots[1:]:
        assert "user_program" in shot_metrics
        assert "post_runtime" in shot_metrics
        assert shot_metrics["user_program"] == metric_store.shots[0]["user_program"]
        assert shot_metrics["post_runtime"] == metric_store.shots[0]["post_runtime"]

    # and check they don't change between commits. They ARE allowed
    # to change, but must be updated manually to prevent *unintended*
    # changes.
    snapshot.assert_match(yaml.dump(first_shot_metrics), "metrics")


def test_metrics_on_exit(snapshot):
    runner = build(qis_file("metrics_on_exit"))
    metric_store = MetricStore()
    shots = QsysResult(
        runner.run_shots(
            Quest(),
            n_qubits=3,
            n_shots=10,
            event_hook=metric_store,
        )
    )
    # as there is no control flow in our program, user and runtime
    # metrics should be identical
    assert len(metric_store.shots) == 10
    first_shot_metrics = metric_store.shots[0]
    for shot_metrics in metric_store.shots[1:]:
        assert "user_program" in shot_metrics
        assert "post_runtime" in shot_metrics
        assert shot_metrics["user_program"] == metric_store.shots[0]["user_program"]
        assert shot_metrics["post_runtime"] == metric_store.shots[0]["post_runtime"]

    # and check they don't change between commits. They ARE allowed
    # to change, but must be updated manually to prevent *unintended*
    # changes.
    snapshot.assert_match(yaml.dump(first_shot_metrics), "metrics_on_exit")


def test_circuit_output():
    try:
        import pytket
    except ImportError:
        pytest.skip("pytket not available")
        return

    runner = build(qis_file("circuit"))
    circuits = CircuitExtractor()
    # ok, so let's construct some classical replay data
    # to run through all classical branches
    measurements = [[False], [True, False], [True, True, True]]

    shots = QsysResult(
        runner.run_shots(
            simulator=ClassicalReplay(measurements=measurements),
            n_qubits=3,
            n_shots=3,
            event_hook=circuits,
        )
    )
    assert len(circuits.shots) == 3
    # the first run should have only one qubit, one H gate, and one measurement
    user_circuit = circuits.shots[0].get_user_circuit()
    expected_circuit = pytket.Circuit(1, 1)
    expected_circuit.Reset(0)
    expected_circuit.PhasedX(0.5, 1.5, 0)
    expected_circuit.Rz(1, 0)
    expected_circuit.Measure(0, 0)
    assert user_circuit == expected_circuit

    # the second run would operate on the same qubit twice
    user_circuit = circuits.shots[1].get_user_circuit()
    expected_circuit = pytket.Circuit(1, 1)
    expected_circuit.Reset(0)
    expected_circuit.PhasedX(0.5, 1.5, 0)
    expected_circuit.Rz(1, 0)
    expected_circuit.Measure(0, 0)
    expected_circuit.Reset(0)
    expected_circuit.PhasedX(0.5, 1.5, 0)
    expected_circuit.Rz(1, 0)
    expected_circuit.Measure(0, 0)
    assert user_circuit == expected_circuit

    # the third would operate on the same qubit three times
    user_circuit = circuits.shots[2].get_user_circuit()
    expected_circuit = pytket.Circuit(1, 1)
    expected_circuit.Reset(0)
    expected_circuit.PhasedX(0.5, 1.5, 0)
    expected_circuit.Rz(1, 0)
    expected_circuit.Measure(0, 0)
    expected_circuit.Reset(0)
    expected_circuit.PhasedX(0.5, 1.5, 0)
    expected_circuit.Rz(1, 0)
    expected_circuit.Measure(0, 0)
    expected_circuit.Reset(0)
    expected_circuit.PhasedX(0.5, 1.5, 0)
    expected_circuit.Rz(1, 0)
    expected_circuit.Measure(0, 0)
    assert user_circuit == expected_circuit


def test_measurement_output():
    runner = build(qis_file("measurement_output"))
    measlog = MeasurementExtractor()
    got = list(runner.run(Quest(), verbose=True, n_qubits=4, event_hook=measlog))

    expected_user = [("q2", 1), ("q3", 0)]
    expected_meas_strs = [
        "MEAS:INTARR:[0, 1]",
        "MEAS:INTARR:[1, 1]",
        "MEAS:INTARR:[2, 1]",
        "MEASLEAKED:INTARR:[3, 0]",
    ]
    assert got == expected_user
    assert [str(entry) for entry in measlog.log_entries[0]] == expected_meas_strs


def test_measurement_output_multishot():
    n_shots = 10
    runner = build(qis_file("measurement_output"))
    measlog = MeasurementExtractor()
    shots = runner.run_shots(
        Quest(), verbose=True, n_qubits=4, n_shots=10, event_hook=measlog
    )

    expected_user = [("q2", 1), ("q3", 0)]
    expected_meas_strs = [
        "MEAS:INTARR:[0, 1]",
        "MEAS:INTARR:[1, 1]",
        "MEAS:INTARR:[2, 1]",
        "MEASLEAKED:INTARR:[3, 0]",
    ]
    for shot_user in shots:
        assert list(shot_user) == expected_user
    for shot_meas in measlog:
        assert [str(entry) for entry in shot_meas] == expected_meas_strs


def test_cy():
    """Test CY is implemented correctly."""
    n_shots = 10
    two_qb_bases = ["00", "01", "10", "11"]

    res = QsysResult(
        build(qis_file("cy_test")).run_shots(
            Quest(),
            n_qubits=2,
            n_shots=n_shots,
        )
    ).register_counts()

    # map from input state to expected output state
    # not sensitive to Z errors on qubits just before the measurement
    expected_map = {
        "00": "01",
        "01": "00",
        "10": "10",
        "11": "11",
    }
    for basis in two_qb_bases:
        assert dict(res[basis]) == {expected_map[basis]: n_shots}


def test_cz():
    """Test CZ is implemented correctly."""
    n_shots = 10

    res = QsysResult(
        build(qis_file("cz_test")).run_shots(
            Quest(),
            n_qubits=2,
            n_shots=n_shots,
            random_seed=42,
        )
    ).register_counts()["c"]

    # mostly 10, small probability of 00, but not hit for 10 shots
    assert res == {"10": n_shots}
