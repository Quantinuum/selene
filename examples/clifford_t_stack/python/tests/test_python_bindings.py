from __future__ import annotations

from pathlib import Path

from selene_sim.build import build
from selene_sim.event_hooks import MetricStore
from selene_sim.interactive import InteractiveFullStack, InteractiveSimulator

from selene_example_clifford_t_stack import (
    CliffordTErrorModel,
    CliffordTInterface,
    CliffordTQrackSimulator,
    CliffordTRuntime,
    clifford_t_gateset,
    cnot,
    h,
    t,
    x,
)


PROGRAMS_PATH = Path(__file__).parent / "programs"


def test_interactive_simulator_accepts_clifford_t_gates_from_python():
    gateset = clifford_t_gateset()
    sim = InteractiveSimulator(
        simulator=CliffordTQrackSimulator(),
        n_qubits=2,
        gateset=gateset,
    )

    assert sim.emitted_gateset is not None
    assert [definition.name for definition in sim.emitted_gateset] == [
        "H",
        "S",
        "Sdg",
        "T",
        "Tdg",
        "X",
        "CNOT",
    ]

    sim.gate(h(0))
    sim.gate(t(0))
    sim.gate(x(0))
    sim.gate(cnot(0, 1))

    m0 = sim.measure(0)
    m1 = sim.measure(1)
    assert isinstance(m0, bool)
    assert m1 == m0
    assert sim.get_metrics() == {
        "gates_seen": 4,
        "measurements": 2,
        "engine_fallbacks": 0,
    }


def test_interactive_simulator_hth_stats():
    gateset = clifford_t_gateset()
    sim = InteractiveSimulator(
        simulator=CliffordTQrackSimulator(random_seed=1234),
        n_qubits=1,
        gateset=gateset,
    )

    outcomes = [0, 0]

    shots = 1000
    for _ in range(shots):
        sim.reset(0)
        sim.gate(h(0))
        sim.gate(t(0))
        sim.gate(h(0))
        meas = sim.measure(0)
        outcomes[meas] += 1

    assert 0.8 < outcomes[0] / shots < 0.9
    assert 0.1 < outcomes[1] / shots < 0.2


def test_interactive_full_stack_uses_example_runtime_error_model_and_simulator():
    gates = clifford_t_gateset()
    stack = InteractiveFullStack(
        runtime=CliffordTRuntime(),
        error_model=CliffordTErrorModel(),
        simulator=CliffordTQrackSimulator(),
        n_qubits=2,
        gateset=gates,
    )

    q0 = stack.qalloc()
    q1 = stack.qalloc()
    stack.gate(gates.H(q0=q0.id))
    stack.gate(gates.T(q0=q0.id))
    stack.gate(gates.CNOT(control=q0.id, target=q1.id))

    m0 = stack.measure(q0)
    m1 = stack.measure(q1)
    assert isinstance(m0, bool)
    assert m1 == m0


def test_selene_build_runs_a_compiled_clifford_t_user_program():
    metric_store = MetricStore()
    runner = build(
        PROGRAMS_PATH / "bell.ct.c",
        interface=CliffordTInterface(),
        strict=True,
    )

    shots = runner.run_shots(
        simulator=CliffordTQrackSimulator(),
        runtime=CliffordTRuntime(),
        error_model=CliffordTErrorModel(),
        event_hook=metric_store,
        n_qubits=2,
        n_shots=1,
        random_seed=1234,
    )

    shot_dicts = [dict(shot) for shot in shots]
    assert len(shot_dicts) == 1
    assert shot_dicts[0]["q1"] == shot_dicts[0]["q0"]
    metrics = metric_store.shots[0]
    assert metrics["user_program"]["gate:T:count"] == 1
    assert metrics["post_runtime"]["gate:T:individual_count"] == 1
    assert metrics["error_model"]["injected_x"] == 2
    assert metrics["simulator"]["gates_seen"] == 5
    assert metrics["simulator"]["measurements"] == 2
    assert metrics["simulator"]["engine_fallbacks"] == 0
