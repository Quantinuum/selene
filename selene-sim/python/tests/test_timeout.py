import datetime
import time
from textwrap import dedent

import pytest
from hugr.qsystem.result import QsysResult
from selene_sim import Quest
from selene_sim.build import build
from selene_sim.exceptions import SeleneTimeoutError, SeleneStartupError
from selene_sim.timeout import Timeout


def test_timeout(compiled_guppy):
    # if a timeout is set at 0, there is no time provided for any selene clients
    # to startup and connect to the results stream. As such we expect a SeleneTimeoutError

    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, measure, h
        from guppylang.std.builtins import result

        @guppy
        def main() -> None:
            while True:
                q0: qubit = qubit()
                h(q0)
                result("r", measure(q0))
        """
    )

    llvm_file = compiled_guppy(
        program_name="non_terminating_with_results",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)

    # test zero timeout
    with pytest.raises(
        SeleneStartupError, match="Timed out waiting for a client to connect for shot 0"
    ):
        QsysResult(
            runner.run_shots(
                Quest(random_seed=1234),
                n_qubits=1,
                n_shots=100,
                timeout=datetime.timedelta(seconds=0),
            )
        )

    # test overall timeout
    #
    # if a timeout is set at 1, there is plenty of time for the selene clients to connect,
    # but as the program is an infinite loop, we expect a SeleneTimeoutError after 1 second.
    start_time = time.perf_counter()
    with pytest.raises(SeleneTimeoutError, match="Expired timers: 'overall'"):
        QsysResult(
            runner.run_shots(
                Quest(random_seed=1234),
                n_qubits=1,
                n_shots=100,
                timeout=datetime.timedelta(seconds=1),
            )
        )
    end_time = time.perf_counter()
    assert 1 <= end_time - start_time < 2, "Timeout should have taken around 1 second"

    # test per-shot timeout
    #
    # In the above, we used a timeout with a timedelta. This sets the overall run_shots
    # duration. Now let's look at a per-shot timeout.
    start_time = time.perf_counter()
    with pytest.raises(SeleneTimeoutError, match="Expired timers: 'per_shot'"):
        QsysResult(
            runner.run_shots(
                Quest(random_seed=1234),
                n_qubits=1,
                n_shots=100,
                timeout=Timeout(
                    overall=datetime.timedelta(seconds=10),
                    per_shot=datetime.timedelta(seconds=1),
                ),
            )
        )
    end_time = time.perf_counter()
    assert 0.9 <= end_time - start_time < 2, (
        "Per-shot timeout should have taken around 1 second"
    )


def test_timeout_per_result(compiled_guppy):
    # Now let's look at the case where the infinite loop doesn't emit results.
    # We have an additional timeout setting, 'per_result', which is useful when
    # we expect a relatively steady stream of outputs from the program.

    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.builtins import result

        @guppy
        def recurse(i: int) -> int:
            # oops, infinite recursion!
            return recurse(i + 1)

        @guppy
        def main() -> None:
            result("i", recurse(0))

        """
    )

    llvm_file = compiled_guppy(
        program_name="non_terminating_without_results",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)
    start_time = time.perf_counter()
    with pytest.raises(SeleneTimeoutError, match="Expired timers: 'per_result'"):
        shots = QsysResult(
            runner.run_shots(
                Quest(random_seed=1234),
                n_qubits=1,
                n_shots=100,
                timeout=Timeout(
                    overall=datetime.timedelta(seconds=10),
                    per_shot=datetime.timedelta(seconds=5),
                    per_result=datetime.timedelta(seconds=1),
                ),
            )
        )
    end_time = time.perf_counter()
    assert 0.8 <= end_time - start_time < 2, (
        "Per-result timeout should have taken around 1 second"
    )
