"""Compare uncached and cached multi-module builds with bounded worker pools.

Run from the repository environment after building the Python extension:
    python selene-toolchain/benchmarks/parallel_builds.py
"""

import argparse
from pathlib import Path
from statistics import median
from tempfile import TemporaryDirectory
from time import perf_counter

from selene_toolchain import Bitcode, Executor, Store, Toolchain


def make_plan(toolchain, modules, functions):
    builder = toolchain.link_executable()
    main = Bitcode.from_bytes(b"define i32 @main() { ret i32 0 }")
    builder = builder.object(toolchain.compile(main).plan())
    for module in range(modules):
        source = "\n".join(
            f"""define i64 @f_{module}_{index}(i64 %x) {{
                %a = mul i64 %x, {index + 1}
                %b = xor i64 %a, {module + index}
                %c = add i64 %b, 17
                ret i64 %c
            }}"""
            for index in range(functions)
        )
        builder = builder.object(
            toolchain.compile(Bitcode.from_bytes(source.encode()))
            .optimisation(2)
            .plan()
        )
    return builder.plan()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--modules", type=int, default=16)
    parser.add_argument("--functions", type=int, default=128)
    parser.add_argument("--repeat", type=int, default=3)
    parser.add_argument("--jobs", type=int, nargs="+", default=[1, 2, 4])
    args = parser.parse_args()
    if min(args.modules, args.functions, args.repeat, *args.jobs) < 1:
        parser.error("module, function, repetition and worker counts must be positive")
    plan = make_plan(Toolchain.bundled(), args.modules, args.functions)
    samples = {jobs: {"cold": [], "cached": []} for jobs in args.jobs}
    with TemporaryDirectory() as directory:
        store = Store.local(Path(directory))
        executors = {jobs: Executor(store, jobs=jobs) for jobs in args.jobs}
        # Initialise LLVM's lazy code-generation state before timing. We evict
        # the build records for each cold run, while keeping the OS file cache
        # warm so the comparison measures build scheduling rather than disk I/O.
        expected = executors[args.jobs[0]].build(plan).key
        for repetition in range(args.repeat):
            order = (
                args.jobs[repetition % len(args.jobs) :]
                + args.jobs[: repetition % len(args.jobs)]
            )
            for jobs in order:
                executor = executors[jobs]
                store.clean()
                start = perf_counter()
                result = executor.build(plan)
                samples[jobs]["cold"].append(perf_counter() - start)
                assert not result.cache_hit
                assert result.key == expected
                for _ in range(5):
                    start = perf_counter()
                    result = executor.build(plan)
                    samples[jobs]["cached"].append(perf_counter() - start)
                    assert result.cache_hit
                    assert result.key == expected
    print(f"{args.modules} modules × {args.functions} functions; median seconds")
    print("jobs\tuncached\tcached")
    for jobs, times in samples.items():
        print(f"{jobs}\t{median(times['cold']):.4f}\t{median(times['cached']):.4f}")


if __name__ == "__main__":
    main()
