from __future__ import annotations

from dataclasses import dataclass
import ctypes

from selene_core import Runtime
import random


class SeleneRuntimeInstance(ctypes.Structure):
    pass


SeleneRuntimeGetOperationInstance = ctypes.c_void_p

RZZ_CB = ctypes.CFUNCTYPE(
    None,
    SeleneRuntimeGetOperationInstance,
    ctypes.c_uint64,
    ctypes.c_uint64,
    ctypes.c_double,
)
RXY_CB = ctypes.CFUNCTYPE(
    None,
    SeleneRuntimeGetOperationInstance,
    ctypes.c_uint64,
    ctypes.c_double,
    ctypes.c_double,
)
RZ_CB = ctypes.CFUNCTYPE(
    None, SeleneRuntimeGetOperationInstance, ctypes.c_uint64, ctypes.c_double
)
MEASURE_CB = ctypes.CFUNCTYPE(
    None, SeleneRuntimeGetOperationInstance, ctypes.c_uint64, ctypes.c_uint64
)
MEASURE_LEAKED_CB = ctypes.CFUNCTYPE(
    None, SeleneRuntimeGetOperationInstance, ctypes.c_uint64, ctypes.c_uint64
)
RESET_CB = ctypes.CFUNCTYPE(None, SeleneRuntimeGetOperationInstance, ctypes.c_uint64)
CUSTOM_CB = ctypes.CFUNCTYPE(
    None,
    SeleneRuntimeGetOperationInstance,
    ctypes.c_size_t,
    ctypes.c_void_p,
    ctypes.c_size_t,
)
SET_BATCH_TIME_CB = ctypes.CFUNCTYPE(
    None, SeleneRuntimeGetOperationInstance, ctypes.c_uint64, ctypes.c_uint64
)


class SeleneRuntimeGetOperationInterface(ctypes.Structure):
    _fields_ = [
        ("rzz_fn", RZZ_CB),
        ("rxy_fn", RXY_CB),
        ("rz_fn", RZ_CB),
        ("measure_fn", MEASURE_CB),
        ("measure_leaked_fn", MEASURE_LEAKED_CB),
        ("reset_fn", RESET_CB),
        ("custom_fn", CUSTOM_CB),
        ("set_batch_time_fn", SET_BATCH_TIME_CB),
    ]


@dataclass
class MeasureOperation:
    qubit_id: int
    result_id: int


@dataclass
class ResetOperation:
    qubit_id: int


@dataclass
class RXYGateOperation:
    qubit_id: int
    theta: float
    phi: float


@dataclass
class RZGateOperation:
    qubit_id: int
    theta: float


@dataclass
class RZZGateOperation:
    qubit_id_a: int
    qubit_id_b: int
    theta: float


@dataclass
class CustomOperation:
    tag: int
    data: bytes


@dataclass
class MeasureLeakedOperation:
    qubit_id: int
    result_id: int


RuntimeOperation = (
    MeasureOperation
    | ResetOperation
    | RXYGateOperation
    | RZGateOperation
    | RZZGateOperation
    | CustomOperation
    | MeasureLeakedOperation
)


