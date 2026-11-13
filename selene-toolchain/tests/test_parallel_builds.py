"""Build the same explicit plans with different worker limits."""

import concurrent.futures
import json
import subprocess
import sys

import pytest

from selene_toolchain import Bitcode, Executor, Store, Toolchain


def compile_ir(toolchain, source):
    return toolchain.compile(Bitcode.from_bytes(source.encode())).plan()


def test_parallel_inputs_keep_their_order_and_cache_keys(tmp_path):
    toolchain = Toolchain.bundled()
    functions = [
        compile_ir(toolchain, f"define i32 @f{i}() {{ ret i32 {i} }}") for i in range(8)
    ]
    calls = "\n".join(f"%v{i} = call i32 @f{i}()" for i in range(8))
    main = compile_ir(
        toolchain,
        "\n".join(f"declare i32 @f{i}()" for i in range(8))
        + f"\ndefine i32 @main() {{ {calls}\nret i32 0 }}",
    )
    empty = compile_ir(toolchain, "")
    # Include both a reused plan and a separately constructed equivalent plan.
    # Their identical cache keys should give us just one compiled empty object,
    # even if different workers request it at the same time.
    inputs = [main, *functions, empty, empty, compile_ir(toolchain, "")]
    builder = toolchain.link_executable()
    for item in inputs:
        builder = builder.object(item)
    plan = builder.plan()
    directory = tmp_path / "store"
    serial = Store.local(directory)
    first = serial.build(plan)
    expected = [serial.build(item).artifact.digest for item in inputs]

    parallel = Executor(serial, jobs=4)
    other = Executor(serial, jobs=2)
    assert parallel.store is other.store
    cached = parallel.build(plan)
    assert cached.cache_hit
    assert cached.key == first.key
    assert cached.artifact.digest == first.artifact.digest
    assert other.build(plan).cache_hit

    serial.clean()
    rebuilt = parallel.build(plan)
    assert not rebuilt.cache_hit
    assert rebuilt.key == first.key
    record = json.loads((directory / "builds" / f"{rebuilt.key}.json").read_text())
    assert [item["digest"] for item in record["description"]["inputs"]] == expected
    assert len(list((directory / "builds").glob("*.json"))) == 11
    output = tmp_path / "program.exe"
    rebuilt.artifact.copy_to(output)
    subprocess.run([str(output)], check=True)


@pytest.mark.parametrize("jobs", [2, 4])
def test_parallel_failure_leaves_the_store_usable(tmp_path, jobs):
    toolchain = Toolchain.bundled()
    store = Store.local(tmp_path / "store")
    executor = Executor(store, jobs=jobs)
    good = compile_ir(toolchain, "define i32 @main() { ret i32 0 }")
    # Parsing succeeds, but the instruction uses its own result before that
    # result exists. The verifier should reject it when a worker compiles it.
    bad = compile_ir(toolchain, "define i32 @bad() { %x = add i32 %x, 1 ret i32 %x }")
    plan = toolchain.link_executable().object(good).object(bad).plan()
    with pytest.raises(
        RuntimeError, match="Only PHI nodes may reference their own value"
    ):
        executor.build(plan)
    # A failed dependency mustn't leave a successful link record behind. Good
    # siblings may have finished, and their objects are safe to reuse.
    records = [
        json.loads(p.read_text()) for p in (store.root / "builds").glob("*.json")
    ]
    assert all(record["kind"] == "object" for record in records)
    fixed = toolchain.link_executable().object(good).plan()
    assert not executor.build(fixed).cache_hit
    assert executor.build(fixed).cache_hit


@pytest.mark.skipif(
    sys.platform == "win32", reason="DLL deployment is separate from linking"
)
def test_nested_parallel_plans_share_dependencies(tmp_path):
    toolchain = Toolchain.bundled()
    store = Store.local(tmp_path / "store")
    executor = Executor(store, jobs=2)
    common = compile_ir(toolchain, "")
    library = (
        toolchain.link_shared_library()
        .object(common)
        .object(compile_ir(toolchain, "define i32 @answer() { ret i32 42 }"))
        .plan()
    )
    main = compile_ir(
        toolchain,
        "declare i32 @answer()\n"
        "define i32 @main() { %v = call i32 @answer() "
        "%r = sub i32 %v, 42 ret i32 %r }",
    )
    plan = (
        toolchain.link_executable().object(main).object(common).object(library).plan()
    )
    result = executor.build(plan)
    assert len(list((store.root / "builds").glob("*.json"))) == 5
    output = tmp_path / "program"
    result.artifact.copy_to(output)
    subprocess.run([str(output)], check=True)


def test_parallel_executors_accept_concurrent_callers(tmp_path):
    toolchain = Toolchain.bundled()
    store = Store.local(tmp_path / "store")
    executor = Executor(store, jobs=2)
    plans = [
        compile_ir(toolchain, f"define i32 @f{i}() {{ ret i32 {i} }}")
        for i in range(12)
    ]
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as callers:
        results = list(callers.map(executor.build, plans * 2))
    assert sum(not result.cache_hit for result in results) == len(plans)
    assert len({result.artifact.digest for result in results}) == len(plans)


@pytest.mark.parametrize("jobs", [0, -1])
def test_invalid_worker_limits(tmp_path, jobs):
    with pytest.raises(ValueError, match="jobs must be greater than zero"):
        Executor(Store.local(tmp_path), jobs=jobs)


def test_worker_limit_is_exposed(tmp_path):
    store = Store.local(tmp_path)
    serial = Executor(store)
    parallel = Executor(store, jobs=3)
    assert serial.jobs == 1
    assert parallel.jobs == 3
    assert serial.store is store
    assert parallel.store is store


def test_executor_uses_the_default_store_when_unspecified():
    assert Executor().store is Store.default()
