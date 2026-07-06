"""
Provides CircuitExtractor, a class that can be used to extract
instructions from the INSTRUCTIONLOG tag emitted by Selene.

This allows the user to extract the instructions requested by the
user program as a pytket.Circuit, the batches of instructions
issued by the runtime, the noisy operations emitted by the error
model, and the timed operations received by the simulator, on a
shot-by-shot basis.
"""

from abc import ABC, abstractmethod
from enum import Enum
from dataclasses import dataclass
from collections.abc import Iterator
from typing import Any
import math

from selene_core import Gate, PhasedX, PhasedXX, RZ, ZZPhase
from selene_core.trace import (
    Trace,
    GateEvent,
    MeasurementEvent,
    ResetEvent,
    OpaquePayload,
    CustomEvent,
)

from .event_hook import EventHook

PYTKET_AVAILABLE = False
try:
    import pytket

    PYTKET_AVAILABLE = True
except ImportError:
    pass


class Operation(ABC):
    @abstractmethod
    def append_to_circuit(self, circuit: "pytket.Circuit"):
        pass

    @abstractmethod
    def to_dict(self) -> dict:
        pass

    @staticmethod
    @abstractmethod
    def from_iterator(it: Iterator):
        pass


@dataclass
class BatchStart(Operation):
    start_time_ns: int
    duration_ns: int

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        pass

    def to_dict(self) -> dict:
        return {
            "op": "BatchStart",
            "start_time_ns": self.start_time_ns,
            "duration_ns": self.duration_ns,
        }

    @staticmethod
    def from_iterator(it: Iterator):
        start_time_ns = next(it)
        duration_ns = next(it)
        return BatchStart(start_time_ns=start_time_ns, duration_ns=duration_ns)


@dataclass
class CustomOperation(Operation):
    tag: int
    data: bytes

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        pass

    def to_dict(self) -> dict:
        return {"op": "CustomOperation", "tag": self.tag, "data": self.data}

    @staticmethod
    def from_iterator(it: Iterator):
        tag = next(it)
        data = bytes(next(it))
        return CustomOperation(tag=tag, data=data)


@dataclass
class LocalBarrier(Operation):
    qubits: list[int]
    sleep_time: int

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        circuit.add_barrier(self.qubits)

    def to_dict(self) -> dict:
        return {
            "op": "LocalBarrier",
            "qubits": self.qubits,
            "sleep_time": self.sleep_time,
        }

    @staticmethod
    def from_iterator(it: Iterator):
        qubits_len = next(it)
        qubits = []
        for _ in range(qubits_len):
            qubits.append(next(it))
        sleep_time = next(it)
        return LocalBarrier(qubits=qubits, sleep_time=sleep_time)


@dataclass
class GlobalBarrier(Operation):
    sleep_time: int

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        circuit.add_barrier(circuit.qubits)

    def to_dict(self) -> dict:
        return {"op": "GlobalBarrier", "sleep_time": self.sleep_time}

    @staticmethod
    def from_iterator(it: Iterator):
        sleep_time = next(it)
        return GlobalBarrier(sleep_time=sleep_time)


@dataclass
class QAlloc(Operation):
    qubit: int

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        assert PYTKET_AVAILABLE, "pytket is not available"
        if circuit.n_qubits <= self.qubit:
            circuit.add_qubit(pytket.Qubit(self.qubit))

    def to_dict(self) -> dict:
        return {"op": "QAlloc", "qubit": self.qubit}

    @staticmethod
    def from_iterator(it: Iterator):
        return QAlloc(qubit=next(it))


@dataclass
class QFree(Operation):
    qubit: int

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        assert PYTKET_AVAILABLE, "pytket is not available"

    def to_dict(self) -> dict:
        return {"op": "QFree", "qubit": self.qubit}

    @staticmethod
    def from_iterator(it: Iterator):
        return QFree(qubit=next(it))