class OperationBatch:
    def __init__(self) -> None:
        self.start_time_nanos: int = 0
        self.duration_nanos: int = 0
        self.operations: list[RuntimeOperation] = []
        self.invoked = False

    def set_time(self, start_time_nanos: int, duration_nanos: int):
        self.start_time_nanos = start_time_nanos
        self.duration_nanos = duration_nanos
        self.invoked = True

    def rxy(self, qubit_id: int, theta: float, phi: float):
        self.operations.append(RXYGateOperation(qubit_id, theta, phi))
        self.invoked = True

    def rz(self, qubit_id: int, theta: float):
        self.operations.append(RZGateOperation(qubit_id, theta))
        self.invoked = True

    def rzz(self, qubit_id_a: int, qubit_id_b: int, theta: float):
        self.operations.append(RZZGateOperation(qubit_id_a, qubit_id_b, theta))
        self.invoked = True

    def measure(self, qubit_id: int, result_id: int):
        self.operations.append(MeasureOperation(qubit_id, result_id))
        self.invoked = True

    def measure_leaked(self, qubit_id: int, result_id: int):
        self.operations.append(MeasureLeakedOperation(qubit_id, result_id))
        self.invoked = True

    def reset(self, qubit_id: int):
        self.operations.append(ResetOperation(qubit_id))
        self.invoked = True

    def custom(self, tag: int, data: bytes):
        self.operations.append(CustomOperation(tag, data))
        self.invoked = True

    def __repr__(self) -> str:
        return f"OperationBatch(start_time_nanos={self.start_time_nanos}, duration_nanos={self.duration_nanos}, operations={self.operations})"

    @staticmethod
    def from_ptr(ptr: SeleneRuntimeGetOperationInstance) -> OperationBatch:
        return ctypes.cast(ptr, ctypes.POINTER(ctypes.py_object)).contents.value


def callback_rxy(
    instance: SeleneRuntimeGetOperationInstance, qubit_id: int, theta: float, phi: float
):
    OperationBatch.from_ptr(instance).rxy(qubit_id, theta, phi)


def callback_rz(
    instance: SeleneRuntimeGetOperationInstance, qubit_id: int, theta: float
):
    OperationBatch.from_ptr(instance).rz(qubit_id, theta)


def callback_rzz(
    instance: SeleneRuntimeGetOperationInstance,
    qubit_id_a: int,
    qubit_id_b: int,
    theta: float,
):
    OperationBatch.from_ptr(instance).rzz(qubit_id_a, qubit_id_b, theta)


def callback_measure(
    instance: SeleneRuntimeGetOperationInstance, qubit_id: int, result_id: int
):
    OperationBatch.from_ptr(instance).measure(qubit_id, result_id)


def callback_measure_leaked(
    instance: SeleneRuntimeGetOperationInstance, qubit_id: int, result_id: int
):
    OperationBatch.from_ptr(instance).measure_leaked(qubit_id, result_id)


def callback_reset(instance: SeleneRuntimeGetOperationInstance, qubit_id: int):
    OperationBatch.from_ptr(instance).reset(qubit_id)


def callback_custom(
    instance: SeleneRuntimeGetOperationInstance,
    tag: int,
    data_ptr: ctypes.c_void_p,
    data_len: int,
):
    data = ctypes.string_at(data_ptr, data_len)
    OperationBatch.from_ptr(instance).custom(tag, data)


def callback_set_batch_time(
    instance: SeleneRuntimeGetOperationInstance, start_time: int, duration: int
):
    OperationBatch.from_ptr(instance).set_time(start_time, duration)


OPERATION_BATCH_CALLBACKS = SeleneRuntimeGetOperationInterface(
    rzz_fn=RZZ_CB(callback_rzz),
    rxy_fn=RXY_CB(callback_rxy),
    rz_fn=RZ_CB(callback_rz),
    measure_fn=MEASURE_CB(callback_measure),
    measure_leaked_fn=MEASURE_LEAKED_CB(callback_measure_leaked),
    reset_fn=RESET_CB(callback_reset),
    custom_fn=CUSTOM_CB(callback_custom),
    set_batch_time_fn=SET_BATCH_TIME_CB(callback_set_batch_time),
)

SeleneRuntimeInstancePtr = ctypes.POINTER(SeleneRuntimeInstance)
SeleneRuntimeInstancePtrPtr = ctypes.POINTER(SeleneRuntimeInstancePtr)


