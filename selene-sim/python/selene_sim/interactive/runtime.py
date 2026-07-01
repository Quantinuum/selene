from __future__ import annotations

from dataclasses import dataclass
import struct

from selene_core import Gate, Gateset, Runtime
from selene_core.c_abi import RuntimeCTypes, ffi
import random

from ._library import load_selene_global


_FFI = ffi()


@dataclass
class MeasureOperation:
    qubit_id: int
    result_id: int


@dataclass
class ResetOperation:
    qubit_id: int


@dataclass
class GateOperation:
    gate: Gate


@dataclass
class CustomOperation:
    tag: int
    data: bytes


@dataclass
class MeasureLeakedOperation:
    qubit_id: int
    result_id: int


@dataclass
class PostselectOperation:
    qubit_id: int
    target_value: bool


RuntimeOperation = (
    MeasureOperation
    | ResetOperation
    | GateOperation
    | CustomOperation
    | MeasureLeakedOperation
    | PostselectOperation
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

    def gate(self, gate: Gate):
        self.operations.append(GateOperation(gate))
        self.invoked = True

    def measure(self, qubit_id: int, result_id: int):
        self.operations.append(MeasureOperation(qubit_id, result_id))
        self.invoked = True

    def measure_leaked(self, qubit_id: int, result_id: int):
        self.operations.append(MeasureLeakedOperation(qubit_id, result_id))
        self.invoked = True

    def postselect(self, qubit_id: int, target_value: bool):
        self.operations.append(PostselectOperation(qubit_id, target_value))
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
    def from_handle(handle) -> OperationBatch:
        return _FFI.from_handle(handle)


@_FFI.callback("void(SeleneRuntimeGetOperationInstance, const uint8_t *, size_t)")
def callback_gate(
    instance,
    data_ptr,
    data_len: int,
):
    OperationBatch.from_handle(instance).gate(
        Gate.deserialize(bytes(_FFI.buffer(data_ptr, data_len)))
    )


@_FFI.callback("void(SeleneRuntimeGetOperationInstance, uint64_t, uint64_t)")
def callback_measure(instance, qubit_id: int, result_id: int):
    OperationBatch.from_handle(instance).measure(qubit_id, result_id)


@_FFI.callback("void(SeleneRuntimeGetOperationInstance, uint64_t, uint64_t)")
def callback_measure_leaked(instance, qubit_id: int, result_id: int):
    OperationBatch.from_handle(instance).measure_leaked(qubit_id, result_id)


@_FFI.callback("void(SeleneRuntimeGetOperationInstance, uint64_t, bool)")
def callback_postselect(instance, qubit_id: int, target_value: bool):
    OperationBatch.from_handle(instance).postselect(qubit_id, target_value)


@_FFI.callback("void(SeleneRuntimeGetOperationInstance, uint64_t)")
def callback_reset(instance, qubit_id: int):
    OperationBatch.from_handle(instance).reset(qubit_id)


@_FFI.callback("void(SeleneRuntimeGetOperationInstance, size_t, const void *, size_t)")
def callback_custom(
    instance,
    tag: int,
    data_ptr,
    data_len: int,
):
    data = bytes(_FFI.buffer(data_ptr, data_len))
    OperationBatch.from_handle(instance).custom(tag, data)


@_FFI.callback("void(SeleneRuntimeGetOperationInstance, uint64_t, uint64_t)")
def callback_set_batch_time(instance, start_time: int, duration: int):
    OperationBatch.from_handle(instance).set_time(start_time, duration)


class SeleneSimRuntimeLib:
    def __init__(self, runtime: Runtime) -> None:
        load_selene_global()
        self.ffi = ffi()
        self.types = RuntimeCTypes(self.ffi)
        self.lib = self.ffi.dlopen(str(runtime.library_file))
        try:
            self.descriptor = self.lib.selene_runtime_plugin_descriptor_v1
        except AttributeError as exc:
            raise RuntimeError(
                "Runtime plugin did not expose descriptor symbol"
            ) from exc

        self.last_error_fn = self._required(
            self.descriptor.header.last_error_fn, "last_error_fn"
        )
        self.get_name_fn = self._required(
            self.descriptor.header.get_name_fn, "get_name_fn"
        )
        self.init_fn = self._required(self.descriptor.init_fn, "init_fn")
        self.get_next_operations_fn = self._required(
            self.descriptor.get_next_operations_fn, "get_next_operations_fn"
        )
        self.shot_start_fn = self._required(
            self.descriptor.shot_start_fn, "shot_start_fn"
        )
        self.shot_end_fn = self._required(self.descriptor.shot_end_fn, "shot_end_fn")
        self.qalloc_fn = self._required(self.descriptor.qalloc_fn, "qalloc_fn")
        self.qfree_fn = self._required(self.descriptor.qfree_fn, "qfree_fn")
        self.local_barrier_fn = self._required(
            self.descriptor.local_barrier_fn, "local_barrier_fn"
        )
        self.global_barrier_fn = self._required(
            self.descriptor.global_barrier_fn, "global_barrier_fn"
        )
        self.measure_fn = self._required(self.descriptor.measure_fn, "measure_fn")
        self.measure_leaked_fn = self._required(
            self.descriptor.measure_leaked_fn, "measure_leaked_fn"
        )
        self.reset_fn = self._required(self.descriptor.reset_fn, "reset_fn")
        self.force_result_fn = self._required(
            self.descriptor.force_result_fn, "force_result_fn"
        )
        self.get_bool_result_fn = self._required(
            self.descriptor.get_bool_result_fn, "get_bool_result_fn"
        )
        self.get_u64_result_fn = self._required(
            self.descriptor.get_u64_result_fn, "get_u64_result_fn"
        )
        self.set_bool_result_fn = self._required(
            self.descriptor.set_bool_result_fn, "set_bool_result_fn"
        )
        self.set_u64_result_fn = self._required(
            self.descriptor.set_u64_result_fn, "set_u64_result_fn"
        )
        self.increment_future_refcount_fn = self._required(
            self.descriptor.increment_future_refcount_fn,
            "increment_future_refcount_fn",
        )
        self.decrement_future_refcount_fn = self._required(
            self.descriptor.decrement_future_refcount_fn,
            "decrement_future_refcount_fn",
        )
        self.gate_fn = self._required(self.descriptor.gate_fn, "gate_fn")
        self.negotiate_gateset_fn = self._required(
            self.descriptor.negotiate_gateset_fn, "negotiate_gateset_fn"
        )

        self.exit_fn = self.descriptor.exit_fn
        self.get_metrics_fn = self.descriptor.get_metrics_fn
        self.custom_call_fn = self.descriptor.custom_call_fn
        self.simulate_delay_fn = self.descriptor.simulate_delay_fn
        self.operation_callbacks = self._operation_callbacks()

    def _required(self, function, function_name: str):
        if function == self.ffi.NULL:
            raise RuntimeError(f"Runtime plugin does not expose {function_name}")
        return function

    def _operation_callbacks(self):
        callbacks = self.ffi.new(self.types.runtime_get_operation_interface_ptr)
        callbacks.measure_fn = callback_measure
        callbacks.measure_leaked_fn = callback_measure_leaked
        callbacks.postselect_fn = callback_postselect
        callbacks.reset_fn = callback_reset
        callbacks.custom_fn = callback_custom
        callbacks.set_batch_time_fn = callback_set_batch_time
        callbacks.gate_fn = callback_gate
        return callbacks[0]

    def init(self, n_qubits: int, start_time_nanos: int, args: list[str]):
        handle = self.ffi.new(self.types.runtime_instance_ptr)
        encoded_args = [
            self.ffi.new(self.types.char_array, arg.encode("utf-8")) for arg in args
        ]
        argv = self.ffi.new(self.types.char_ptr_array, encoded_args)
        errno = self.init_fn(handle, n_qubits, start_time_nanos, len(args), argv)
        if errno != 0:
            raise RuntimeError("Failed to initialize Selene runtime")
        return handle[0]

    def shot_start(self, instance, shot_id: int, seed: int):
        return self.shot_start_fn(instance, shot_id, seed)

    def shot_end(self, instance):
        return self.shot_end_fn(instance)

    def negotiate_gateset(self, instance, payload: bytes) -> bytes:
        input_data = self.ffi.new(self.types.uint8_array, payload)
        written = self.ffi.new(self.types.size_ptr)
        errno = self.negotiate_gateset_fn(
            instance, input_data, len(payload), self.ffi.NULL, 0, written
        )
        if errno != 0:
            raise RuntimeError("Failed to negotiate gateset with Selene runtime")
        output_data = self.ffi.new(self.types.uint8_array, written[0])
        errno = self.negotiate_gateset_fn(
            instance, input_data, len(payload), output_data, written[0], written
        )
        if errno != 0:
            raise RuntimeError("Failed to negotiate gateset with Selene runtime")
        return bytes(self.ffi.buffer(output_data, written[0]))

    def get_next_operations(self, instance, batch: OperationBatch):
        batch_handle = self.ffi.new_handle(batch)
        handle = self.ffi.new(self.types.runtime_get_operation_handle_ptr)
        handle.instance = batch_handle
        handle.interface = self.operation_callbacks
        return self.get_next_operations_fn(instance, handle[0])

    def qalloc(self, instance):
        qubit_id = self.ffi.new(self.types.uint64_ptr)
        errno = self.qalloc_fn(instance, qubit_id)
        return errno, int(qubit_id[0])

    def qfree(self, instance, qubit_id: int):
        return self.qfree_fn(instance, qubit_id)

    def gate(self, instance, payload: bytes):
        data = self.ffi.new(self.types.uint8_array, payload)
        return self.gate_fn(instance, data, len(payload))

    def measure(self, instance, qubit: int):
        future_ref = self.ffi.new(self.types.uint64_ptr)
        errno = self.measure_fn(instance, qubit, future_ref)
        return errno, int(future_ref[0])

    def measure_leaked(self, instance, qubit: int):
        future_ref = self.ffi.new(self.types.uint64_ptr)
        errno = self.measure_leaked_fn(instance, qubit, future_ref)
        return errno, int(future_ref[0])

    def reset(self, instance, qubit: int):
        return self.reset_fn(instance, qubit)

    def force_result(self, instance, result_id: int):
        return self.force_result_fn(instance, result_id)

    def get_bool_result(self, instance, result_id: int):
        value = self.ffi.new(self.types.int8_ptr)
        errno = self.get_bool_result_fn(instance, result_id, value)
        return errno, int(value[0])

    def get_u64_result(self, instance, result_id: int):
        value = self.ffi.new(self.types.uint64_ptr)
        errno = self.get_u64_result_fn(instance, result_id, value)
        return errno, int(value[0])

    def set_bool_result(self, instance, result_id: int, value: bool):
        return self.set_bool_result_fn(instance, result_id, value)

    def set_u64_result(self, instance, result_id: int, value: int):
        return self.set_u64_result_fn(instance, result_id, value)

    def get_metric(self, instance, nth_metric: int):
        if self.get_metrics_fn == self.ffi.NULL:
            return None
        name = self.ffi.new(self.types.char_array, 256)
        datatype = self.ffi.new(self.types.uint8_ptr)
        value = self.ffi.new(self.types.uint64_ptr)
        errno = self.get_metrics_fn(instance, nth_metric, name, datatype, value)
        if errno != 0:
            return None
        return self.ffi.string(name).decode("utf-8"), int(datatype[0]), int(value[0])


class InteractiveRuntime:
    def __init__(
        self,
        *,
        n_qubits: int,
        runtime: Runtime,
        start_time_nanos: int = 0,
        gateset: Gateset | None = None,
    ):
        self._lib = SeleneSimRuntimeLib(runtime)
        if runtime.random_seed is None:
            runtime.random_seed = random.randint(0, 2**64 - 1)
        self.runtime = runtime
        self.gateset = gateset
        self.emitted_gateset: Gateset | None = None
        self.n_qubits = n_qubits
        self.shot_id = 0
        arguments = runtime.get_init_args()
        self._instance = self._lib.init(n_qubits, start_time_nanos, arguments)
        if self.gateset is not None:
            self.emitted_gateset = self.register_gateset(self.gateset)
        seed = self.runtime.random_seed
        assert seed is not None
        if 0 != self._lib.shot_start(self._instance, self.shot_id, seed):
            raise RuntimeError("Failed to start first shot on Selene runtime")

    def register_gateset(self, gateset: Gateset) -> Gateset:
        payload = gateset.serialize()
        return Gateset.deserialize(self._lib.negotiate_gateset(self._instance, payload))

    def next_shot(self):
        if 0 != self._lib.shot_end(self._instance):
            raise RuntimeError("Failed to end current shot on Selene runtime")
        self.shot_id += 1
        seed = self.runtime.random_seed
        assert seed is not None
        if 0 != self._lib.shot_start(self._instance, self.shot_id, seed + self.shot_id):
            raise RuntimeError("Failed to start next shot on Selene runtime")

    def get_operations(self) -> list[OperationBatch]:
        batches = []
        while True:
            batch = OperationBatch()
            if 0 != self._lib.get_next_operations(self._instance, batch):
                raise RuntimeError("Failed to get next operations from Selene runtime")
            if not batch.invoked:
                break
            batches.append(batch)
        return batches

    def qalloc(self) -> int:
        errno, qubit_id = self._lib.qalloc(self._instance)
        if errno != 0:
            raise RuntimeError("Failed to allocate qubit on Selene runtime")
        if qubit_id == 2**64 - 1:
            raise RuntimeError(
                "Runtime returned UINT64_MAX, which is reserved to indicate failure (e.g. out of qubits), when trying to allocate a qubit"
            )
        return qubit_id

    def qfree(self, qubit_id: int):
        if 0 != self._lib.qfree(self._instance, qubit_id):
            raise RuntimeError("Failed to free qubit on Selene runtime")

    def gate(self, gate: Gate):
        payload = gate.serialize()
        if 0 != self._lib.gate(self._instance, payload):
            raise RuntimeError(
                "Failed to apply generic gate operation on Selene runtime"
            )

    def measure(self, qubit: int) -> int:
        errno, future_ref = self._lib.measure(self._instance, qubit)
        if errno != 0:
            raise RuntimeError("Failed to apply measure operation on Selene runtime")
        return future_ref

    def measure_leaked(self, qubit: int) -> int:
        errno, future_ref = self._lib.measure_leaked(self._instance, qubit)
        if errno != 0:
            raise RuntimeError(
                "Failed to apply measure_leaked operation on Selene runtime"
            )
        return future_ref

    def reset(self, qubit: int):
        if 0 != self._lib.reset(self._instance, qubit):
            raise RuntimeError("Failed to apply RESET operation on Selene runtime")

    def force_result(self, result_id: int):
        if 0 != self._lib.force_result(self._instance, result_id):
            raise RuntimeError("Failed to force result on Selene runtime")

    def get_bool_result(self, result_id: int) -> bool:
        errno, value = self._lib.get_bool_result(self._instance, result_id)
        if errno != 0:
            raise RuntimeError("Failed to get bool result from Selene runtime")
        return bool(value)

    def get_u64_result(self, result_id: int) -> int:
        errno, value = self._lib.get_u64_result(self._instance, result_id)
        if errno != 0:
            raise RuntimeError("Failed to get u64 result from Selene runtime")
        return value

    def set_bool_result(self, result_id: int, value: bool):
        if 0 != self._lib.set_bool_result(self._instance, result_id, value):
            raise RuntimeError("Failed to set bool result on Selene runtime")

    def set_u64_result(self, result_id: int, value: int):
        if 0 != self._lib.set_u64_result(self._instance, result_id, value):
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
            metric = self._lib.get_metric(self._instance, i)
            if metric is None:
                break
            name, type_, value = metric
            if type_ == 0:
                results[name] = bool(value)
            elif type_ == 1:
                results[name] = int.from_bytes(
                    value.to_bytes(8, "little"), "little", signed=True
                )
            elif type_ == 2:
                results[name] = value
            elif type_ == 3:
                results[name] = struct.unpack("<d", value.to_bytes(8, "little"))[0]
            else:
                raise RuntimeError(f"Unknown metric type {type_} for metric {name}")
        return results