@dataclass
class GateInstruction(Operation):
    gate: Gate

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        assert PYTKET_AVAILABLE, "pytket is not available"
        if self.gate.semantic_id == RZ.semantic_id:
            q0, theta = self._values()
            q0 = int(q0)
            theta = float(theta)
            circuit.Rz(angle=theta / math.pi, qubit=q0)
        elif self.gate.semantic_id == PhasedX.semantic_id:
            q0, theta, phi = self._values()
            q0 = int(q0)
            theta = float(theta)
            phi = float(phi)
            circuit.PhasedX(angle0=theta / math.pi, angle1=phi / math.pi, qubit=q0)
        elif self.gate.semantic_id == ZZPhase.semantic_id:
            q0, q1, theta = self._values()
            q0 = int(q0)
            q1 = int(q1)
            theta = float(theta)
            circuit.ZZPhase(angle=theta / math.pi, qubit0=q0, qubit1=q1)
        elif self.gate.semantic_id == PhasedXX.semantic_id:
            q0, q1, theta, phi = self._values()
            q0 = int(q0)
            q1 = int(q1)
            theta = float(theta)
            phi = float(phi)
            circuit.PhasedXX(
                angle0=theta / math.pi,
                angle1=phi / math.pi,
                qubit0=q0,
                qubit1=q1,
            )

    def to_dict(self) -> dict:
        return {
            "op": "Gate",
            "gate": self.gate_name(),
            "qubits": self.qubits(),
            "params": self.params(),
        }

    def to_trace_event(self) -> GateEvent:
        return GateEvent(
            gate_name=self.gate_name(),
            qubits=self.qubits(),
            params=self.params(),
        )

    @staticmethod
    def from_iterator(it: Iterator):
        return GateInstruction(Gate.deserialize(bytes(next(it))))

    def gate_name(self) -> str:
        if self.gate.semantic_id == RZ.semantic_id:
            return "RZ"
        if self.gate.semantic_id == PhasedX.semantic_id:
            return "PhasedX"
        if self.gate.semantic_id == ZZPhase.semantic_id:
            return "ZZPhase"
        if self.gate.semantic_id == PhasedXX.semantic_id:
            return "PhasedXX"
        return self.gate.semantic_id.hex()

    def _values(self) -> list[int | float | bool]:
        return [operand.value for operand in self.gate.operands]

    def qubits(self) -> list[int]:
        if self.gate.semantic_id in {RZ.semantic_id, PhasedX.semantic_id}:
            return [int(self.gate.operands[0].value)]
        if self.gate.semantic_id in {ZZPhase.semantic_id, PhasedXX.semantic_id}:
            return [int(self.gate.operands[0].value), int(self.gate.operands[1].value)]
        return [
            int(operand.value)
            for operand in self.gate.operands
            if operand.kind.name == "QUBIT"
        ]

    def params(self) -> list[int | float | bool]:
        if self.gate.semantic_id in {RZ.semantic_id, PhasedX.semantic_id}:
            return [operand.value for operand in self.gate.operands[1:]]
        if self.gate.semantic_id in {ZZPhase.semantic_id, PhasedXX.semantic_id}:
            return [operand.value for operand in self.gate.operands[2:]]
        return [
            operand.value
            for operand in self.gate.operands
            if operand.kind.name != "QUBIT"
        ]


@dataclass
class Reset(Operation):
    qubit: int

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        assert PYTKET_AVAILABLE, "pytket is not available"
        circuit.Reset(qubit=self.qubit)

    def to_dict(self) -> dict:
        return {"op": "Reset", "qubit": self.qubit}

    @staticmethod
    def from_iterator(it: Iterator):
        return Reset(qubit=next(it))


@dataclass
class MeasureRequest(Operation):
    qubit: int

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        assert PYTKET_AVAILABLE, "pytket is not available"
        for i in range(circuit.n_bits, self.qubit + 1):
            circuit.add_bit(pytket.Bit(i))
        circuit.Measure(qubit=self.qubit, bit=self.qubit)

    def to_dict(self) -> dict:
        return {"op": "MeasureRequest", "qubit": self.qubit}

    @staticmethod
    def from_iterator(it: Iterator):
        return MeasureRequest(qubit=next(it))


@dataclass
class MeasureLeakedRequest(Operation):
    qubit: int

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        assert PYTKET_AVAILABLE, "pytket is not available"
        for i in range(circuit.n_bits, self.qubit + 1):
            circuit.add_bit(pytket.Bit(i))
        circuit.Measure(qubit=self.qubit, bit=self.qubit)

    def to_dict(self) -> dict:
        return {"op": "MeasureLeakedRequest", "qubit": self.qubit}

    @staticmethod
    def from_iterator(it: Iterator):
        return MeasureLeakedRequest(qubit=next(it))


@dataclass
class FutureRead(Operation):
    qubit: int

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        # only use on the request to prevent duplicate reads
        # becoming duplicate operations
        pass

    def to_dict(self) -> dict:
        return {"op": "FutureRead", "qubit": self.qubit}

    @staticmethod
    def from_iterator(it: Iterator):
        return FutureRead(qubit=next(it))


