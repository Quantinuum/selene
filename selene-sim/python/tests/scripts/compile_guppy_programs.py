# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "guppylang~=0.21.6,!=0.21.7,!=0.21.9",
#   "selene-hugr-qis-compiler~=0.2.6",
# ]
# ///
"""Compile guppy programs to QIS LLVM IR snapshots for use in selene-sim tests.

The generated .ll files are stored in:
    selene-sim/python/tests/resources/qis/guppy/<name>-<platform>.ll

Platform-independent HUGR files are stored in:
    selene-sim/python/tests/resources/hugr/<name>.hugr

These files are committed to the repository. Re-run this script after updating
guppy programs or when upgrading guppylang/selene-hugr-qis-compiler.

Usage:
    uv run selene-sim/python/tests/scripts/compile_guppy_programs.py
"""

import platform
import sys
from pathlib import Path

from guppylang import guppy
from guppylang.std.angles import angle, pi
from guppylang.std.builtins import array, exit, panic, result
from guppylang.std.debug import state_result
from guppylang.std.quantum import (
    cx,
    cy,
    cz,
    discard,
    discard_array,
    h,
    measure,
    measure_array,
    qubit,
    rx,
    ry,
    rz,
    t,
    tdg,
    toffoli,
    x,
    y,
    z,
)
from guppylang.std.qsystem import measure_leaked
from guppylang.std.qsystem.random import RNG
from guppylang.std.qsystem.utils import get_current_shot
from selene_hugr_qis_compiler import compile_to_bitcode, compile_to_llvm_ir

TESTS_DIR = Path(__file__).parent.parent
QIS_DIR = TESTS_DIR / "resources" / "qis" / "guppy"
HUGR_DIR = TESTS_DIR / "resources" / "hugr"
QIS_DIR.mkdir(parents=True, exist_ok=True)
HUGR_DIR.mkdir(parents=True, exist_ok=True)


def get_platform_suffix() -> str:
    arch = platform.machine().lower()
    system = platform.system().lower()
    match arch:
        case "arm64" | "aarch64":
            target_arch = "aarch64"
        case "amd64" | "x86_64":
            target_arch = "x86_64"
        case _:
            raise RuntimeError(f"Unsupported architecture: {arch}")
    match system:
        case "linux":
            target_system = "unknown-linux-gnu"
        case "darwin":
            target_system = "apple-darwin"
        case "windows":
            target_system = "windows-msvc"
        case _:
            raise RuntimeError(f"Unsupported OS: {system}")
    return f"{target_arch}-{target_system}"


PLATFORM_SUFFIX = get_platform_suffix()


def save_qis(name: str, fn) -> None:
    """Compile a guppy function and save the QIS LLVM IR."""
    pkg = fn.compile()
    hugr_bytes = pkg.to_bytes()
    ir = compile_to_llvm_ir(hugr_bytes)
    path = QIS_DIR / f"{name}-{PLATFORM_SUFFIX}.ll"
    path.write_text(ir)
    print(f"  {path.name}")


def save_hugr(name: str, fn) -> None:
    """Compile a guppy function and save the HUGR envelope (platform-independent)."""
    pkg = fn.compile()
    hugr_bytes = pkg.to_bytes()
    path = HUGR_DIR / f"{name}.hugr"
    path.write_bytes(hugr_bytes)
    print(f"  {path.name}")


print(f"Generating QIS files for platform: {PLATFORM_SUFFIX}")
print(f"Output QIS directory: {QIS_DIR}")
print(f"Output HUGR directory: {HUGR_DIR}")
print()

# ---------------------------------------------------------------------------
# Programs shared across test files (test_guppy.py, test_unparsed.py, etc.)
# ---------------------------------------------------------------------------
print("Shared programs:")


@guppy
def no_results() -> None:
    q0: qubit = qubit()
    h(q0)
    m = measure(q0)


save_qis("no_results", no_results)


@guppy
def flip_n4() -> None:
    q0: qubit = qubit()
    q1: qubit = qubit()
    q2: qubit = qubit()
    q3: qubit = qubit()
    x(q0)
    x(q2)
    x(q3)
    result("c0", measure(q0))
    result("c1", measure(q1))
    result("c2", measure(q2))
    result("c3", measure(q3))


