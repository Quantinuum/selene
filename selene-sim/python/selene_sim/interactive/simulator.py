from __future__ import annotations

import ctypes
from pathlib import Path

from selene_core import Gate, Gateset, Simulator
import random

from ._library import load_selene_global


class SeleneSimulatorInstance(ctypes.Structure):
    pass


SeleneSimulatorInstancePtr = ctypes.POINTER(SeleneSimulatorInstance)
SeleneSimulatorInstancePtrPtr = ctypes.POINTER(SeleneSimulatorInstancePtr)

Errno = ctypes.c_int32

SimGetNameFn = ctypes.CFUNCTYPE(ctypes.c_char_p)
SimInitFn = ctypes.CFUNCTYPE(
    Errno,
    SeleneSimulatorInstancePtrPtr,
    ctypes.c_uint64,
    ctypes.c_uint32,
    ctypes.POINTER(ctypes.c_char_p),
)
SimExitFn = ctypes.CFUNCTYPE(Errno, SeleneSimulatorInstancePtr)
SimShotStartFn = ctypes.CFUNCTYPE(
    Errno,
    SeleneSimulatorInstancePtr,
    ctypes.c_uint64,
    ctypes.c_uint64,
)
SimShotEndFn = ctypes.CFUNCTYPE(Errno, SeleneSimulatorInstancePtr)
SimMeasureFn = ctypes.CFUNCTYPE(Errno, SeleneSimulatorInstancePtr, ctypes.c_uint64)
SimPostselectFn = ctypes.CFUNCTYPE(
    Errno, SeleneSimulatorInstancePtr, ctypes.c_uint64, ctypes.c_bool
)
SimResetFn = ctypes.CFUNCTYPE(Errno, SeleneSimulatorInstancePtr, ctypes.c_uint64)
SimGetMetricsFn = ctypes.CFUNCTYPE(
    Errno,
    SeleneSimulatorInstancePtr,
    ctypes.c_uint8,
    ctypes.c_char_p,
    ctypes.POINTER(ctypes.c_uint8),
    ctypes.POINTER(ctypes.c_uint64),
)
SimDumpStateFn = ctypes.CFUNCTYPE(
    Errno,
    SeleneSimulatorInstancePtr,
    ctypes.c_char_p,
    ctypes.POINTER(ctypes.c_uint64),
    ctypes.c_uint64,
)
SimGateFn = ctypes.CFUNCTYPE(
    Errno,
    SeleneSimulatorInstancePtr,
    ctypes.POINTER(ctypes.c_uint8),
    ctypes.c_size_t,
)
SimNegotiateGatesetFn = ctypes.CFUNCTYPE(
    Errno,
    SeleneSimulatorInstancePtr,
    ctypes.POINTER(ctypes.c_uint8),
    ctypes.c_size_t,
    ctypes.POINTER(ctypes.c_uint8),
    ctypes.c_size_t,
    ctypes.POINTER(ctypes.c_size_t),
)


class SimulatorPluginDescriptorV1(ctypes.Structure):
    _fields_ = [
        ("struct_size", ctypes.c_uint64),
        ("api_version", ctypes.c_uint64),
        ("get_name_fn", SimGetNameFn),
        ("init_fn", SimInitFn),
        ("exit_fn", SimExitFn),
        ("shot_start_fn", SimShotStartFn),
        ("shot_end_fn", SimShotEndFn),
        ("measure_fn", SimMeasureFn),
        ("postselect_fn", SimPostselectFn),
        ("reset_fn", SimResetFn),
        ("get_metrics_fn", SimGetMetricsFn),
        ("dump_state_fn", SimDumpStateFn),
        ("gate_fn", SimGateFn),
        ("negotiate_gateset_fn", SimNegotiateGatesetFn),
    ]


GetSimulatorDescriptorFn = ctypes.CFUNCTYPE(ctypes.POINTER(SimulatorPluginDescriptorV1))


class SeleneSimSimulatorLib(ctypes.CDLL):
    def __init__(self, simulator: Simulator) -> None:
        load_selene_global()
        super().__init__(str(simulator.library_file))
        self._configure_signatures()

    def _configure_signatures(self):
        descriptor: SimulatorPluginDescriptorV1 | None = None
        try:
            descriptor = SimulatorPluginDescriptorV1.in_dll(
                self, "selene_simulator_plugin_descriptor_v1"
            )
        except ValueError:
            getter = GetSimulatorDescriptorFn(
                ("selene_simulator_get_plugin_descriptor_v1", self)
            )
            descriptor_ptr = getter()
            if bool(descriptor_ptr):
                descriptor = descriptor_ptr.contents
        if descriptor is None:
            raise RuntimeError(
                "Simulator plugin did not expose descriptor symbol or accessor"
            )

        self.selene_simulator_init = descriptor.init_fn
        self.selene_simulator_exit = descriptor.exit_fn
        self.selene_simulator_shot_start = descriptor.shot_start_fn
        self.selene_simulator_shot_end = descriptor.shot_end_fn
        self.selene_simulator_operation_measure = descriptor.measure_fn
        self.selene_simulator_operation_postselect = descriptor.postselect_fn
        self.selene_simulator_operation_reset = descriptor.reset_fn
        self.selene_simulator_get_metrics = descriptor.get_metrics_fn
        self.selene_simulator_dump_state = descriptor.dump_state_fn
        self.selene_simulator_operation_gate = descriptor.gate_fn
        self.selene_simulator_negotiate_gateset = descriptor.negotiate_gateset_fn

        if self.selene_simulator_operation_postselect is None:
            raise RuntimeError("Simulator plugin does not expose postselect_fn")
        if self.selene_simulator_get_metrics is None:
            raise RuntimeError("Simulator plugin does not expose get_metrics_fn")
        if self.selene_simulator_operation_gate is None:
            raise RuntimeError("Simulator plugin does not expose gate_fn")
        if self.selene_simulator_negotiate_gateset is None:
            raise RuntimeError("Simulator plugin does not expose negotiate_gateset_fn")