class SeleneSimRuntimeLib(ctypes.CDLL):
    def __init__(self, runtime: Runtime) -> None:
        super().__init__(str(runtime.library_file))
        self._configure_signatures()

    def _configure_signatures(self):
        self.selene_runtime_get_api_version.argtypes = []
        self.selene_runtime_get_api_version.restype = ctypes.c_uint64
        self.selene_runtime_init.argtypes = [
            SeleneRuntimeInstancePtrPtr,
            ctypes.c_uint64,  # n_qubits
            ctypes.c_uint64,  # start timestamp
            ctypes.c_uint32,  # argc
            ctypes.POINTER(ctypes.c_char_p),  # argv
        ]
        self.selene_runtime_init.restype = ctypes.c_int32

        self.selene_runtime_exit.argtypes = [SeleneRuntimeInstancePtr]
        self.selene_runtime_exit.restype = ctypes.c_int32

        self.selene_runtime_shot_start.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
            ctypes.c_uint64,
        ]
        self.selene_runtime_shot_start.restype = ctypes.c_int32
        self.selene_runtime_shot_end.argtypes = [SeleneRuntimeInstancePtr]
        self.selene_runtime_shot_end.restype = ctypes.c_int32
        self.selene_runtime_custom_call.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
            ctypes.POINTER(ctypes.c_char_p),
            ctypes.c_size_t,
            ctypes.POINTER(ctypes.c_uint64),
        ]
        self.selene_runtime_custom_call.restype = ctypes.c_int32
        self.selene_runtime_get_next_operations.argtypes = [
            SeleneRuntimeInstancePtr,
            SeleneRuntimeGetOperationInstance,
            ctypes.POINTER(SeleneRuntimeGetOperationInterface),
        ]
        self.selene_runtime_get_next_operations.restype = ctypes.c_int32
        self.selene_runtime_qalloc.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.POINTER(ctypes.c_uint64),
        ]
        self.selene_runtime_qalloc.restype = ctypes.c_int32
        self.selene_runtime_qfree.argtypes = [SeleneRuntimeInstancePtr, ctypes.c_uint64]
        self.selene_runtime_qfree.restype = ctypes.c_int32
        self.selene_runtime_rxy_gate.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
            ctypes.c_double,
            ctypes.c_double,
        ]
        self.selene_runtime_rxy_gate.restype = ctypes.c_int32
        self.selene_runtime_rz_gate.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
            ctypes.c_double,
        ]
        self.selene_runtime_rz_gate.restype = ctypes.c_int32
        self.selene_runtime_rzz_gate.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
            ctypes.c_uint64,
            ctypes.c_double,
        ]
        self.selene_runtime_rzz_gate.restype = ctypes.c_int32
        self.selene_runtime_measure.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
            ctypes.POINTER(ctypes.c_uint64),
        ]
        self.selene_runtime_measure.restype = ctypes.c_int32
        self.selene_runtime_measure_leaked.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
            ctypes.POINTER(ctypes.c_uint64),
        ]
        self.selene_runtime_measure_leaked.restype = ctypes.c_int32
        self.selene_runtime_reset.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
        ]
        self.selene_runtime_reset.restype = ctypes.c_int32
        self.selene_runtime_force_result.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
        ]
        self.selene_runtime_force_result.restype = ctypes.c_int32
        self.selene_runtime_get_bool_result.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
            ctypes.POINTER(ctypes.c_uint8),
        ]
        self.selene_runtime_get_bool_result.restype = ctypes.c_int32
        self.selene_runtime_get_u64_result.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
            ctypes.POINTER(ctypes.c_uint64),
        ]
        self.selene_runtime_get_u64_result.restype = ctypes.c_int32
        self.selene_runtime_set_bool_result.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
            ctypes.c_uint8,
        ]
        self.selene_runtime_set_bool_result.restype = ctypes.c_int32
        self.selene_runtime_set_u64_result.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
            ctypes.c_uint64,
        ]
        self.selene_runtime_set_u64_result.restype = ctypes.c_int32
        self.selene_runtime_increment_future_refcount.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
        ]
        self.selene_runtime_increment_future_refcount.restype = ctypes.c_int32
        self.selene_runtime_decrement_future_refcount.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint64,
        ]
        self.selene_runtime_decrement_future_refcount.restype = ctypes.c_int32
        self.selene_runtime_get_metrics.argtypes = [
            SeleneRuntimeInstancePtr,
            ctypes.c_uint8,
            ctypes.c_char_p,
            ctypes.POINTER(ctypes.c_uint8),
            ctypes.POINTER(ctypes.c_uint64),
        ]
        self.selene_runtime_get_metrics.restype = ctypes.c_int32