save_qis("flip_n4", flip_n4)


@guppy
def flip_n4_arr() -> None:
    qs = array(qubit() for _ in range(10))
    x(qs[0])
    x(qs[2])
    x(qs[3])
    x(qs[9])
    cs = measure_array(qs)
    result("cs", cs)
    result("is", array(i for i in range(100)))
    result("fs", array(i * 0.0625 for i in range(100)))


save_qis("flip_n4_arr", flip_n4_arr)


@guppy
def exit_prog() -> None:
    q = qubit()
    h(q)
    outcome = measure(q)
    if outcome:
        exit("Postselection failed", 42)
    result("c", outcome)


save_qis("exit", exit_prog)


@guppy
def panic_prog() -> None:
    q = qubit()
    h(q)
    outcome = measure(q)
    if outcome:
        panic("Postselection failed")
    result("c", outcome)


save_qis("panic", panic_prog)


@guppy
def broken_plugin_prog() -> None:
    q0: qubit = qubit()
    h(q0)
    result("c0", measure(q0))


save_qis("broken_plugin", broken_plugin_prog)

# ---------------------------------------------------------------------------
# Programs for test_guppy.py
# ---------------------------------------------------------------------------
print("test_guppy.py programs:")


@guppy
def cx_from_head() -> None:
    head = qubit()
    tail = array(qubit() for _ in range(20))
    h(head)
    for i in range(20):
        cx(head, tail[i])
    hl = measure_leaked(head)
    if hl.is_leaked():
        hl.discard()
        result("head_leaked", 1)
    else:
        result("head", hl.to_result().unwrap())
    result("tail", measure_array(tail))


save_qis("leak_from_head", cx_from_head)


@guppy
def cx_within_tail() -> None:
    head = qubit()
    tail = array(qubit() for _ in range(20))
    h(head)
    cx(head, tail[0])
    for i in range(19):
        cx(tail[i], tail[i + 1])
    hl = measure_leaked(head)
    if hl.is_leaked():
        hl.discard()
        result("head_leaked", 1)
    else:
        result("head", hl.to_result().unwrap())
    result("tail", measure_array(tail))


save_qis("leak_within_tail", cx_within_tail)


@guppy
def rus(q: qubit) -> None:
    while True:
        a, b = qubit(), qubit()
        h(a)
        h(b)
        tdg(a)
        cx(b, a)
        t(a)
        if not measure(a):
            discard(b)
            continue
        t(q)
        z(q)
        cx(q, b)
        t(b)
        if measure(b):
            break
        x(q)


@guppy
def repeat_until_success() -> None:
    q = qubit()
    rus(q)
    result("result", measure(q))


save_qis("repeat_until_success", repeat_until_success)


@guppy
def current_shot_prog() -> None:
    result("shot", get_current_shot())


save_qis("current_shot", current_shot_prog)


@guppy
def rng_prog() -> None:
    rng = RNG(42)
    rint = rng.random_int()
    rint1 = rng.random_int()
    rfloat = rng.random_float()
    rint_bnd = rng.random_int_bounded(100)
    rng.discard()
    result("rint", rint)
    result("rint1", rint1)
    result("rfloat", rfloat)
    result("rint_bnd", rint_bnd)
    rng = RNG(84)
    rint = rng.random_int()
    rfloat = rng.random_float()
    rint_bnd = rng.random_int_bounded(200)
    rng.discard()
    result("rint2", rint)
    result("rfloat2", rfloat)
    result("rint_bnd2", rint_bnd)


save_qis("rng", rng_prog)

# rng_advance is conditional on the feature being available in guppy
if hasattr(RNG, "random_advance"):

    @guppy
    def rng_advance_prog() -> None:
        rng = RNG(get_current_shot() + 42)
        rint = rng.random_int()
        rfloat = rng.random_float()
        rng.advance(-2)
        rint2 = rng.random_int()
        rfloat2 = rng.random_float()
        result("rint", rint)
        result("rint2", rint2)
        result("rfloat", rfloat)
        result("rfloat2", rfloat2)

    save_qis("rng_advance", rng_advance_prog)
