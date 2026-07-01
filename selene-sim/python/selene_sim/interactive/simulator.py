from __future__ import annotations

import struct
from pathlib import Path
from typing import Any

from selene_core import Gate, Gateset, Simulator
from selene_core.c_abi import SimulatorCTypes, ffi
import random

from ._library import load_selene_global


class SeleneSimSimulatorLib:
    def __init__(self, simulator: Simulator) -> None:
        load_selene_global()
        self.ffi = ffi()
        self.types = SimulatorCTypes(self.ffi)
        self.lib = self.ffi.dlopen(str(simulator.library_file))
        try:
            self.descriptor = self.lib.selene_simulator_plugin_descriptor_v1
        except AttributeError as exc:
            raise RuntimeError(
                "Simulator plugin did not expose descriptor symbol"
            ) from exc

        self.last_error_fn = self._required(
            self.descriptor.header.last_error_fn, "last_error_fn"
        )
        self.get_name_fn = self._required(
            self.descriptor.header.get_name_fn, "get_name_fn"
        )
        self.init_fn = self._required(self.descriptor.init_fn, "init_fn")
        self.shot_start_fn = self._required(
            self.descriptor.shot_start_fn, "shot_start_fn"
        )
        self.shot_end_fn = self._required(self.descriptor.shot_end_fn, "shot_end_fn")
        self.handle_operations_fn = self._required(
            self.descriptor.handle_operations_fn, "handle_operations_fn"
        )
        self.negotiate_gateset_fn = self._required(
            self.descriptor.negotiate_gateset_fn, "negotiate_gateset_fn"
        )
        self.dump_state_fn = self._required(
            self.descriptor.dump_state_fn, "dump_state_fn"
        )

        self.exit_fn = self.descriptor.exit_fn
        self.get_metrics_fn = self.descriptor.get_metrics_fn

    def _required(self, function, function_name: str):
        if function == self.ffi.NULL:
            raise RuntimeError(f"Simulator plugin does not expose {function_name}")
        return function

    def init(self, n_qubits: int, args: list[str]):
        handle = self.ffi.new(self.types.simulator_instance_ptr)
        encoded_args = [
            self.ffi.new(self.types.char_array, arg.encode("utf-8")) for arg in args
        ]
        argv = self.ffi.new(self.types.char_ptr_array, encoded_args)
        errno = self.init_fn(handle, n_qubits, len(args), argv)
        if errno != 0:
            raise RuntimeError("Failed to initialize Selene simulator")
        return handle[0]

    def shot_start(self, instance, shot_id: int, seed: int):
        return self.shot_start_fn(instance, shot_id, seed)

    def shot_end(self, instance):
        return self.shot_end_fn(instance)

    def _batch_handle(self, operations: list[Any]):
        refs: list[Any] = []

        @self.ffi.callback(
            "void(const RuntimeExtractOperationHandle *, RuntimeGetOperationHandle)"
        )
        def extract(input_handle, output_handle):
            batch = self.ffi.from_handle(input_handle[0].instance)
            for operation in batch:
                kind = operation[0]
                if kind == "gate":
                    payload = operation[1]
                    data = self.ffi.new(self.types.uint8_array, payload)
                    refs.append(data)
                    output_handle.interface.gate_fn(
                        output_handle.instance, data, len(payload)
                    )
                elif kind == "measure":
                    output_handle.interface.measure_fn(
                        output_handle.instance, operation[1], operation[2]
                    )
                elif kind == "postselect":
                    output_handle.interface.postselect_fn(
                        output_handle.instance, operation[1], operation[2]
                    )
                elif kind == "reset":
                    output_handle.interface.reset_fn(output_handle.instance, operation[1])
                else:
                    raise RuntimeError(f"unsupported simulator operation {kind!r}")

        batch_ref = self.ffi.new_handle(operations)
        refs.extend([batch_ref, extract])
        return self.ffi.new(
            self.types.runtime_extract_operation_handle,
            {"instance": batch_ref, "interface": {"extract_fn": extract}},
        ), refs

    def _result_handle(self):
        result = {"bool": {}, "u64": {}}
        refs: list[Any] = []

        @self.ffi.callback("void(SeleneOperationResultInstance, uint64_t, bool)")
        def set_bool(instance, result_id, value):
            target = self.ffi.from_handle(instance)
            target["bool"][int(result_id)] = bool(value)

        @self.ffi.callback("void(SeleneOperationResultInstance, uint64_t, uint64_t)")
        def set_u64(instance, result_id, value):
            target = self.ffi.from_handle(instance)
            target["u64"][int(result_id)] = int(value)

        result_ref = self.ffi.new_handle(result)
        refs.extend([result_ref, set_bool, set_u64])
        return self.ffi.new(
            self.types.operation_result_handle,
            {
                "instance": result_ref,
                "interface": {
                    "set_bool_result_fn": set_bool,
                    "set_u64_result_fn": set_u64,
                },
            },
        ), result, refs

    def _handle_operations(self, instance, operations: list[Any]):
        batch, batch_refs = self._batch_handle(operations)
        result, result_data, result_refs = self._result_handle()
        refs = [batch, result, *batch_refs, *result_refs]
        try:
            errno = self.handle_operations_fn(instance, batch[0], result[0])
        finally:
            refs.clear()
        return errno, result_data

    def gate(self, instance, payload: bytes):
        errno, result = self._handle_operations(instance, [("gate", payload)])
        if errno == 0 and (result["bool"] or result["u64"]):
            return -1
        return errno

    def measure(self, instance, qubit: int):
        errno, result = self._handle_operations(instance, [("measure", qubit, 0)])
        if errno != 0:
            return errno
        bool_results = result["bool"]
        if set(bool_results) != {0} or result["u64"]:
            return -1
        return 1 if bool_results[0] else 0

    def reset(self, instance, qubit: int):
        errno, result = self._handle_operations(instance, [("reset", qubit)])
        if errno == 0 and (result["bool"] or result["u64"]):
            return -1
        return errno

    def postselect(self, instance, qubit: int, value: bool):
        errno, result = self._handle_operations(instance, [("postselect", qubit, value)])
        if errno == 0 and (result["bool"] or result["u64"]):
            return -1
        return errno

    def negotiate_gateset(self, instance, payload: bytes) -> bytes:
        input_data = self.ffi.new(self.types.uint8_array, payload)
        written = self.ffi.new(self.types.size_ptr)
        errno = self.negotiate_gateset_fn(
            instance, input_data, len(payload), self.ffi.NULL, 0, written
        )
        if errno != 0:
            raise RuntimeError("Failed to negotiate gateset with Selene simulator")
        output_data = self.ffi.new(self.types.uint8_array, written[0])
        errno = self.negotiate_gateset_fn(
            instance, input_data, len(payload), output_data, written[0], written
        )
        if errno != 0:
            raise RuntimeError("Failed to negotiate gateset with Selene simulator")
        return bytes(self.ffi.buffer(output_data, written[0]))

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

    def dump_state(self, instance, outfile: Path, qubits: list[int]):
        path = self.ffi.new(self.types.char_array, str(outfile).encode("utf-8"))
        qubit_data = self.ffi.new(self.types.uint64_array, qubits)
        return self.dump_state_fn(instance, path, qubit_data, len(qubits))


