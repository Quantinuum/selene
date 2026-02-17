from math import pi
from pathlib import Path
import pytest
import tempfile

import numpy as np

from selene_sim import Quest
from selene_sim.interactive import InteractiveFullStack, InteractiveSimulator


def test_interactive_full_stack_event_hooks():
    from selene_sim.event_hooks import CircuitExtractor, MetricStore, MultiEventHook

    # Set up a full stack with both a circuit extractor and a metric store as event hooks, and run some operations to ensure they are properly integrated.
    circuit_extractor = CircuitExtractor()
    metric_store = MetricStore()
    hook = MultiEventHook([circuit_extractor, metric_store])
    s = InteractiveFullStack(simulator=Quest(), n_qubits=10, event_hook=hook)
    metrics = metric_store.shots[0]
    extractor = circuit_extractor.shots[0]
    # Allocate 3 qubits
    assert metrics["user_program"]["qalloc_count"] == 0
    assert metrics["user_program"]["currently_allocated"] == 0
    assert metrics["user_program"]["max_allocated"] == 0
    qs = [s.qalloc() for _ in range(3)]
    assert metrics["user_program"]["qalloc_count"] == 3
    assert metrics["user_program"]["currently_allocated"] == 3
    assert metrics["user_program"]["max_allocated"] == 3
    # We can now qfree those - observe the impact on currently_allocated and the lack of impact on qalloc_count and max_allocated
    assert metrics["user_program"]["qfree_count"] == 0
    s.qfree(qs[0])
    s.qfree(qs[1])
    # leave qs[2] allocated for these checks
    assert metrics["user_program"]["qfree_count"] == 2
    assert metrics["user_program"]["currently_allocated"] == 1
    assert metrics["user_program"]["max_allocated"] == 3
    spare_qubit = qs[2]  # leave this hanging for the next allocations
    qs = [s.qalloc() for _ in range(3)]
    assert (
        metrics["user_program"]["qalloc_count"] == 6
    )  # so far we've called qalloc 6 times
    assert (
        metrics["user_program"]["currently_allocated"] == 4
    )  # spare qubit + 3 new ones
    assert (
        metrics["user_program"]["max_allocated"] == 4
    )  # we only had a max of 4 allocated at one time.
    s.qfree(
        spare_qubit
    )  # free the spare qubit, we don't need to keep track of it for the rest of the test

    # Reset our 3 fresh qubits
    assert metrics["user_program"]["reset_count"] == 0
    [s.reset(q) for q in qs]
    assert metrics["user_program"]["reset_count"] == 3
    # We can apply some gates and check that the metrics are properly updated
    # We'll build a GHZ state. As we only have access to the native gateset and
    # not (yet) a direct hadamard or cnot, I'll write it out verbatim.
    assert metrics["user_program"]["rxy_count"] == 0
    assert metrics["user_program"]["rzz_count"] == 0
    # h(q0)
    s.rxy(qs[0], pi / 2, -pi / 2)
    s.rz(qs[0], pi)
    # cx(q0, q1)
    s.rxy(qs[1], -pi / 2, pi / 2)
    s.rzz(qs[0], qs[1], pi / 2)
    s.rz(qs[0], -pi / 2)
    s.rxy(qs[1], pi / 2, pi)
    s.rz(qs[1], -pi / 2)
    # cx(q1, q2)
    s.rxy(qs[2], -pi / 2, pi / 2)
    s.rzz(qs[1], qs[2], pi / 2)
    s.rz(qs[1], -pi / 2)
    s.rxy(qs[2], pi / 2, pi)
    s.rz(qs[2], -pi / 2)
    # Check that the metrics reflect the gates we've applied
    assert metrics["user_program"]["rxy_count"] == 5
    assert metrics["user_program"]["rzz_count"] == 2
    assert metrics["user_program"]["rz_count"] == 5

    # We can get the state of the qubits.
    state = s.get_state(qs).get_single_state()
    np.testing.assert_almost_equal(
        state, [1 / np.sqrt(2), 0, 0, 0, 0, 0, 0, 1 / np.sqrt(2)]
    )

    # Now ensure the simulator measures accordingly
    assert metrics["user_program"]["measure_request_count"] == 0
    assert metrics["user_program"]["measure_read_count"] == 0
    # We can measure directly
    measurements = [s.measure(qs[0])]
    assert metrics["user_program"]["measure_request_count"] == 1
    assert metrics["user_program"]["measure_read_count"] == 1
    # Or we can be lazy and encourage some parallelism in the runtime if available.
    r1 = s.lazy_measure(qs[1])
    r2 = s.lazy_measure(qs[2])
    assert metrics["user_program"]["measure_request_count"] == 3
    assert metrics["user_program"]["measure_read_count"] == 1
    measurements.append(s.future_read_bool(r1))
    measurements.append(s.future_read_bool(r2))
    assert metrics["user_program"]["measure_request_count"] == 3
    assert metrics["user_program"]["measure_read_count"] == 3
    assert measurements[0] in (True, False)
    assert measurements[1] == measurements[2] == measurements[0]
    # As measurement necessarily forces the runtime to have emitted instructions, we can now check the post-runtime metrics
    # As we're using the SimpleRuntime, all gates are applied (no optimisation, no soft RZ gate, etc)
    assert metrics["post_runtime"]["measure_individual_count"] == 3
    assert metrics["post_runtime"]["rxy_individual_count"] == 5
    assert metrics["post_runtime"]["rz_individual_count"] == 5
    assert metrics["post_runtime"]["rzz_individual_count"] == 2
    # We can also check the circuit extractor

    output = extractor.get_optimiser_output()
    batches = [e for e in output if e["op"] == "BatchStart"]
    assert len(batches) == 18


