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

    class EndpointOperations(ctypes.Structure):
        _fields_ = [
            ("handle_operations_fn", ctypes.c_void_p),
            ("dump_state_fn", ctypes.c_void_p),
        ]

    class Endpoint(ctypes.Structure):
        _fields_ = [("instance", ctypes.c_void_p), ("interface", EndpointOperations)]

    callback_type = ctypes.CFUNCTYPE(ctypes.c_int32, ctypes.c_void_p, Endpoint)
    stack = InteractiveFullStack(
        simulator=Quest(), runtime=ThreadedRuntime(), n_qubits=1
    )
    borrow = stack._lib.selene_borrow_endpoint
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
    def inspect(context_pointer, endpoint):
        value = ctypes.cast(
            context_pointer, ctypes.POINTER(ctypes.c_uint64)
        ).contents.value
        observations.append((threading.get_ident(), value, bool(endpoint.instance)))
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


def test_concurrent_prints_produce_complete_records_in_each_callers_order():
    from selene_sim.interactive.full_stack import selene_string_t

    stack = InteractiveFullStack(
        simulator=Quest(), runtime=ThreadedRuntime(), n_qubits=1
    )
    print_array = stack._lib.selene_print_u64_array
    print_array.argtypes = [
        SeleneInstancePtr,
        selene_string_t,
        ctypes.POINTER(ctypes.c_uint64),
        ctypes.c_uint64,
    ]
    print_array.restype = selene_void_result_t
    ready = threading.Barrier(4)

    def print_values(worker):
        ready.wait(timeout=5)
        for index in range(50):
            values = (ctypes.c_uint64 * 2)(worker, index)
            print_array(
                stack._instance,
                selene_string_t.from_str(f"USER:ARRAY:{worker}"),
                values,
                2,
            ).unwrap()
            # The caller is free to reuse this buffer as soon as printing
            # returns, even if the runtime hasn't written the record yet.
            values[0] = 999
            values[1] = 999

    try:
        with ThreadPoolExecutor(max_workers=4) as pool:
            list(pool.map(print_values, range(4)))
        entries = stack.drain_results()
        assert len(entries) == 200
        for worker in range(4):
            values = [
                entry.values for entry in entries if entry.tag == f"USER:ARRAY:{worker}"
            ]
            assert values == [[[worker, index]] for index in range(50)]
    finally:
        stack.close()


@pytest.mark.parametrize("runtime", [SimpleRuntime, ThreadedRuntime])
@pytest.mark.parametrize("error_code", [42, 1001])
def test_exit_flushes_pending_quantum_work_before_returning(runtime, error_code):
    from selene_sim.interactive.full_stack import selene_string_t

    trace = CircuitExtractor()
    stack = InteractiveFullStack(
        simulator=Quest(), runtime=runtime(), n_qubits=1, event_hook=trace
    )
    exit_program = stack._lib.selene_print_exit
    exit_program.argtypes = [SeleneInstancePtr, selene_string_t, ctypes.c_uint32]
    exit_program.restype = selene_void_result_t
    try:
        q = stack.qalloc()
        stack.reset(q)
        stack.rxy(q, pi, 0)
        exit_program(
            stack._instance, selene_string_t.from_str("finished"), error_code
        ).unwrap()

        # This borrow deliberately doesn't ask for a flush. If exit returned
        # before executing the X gate, inspecting the simulator here would see
        # the wrong state. The host still owns shot end, so the endpoint must
        # remain available until then.
        class BorrowRequest(ctypes.Structure):
            _fields_ = [
                ("struct_size", ctypes.c_uint64),
                ("force_flush", ctypes.c_bool),
            ]

        class EndpointOperations(ctypes.Structure):
            _fields_ = [
                ("handle_operations_fn", ctypes.c_void_p),
                ("dump_state_fn", ctypes.c_void_p),
            ]

        class Endpoint(ctypes.Structure):
            _fields_ = [
                ("instance", ctypes.c_void_p),
                ("interface", EndpointOperations),
            ]

        callback_type = ctypes.CFUNCTYPE(ctypes.c_int32, ctypes.c_void_p, Endpoint)
        dump_type = ctypes.CFUNCTYPE(
            ctypes.c_int32,
            ctypes.c_void_p,
            ctypes.c_char_p,
            ctypes.POINTER(ctypes.c_uint64),
            ctypes.c_uint64,
        )
        file = stack.artifact_dir / "after_exit.json"
        calls = []

        @callback_type
        def inspect(_context, endpoint):
            dump = dump_type(endpoint.interface.dump_state_fn)
            qubits = (ctypes.c_uint64 * 1)(q.id)
            status = dump(endpoint.instance, str(file).encode(), qubits, 1)
            calls.append(status)
            return status

        borrow = stack._lib.selene_borrow_endpoint
        borrow.argtypes = [
            SeleneInstancePtr,
            ctypes.POINTER(BorrowRequest),
            callback_type,
            ctypes.c_void_p,
        ]
        borrow.restype = selene_void_result_t
        request = BorrowRequest(ctypes.sizeof(BorrowRequest), False)
        borrow(stack._instance, ctypes.byref(request), inspect, None).unwrap()
        assert calls == [0]
        _, state = next(Quest.extract_states([("STATE:after_exit", str(file))]))
        np.testing.assert_allclose(
            state.get_density_matrix(), [[0, 0], [0, 1]], atol=1e-12
        )
        stack.next_shot()
        q = stack.qalloc()
        stack.reset(q)
        assert not stack.measure(q)
    finally:
        stack.close()


@pytest.mark.parametrize("runtime", [SimpleRuntime, ThreadedRuntime])
@pytest.mark.parametrize("panic", [False, True])
def test_compiled_program_can_jump_after_runtime_exit(runtime, panic):
    from selene_sim.exceptions import SelenePanicError
    from selene_sim.result_handling.parse_shot import postprocess_unparsed_stream

    # These snapshots exercise the actual QIS functions and the C jump back to
    # the program wrapper. A raw libselene exit call can't cover that boundary.
    resources = Path(__file__).parent / "resources/from_guppy"
    if panic:
        folder = resources / "test_backtrace/test_backtrace_always_panic"
        name = "panic"
    else:
        folder = resources / "test_unparsed/test_exit_unparsed"
        name = "exit_unparsed"
    runner = build(folder / f"{name}-helios-{get_platform_suffix()}.ll")
    shots, error = postprocess_unparsed_stream(
        runner.run_shots(
            simulator=Quest(),
            runtime=runtime(),
            n_qubits=1,
            n_shots=100,
            random_seed=0,
            parse_results=False,
        )
    )
    if panic:
        assert isinstance(error, SelenePanicError)
        assert error.code == 1001
        assert error.message == "This should always panic"
        assert len(shots) == 1
        assert error.stack_trace is not None
        symbols = [
            symbol for entry in error.stack_trace.entries for symbol in entry.symbols
        ]
        assert any(
            symbol.function_name == "main" and symbol.line == 7 for symbol in symbols
        )
    else:
        assert error is None
        assert len(shots) == 100
        assert [("EXIT:INT:Postselection failed", 42)] in shots
        assert [("USER:BOOL:c", 0)] in shots
        assert all(
            shot in [[("EXIT:INT:Postselection failed", 42)], [("USER:BOOL:c", 0)]]
            for shot in shots
        )