@dataclass
class ClassicalDelay(Operation):
    duration_ns: int

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        pass

    def to_dict(self) -> dict:
        return {"op": "ClassicalDelay", "duration_ns": self.duration_ns}

    @staticmethod
    def from_iterator(it: Iterator):
        duration_ns = next(it)
        return ClassicalDelay(duration_ns=duration_ns)


@dataclass
class Postselect(Operation):
    qubit: int
    target: bool

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        pass

    def to_dict(self) -> dict:
        return {"op": "Postselect", "qubit": self.qubit, "target": self.target}

    @staticmethod
    def from_iterator(it: Iterator):
        qubit = next(it)
        target = next(it)
        return Postselect(qubit=qubit, target=target)


class Source(Enum):
    """
    Selene provides the source of each instruction as an
    integer index. This enum maps those indices to a more
    human-readable form.
    """

    USER = 0
    OPTIMISER = 1
    ERROR_MODEL = 2
    SIMULATOR = 3


@dataclass
class Instruction:
    source: Source
    operation: Operation
    duration_ns: int | None = None

    def to_dict(self) -> dict[str, Any]:
        result: dict[str, Any] = {
            "source": str(self.source),
            "operation": self.operation.to_dict(),
        }
        if self.duration_ns is not None:
            result["duration_ns"] = self.duration_ns
        return result

    @staticmethod
    def from_iterator(it: Iterator):
        """
        Extract a single instruction from an iterator of the
        data array provided by Selene, and advance the iterator.

        An instruction is of the form:

        ( source: u64 | operation: u64 | data: ... )

        where the length of the data depends on the operation.

        For example:
        - a QAlloc operation would have a data array of length 1,
          containing the qubit index to allocate.
        - a Gate operation would have a single serialized gatewire
          payload containing the gate semantic ID and operands.

        The parsing of the data array is delegated to the operation
        class itself, and it is responsible for advancing the iterator
        as it consumes the data.
        """
        source_idx: int = next(it)
        source = Source(source_idx)
        duration_ns = next(it) if source == Source.SIMULATOR else None
        operation_idx: int = next(it)
        operation: Operation | None = None
        match operation_idx:
            case 0:
                operation = BatchStart.from_iterator(it)
            case 1:
                operation = QAlloc.from_iterator(it)
            case 2:
                operation = QFree.from_iterator(it)
            case 3:
                operation = Reset.from_iterator(it)
            case 4:
                operation = MeasureRequest.from_iterator(it)
            case 5:
                operation = FutureRead.from_iterator(it)
            case 9:
                operation = CustomOperation.from_iterator(it)
            case 10:
                operation = LocalBarrier.from_iterator(it)
            case 11:
                operation = GlobalBarrier.from_iterator(it)
            case 12:
                operation = MeasureLeakedRequest.from_iterator(it)
            case 13:
                operation = ClassicalDelay.from_iterator(it)
            case 15:
                operation = GateInstruction.from_iterator(it)
            case 16:
                operation = Postselect.from_iterator(it)
        if operation is None:
            raise ValueError(f"Unknown instruction operation index {operation_idx}")
        return Instruction(source=source, operation=operation, duration_ns=duration_ns)


