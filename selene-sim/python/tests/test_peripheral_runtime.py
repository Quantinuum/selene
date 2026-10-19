import ctypes
from concurrent.futures import ThreadPoolExecutor
from math import pi
from pathlib import Path
import threading

import numpy as np
import pytest

from conftest import get_platform_suffix
from selene_sim import DepolarizingErrorModel, Quest, SimpleRuntime, ThreadedRuntime
from selene_sim.build import build
from selene_sim.event_hooks import CircuitExtractor, MetricStore, MultiEventHook
from selene_sim.interactive import InteractiveFullStack
from selene_sim.interactive.full_stack import SeleneInstancePtr, selene_void_result_t


def test_threaded_runtime_matches_legacy_results_and_traces():
    # We already have a compiled program with several gates and measurements.
    # Reuse it so this test compares the two runtime interfaces, including their
    # FFI boundaries, without depending on a Guppy compiler installation.
    llvm = (
        Path(__file__).parent
        / "resources/from_guppy/test_runtimes/test_simple_vs_softrz"
        / f"simple_vs_softrz-helios-{get_platform_suffix()}.ll"
    )
    runner = build(llvm)
    runs = []
    for runtime in [SimpleRuntime(), ThreadedRuntime()]:
        trace = CircuitExtractor()
        metrics = MetricStore()
        results = [
            dict(shot)
            for shot in runner.run_shots(
                simulator=Quest(),
                error_model=DepolarizingErrorModel(
                    p_init=0.01, p_meas=0.01, p_1q=0.01, p_2q=0.01
                ),
                runtime=runtime,
                n_qubits=4,
                n_shots=8,
                random_seed=13579,
                event_hook=MultiEventHook([trace, metrics]),
            )
        ]

        # The threaded runtime may execute a batch after later user calls have
        # been recorded. Within each source the operations and their order must
        # still agree, including noise inserted by the error model.
        shots = []
        for events in trace.shots:
            sources = {}
            for event in events:
                operation = event.operation.to_dict()
                operation.pop("duration_ns", None)
                sources.setdefault(str(event.source), []).append(operation)
            shots.append(sources)
        runs.append((results, shots, metrics.shots))

    assert runs[0][0] == runs[1][0]
    assert runs[0][1] == runs[1][1]
    for legacy, threaded in zip(runs[0][2], runs[1][2], strict=True):
        assert legacy["user_program"] == threaded["user_program"]
        assert legacy["post_runtime"] == threaded["post_runtime"]


@pytest.mark.parametrize("runtime", [SimpleRuntime, ThreadedRuntime])
def test_state_inspection_flushes_pending_gates(runtime):
    stack = InteractiveFullStack(simulator=Quest(), runtime=runtime(), n_qubits=2)
    try:
        for _ in range(2):
            q = stack.qalloc()
            stack.reset(q)
            stack.rxy(q, pi, 0)
            # No measurement has forced the threaded runtime to execute the X
            # gate. State inspection must flush it before borrowing the simulator.
            state = stack.get_state([q]).get_density_matrix()
            np.testing.assert_allclose(state, [[0, 0], [0, 1]], atol=1e-12)
            assert stack.measure(q)
            stack.qfree(q)
            stack.next_shot()
    finally:
        stack.close()


@pytest.mark.parametrize("runtime", [SimpleRuntime, ThreadedRuntime])
def test_state_inspection_includes_measurements_on_other_qubits(runtime):
    stack = InteractiveFullStack(simulator=Quest(), runtime=runtime(), n_qubits=2)
    try:
        q0, q1 = stack.qalloc(), stack.qalloc()
        for qubit in [q0, q1]:
            stack.reset(qubit)
            stack.rxy(qubit, pi / 2, 0)
        stack.rzz(q0, q1, pi / 2)
        reduced = stack.get_state([q0]).get_density_matrix()
        np.testing.assert_allclose(reduced, np.eye(2) / 2, atol=1e-12)

        # These qubits are entangled, so measuring q1 changes the conditional
        # state of q0. We haven't read the result, and q1 isn't in the state
        # request. The borrow must still execute its pending measurement: q0
        # should now have a pure state, rather than the mixed state above.
        result = stack.lazy_measure(q1)
        reduced = stack.get_state([q0]).get_density_matrix()
        assert np.trace(reduced @ reduced).real == pytest.approx(1)
        assert stack.future_read_bool(result) in [False, True]
    finally:
        stack.close()


def test_concurrent_libselene_calls_with_threaded_runtime():
    stack = InteractiveFullStack(
        simulator=Quest(), runtime=ThreadedRuntime(), n_qubits=4
    )
    lib = stack._lib
    instance = stack._instance
    ready = threading.Barrier(4)

    def run_qubit():
        # Use the C functions directly: the interactive Python wrapper's result
        # parser is intentionally not shared between these submitting threads.
        q = lib.selene_qalloc(instance).unwrap()
        ready.wait(timeout=5)
        lib.selene_qubit_reset(instance, q).unwrap()
        lib.selene_rxy(instance, q, pi, 0).unwrap()
        result = lib.selene_qubit_lazy_measure(instance, q).unwrap()
        measured = lib.selene_future_read_bool(instance, result).unwrap()
        lib.selene_refcount_decrement(instance, result).unwrap()
        lib.selene_qfree(instance, q).unwrap()
        return measured

    try:
        with ThreadPoolExecutor(max_workers=4) as pool:
            assert list(pool.map(lambda _: run_qubit(), range(4))) == [True] * 4
    finally:
        stack.close()


def test_c_borrow_request_and_callback_run_on_the_execution_thread():
    class BorrowRequest(ctypes.Structure):
        _fields_ = [("struct_size", ctypes.c_uint64), ("force_flush", ctypes.c_bool)]

    class PeripheralOperations(ctypes.Structure):
        _fields_ = [
            ("handle_operations_fn", ctypes.c_void_p),
            ("dump_state_fn", ctypes.c_void_p),
        ]

    class Peripheral(ctypes.Structure):
        _fields_ = [("instance", ctypes.c_void_p), ("interface", PeripheralOperations)]

    callback_type = ctypes.CFUNCTYPE(ctypes.c_int32, ctypes.c_void_p, Peripheral)
    stack = InteractiveFullStack(
        simulator=Quest(), runtime=ThreadedRuntime(), n_qubits=1
    )
    borrow = stack._lib.selene_borrow_peripheral
    borrow.argtypes = [
        SeleneInstancePtr,
        ctypes.POINTER(BorrowRequest),
        callback_type,
        ctypes.c_void_p,
    ]
    borrow.restype = selene_void_result_t
    caller = threading.get_ident()
    observations = []
    context = ctypes.c_uint64(812)

    @callback_type
    def inspect(context_pointer, peripheral):
        value = ctypes.cast(
            context_pointer, ctypes.POINTER(ctypes.c_uint64)
        ).contents.value
        observations.append((threading.get_ident(), value, bool(peripheral.instance)))
        return 0

    try:
        for force_flush in [False, True]:
            request = BorrowRequest(ctypes.sizeof(BorrowRequest), force_flush)
            borrow(
                stack._instance, ctypes.byref(request), inspect, ctypes.byref(context)
            ).unwrap()
        assert len(observations) == 2
        assert observations[0][0] == observations[1][0] != caller
        assert all(value == 812 and present for _, value, present in observations)
    finally:
        stack.close()
