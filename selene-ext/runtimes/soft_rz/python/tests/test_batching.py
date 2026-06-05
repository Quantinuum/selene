from textwrap import dedent
import json

from selene_sim.build import build
from selene_sim.backends import Quest, SoftRZRuntime
from selene_sim.event_hooks import MetricStore, CircuitExtractor, MultiEventHook


def test_batching_behaviour(snapshot, compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang.decorator import guppy
        from guppylang.std.quantum import qubit, measure_array, h, cx, x, crz
        from guppylang.std.builtins import result, array
        from guppylang.std.angles import pi

        @guppy
        def main() -> None:
            qs = array(qubit() for _ in range(8))
            # qft algorithm
            for i in range(8):
                h(qs[i])
                for j in range(8-i-1):
                    crz(qs[i], qs[8-j-1], pi/(2**i))
            h(qs[7])
            result("measurements", array(m.read() for m in measure_array(qs)))
        """
    )

    llvm_file = compiled_guppy(
        program_name="qft_8qb",
        guppy_source=guppy_source,
    )

    # provide some dummy timing information for the runtimes
    defaults = {
        "duration_ns_rxy": 1_200_000,  # 1.2ms
        "duration_ns_rzz": 2_500_000,  # 2.5ms
        "duration_ns_measure": 3_000_000,  # 3ms
        "duration_ns_reset": 500_000,  # 0.5ms
        "duration_ns_measure_leaked": 4_000_000,  # 4ms
    }

    runner = build(llvm_file)
    simulator = Quest(random_seed=561278)

    runtimes = {n: SoftRZRuntime(max_batch_size=n, **defaults) for n in (1, 2, 8)}
    metrics = {}
    instructions = {}

    for batching, runtime in runtimes.items():
        metric_store = MetricStore()
        circuit_extractor = CircuitExtractor()
        event_hook = MultiEventHook([metric_store, circuit_extractor])
        results = dict(
            runner.run(
                simulator,
                runtime=runtime,
                n_qubits=8,
                event_hook=event_hook,
            )
        )
        metrics[batching] = metric_store.shots[0]
        instructions[batching] = circuit_extractor.shots[0]

    def sum_up(metric_dict: dict[str, dict[str, int]], category: str):
        return sum(
            metric_dict["post_runtime"][key]
            for key in metric_dict["post_runtime"]
            if key.endswith(category)
        )

    for batching, output_metrics in metrics.items():
        if batching == 1:
            # with no batching, we expect the batch count to be the same as the individual count, since each operation is its own batch.
            assert sum_up(output_metrics, "batch_count") == sum_up(
                output_metrics, "individual_count"
            )
        else:
            # with batching, we expect some operations to be batched together, so the batch count should be less than the individual count.
            assert sum_up(output_metrics, "batch_count") < sum_up(
                output_metrics, "individual_count"
            )
            # we also expect fewer batches compared with batch size 1
            assert sum_up(output_metrics, "batch_count") < sum_up(
                metrics[1], "batch_count"
            )
            # but the total number of individual operations should be the same regardless of batching
            assert sum_up(output_metrics, "individual_count") == sum_up(
                metrics[1], "individual_count"
            )

    for batching, output_instructions in instructions.items():
        format_friendly = [
            {"source": str(event.source), "operation": event.operation.to_dict()}
            for event in output_instructions
        ]
        snapshot.assert_match(
            json.dumps(format_friendly, indent=2),
            f"instructions_batching_{batching}.json",
        )
        trace = output_instructions.get_trace()
        snapshot.assert_match(
            trace.model_dump_json(indent=2),
            f"trace_batching_{batching}.json",
        )