class ShotInstructions:
    instructions: list

    def __init__(self):
        self.instructions = []

    def extend(self, instructions: list):
        self.instructions.extend(instructions)

    def __iter__(self):
        """
        Parses the data provided by Selene.

        The data is in the form of instructions of arbitrary
        length. Instruction.from_iterator is used to parse a
        single record, advancing the iterator as it goes.
        """
        it = iter(self.instructions)
        while True:
            try:
                yield Instruction.from_iterator(it)
            except StopIteration:
                break

    def _get_circuit(
        self, source: Source, init_qubits: int | None = None
    ) -> "pytket.Circuit":
        assert PYTKET_AVAILABLE, "pytket is not available"
        circuit = pytket.Circuit()
        for instruction in self:
            if instruction.source == source:
                instruction.operation.append_to_circuit(circuit)
        return circuit

    def _get_list_of_dicts(self, source: Source) -> list[dict]:
        result = []
        for instruction in self:
            if instruction.source == source:
                operation = instruction.operation.to_dict()
                if instruction.duration_ns is not None:
                    operation["duration_ns"] = instruction.duration_ns
                result.append(operation)
        return result

    def get_user_circuit(self) -> "pytket.Circuit":
        return self._get_circuit(Source.USER)

    def get_optimiser_output(self) -> list[dict[Any, Any]]:
        return self._get_list_of_dicts(Source.OPTIMISER)

    def get_error_model_input(self) -> list[dict[Any, Any]]:
        return self.get_optimiser_output()

    def get_error_model_output(self) -> list[dict[Any, Any]]:
        return self._get_list_of_dicts(Source.ERROR_MODEL)

    def get_simulator_output(self) -> list[dict[Any, Any]]:
        return self._get_list_of_dicts(Source.SIMULATOR)

    def dump(self) -> None:
        for instruction in self:
            print(f"{instruction.source}: {instruction.operation}")

    def get_trace(self) -> Trace:
        """
        Obtain a selene_core.Trace from the instruction log, providing a
        structured representation of the operations performed by the runtime.
        This trace may be consumed, analysed, and communicated easily, allowing
        decoupling of simulation itself from analysis and visualization.
        """
        trace = Trace()
        user_program_event_index = 0
        error_model_event_index = 0
        simulator_event_index = 0
        start_time_ns = 0
        end_time_ns = 0
        for instruction in self:
            if instruction.source == Source.USER:
                match instruction.operation:
                    case CustomOperation(tag=tag, data=data):
                        trace.add_user_program_event(
                            CustomEvent(payload=OpaquePayload(tag=tag, data=data)),
                            index=user_program_event_index,
                        )
                        user_program_event_index += 1
                    case LocalBarrier(qubits=qubits, sleep_time=sleep_time):
                        trace.add_user_program_event(
                            GateEvent(
                                gate_name="LocalBarrier",
                                qubits=qubits,
                                params=[sleep_time],
                            ),
                            index=user_program_event_index,
                        )
                        user_program_event_index += 1
                    case GlobalBarrier(sleep_time=sleep_time):
                        trace.add_user_program_event(
                            GateEvent(
                                gate_name="GlobalBarrier",
                                qubits=[],
                                params=[sleep_time],
                            ),
                            index=user_program_event_index,
                        )
                        user_program_event_index += 1
                    case QAlloc(qubit=qubit):
                        trace.add_user_program_event(
                            GateEvent(
                                gate_name="QAlloc",
                                qubits=[qubit],
                                params=[],
                            ),
                            index=user_program_event_index,
                        )
                        user_program_event_index += 1
                    case QFree(qubit=qubit):
                        trace.add_user_program_event(
                            GateEvent(
                                gate_name="QFree",
                                qubits=[qubit],
                                params=[],
                            ),
                            index=user_program_event_index,
                        )
                        user_program_event_index += 1
                    case GateInstruction() as gate:
                        trace.add_user_program_event(
                            gate.to_trace_event(),
                            index=user_program_event_index,
                        )
                        user_program_event_index += 1
                    case Reset(qubit=qubit):
                        trace.add_user_program_event(
                            ResetEvent(qubit=qubit), index=user_program_event_index
                        )
                        user_program_event_index += 1
                    case MeasureRequest(qubit=qubit):
                        trace.add_user_program_event(
                            MeasurementEvent(qubit=qubit),
                            index=user_program_event_index,
                        )
                        user_program_event_index += 1
                    case MeasureLeakedRequest(qubit=qubit):
                        trace.add_user_program_event(
                            MeasurementEvent(qubit=qubit),
                            index=user_program_event_index,
                        )
                        user_program_event_index += 1
                    case FutureRead(qubit=qubit):
                        trace.add_user_program_event(
                            MeasurementEvent(qubit=qubit),
                            index=user_program_event_index,
                        )
                        user_program_event_index += 1
                    case ClassicalDelay(duration_ns=duration_ns):
                        trace.add_user_program_event(
                            event=GateEvent(
                                gate_name="ClassicalDelay",
                                qubits=[],
                                params=[duration_ns],
                            ),
                            index=user_program_event_index,
                        )
                        user_program_event_index += 1
            if instruction.source == Source.OPTIMISER:
                match instruction.operation:
                    case BatchStart(start_time_ns=start, duration_ns=duration):
                        start_time_ns = start
                        end_time_ns = start + duration
                    case Reset(qubit=qubit):
                        trace.add_runtime_event(
                            ResetEvent(qubit=qubit), start_time_ns, end_time_ns
                        )
                    case FutureRead(qubit=qubit):
                        trace.add_runtime_event(
                            MeasurementEvent(qubit=qubit), start_time_ns, end_time_ns
                        )
                    case GateInstruction() as gate:
                        trace.add_runtime_event(
                            gate.to_trace_event(),
                            start_time_ns,
                            end_time_ns,
                        )
                    case CustomOperation(tag=tag, data=data):
                        trace.add_runtime_event(
                            CustomEvent(payload=OpaquePayload(tag=tag, data=data)),
                            start_time_ns,
                            end_time_ns,
                        )
                    case _:
                        pass
            if instruction.source == Source.ERROR_MODEL:
                match instruction.operation:
                    case Reset(qubit=qubit):
                        trace.add_error_model_event(
                            ResetEvent(qubit=qubit), index=error_model_event_index
                        )
                        error_model_event_index += 1
                    case MeasureRequest(qubit=qubit):
                        trace.add_error_model_event(
                            MeasurementEvent(qubit=qubit),
                            index=error_model_event_index,
                        )
                        error_model_event_index += 1
                    case MeasureLeakedRequest(qubit=qubit):
                        trace.add_error_model_event(
                            MeasurementEvent(qubit=qubit),
                            index=error_model_event_index,
                        )
                        error_model_event_index += 1
                    case FutureRead(qubit=qubit):
                        trace.add_error_model_event(
                            MeasurementEvent(qubit=qubit),
                            index=error_model_event_index,
                        )
                        error_model_event_index += 1
                    case GateInstruction() as gate:
                        trace.add_error_model_event(
                            gate.to_trace_event(),
                            index=error_model_event_index,
                        )
                        error_model_event_index += 1
                    case Postselect(qubit=qubit, target=target):
                        trace.add_error_model_event(
                            GateEvent(
                                gate_name="Postselect",
                                qubits=[qubit],
                                params=[target],
                            ),
                            index=error_model_event_index,
                        )
                        error_model_event_index += 1
                    case CustomOperation(tag=tag, data=data):
                        trace.add_error_model_event(
                            CustomEvent(payload=OpaquePayload(tag=tag, data=data)),
                            index=error_model_event_index,
                        )
                        error_model_event_index += 1
                    case _:
                        pass
            if instruction.source == Source.SIMULATOR:
                duration_ns = instruction.duration_ns if instruction.duration_ns else 0
                match instruction.operation:
                    case Reset(qubit=qubit):
                        trace.add_simulator_event(
                            ResetEvent(qubit=qubit),
                            index=simulator_event_index,
                            duration_ns=duration_ns,
                        )
                        simulator_event_index += 1
                    case MeasureRequest(qubit=qubit):
                        trace.add_simulator_event(
                            MeasurementEvent(qubit=qubit),
                            index=simulator_event_index,
                            duration_ns=duration_ns,
                        )
                        simulator_event_index += 1
                    case MeasureLeakedRequest(qubit=qubit):
                        trace.add_simulator_event(
                            MeasurementEvent(qubit=qubit),
                            index=simulator_event_index,
                            duration_ns=duration_ns,
                        )
                        simulator_event_index += 1
                    case FutureRead(qubit=qubit):
                        trace.add_simulator_event(
                            MeasurementEvent(qubit=qubit),
                            index=simulator_event_index,
                            duration_ns=duration_ns,
                        )
                        simulator_event_index += 1
                    case GateInstruction() as gate:
                        trace.add_simulator_event(
                            gate.to_trace_event(),
                            index=simulator_event_index,
                            duration_ns=duration_ns,
                        )
                        simulator_event_index += 1
                    case Postselect(qubit=qubit, target=target):
                        trace.add_simulator_event(
                            GateEvent(
                                gate_name="Postselect",
                                qubits=[qubit],
                                params=[target],
                            ),
                            index=simulator_event_index,
                            duration_ns=duration_ns,
                        )
                        simulator_event_index += 1
                    case CustomOperation(tag=tag, data=data):
                        trace.add_simulator_event(
                            CustomEvent(payload=OpaquePayload(tag=tag, data=data)),
                            index=simulator_event_index,
                            duration_ns=duration_ns,
                        )
                        simulator_event_index += 1
                    case _:
                        pass
        return trace


class CircuitExtractor(EventHook):
    shots: list[ShotInstructions]

    def get_selene_flags(self) -> list[str]:
        """
        When given --provide-instruction-log, Selene will emit
        an INSTRUCTIONLOG tag to the results stream, followed
        by a dump of all instructions that were logged from
        e.g. the user program, runtime, error model, or simulator.
        """
        return ["provide_instruction_log"]

    def __init__(self):
        self.shots = []

    def try_invoke(self, tag: str, data: list) -> bool:
        if tag != "INSTRUCTIONLOG":
            return False
        self.shots[-1].extend(data)
        return True

    def on_new_shot(self):
        self.shots.append(ShotInstructions())