else:
    print("  rng_advance: skipped (RNG.random_advance not available)")


@guppy
def nonclifford() -> None:
    q0: qubit = qubit()
    q1: qubit = qubit()
    q2: qubit = qubit()
    h(q0)
    toffoli(q0, q1, q2)
    result("c0", measure(q0))
    result("c1", measure(q1))
    result("c2", measure(q2))


save_qis("nonclifford", nonclifford)


@guppy
def metrics_prog() -> None:
    q0: qubit = qubit()
    q1: qubit = qubit()
    q2: qubit = qubit()
    h(q0)
    toffoli(q0, q1, q2)
    result("c0", measure(q0))
    result("c1", measure(q1))
    result("c2", measure(q2))


save_qis("metrics", metrics_prog)


@guppy
def metrics_on_exit_prog() -> None:
    q0: qubit = qubit()
    q1: qubit = qubit()
    q2: qubit = qubit()
    h(q0)
    toffoli(q0, q1, q2)
    result("c0", measure(q0))
    exit("Testing exit with metrics", 0)
    result("c1", measure(q1))
    result("c2", measure(q2))


save_qis("metrics_on_exit", metrics_on_exit_prog)


@guppy
def circuit_prog() -> None:
    q0: qubit = qubit()
    h(q0)
    c0 = measure(q0)
    result("c0", c0)
    if c0:
        q1: qubit = qubit()
        h(q1)
        c1 = measure(q1)
        result("c1", c1)
        if c1:
            q2: qubit = qubit()
            h(q2)
            c2 = measure(q2)
            result("c2", c2)


save_qis("circuit", circuit_prog)


@guppy
def measurement_output_prog() -> None:
    q0 = qubit()
    q1 = qubit()
    q2 = qubit()
    q3 = qubit()

    x(q0)
    if measure(q0):
        x(q1)
        cx(q1, q2)
        z(q3)
    else:
        y(q1)
        cz(q1, q2)
        x(q3)

    if measure(q1):
        result("q2", measure(q2))
        q3r = measure_leaked(q3).to_result()
        result("q3", 2 if q3r.is_nothing() else 1 if q3r.unwrap() else 0)
    else:
        q2r = measure_leaked(q2).to_result()
        result("q2", 2 if q2r.is_nothing() else 1 if q2r.unwrap() else 0)
        result("q3", measure(q3))


save_qis("measurement_output", measurement_output_prog)

# CY gate test - uses @guppy.comptime to unroll the loop at compile time
two_qb_bases = ["00", "01", "10", "11"]


@guppy.comptime
def cy_test() -> None:
    for basis in two_qb_bases:
        a, b = qubit(), qubit()
        if basis[0] == "1":
            x(a)
        if basis[1] == "1":
            x(b)
        # if a is |1> the y gate will undo the cy
        cy(a, b)
        y(b)
        ar = array(measure(a), measure(b))
        result(basis, ar)


save_qis("cy_test", cy_test)


# CZ gate test - uses a helper function
@guppy
def cz_subc(a: qubit, b: qubit) -> None:
    ry(a, angle(5.535942))
    cz(a, b)


@guppy
def cz_test() -> None:
    a, b = qubit(), qubit()
    cz_subc(a, b)
    cz_subc(a, b)
    ar = array(measure(a), measure(b))
    result("c", ar)


save_qis("cz_test", cz_test)

# ---------------------------------------------------------------------------
# Programs for test_debug.py
# ---------------------------------------------------------------------------
print("test_debug.py programs:")


@guppy
def debug_initial_state() -> None:
    q0 = qubit()
    state_result("initial_state", q0)
    discard(q0)


save_qis("debug_initial_state", debug_initial_state)


@guppy
def debug_array_state_full() -> None:
    qs = array(qubit() for _ in range(2))
    for i in range(2):
        x(qs[i])
    state_result("array_state", qs)
    discard_array(qs)


save_qis("debug_array_state_full", debug_array_state_full)