class InteractiveSimulator:
    def __init__(
        self,
        *,
        n_qubits: int,
        simulator: Simulator,
        gateset: Gateset | None = None,
    ):
        self._lib = SeleneSimSimulatorLib(simulator)
        if simulator.random_seed is None:
            simulator.random_seed = random.randint(0, 2**64 - 1)
        self.simulator = simulator
        self.gateset = gateset
        self.emitted_gateset: Gateset | None = None
        self.n_qubits = n_qubits
        self.shot_id = 0
        arguments = simulator.get_init_args()
        self._instance = self._lib.init(n_qubits, arguments)
        if self.gateset is not None:
            self.emitted_gateset = self.register_gateset(self.gateset)
        seed = self.simulator.random_seed
        assert seed is not None
        if 0 != self._lib.shot_start(self._instance, self.shot_id, seed):
            raise RuntimeError("Failed to start first shot on Selene simulator")

    def _apply_void_operation(self, errno: int, operation_name: str):
        # The Python surface stays single-operation for ergonomics, while the
        # native bridge now executes each call via the simulator's batch API.
        if errno != 0:
            raise RuntimeError(
                f"Failed to apply {operation_name} operation on Selene simulator"
            )

    def register_gateset(self, gateset: Gateset) -> Gateset:
        payload = gateset.serialize()
        return Gateset.deserialize(self._lib.negotiate_gateset(self._instance, payload))

    def gate(self, gate: Gate):
        payload = gate.serialize()
        self._apply_void_operation(
            self._lib.gate(self._instance, payload),
            "GATE",
        )

    def _apply_measure_operation(self, qubit: int) -> bool:
        result = self._lib.measure(self._instance, qubit)
        if result not in (0, 1):
            raise RuntimeError("Failed to apply MEASURE operation on Selene simulator")
        return bool(result)

    def next_shot(self):
        if 0 != self._lib.shot_end(self._instance):
            raise RuntimeError("Failed to end current shot on Selene simulator")
        self.shot_id += 1
        seed = self.simulator.random_seed
        assert seed is not None
        if 0 != self._lib.shot_start(
            self._instance,
            self.shot_id,
            seed + self.shot_id,
        ):
            raise RuntimeError("Failed to start next shot on Selene simulator")

    def measure(self, qubit: int) -> bool:
        return self._apply_measure_operation(qubit)

    def reset(self, qubit: int):
        self._apply_void_operation(
            self._lib.reset(self._instance, qubit), "RESET"
        )

    def postselect(self, qubit: int, value: bool):
        self._apply_void_operation(
            self._lib.postselect(self._instance, qubit, value),
            "POSTSELECT",
        )

    def get_metrics(self) -> dict[str, int | float | bool]:
        # for i in 0...255, calls selene_simulator_get_metrics with:
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

    def dump_state(self, outfile: Path, qubits: list[int]) -> None:
        if 0 != self._lib.dump_state(self._instance, outfile, qubits):
            raise RuntimeError("Failed to dump state on Selene simulator")