def test_interactive_simulator():
    sim = InteractiveSimulator(simulator=Quest(random_seed=1234), n_qubits=10)
    # Some simple checks on measurement and postselection
    assert sim.measure(0) == 0
    sim.rxy(0, pi, 0)
    assert sim.measure(0) == 1
    assert sim.get_metrics()["cumulative_postselect_probability"] == 1.0
    sim.reset(0)
    sim.rxy(0, pi / 2, 0)
    sim.rxy(1, pi / 2, 0)
    sim.postselect(0, True)
    sim.postselect(1, False)
    assert sim.measure(0)
    assert not sim.measure(1)
    # As we've postselected on two 50/50 outcomes, the cumulative postselect probability should be ~0.25
    assert sim.get_metrics()["cumulative_postselect_probability"] == pytest.approx(0.25)

    # Now make a GHZ state on qubits 1, 2, 3, dump the state and check amplitudes, postselect one of the qubits, then assert measurements are consistent.
    # h(1)
    sim.rxy(1, pi / 2, -pi / 2)
    sim.rz(1, pi)
    # cx(1, 2)
    sim.rxy(2, -pi / 2, pi / 2)
    sim.rzz(1, 2, pi / 2)
    sim.rz(1, -pi / 2)
    sim.rxy(2, pi / 2, pi)
    sim.rz(2, -pi / 2)
    # cx(2, 3)
    sim.rxy(3, -pi / 2, pi / 2)
    sim.rzz(2, 3, pi / 2)
    sim.rz(2, -pi / 2)
    sim.rxy(3, pi / 2, pi)
    sim.rz(3, -pi / 2)

    # get a temp file
    with tempfile.NamedTemporaryFile() as f:
        dump_file = Path(f.name)
        sim.dump_state(dump_file, [1, 2, 3])
        from selene_quest_plugin import SeleneQuestState

        state = SeleneQuestState.parse_from_file(
            dump_file, cleanup=False
        ).get_single_state()

        np.testing.assert_almost_equal(
            state, [1 / np.sqrt(2), 0, 0, 0, 0, 0, 0, 1 / np.sqrt(2)]
        )

    sim.postselect(2, True)
    assert sim.measure(1)
    assert sim.measure(2)
    assert sim.measure(3)