@guppy
def debug_array_state_single() -> None:
    qs = array(qubit() for _ in range(2))
    for i in range(2):
        x(qs[i])
    state_result("array_state", qs[0])
    discard_array(qs)


save_qis("debug_array_state_single", debug_array_state_single)


@guppy
def debug_qubit_ordering() -> None:
    qs = array(qubit() for _ in range(2))
    x(qs[0])
    # expected state is |10> so that qs[0] is the MSB
    state_result("default", qs[0], qs[1])
    # reversed order, expected state is |01>
    state_result("reversed", qs[1], qs[0])
    discard_array(qs)


save_qis("debug_qubit_ordering", debug_qubit_ordering)


@guppy
def debug_quantum_replay() -> None:
    q0: qubit = qubit()
    q1: qubit = qubit()
    h(q0)
    cx(q0, q1)
    state_result("entangled_state", q0, q1)
    result("c0", measure(q0))
    state_result("post_measurement_state", q1)
    result("c1", measure(q1))


save_qis("debug_quantum_replay", debug_quantum_replay)

# Gate implementation tests - parametrized by gate name
# Use same seed as in the test for reproducibility
import random

random.seed(1234)
all_quarter_turns = [i / 2 for i in range(-8, 9)]
_gate_params = [random.choice(all_quarter_turns) for _ in range(1000)]


@guppy
def debug_gate_impl_rx() -> None:
    q0: qubit = qubit()
    angle_val = comptime(_gate_params)[get_current_shot()]
    rx(q0, pi * angle_val)
    state_result("entangled_state", q0)
    discard(q0)


save_qis("debug_gate_impl_rx", debug_gate_impl_rx)


@guppy
def debug_gate_impl_ry() -> None:
    q0: qubit = qubit()
    angle_val = comptime(_gate_params)[get_current_shot()]
    ry(q0, pi * angle_val)
    state_result("entangled_state", q0)
    discard(q0)


save_qis("debug_gate_impl_ry", debug_gate_impl_ry)


@guppy
def debug_gate_impl_rz() -> None:
    q0: qubit = qubit()
    angle_val = comptime(_gate_params)[get_current_shot()]
    rz(q0, pi * angle_val)
    state_result("entangled_state", q0)
    discard(q0)


save_qis("debug_gate_impl_rz", debug_gate_impl_rz)

random.seed(1234)
_gate_triples_params = [
    [random.choice(all_quarter_turns) for _ in range(3)] for _ in range(1000)
]


@guppy
def debug_gate_impl_triples() -> None:
    q0: qubit = qubit()
    angles = comptime(_gate_triples_params)[get_current_shot()]
    rx(q0, pi * angles[0])
    ry(q0, pi * angles[1])
    rz(q0, pi * angles[2])
    state_result("entangled_state", q0)
    discard(q0)


save_qis("debug_gate_impl_triples", debug_gate_impl_triples)

# ---------------------------------------------------------------------------
# Programs for test_depolarising_error_model.py
# ---------------------------------------------------------------------------
print("test_depolarising_error_model.py programs:")


@guppy
def depolarising_2q_measure() -> None:
    q1: qubit = qubit()
    q2: qubit = qubit()
    h(q1)
    h(q2)
    result("c1", measure(q1))
    result("c2", measure(q2))


save_qis("depolarising_2q_measure", depolarising_2q_measure)


@guppy
def depolarising_2q_init() -> None:
    q1: qubit = qubit()
    q2: qubit = qubit()
    # note: no gates
    result("c1", measure(q1))
    result("c2", measure(q2))


save_qis("depolarising_2q_init", depolarising_2q_init)


# test_1q_error and test_2q_error use the same program
@guppy
def depolarising_gates() -> None:
    q1: qubit = qubit()
    q2: qubit = qubit()
    # 1 1q gate on q1
    x(q1)
    # 2 1q gates on q2
    y(q2)
    y(q2)
    # some self-cancelling 2q gates
    cx(q1, q2)
    cx(q1, q2)
    result("c1", measure(q1))
    result("c2", measure(q2))


save_qis("depolarising_gates", depolarising_gates)

