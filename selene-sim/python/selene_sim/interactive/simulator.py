from __future__ import annotations

import ctypes
from pathlib import Path

from selene_core import Simulator
import random


class SeleneSimulatorInstance(ctypes.Structure):
    pass


SeleneSimulatorInstancePtr = ctypes.POINTER(SeleneSimulatorInstance)
SeleneSimulatorInstancePtrPtr = ctypes.POINTER(SeleneSimulatorInstancePtr)


class SeleneSimSimulatorLib(ctypes.CDLL):
    def __init__(self, simulator: Simulator) -> None:
        super().__init__(str(simulator.library_file))
        self._configure_signatures()

    def _configure_signatures(self):
        self.selene_simulator_get_api_version.argtypes = []
        self.selene_simulator_get_api_version.restype = ctypes.c_uint64
        self.selene_simulator_init.argtypes = [
            SeleneSimulatorInstancePtrPtr,
            ctypes.c_uint64,
            ctypes.c_uint32,
            ctypes.POINTER(ctypes.c_char_p),
        ]
        self.selene_simulator_init.restype = ctypes.c_int32

        self.selene_simulator_exit.argtypes = [SeleneSimulatorInstancePtr]
        self.selene_simulator_exit.restype = ctypes.c_int32

        self.selene_simulator_shot_start.argtypes = [
            SeleneSimulatorInstancePtr,
            ctypes.c_uint64,
            ctypes.c_uint64,
        ]
        self.selene_simulator_shot_start.restype = ctypes.c_int32
        self.selene_simulator_shot_end.argtypes = [SeleneSimulatorInstancePtr]
        self.selene_simulator_shot_end.restype = ctypes.c_int32
        self.selene_simulator_operation_rxy.argtypes = [
            SeleneSimulatorInstancePtr,
            ctypes.c_uint64,
            ctypes.c_double,
            ctypes.c_double,
        ]
        self.selene_simulator_operation_rxy.restype = ctypes.c_int32
        self.selene_simulator_operation_rz.argtypes = [
            SeleneSimulatorInstancePtr,
            ctypes.c_uint64,
            ctypes.c_double,
        ]
        self.selene_simulator_operation_rz.restype = ctypes.c_int32
        self.selene_simulator_operation_rzz.argtypes = [
            SeleneSimulatorInstancePtr,
            ctypes.c_uint64,
            ctypes.c_uint64,
            ctypes.c_double,
        ]
        self.selene_simulator_operation_rzz.restype = ctypes.c_int32
        self.selene_simulator_operation_measure.argtypes = [
            SeleneSimulatorInstancePtr,
            ctypes.c_uint64,
        ]
        self.selene_simulator_operation_measure.restype = ctypes.c_int32
        self.selene_simulator_operation_postselect.argtypes = [
            SeleneSimulatorInstancePtr,
            ctypes.c_uint64,
            ctypes.c_bool,
        ]
        self.selene_simulator_operation_postselect.restype = ctypes.c_int32
        self.selene_simulator_operation_reset.argtypes = [
            SeleneSimulatorInstancePtr,
            ctypes.c_uint64,
        ]
        self.selene_simulator_operation_reset.restype = ctypes.c_int32
        self.selene_simulator_get_metrics.argtypes = [
            SeleneSimulatorInstancePtr,
            ctypes.c_uint8,
            ctypes.c_char_p,
            ctypes.POINTER(ctypes.c_uint8),
            ctypes.POINTER(ctypes.c_uint64),
        ]
        self.selene_simulator_get_metrics.restype = ctypes.c_int32
        self.selene_simulator_dump_state.argtypes = [
            SeleneSimulatorInstancePtr,
            ctypes.c_char_p,
            ctypes.POINTER(ctypes.c_uint64),
            ctypes.c_uint64,
        ]
        self.selene_simulator_dump_state.restype = ctypes.c_int32


class InteractiveSimulator:
    def __init__(
        self,
        *,
        n_qubits: int,
        simulator: Simulator,
    ):
        self._lib = SeleneSimSimulatorLib(simulator)
        self._instance = SeleneSimulatorInstancePtr()
        if simulator.random_seed is None:
            simulator.random_seed = random.randint(0, 2**64 - 1)
        self.simulator = simulator
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
        if 0 != self._lib.selene_simulator_shot_start(
            self._instance, self.shot_id, self.simulator.random_seed
        ):
            raise RuntimeError("Failed to start first shot on Selene simulator")

    def next_shot(self):
        if 0 != self._lib.selene_simulator_shot_end(self._instance):
            raise RuntimeError("Failed to end current shot on Selene simulator")
        self.shot_id += 1
        if 0 != self._lib.selene_simulator_shot_start(
            self._instance, self.shot_id, self.simulator.random_seed + self.shot_id
        ):
            raise RuntimeError("Failed to start next shot on Selene simulator")

    def rxy(self, qubit: int, theta: float, phi: float):
        if 0 != self._lib.selene_simulator_operation_rxy(
            self._instance, qubit, theta, phi
        ):
            raise RuntimeError("Failed to apply RXY operation on Selene simulator")

    def rz(self, qubit: int, theta: float):
        if 0 != self._lib.selene_simulator_operation_rz(self._instance, qubit, theta):
            raise RuntimeError("Failed to apply RZ operation on Selene simulator")

    def rzz(self, qubit_a: int, qubit_b: int, theta: float):
        if 0 != self._lib.selene_simulator_operation_rzz(
            self._instance, qubit_a, qubit_b, theta
        ):
            raise RuntimeError("Failed to apply RZZ operation on Selene simulator")

    def measure(self, qubit: int) -> bool:
        result = self._lib.selene_simulator_operation_measure(self._instance, qubit)
        if result not in (0, 1):
            raise RuntimeError("Failed to apply MEASURE operation on Selene simulator")
        return bool(result)

    def reset(self, qubit: int):
        if 0 != self._lib.selene_simulator_operation_reset(self._instance, qubit):
            raise RuntimeError("Failed to apply RESET operation on Selene simulator")

    def postselect(self, qubit: int, value: bool):
        if 0 != self._lib.selene_simulator_operation_postselect(
            self._instance, qubit, value
        ):
            raise RuntimeError(
                "Failed to apply POSTSELECT operation on Selene simulator"
            )

    def get_metrics(self) -> dict[str, int | float | bool]:
        # for i in 0...255, call selene_simulator_get_metrics with:
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
