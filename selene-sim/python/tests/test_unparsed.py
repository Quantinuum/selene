import yaml
import datetime
from pathlib import Path
from textwrap import dedent

from selene_sim.build import build
from selene_sim import Quest, Stim
from selene_sim.event_hooks import MetricStore
from selene_sim.exceptions import (
    SelenePanicError,
    SeleneStartupError,
    SeleneTimeoutError,
)
from selene_sim.result_handling.parse_shot import postprocess_unparsed_stream


def test_flip_some_unparsed(compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, x, measure
        from guppylang.std.builtins import result

        @guppy
        def main() -> None:
            q0: qubit = qubit()
            q1: qubit = qubit()
            q2: qubit = qubit()
            q3: qubit = qubit()
            x(q0)
            x(q2)
            x(q3)
            result("c0", measure(q0).read())
            result("c1", measure(q1).read())
            result("c2", measure(q2).read())
            result("c3", measure(q3).read())
        """
    )

    llvm_file = compiled_guppy(
        program_name="unparsed_flip_n4",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)
    got = list(runner.run(Quest(), verbose=True, n_qubits=4, parse_results=False))
    expected = [
        ("USER:BOOL:c0", 1),
        ("USER:BOOL:c1", 0),
        ("USER:BOOL:c2", 1),
        ("USER:BOOL:c3", 1),
    ]
    assert got == expected, f"expected {expected}, got {got}"


def test_flip_some_multishot_unparsed(compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, x, measure
        from guppylang.std.builtins import result

        @guppy
        def main() -> None:
            q0: qubit = qubit()
            q1: qubit = qubit()
            q2: qubit = qubit()
            q3: qubit = qubit()
            x(q0)
            x(q2)
            x(q3)
            result("c0", measure(q0).read())
            result("c1", measure(q1).read())
            result("c2", measure(q2).read())
            result("c3", measure(q3).read())
        """
    )

    llvm_file = compiled_guppy(
        program_name="unparsed_flip_n4",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)
    shots = runner.run_shots(
        Quest(), verbose=True, n_qubits=4, n_shots=10, parse_results=False
    )
    expected = [
        ("USER:BOOL:c0", 1),
        ("USER:BOOL:c1", 0),
        ("USER:BOOL:c2", 1),
        ("USER:BOOL:c3", 1),
    ]
    for shot in shots:
        got = list(shot)
        assert got == expected, f"expected {expected}, got {got}"


