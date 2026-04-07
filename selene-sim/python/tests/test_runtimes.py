from selene_sim.build import build
from selene_sim import Quest, SimpleRuntime, SoftRZRuntime
from selene_sim.event_hooks import MetricStore
from conftest import guppy_python_file, qis_file, register_inline_guppy_programs


INLINE_GUPPY_PROGRAMS = {
    "runtime_diff": """@guppy
def main() -> None:
    q0: qubit = qubit()
    q1: qubit = qubit()
    q2: qubit = qubit()
    h(q0)
    cx(q0, q1)
    cx(q1, q2)
    result("c0", measure(q0))
    result("c1", measure(q1))
    result("c2", measure(q2))
""",
}

INLINE_GUPPY_PROGRAMS = {
    name: guppy_python_file(source) for name, source in INLINE_GUPPY_PROGRAMS.items()
}
register_inline_guppy_programs(INLINE_GUPPY_PROGRAMS, artifact_kind="qis")


def test_simple_vs_softrz():
    runner = build(qis_file("runtime_diff"))
    simulator = Quest(random_seed=561278)

    simple_metric_store = MetricStore()
    simple = dict(
        runner.run(
            simulator,
            runtime=SimpleRuntime(),
            verbose=True,
            n_qubits=4,
            event_hook=simple_metric_store,
        )
    )
    simple_metrics = simple_metric_store.shots[0]

    soft_metric_store = MetricStore()
    soft = dict(
        runner.run(
            simulator,
            runtime=SoftRZRuntime(),
            verbose=True,
            n_qubits=4,
            event_hook=soft_metric_store,
        )
    )
    soft_metrics = soft_metric_store.shots[0]

    assert simple == soft, (
        f"Simple and SoftRZ runtimes produced different results: {simple} vs {soft}"
    )
    assert soft_metrics["user_program"] == simple_metrics["user_program"], (
        f"User program metrics differ: {soft_metrics['user_program']} vs {simple_metrics['user_program']}"
    )

    assert simple_metrics["post_runtime"]["rz_batch_count"] > 0
    assert simple_metrics["post_runtime"]["rz_individual_count"] > 0
    assert soft_metrics["post_runtime"]["rz_batch_count"] == 0
    assert soft_metrics["post_runtime"]["rz_individual_count"] == 0

    def sum_up(metrics: dict[str, int], category: str):
        return sum(
            metrics["post_runtime"][key]
            for key in metrics["post_runtime"]
            if key.endswith(category)
        )

    assert sum_up(soft_metrics, "batch_count") < sum_up(simple_metrics, "batch_count")
    assert sum_up(soft_metrics, "individual_count") < sum_up(
        simple_metrics, "individual_count"
    )