class InteractiveRuntime:
    def __init__(
        self,
        *,
        n_qubits: int,
        runtime: Runtime,
        start_time_nanos: int = 0,
    ):
        self._lib = SeleneSimRuntimeLib(runtime)
        self._instance = SeleneRuntimeInstancePtr()
        if runtime.random_seed is None:
            runtime.random_seed = random.randint(0, 2**64 - 1)
        self.runtime = runtime
        self.n_qubits = n_qubits
        self.shot_id = 0
        arguments = runtime.get_init_args()
        # create an array of c_char_p from the list of strings
        argc = len(arguments)
        argv = (ctypes.c_char_p * argc)(*(arg.encode("utf-8") for arg in arguments))
        if 0 != self._lib.selene_runtime_init(
            ctypes.byref(self._instance), n_qubits, start_time_nanos, argc, argv
        ):
            raise RuntimeError("Failed to initialize Selene runtime")
        if 0 != self._lib.selene_runtime_shot_start(
            self._instance, self.shot_id, self.runtime.random_seed
        ):
            raise RuntimeError("Failed to start first shot on Selene runtime")

    def next_shot(self):
        if 0 != self._lib.selene_runtime_shot_end(self._instance):
            raise RuntimeError("Failed to end current shot on Selene runtime")
        self.shot_id += 1
        if 0 != self._lib.selene_runtime_shot_start(
            self._instance, self.shot_id, self.runtime.random_seed + self.shot_id
        ):
            raise RuntimeError("Failed to start next shot on Selene runtime")

    def get_operations(self) -> list[OperationBatch]:
        batches = []
        while True:
            batch = OperationBatch()
            batch_ref = ctypes.py_object(batch)
            instance = ctypes.cast(
                ctypes.pointer(batch_ref), SeleneRuntimeGetOperationInstance
            )
            if 0 != self._lib.selene_runtime_get_next_operations(
                self._instance, instance, ctypes.byref(OPERATION_BATCH_CALLBACKS)
            ):
                raise RuntimeError("Failed to get next operations from Selene runtime")
            if not batch.invoked:
                break
            batches.append(batch)
        return batches

    def qalloc(self) -> int:
        qubit_id = ctypes.c_uint64()
        if 0 != self._lib.selene_runtime_qalloc(self._instance, ctypes.byref(qubit_id)):
            raise RuntimeError("Failed to allocate qubit on Selene runtime")
        if qubit_id.value == 2**64 - 1:
            raise RuntimeError(
                "Runtime returned UINT64_MAX, which is reserved to indicate failure (e.g. out of qubits), when trying to allocate a qubit"
            )
        return qubit_id.value

    def qfree(self, qubit_id: int):
        if 0 != self._lib.selene_runtime_qfree(self._instance, qubit_id):
            raise RuntimeError("Failed to free qubit on Selene runtime")

    def rxy(self, qubit: int, theta: float, phi: float):
        if 0 != self._lib.selene_runtime_rxy_gate(self._instance, qubit, theta, phi):
            raise RuntimeError("Failed to apply RXY operation on Selene runtime")

    def rz(self, qubit: int, theta: float):
        if 0 != self._lib.selene_runtime_rz_gate(self._instance, qubit, theta):
            raise RuntimeError("Failed to apply RZ operation on Selene runtime")

    def rzz(self, qubit_a: int, qubit_b: int, theta: float):
        if 0 != self._lib.selene_runtime_rzz_gate(
            self._instance, qubit_a, qubit_b, theta
        ):
            raise RuntimeError("Failed to apply RZZ operation on Selene runtime")

    def measure(self, qubit: int) -> int:
        future_ref = ctypes.c_uint64()
        if 0 != self._lib.selene_runtime_measure(
            self._instance, qubit, ctypes.byref(future_ref)
        ):
            raise RuntimeError("Failed to apply measure operation on Selene runtime")
        return future_ref.value

    def measure_leaked(self, qubit: int) -> int:
        future_ref = ctypes.c_uint64()
        if 0 != self._lib.selene_runtime_measure_leaked(
            self._instance, qubit, ctypes.byref(future_ref)
        ):
            raise RuntimeError(
                "Failed to apply measure_leaked operation on Selene runtime"
            )
        return future_ref.value

    def reset(self, qubit: int):
        if 0 != self._lib.selene_runtime_reset(self._instance, qubit):
            raise RuntimeError("Failed to apply RESET operation on Selene runtime")

    def force_result(self, result_id: int):
        if 0 != self._lib.selene_runtime_force_result(self._instance, result_id):
            raise RuntimeError("Failed to force result on Selene runtime")

    def get_bool_result(self, result_id: int) -> bool:
        value = ctypes.c_uint8()
        if 0 != self._lib.selene_runtime_get_bool_result(
            self._instance, result_id, ctypes.byref(value)
        ):
            raise RuntimeError("Failed to get bool result from Selene runtime")
        return bool(value.value)

    def get_u64_result(self, result_id: int) -> int:
        value = ctypes.c_uint64()
        if 0 != self._lib.selene_runtime_get_u64_result(
            self._instance, result_id, ctypes.byref(value)
        ):
            raise RuntimeError("Failed to get u64 result from Selene runtime")
        return value.value

    def set_bool_result(self, result_id: int, value: bool):
        if 0 != self._lib.selene_runtime_set_bool_result(
            self._instance, result_id, value
        ):
            raise RuntimeError("Failed to set bool result on Selene runtime")

    def set_u64_result(self, result_id: int, value: int):
        if 0 != self._lib.selene_runtime_set_u64_result(
            self._instance, result_id, value
        ):
            raise RuntimeError("Failed to set u64 result on Selene runtime")

    def get_metrics(self) -> dict[str, int | float | bool]:
        # for i in 0...255, calls selene_runtime_get_metrics with:
        # - that index
        # - a pointer to a 256-byte buffer for the name
        # - a pointer to a byte for the type (0 = bool, 1 == i64, 2 == u64, 3 == f64)
        # - a pointer to a 64-bit int for the function to write the value into (even for bools and floats, which will be encoded into the int)
        # if it returns 0, read the name, type and value, and add it to the results dict. If it returns nonzero, stop and return the results dict.
        results: dict[str, int | float | bool] = {}
        for i in range(256):
            name_buffer = ctypes.create_string_buffer(256)
            type_buffer = ctypes.c_uint8()
            value_buffer = ctypes.c_uint64()
            if 0 != self._lib.selene_runtime_get_metrics(
                self._instance,
                i,
                name_buffer,
                ctypes.byref(type_buffer),
                ctypes.byref(value_buffer),
            ):
                break
            name = name_buffer.value.decode("utf-8")
            type_ = type_buffer.value
            value = value_buffer.value
            if type_ == 0:
                results[name] = bool(value)
            elif type_ == 1:
                results[name] = ctypes.c_int64(value).value
            elif type_ == 2:
                results[name] = value
            elif type_ == 3:
                results[name] = ctypes.cast(
                    ctypes.pointer(ctypes.c_uint64(value)),
                    ctypes.POINTER(ctypes.c_double),
                ).contents.value
            else:
                raise RuntimeError(f"Unknown metric type {type_} for metric {name}")
        return results