# ---------------------------------------------------------------------------
# Programs for test_determinism.py
# ---------------------------------------------------------------------------
print("test_determinism.py programs:")


@guppy
def determinism_prog() -> None:
    qubits = array(qubit() for _ in range(5))
    for i in range(len(qubits)):
        h(qubits[i])
    bits = measure_array(qubits)
    result("a", bits[0])
    result("b", bits[1])
    result("c", bits[2])
    result("d", bits[3])
    result("e", bits[4])
    result("shot", get_current_shot())
    rng = RNG(get_current_shot())
    result("random_int", rng.random_int())
    result("random_float", rng.random_float())
    rng.discard()


save_qis("determinism", determinism_prog)

# ---------------------------------------------------------------------------
# Programs for test_runtimes.py
# ---------------------------------------------------------------------------
print("test_runtimes.py programs:")


@guppy
def runtime_diff() -> None:
    q0: qubit = qubit()
    q1: qubit = qubit()
    q2: qubit = qubit()
    h(q0)
    cx(q0, q1)
    cx(q1, q2)
    result("c0", measure(q0))
    result("c1", measure(q1))
    result("c2", measure(q2))


save_qis("runtime_diff", runtime_diff)

# ---------------------------------------------------------------------------
# Programs for test_timeout.py
# ---------------------------------------------------------------------------
print("test_timeout.py programs:")


@guppy
def non_terminating_with_results() -> None:
    while True:
        q0: qubit = qubit()
        h(q0)
        result("r", measure(q0))


save_qis("non_terminating_with_results", non_terminating_with_results)


@guppy
def recurse_infinite(i: int) -> int:
    # oops, infinite recursion!
    return recurse_infinite(i + 1)


@guppy
def non_terminating_without_results() -> None:
    result("i", recurse_infinite(0))


save_qis("non_terminating_without_results", non_terminating_without_results)

# ---------------------------------------------------------------------------
# Programs for test_unparsed.py (additional, not already covered above)
# ---------------------------------------------------------------------------
print("test_unparsed.py programs:")


@guppy
def array_results() -> None:
    qs = array(qubit() for _ in range(10))
    for i in range(len(qs)):
        x(qs[i])
    bs = measure_array(qs)
    result("bools", bs)
    result("floats", array(1.0 / 2**i for i in range(10)))
    result("ints", array(i for i in range(100)))


save_qis("array_results", array_results)


@guppy
def infinite_loop() -> None:
    while True:
        q0: qubit = qubit()
        h(q0)
        result("r", measure(q0))


save_qis("infinite_loop", infinite_loop)


@guppy
def memory_allocation() -> None:
    qs = array(qubit() for _ in range(70))
    for i in range(len(qs)):
        if i % 2 == 0:
            x(qs[i])
    bs = measure_array(qs)
    result("bools", bs)


save_qis("memory_allocation", memory_allocation)

# ---------------------------------------------------------------------------
# Programs for test_replay.py
# ---------------------------------------------------------------------------
print("test_replay.py programs:")


@guppy
def recursive_condition() -> None:
    q = qubit()
    h(q)
    outcome = measure(q)
    result("c", outcome)
    if outcome:
        recursive_condition()


@guppy
def recursive_condition_main() -> None:
    recursive_condition()


save_qis("recursive_condition", recursive_condition_main)


@guppy
def quantum_replay_prog() -> None:
    q0: qubit = qubit()
    q1: qubit = qubit()
    q2: qubit = qubit()
    q3: qubit = qubit()
    h(q0)
    cx(q0, q1)
    cx(q1, q2)
    x(q2)
    cx(q2, q3)
    result("c0", measure(q0))
    result("c1", measure(q1))
    result("c2", measure(q2))
    result("c3", measure(q3))


save_qis("quantum_replay", quantum_replay_prog)

# ---------------------------------------------------------------------------
# HUGR files for test_build_validation.py and test_cleanup.py
# (platform-independent, can test all build methods)
# ---------------------------------------------------------------------------
print("HUGR files (platform-independent):")


@guppy
def simple_discard() -> None:
    q0 = qubit()
    discard(q0)


save_hugr("simple_discard", simple_discard)

print()
print("Done!")
