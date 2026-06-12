from textwrap import dedent
import json

from selene_sim.build import build
from selene_sim import Quest, SimpleRuntime, SoftRZRuntime
from selene_sim.event_hooks import MetricStore, CircuitExtractor, MultiEventHook


def _snapshot_instruction_log(shot_instructions):
    result = []
    for event in shot_instructions:
        operation = event.operation.to_dict()
        if event.duration_ns is not None:
            operation["duration_ns"] = 0
        result.append({"source": str(event.source), "operation": operation})
    return result


def test_simple_vs_softrz(snapshot, compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, measure_array, h, cx, x
        from guppylang.std.builtins import result

        @guppy
        def main() -> None:
            qs = array(qubit() for _ in range(3))
            x(qs[0])
            x(qs[1])
            cx(qs[0], qs[1])
            h(qs[0])
            h(qs[1])
            cx(qs[0], qs[1])
            cx(qs[1], qs[2])
            ms = measure_array(qs)
            result("c0", ms[0].read())
            result("c1", ms[1].read())
            result("c2", ms[2].read())
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
    simple_events = _snapshot_instruction_log(simple_instructions)
    soft_events = _snapshot_instruction_log(soft_instructions)
    snapshot.assert_match(json.dumps(simple_events, indent=2), "simple_events.json")
    snapshot.assert_match(json.dumps(soft_events, indent=2), "soft_events.json")
