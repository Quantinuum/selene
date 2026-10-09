"""
Provides CircuitExtractor, a class that can be used to extract
circuits and instruction views from backend trace streams.

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
from typing import Any, Callable
import math

from selene_api_models.trace import (
    Trace,
    GateEvent,
    MeasurementEvent,
    ResetEvent,
    OpaquePayload,
    CustomEvent,
)

from .event_hook import EventHook
from .trace_store import ShotTrace, TraceStore
from selene_api_models.trace_stream import BatchStartRecord, UIntInstructionRecord

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
        data_or_flag = next(it)
        if isinstance(data_or_flag, bytes):
            data = data_or_flag
        else:
            data = bytes(next(it)) if data_or_flag else b""
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
class Rxy(Operation):
    qubit: int
    theta: float
    phi: float

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        assert PYTKET_AVAILABLE, "pytket is not available"
        circuit.PhasedX(
            angle0=self.theta / math.pi, angle1=self.phi / math.pi, qubit=self.qubit
        )

    def to_dict(self) -> dict:
        return {"op": "Rxy", "qubit": self.qubit, "theta": self.theta, "phi": self.phi}

    @staticmethod
    def from_iterator(it: Iterator):
        qubit = next(it)
        theta = next(it)
        phi = next(it)
        assert isinstance(qubit, int), (
            f"qubit must be an integer, got {qubit} of type {type(qubit)}"
        )
        assert isinstance(theta, float), (
            f"theta must be a float, got {theta} of type {type(theta)}"
        )
        assert isinstance(phi, float), (
            f"phi must be a float, got {phi} of type {type(phi)}"
        )
        return Rxy(qubit=qubit, theta=theta, phi=phi)


@dataclass
class Rzz(Operation):
    qubit0: int
    qubit1: int
    theta: float

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        assert PYTKET_AVAILABLE, "pytket is not available"
        circuit.ZZPhase(
            angle=self.theta / math.pi, qubit0=self.qubit0, qubit1=self.qubit1
        )

    def to_dict(self) -> dict:
        return {
            "op": "Rzz",
            "qubit0": self.qubit0,
            "qubit1": self.qubit1,
            "theta": self.theta,
        }

    @staticmethod
    def from_iterator(it: Iterator):
        qubit0 = next(it)
        qubit1 = next(it)
        theta = next(it)
        return Rzz(qubit0=qubit0, qubit1=qubit1, theta=theta)


@dataclass
class Rz(Operation):
    qubit: int
    theta: float

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        assert PYTKET_AVAILABLE, "pytket is not available"
        circuit.Rz(angle=self.theta / math.pi, qubit=self.qubit)

    def to_dict(self) -> dict:
        return {"op": "Rz", "qubit": self.qubit, "theta": self.theta}

    @staticmethod
    def from_iterator(it: Iterator):
        return Rz(qubit=next(it), theta=next(it))


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
class Rpp(Operation):
    qubit0: int
    qubit1: int
    theta: float
    phi: float

    def append_to_circuit(self, circuit: "pytket.Circuit"):
        assert PYTKET_AVAILABLE, "pytket is not available"
        circuit.PhasedXX(
            angle0=self.theta / math.pi,
            angle1=self.phi / math.pi,
            qubit0=self.qubit0,
            qubit1=self.qubit1,
        )

    def to_dict(self) -> dict:
        return {
            "op": "Rpp",
            "qubit0": self.qubit0,
            "qubit1": self.qubit1,
            "theta": self.theta,
            "phi": self.phi,
        }

    @staticmethod
    def from_iterator(it: Iterator):
        qubit0 = next(it)
        qubit1 = next(it)
        theta = next(it)
        phi = next(it)
        return Rpp(qubit0=qubit0, qubit1=qubit1, theta=theta, phi=phi)


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
        - An Rzz would have a data array of length 3, containing
          the two qubit indices and the rotation angle.

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
            case 6:
                operation = Rxy.from_iterator(it)
            case 7:
                operation = Rz.from_iterator(it)
            case 8:
                operation = Rzz.from_iterator(it)
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
            case 14:
                operation = Rpp.from_iterator(it)
            case 15:
                operation = Postselect.from_iterator(it)
        if operation is None:
            raise ValueError(f"Unknown instruction operation index {operation_idx}")
        return Instruction(source=source, operation=operation, duration_ns=duration_ns)


class ShotInstructions:
    def __init__(self, trace: ShotTrace) -> None:
        self.trace = trace

    def __iter__(self) -> Iterator[Instruction]:
        """Provide the existing instruction view from the stored trace events."""
        sources = {
            "UserProgram": Source.USER,
            "Runtime": Source.OPTIMISER,
            "ErrorModel": Source.ERROR_MODEL,
            "Simulator": Source.SIMULATOR,
        }
        gates: dict[str, Callable[..., Operation]] = {
            "QAlloc": QAlloc,
            "QFree": QFree,
            "Rxy": Rxy,
            "Rz": Rz,
            "Rzz": Rzz,
            "Rpp": Rpp,
            "Postselect": Postselect,
            "GlobalBarrier": GlobalBarrier,
            "ClassicalDelay": ClassicalDelay,
        }
        for record in self.trace.iter_records():
            if isinstance(record, BatchStartRecord):
                timing = record.batch_start
                yield Instruction(
                    Source.OPTIMISER,
                    BatchStart(timing.start_time, timing.end_time - timing.start_time),
                )
                continue
            source = sources[record.source.kind]
            duration = (
                record.source.duration_ns if record.source.kind == "Simulator" else None
            )
            operation: Operation
            if isinstance(record, UIntInstructionRecord):
                if record.uint_instruction == "LocalBarrier":
                    operation = LocalBarrier(record.qubits, record.value)
                elif record.uint_instruction == "GlobalBarrier":
                    operation = GlobalBarrier(record.value)
                else:
                    operation = ClassicalDelay(record.value)
                yield Instruction(source, operation, duration)
                continue
            event = record.event
            match event:
                case GateEvent(gate_name="LocalBarrier", qubits=qubits, params=params):
                    operation = LocalBarrier(qubits, int(params[0]))
                case GateEvent(gate_name=name, qubits=qubits, params=params):
                    if name not in gates:
                        raise ValueError(
                            f"No circuit instruction mapping for trace gate {name!r}"
                        )
                    operation = gates[name](*qubits, *params)
                case MeasurementEvent(qubit=qubit):
                    if record.instruction == "FutureRead":
                        operation = FutureRead(qubit)
                    elif record.instruction == "MeasureLeakedRequest":
                        operation = MeasureLeakedRequest(qubit)
                    elif source == Source.OPTIMISER:
                        operation = FutureRead(qubit)
                    else:
                        operation = MeasureRequest(qubit)
                case ResetEvent(qubit=qubit):
                    operation = Reset(qubit)
                case CustomEvent(payload=OpaquePayload(tag=tag, data=data)):
                    operation = CustomOperation(tag, data)
                case _:
                    raise ValueError(
                        f"No circuit instruction mapping for trace event {event!r}"
                    )
            yield Instruction(source, operation, duration)

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
        return self.trace.get_trace()


class CircuitExtractor(EventHook):
    """Circuit and instruction views over traces loaded by a TraceStore."""

    @property
    def shots(self) -> list[ShotInstructions]:
        return [ShotInstructions(trace) for trace in self.trace_store.shots]

    def get_selene_flags(self) -> list[str]:
        return self.trace_store.get_selene_flags()

    def __init__(self, trace_store: TraceStore | None = None) -> None:
        self.trace_store = trace_store if trace_store is not None else TraceStore()

    def try_invoke(self, tag: str, data: list) -> bool:
        return self.trace_store.try_invoke(tag, data)

    def on_new_shot(self) -> None:
        self.trace_store.on_new_shot()