def test_flip_some_with_metrics_unparsed(snapshot, compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, x, measure
        from guppylang.std.builtins import result


        @guppy
        def main() -> None:
            q0: qubit = qubit()
            q1: qubit = qubit()
            q2: qubit = qubit()
            q3: qubit = qubit()
            x(q0)
            x(q2)
            x(q3)
            result("c0", measure(q0).read())
            result("c1", measure(q1).read())
            result("c2", measure(q2).read())
            result("c3", measure(q3).read())
        """
    )
    llvm_file = compiled_guppy(
        program_name="unparsed_flip_n4",
        guppy_source=guppy_source,
    )
    runner = build(llvm_file)
    store = MetricStore()
    got = list(
        runner.run(
            Quest(), verbose=True, n_qubits=4, parse_results=False, event_hook=store
        )
    )
    snapshot.assert_match(yaml.dump(got), "unparsed_metrics")


def test_array_results_unparsed(compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, x, measure_array, collect_measurements
        from guppylang.std.builtins import result

        @guppy
        def main() -> None:
            qs = array(qubit() for _ in range(10))
            for i in range(len(qs)):
                x(qs[i])
            bs = measure_array(qs)
            result("bools", collect_measurements(bs))
            result("floats", array(1.0 / 2**i for i in range(10)))
            result("ints", array(i for i in range(100)))
        """
    )

    llvm_file = compiled_guppy(
        program_name="array_results",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)

    shots = list(
        list(shot)
        for shot in runner.run_shots(
            Stim(), n_qubits=10, n_shots=20, parse_results=False, verbose=True
        )
    )

    expected = [
        ("USER:BOOLARR:bools", [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
        (
            "USER:FLOATARR:floats",
            [
                1.0,
                0.5,
                0.25,
                0.125,
                0.0625,
                0.03125,
                0.015625,
                0.0078125,
                0.00390625,
                0.001953125,
            ],
        ),
        ("USER:INTARR:ints", list(range(100))),
    ]

    assert len(shots) == 20
    for shot in shots:
        assert shot == expected


def test_exit_unparsed(compiled_guppy):
    """
    This test verifies the behaviour of exit(), which should stop the shot
    and add the error message to the result stream, but should then resume
    further shots.
    """

    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, h, measure
        from guppylang.std.builtins import result, exit

        @guppy
        def main() -> None:
            q = qubit()
            h(q)
            outcome = measure(q).read()
            if outcome:
                exit("Postselection failed", 42)
            result("c", outcome)
        """
    )

    llvm_file = compiled_guppy(
        program_name="exit_unparsed",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)

    # some should have measurements of 0, some should have no measurements.
    n_1 = 0
    n_0 = 0
    n_exit = 0
    for shot in runner.run_shots(
        Quest(),
        n_qubits=1,
        n_shots=100,
        random_seed=0,
        parse_results=False,
    ):
        shot = list(shot)
        if shot == [
            ("EXIT:INT:Postselection failed", 42),
        ]:
            n_exit += 1
        elif shot == [
            ("USER:BOOL:c", 1),
        ]:
            n_1 += 1
        elif shot == [
            ("USER:BOOL:c", 0),
        ]:
            n_0 += 1
        else:
            raise ValueError(f"Unexpected shot result: {shot}")
    # no shots should have provided a result of 1
    assert n_1 == 0
    # some shots should have provided a result of 0
    assert n_0 > 0
    # some shots should have exited
    assert n_exit > 0
    # we still have 100 shots total
    assert n_0 + n_exit == 100


def test_panic_unparsed(compiled_guppy):
    """
    This test verifies the behaviour of panic(), which should stop the shot
    and should not allow any further shots to be performed. Unlike with
    parse_results=True, the panic should be added into the results,
    and the panic should not result in an exception.
    """

    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, h, measure
        from guppylang.std.builtins import result, panic

        @guppy
        def main() -> None:
            q = qubit()
            h(q)
            outcome = measure(q).read()
            if outcome:
                panic("Postselection failed")
            result("c", outcome)
        """
    )

    llvm_file = compiled_guppy(
        program_name="panic_unparsed",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)
    shots, error = postprocess_unparsed_stream(
        runner.run_shots(
            Stim(),
            n_qubits=1,
            n_shots=100,
            random_seed=1,
            parse_results=False,
        )
    )
    assert error is not None
    assert isinstance(error, SelenePanicError)
    assert error.code == 1001
    assert error.message == "Postselection failed"

    assert len(shots) == 3
    assert shots[0] == [("USER:BOOL:c", 0)]
    assert shots[1] == [("USER:BOOL:c", 0)]
    assert shots[2] == [("EXIT:INT:Postselection failed", 1001)]


def test_infinite_loop_unparsed(compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, h, measure
        from guppylang.std.builtins import result

        @guppy
        def main() -> None:
            while True:
                q0: qubit = qubit()
                h(q0)
                result("r", measure(q0).read())
        """
    )

    llvm_file = compiled_guppy(
        program_name="infinite_loop",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)

    # give it no time to connect
    shots, error = postprocess_unparsed_stream(
        runner.run_shots(
            Quest(random_seed=1234),
            n_qubits=1,
            n_shots=100,
            timeout=datetime.timedelta(seconds=0),
            n_processes=4,
            parse_results=False,
        )
    )

    assert error is not None
    assert isinstance(error, SeleneStartupError)
    assert "Timed out waiting for a client to connect for shot 0" in error.message
    assert "Expired timers: 'overall'" in error.message
    assert len(shots) == 0

    # now give it some time to connect, but not enough to complete a shot (note: it is an infinite loop)
    shots, error = postprocess_unparsed_stream(
        runner.run_shots(
            Quest(random_seed=1234),
            n_qubits=1,
            n_shots=100,
            timeout=datetime.timedelta(seconds=1),
            n_processes=4,
            parse_results=False,
        )
    )
    assert error is not None
    assert isinstance(error, SeleneTimeoutError)
    assert "Timed out waiting for shot results" in error.message
    assert "Expired timers: 'overall'" in error.message


def test_memory_allocation_unparsed(compiled_guppy):
    """
    Quest cannot physically allocate more qubits than can be addressed in memory,
    regardless of RAM available. This test verifies that the process fails and that
    the failure is reported correctly.
    """

    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, x, measure_array, collect_measurements
        from guppylang.std.builtins import result

        @guppy
        def main() -> None:
            qs = array(qubit() for _ in range(70))
            for i in range(len(qs)):
                if i % 2 == 0:
                    x(qs[i])
            bs = measure_array(qs)
            result("bools", collect_measurements(bs))
        """
    )

    llvm_file = compiled_guppy(
        program_name="memory_allocation",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)

    shots, error = postprocess_unparsed_stream(
        runner.run_shots(
            Quest(),
            n_qubits=70,
            n_shots=100,
            parse_results=False,
        )
    )
    assert isinstance(error, SeleneStartupError)
    assert (
        "It is impossible to describe more than 60 qubits in a statevector on a computer with a 64-bit address space."
        in error.stderr
    )
    assert len(shots) == 0


def test_corrupted_plugin_unparsed(compiled_guppy):
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

        def get_init_args(self) -> list[str]:
            return []

        @property
        def library_file(self) -> Path:
            return self.path

        def __del__(self):
            self.path.unlink(missing_ok=True)

    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, h, measure
        from guppylang.std.builtins import result

        @guppy
        def main() -> None:
            q0: qubit = qubit()
            h(q0)
            result("c0", measure(q0).read())
        """
    )

    llvm_file = compiled_guppy(
        program_name="corrupted_plugin",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)

    shots, error = postprocess_unparsed_stream(
        runner.run_shots(
            Quest(),
            n_qubits=1,
            n_shots=10,
            runtime=CorruptedPlugin(),
            parse_results=False,
        )
    )
    assert len(shots) == 0
    assert isinstance(error, SeleneStartupError)
    assert "Failed to load runtime plugin" in error.stderr