class InteractiveSimulator:
    def __init__(
        self,
        *,
        n_qubits: int,
        simulator: Simulator,
        gateset: Gateset | None = None,
    ):
        self._lib = SeleneSimSimulatorLib(simulator)
        self._instance = SeleneSimulatorInstancePtr()
        if simulator.random_seed is None:
            simulator.random_seed = random.randint(0, 2**64 - 1)
        self.simulator = simulator
        self.gateset = gateset
        self.emitted_gateset: Gateset | None = None
        self.n_qubits = n_qubits
        self.shot_id = 0
        arguments = simulator.get_init_args()
        # create an array of c_char_p from the list of strings
        argc = len(arguments)
        argv = (ctypes.c_char_p * argc)(*(arg.encode("utf-8") for arg in arguments))
        if 0 != self._lib.selene_simulator_init(
            ctypes.byref(self._instance), n_qubits, argc, argv
        ):
            raise RuntimeError("Failed to initialize Selene simulator")
        if self.gateset is not None:
            self.emitted_gateset = self.register_gateset(self.gateset)
        if 0 != self._lib.selene_simulator_shot_start(
            self._instance, self.shot_id, self.simulator.random_seed
        ):
            raise RuntimeError("Failed to start first shot on Selene simulator")

    def _apply_void_operation(self, func, operation_name: str, *args):
        # The Python surface stays single-operation for ergonomics, while the
        # native bridge now executes each call via the simulator's batch API.
        if 0 != func(self._instance, *args):
            raise RuntimeError(
                f"Failed to apply {operation_name} operation on Selene simulator"
            )

    def register_gateset(self, gateset: Gateset) -> Gateset:
        payload = gateset.serialize()
        input_buffer = (ctypes.c_uint8 * len(payload))(*payload)
        input_ptr = ctypes.cast(input_buffer, ctypes.POINTER(ctypes.c_uint8))
        written = ctypes.c_size_t()
        if 0 != self._lib.selene_simulator_negotiate_gateset(
            self._instance,
            input_ptr,
            len(payload),
            None,
            0,
            ctypes.byref(written),
        ):
            raise RuntimeError("Failed to negotiate gateset with Selene simulator")
        output_buffer = (ctypes.c_uint8 * written.value)()
        output_ptr = ctypes.cast(output_buffer, ctypes.POINTER(ctypes.c_uint8))
        if 0 != self._lib.selene_simulator_negotiate_gateset(
            self._instance,
            input_ptr,
            len(payload),
            output_ptr,
            written.value,
            ctypes.byref(written),
        ):
            raise RuntimeError("Failed to negotiate gateset with Selene simulator")
        return Gateset.deserialize(bytes(output_buffer[: written.value]))

    def gate(self, gate: Gate):
        payload = gate.serialize()
        buffer = (ctypes.c_uint8 * len(payload))(*payload)
        self._apply_void_operation(
            self._lib.selene_simulator_operation_gate,
            "GATE",
            ctypes.cast(buffer, ctypes.POINTER(ctypes.c_uint8)),
            len(payload),
        )

    def _apply_measure_operation(self, qubit: int) -> bool:
        result = self._lib.selene_simulator_operation_measure(self._instance, qubit)
        if result not in (0, 1):
            raise RuntimeError("Failed to apply MEASURE operation on Selene simulator")
        return bool(result)

    def next_shot(self):
        if 0 != self._lib.selene_simulator_shot_end(self._instance):
            raise RuntimeError("Failed to end current shot on Selene simulator")
        self.shot_id += 1
        if 0 != self._lib.selene_simulator_shot_start(
            self._instance, self.shot_id, self.simulator.random_seed + self.shot_id
        ):
            raise RuntimeError("Failed to start next shot on Selene simulator")

    def measure(self, qubit: int) -> bool:
        return self._apply_measure_operation(qubit)

    def reset(self, qubit: int):
        self._apply_void_operation(
            self._lib.selene_simulator_operation_reset, "RESET", qubit
        )

    def postselect(self, qubit: int, value: bool):
        self._apply_void_operation(
            self._lib.selene_simulator_operation_postselect,
            "POSTSELECT",
            qubit,
            value,
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
            name_buffer = ctypes.create_string_buffer(256)
            type_buffer = ctypes.c_uint8()
            value_buffer = ctypes.c_uint64()
            if 0 != self._lib.selene_simulator_get_metrics(
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

    def dump_state(self, outfile: Path, qubits: list[int]) -> None:
        qubit_array = (ctypes.c_uint64 * len(qubits))(*qubits)
        outfile_str = str(outfile).encode("utf-8")
        len_qubits = len(qubits)
        pointer_to_qubit_array = ctypes.cast(
            ctypes.pointer(qubit_array), ctypes.POINTER(ctypes.c_uint64)
        )

        if 0 != self._lib.selene_simulator_dump_state(
            self._instance,
            outfile_str,
            pointer_to_qubit_array,
            ctypes.c_uint64(len_qubits),
        ):
            raise RuntimeError("Failed to dump state on Selene simulator")
