from textwrap import dedent
import json

from selene_sim.build import build
from selene_sim import Quest, SimpleRuntime, SoftRZRuntime
from selene_sim.event_hooks import MetricStore, CircuitExtractor, MultiEventHook


def test_simple_vs_softrz(snapshot, compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, measure, h, cx, x
        from guppylang.std.builtins import result

        @guppy
        def main() -> None:
            q0: qubit = qubit()
            q1: qubit = qubit()
            q2: qubit = qubit()
            x(q0)
            x(q1)
            cx(q0, q1)
            h(q0)
            h(q1)
            cx(q0, q1)
            cx(q1, q2)
            result("c0", measure(q0))
            result("c1", measure(q1))
            result("c2", measure(q2))
        """
    )

    llvm_file = compiled_guppy(
        program_name="simple_vs_softrz",
        guppy_source=guppy_source,
    )

    runner = build(llvm_file)
    simulator = Quest(random_seed=561278)

    simple_metric_store = MetricStore()
    simple_circuit_extractor = CircuitExtractor()
    simple_event_hook = MultiEventHook([simple_metric_store, simple_circuit_extractor])
    simple = dict(
        runner.run(
            simulator,
            runtime=SimpleRuntime(),
            verbose=True,
            n_qubits=4,
            event_hook=simple_event_hook,
        )
    )
    simple_metrics = simple_metric_store.shots[0]
    simple_instructions = simple_circuit_extractor.shots[0]

    soft_metric_store = MetricStore()
    soft_circuit_extractor = CircuitExtractor()
    soft_event_hook = MultiEventHook([soft_metric_store, soft_circuit_extractor])
    soft = dict(
        runner.run(
            simulator,
            runtime=SoftRZRuntime(),
            verbose=True,
            n_qubits=4,
            event_hook=soft_event_hook,
        )
    )
    soft_metrics = soft_metric_store.shots[0]
    soft_instructions = soft_circuit_extractor.shots[0]

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

    # snapshot the instruction logs for each mode.
    simple_events = [
        {"source": str(event.source), "operation": event.operation.to_dict()}
        for event in simple_instructions
    ]
    soft_events = [
        {"source": str(event.source), "operation": event.operation.to_dict()}
        for event in soft_instructions
    ]
    snapshot.assert_match(json.dumps(simple_events, indent=2), "simple_events.json")
    snapshot.assert_match(json.dumps(soft_events, indent=2), "soft_events.json")
