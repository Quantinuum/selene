from __future__ import annotations

from dataclasses import dataclass
from enum import IntEnum
import struct
from typing import Iterable, Mapping

import blake3


class OperandKind(IntEnum):
    QUBIT = 1
    F64 = 2
    U64 = 3
    I64 = 4
    U8 = 5
    BOOL = 6


class MetadataValueKind(IntEnum):
    BOOL = 1
    I64 = 2
    U64 = 3
    F64 = 4
    STRING = 5
    BYTES = 6


@dataclass(frozen=True)
class OperandDefinition:
    name: str
    kind: OperandKind


@dataclass(frozen=True)
class GateDefinition:
    semantic_id: bytes
    name: str
    operands: tuple[OperandDefinition, ...]
    version: int = 1

    def __init__(
        self,
        semantic_id: str | bytes,
        name: str,
        operands: Iterable[OperandDefinition],
        version: int = 1,
    ):
        object.__setattr__(
            self,
            "semantic_id",
            semantic_id_from_text(semantic_id)
            if isinstance(semantic_id, str)
            else bytes(semantic_id),
        )
        if len(self.semantic_id) != 16:
            raise ValueError("semantic_id must be 16 bytes")
        object.__setattr__(self, "name", name)
        object.__setattr__(self, "operands", tuple(operands))
        object.__setattr__(self, "version", int(version))


@dataclass(frozen=True)
class GateValue:
    kind: OperandKind
    value: int | float | bool

    @staticmethod
    def qubit(value: int) -> GateValue:
        return GateValue(OperandKind.QUBIT, int(value))

    @staticmethod
    def f64(value: float) -> GateValue:
        return GateValue(OperandKind.F64, float(value))

    @staticmethod
    def u64(value: int) -> GateValue:
        return GateValue(OperandKind.U64, int(value))

    @staticmethod
    def i64(value: int) -> GateValue:
        return GateValue(OperandKind.I64, int(value))

    @staticmethod
    def u8(value: int) -> GateValue:
        return GateValue(OperandKind.U8, int(value))

    @staticmethod
    def bool(value: bool) -> GateValue:
        return GateValue(OperandKind.BOOL, bool(value))


@dataclass(frozen=True)
class MetadataValue:
    kind: MetadataValueKind
    value: bool | int | float | str | bytes

    @staticmethod
    def bool(value: bool) -> MetadataValue:
        return MetadataValue(MetadataValueKind.BOOL, bool(value))

    @staticmethod
    def i64(value: int) -> MetadataValue:
        return MetadataValue(MetadataValueKind.I64, int(value))

    @staticmethod
    def u64(value: int) -> MetadataValue:
        return MetadataValue(MetadataValueKind.U64, int(value))

    @staticmethod
    def f64(value: float) -> MetadataValue:
        return MetadataValue(MetadataValueKind.F64, float(value))

    @staticmethod
    def string(value: str) -> MetadataValue:
        return MetadataValue(MetadataValueKind.STRING, str(value))

    @staticmethod
    def bytes(value: bytes | bytearray | memoryview) -> MetadataValue:
        return MetadataValue(MetadataValueKind.BYTES, bytes(value))


@dataclass(frozen=True)
class GateMetadata:
    key: str
    value: MetadataValue


@dataclass(frozen=True)
class Gate:
    semantic_id: bytes
    operands: tuple[GateValue, ...]
    metadata: tuple[GateMetadata, ...]

    def __init__(
        self,
        semantic_id: str | bytes,
        operands: Iterable[GateValue],
        metadata: (
            Mapping[str, MetadataValue | bool | int | float | str | bytes]
            | Iterable[
                GateMetadata
                | tuple[str, MetadataValue | bool | int | float | str | bytes]
            ]
            | None
        ) = None,
    ):
        object.__setattr__(
            self,
            "semantic_id",
            semantic_id_from_text(semantic_id)
            if isinstance(semantic_id, str)
            else bytes(semantic_id),
        )
        if len(self.semantic_id) != 16:
            raise ValueError("semantic_id must be 16 bytes")
        object.__setattr__(self, "operands", tuple(operands))
        object.__setattr__(self, "metadata", _coerce_metadata(metadata))

    def with_metadata(
        self, key: str, value: MetadataValue | bool | int | float | str | bytes
    ) -> Gate:
        metadata = {entry.key: entry.value for entry in self.metadata}
        metadata[str(key)] = _coerce_metadata_value(value)
        return Gate(self.semantic_id, self.operands, metadata)

    def metadata_value(self, key: str) -> MetadataValue | None:
        for entry in self.metadata:
            if entry.key == key:
                return entry.value
        return None

    def serialize(self) -> bytes:
        out = bytearray()
        out.extend(b"GWG1")
        wire_version = 2 if self.metadata else 1
        out.extend(struct.pack("<HH", wire_version, 0))
        out.extend(self.semantic_id)
        out.extend(struct.pack("<I", len(self.operands)))
        for operand in self.operands:
            out.extend(struct.pack("<I", int(operand.kind)))
            match operand.kind:
                case OperandKind.QUBIT:
                    out.extend(struct.pack("<I", int(operand.value)))
                case OperandKind.F64:
                    out.extend(struct.pack("<d", float(operand.value)))
                case OperandKind.U64:
                    out.extend(struct.pack("<Q", int(operand.value)))
                case OperandKind.I64:
                    out.extend(struct.pack("<q", int(operand.value)))
                case OperandKind.U8:
                    out.extend(struct.pack("<B", int(operand.value)))
                case OperandKind.BOOL:
                    out.extend(struct.pack("<B", 1 if operand.value else 0))
        if self.metadata:
            out.extend(struct.pack("<I", len(self.metadata)))
            for entry in self.metadata:
                _write_string(out, entry.key)
                out.extend(struct.pack("<I", int(entry.value.kind)))
                match entry.value.kind:
                    case MetadataValueKind.BOOL:
                        out.extend(struct.pack("<B", 1 if entry.value.value else 0))
                    case MetadataValueKind.I64:
                        out.extend(struct.pack("<q", int(entry.value.value)))
                    case MetadataValueKind.U64:
                        out.extend(struct.pack("<Q", int(entry.value.value)))
                    case MetadataValueKind.F64:
                        out.extend(struct.pack("<d", float(entry.value.value)))
                    case MetadataValueKind.STRING:
                        _write_string(out, str(entry.value.value))
                    case MetadataValueKind.BYTES:
                        value = entry.value.value
                        if not isinstance(value, bytes):
                            raise TypeError("bytes metadata must contain bytes")
                        _write_bytes(out, value)
        return bytes(out)

    @staticmethod
    def deserialize(data: bytes | bytearray | memoryview) -> Gate:
        cursor = _Cursor(bytes(data))
        if cursor.read(4) != b"GWG1":
            raise ValueError("bad gate magic")
        version, _reserved = struct.unpack("<HH", cursor.read(4))
        if version not in (1, 2):
            raise ValueError("unsupported gate wire version")
        semantic_id = cursor.read(16)
        (operand_count,) = struct.unpack("<I", cursor.read(4))
        operands = []
        for _ in range(operand_count):
            (kind,) = struct.unpack("<I", cursor.read(4))
            operand_kind = OperandKind(kind)
            match operand_kind:
                case OperandKind.QUBIT:
                    (value,) = struct.unpack("<I", cursor.read(4))
                case OperandKind.F64:
                    (value,) = struct.unpack("<d", cursor.read(8))
                case OperandKind.U64:
                    (value,) = struct.unpack("<Q", cursor.read(8))
                case OperandKind.I64:
                    (value,) = struct.unpack("<q", cursor.read(8))
                case OperandKind.U8:
                    (value,) = struct.unpack("<B", cursor.read(1))
                case OperandKind.BOOL:
                    (raw,) = struct.unpack("<B", cursor.read(1))
                    value = bool(raw)
            operands.append(GateValue(operand_kind, value))
        metadata = []
        if version >= 2:
            (metadata_count,) = struct.unpack("<I", cursor.read(4))
            for _ in range(metadata_count):
                key = cursor.read_string()
                (kind,) = struct.unpack("<I", cursor.read(4))
                metadata_kind = MetadataValueKind(kind)
                match metadata_kind:
                    case MetadataValueKind.BOOL:
                        (raw,) = struct.unpack("<B", cursor.read(1))
                        value = bool(raw)
                    case MetadataValueKind.I64:
                        (value,) = struct.unpack("<q", cursor.read(8))
                    case MetadataValueKind.U64:
                        (value,) = struct.unpack("<Q", cursor.read(8))
                    case MetadataValueKind.F64:
                        (value,) = struct.unpack("<d", cursor.read(8))
                    case MetadataValueKind.STRING:
                        value = cursor.read_string()
                    case MetadataValueKind.BYTES:
                        value = cursor.read_bytes()
                metadata.append(GateMetadata(key, MetadataValue(metadata_kind, value)))
        cursor.finish()
        return Gate(semantic_id, operands, metadata)


class Gateset:
    def __init__(self, *definitions: GateDefinition | Iterable[GateDefinition]):
        if len(definitions) == 1 and not isinstance(definitions[0], GateDefinition):
            definitions = tuple(definitions[0])  # type: ignore[assignment]
        self._definitions: tuple[GateDefinition, ...] = tuple(definitions)  # type: ignore[arg-type]
        seen: set[bytes] = set()
        for definition in self._definitions:
            if definition.semantic_id in seen:
                raise ValueError(f"duplicate gate definition {definition.name}")
            seen.add(definition.semantic_id)

    @property
    def definitions(self) -> tuple[GateDefinition, ...]:
        return self._definitions

    def union(self, *others: Gateset) -> Gateset:
        definitions = list(self._definitions)
        seen = {definition.semantic_id: definition for definition in definitions}
        for other in others:
            for definition in other:
                existing = seen.get(definition.semantic_id)
                if existing is not None:
                    if existing != definition:
                        raise ValueError(
                            f"duplicate gate semantic_id for {definition.name}"
                        )
                    continue
                definitions.append(definition)
                seen[definition.semantic_id] = definition
        return Gateset(definitions)

    def bind(self, gate: bytes | bytearray | memoryview | GateDefinition) -> BoundGate:
        return BoundGate(self.definition(gate))

    def __getattr__(self, name: str) -> BoundGate:
        for definition in self._definitions:
            if definition.name == name:
                return BoundGate(definition)
        raise AttributeError(f"{type(self).__name__!s} has no gate {name!r}")

    def serialize(self) -> bytes:
        out = bytearray()
        out.extend(b"GWS1")
        out.extend(struct.pack("<HHI", 1, 0, len(self._definitions)))
        for definition in self._definitions:
            out.extend(definition.semantic_id)
            _write_string(out, definition.name)
            out.extend(struct.pack("<II", definition.version, len(definition.operands)))
            for operand in definition.operands:
                out.extend(struct.pack("<I", int(operand.kind)))
                _write_string(out, operand.name)
        return bytes(out)

    @staticmethod
    def deserialize(data: bytes | bytearray | memoryview) -> Gateset:
        cursor = _Cursor(bytes(data))
        if cursor.read(4) != b"GWS1":
            raise ValueError("bad gateset magic")
        version, _reserved, count = struct.unpack("<HHI", cursor.read(8))
        if version != 1:
            raise ValueError("unsupported gateset wire version")
        definitions = []
        for _ in range(count):
            semantic_id = cursor.read(16)
            name = cursor.read_string()
            gate_version, operand_count = struct.unpack("<II", cursor.read(8))
            operands = []
            for _ in range(operand_count):
                (kind,) = struct.unpack("<I", cursor.read(4))
                operands.append(
                    OperandDefinition(cursor.read_string(), OperandKind(kind))
                )
            definitions.append(
                GateDefinition(semantic_id, name, operands, gate_version)
            )
        cursor.finish()
        return Gateset(definitions)

    def definition(
        self, gate: bytes | bytearray | memoryview | GateDefinition
    ) -> GateDefinition:
        if isinstance(gate, GateDefinition):
            semantic_id = gate.semantic_id
        else:
            semantic_id = bytes(gate)

        for definition in self._definitions:
            if definition.semantic_id == semantic_id:
                return definition
        raise KeyError("unknown gate semantic_id")

    def gate(
        self,
        gate: bytes | bytearray | memoryview | GateDefinition,
        *values: int | float | bool | GateValue,
        **named_values: int | float | bool | GateValue,
    ) -> Gate:
        definition = self.definition(gate)
        if values and named_values:
            raise TypeError(
                "provide either positional or named gate operands, not both"
            )
        if named_values:
            missing = [
                operand.name
                for operand in definition.operands
                if operand.name not in named_values
            ]
            if missing:
                raise TypeError(f"missing gate operands: {', '.join(missing)}")
            extra = [
                operand_name
                for operand_name in named_values
                if operand_name not in {operand.name for operand in definition.operands}
            ]
            if extra:
                raise TypeError(f"unknown gate operands: {', '.join(extra)}")
            values = tuple(
                named_values[operand.name] for operand in definition.operands
            )
        if len(values) != len(definition.operands):
            raise TypeError(
                f"{definition.name} expects {len(definition.operands)} operands, "
                f"got {len(values)}"
            )
        return _instantiate_gate(definition, values)

    def __iter__(self):
        return iter(self._definitions)

    def __len__(self) -> int:
        return len(self._definitions)


@dataclass(frozen=True)
class BoundGate:
    definition: GateDefinition

    def __call__(
        self,
        *values: int | float | bool | GateValue,
        **named_values: int | float | bool | GateValue,
    ) -> Gate:
        if values and named_values:
            raise TypeError(
                "provide either positional or named gate operands, not both"
            )
        if named_values:
            missing = [
                operand.name
                for operand in self.definition.operands
                if operand.name not in named_values
            ]
            if missing:
                raise TypeError(f"missing gate operands: {', '.join(missing)}")
            expected_names = {operand.name for operand in self.definition.operands}
            extra = [
                operand_name
                for operand_name in named_values
                if operand_name not in expected_names
            ]
            if extra:
                raise TypeError(f"unknown gate operands: {', '.join(extra)}")
            values = tuple(
                named_values[operand.name] for operand in self.definition.operands
            )
        if len(values) != len(self.definition.operands):
            raise TypeError(
                f"{self.definition.name} expects {len(self.definition.operands)} "
                f"operands, got {len(values)}"
            )
        return _instantiate_gate(self.definition, values)


def semantic_id_from_text(text: str | bytes) -> bytes:
    if isinstance(text, str):
        text = text.encode("utf-8")
    return blake3.blake3(text).digest(length=16)


def _write_string(out: bytearray, value: str) -> None:
    data = value.encode("utf-8")
    out.extend(struct.pack("<I", len(data)))
    out.extend(data)


def _write_bytes(out: bytearray, value: bytes) -> None:
    out.extend(struct.pack("<I", len(value)))
    out.extend(value)


def _coerce_gate_value(kind: OperandKind, value: int | float | bool | GateValue):
    if isinstance(value, GateValue):
        if value.kind != kind:
            raise TypeError(f"expected operand kind {kind.name}, got {value.kind.name}")
        return value
    match kind:
        case OperandKind.QUBIT:
            return GateValue.qubit(int(value))
        case OperandKind.F64:
            return GateValue.f64(float(value))
        case OperandKind.U64:
            return GateValue.u64(int(value))
        case OperandKind.I64:
            return GateValue.i64(int(value))
        case OperandKind.U8:
            return GateValue.u8(int(value))
        case OperandKind.BOOL:
            return GateValue.bool(bool(value))


def _coerce_metadata_value(value: MetadataValue | bool | int | float | str | bytes):
    if isinstance(value, MetadataValue):
        return value
    if isinstance(value, bool):
        return MetadataValue.bool(value)
    if isinstance(value, int):
        return MetadataValue.i64(value)
    if isinstance(value, float):
        return MetadataValue.f64(value)
    if isinstance(value, str):
        return MetadataValue.string(value)
    if isinstance(value, bytes):
        return MetadataValue.bytes(value)
    raise TypeError(f"unsupported metadata value {type(value).__name__}")


def _coerce_metadata(
    metadata: (
        Mapping[str, MetadataValue | bool | int | float | str | bytes]
        | Iterable[
            GateMetadata | tuple[str, MetadataValue | bool | int | float | str | bytes]
        ]
        | None
    ),
) -> tuple[GateMetadata, ...]:
    if metadata is None:
        return ()
    raw_items = metadata.items() if isinstance(metadata, Mapping) else metadata
    entries: dict[str, MetadataValue] = {}
    for item in raw_items:
        if isinstance(item, GateMetadata):
            key = item.key
            value = item.value
        else:
            key, raw_value = item
            value = _coerce_metadata_value(raw_value)
        entries[str(key)] = value
    return tuple(GateMetadata(key, value) for key, value in entries.items())


def _instantiate_gate(
    definition: GateDefinition, values: Iterable[int | float | bool | GateValue]
) -> Gate:
    return Gate(
        definition.semantic_id,
        [
            _coerce_gate_value(operand.kind, value)
            for operand, value in zip(definition.operands, values, strict=True)
        ],
    )


class _Cursor:
    def __init__(self, data: bytes):
        self._data = data
        self._offset = 0

    def read(self, length: int) -> bytes:
        end = self._offset + length
        if end > len(self._data):
            raise ValueError("truncated gatewire data")
        value = self._data[self._offset : end]
        self._offset = end
        return value

    def read_string(self) -> str:
        (length,) = struct.unpack("<I", self.read(4))
        return self.read(length).decode("utf-8")

    def read_bytes(self) -> bytes:
        (length,) = struct.unpack("<I", self.read(4))
        return self.read(length)

    def finish(self) -> None:
        if self._offset != len(self._data):
            raise ValueError("trailing gatewire data")


QUBIT = OperandKind.QUBIT
F64 = OperandKind.F64
U64 = OperandKind.U64
I64 = OperandKind.I64
U8 = OperandKind.U8
BOOL = OperandKind.BOOL


def _builtin(name: str, operands: Iterable[tuple[str, OperandKind]]) -> GateDefinition:
    return GateDefinition(
        f"gatewire.builtin.{name}.v1",
        name,
        [OperandDefinition(operand_name, kind) for operand_name, kind in operands],
    )


RZ = _builtin("RZ", [("q0", QUBIT), ("theta", F64)])
PhasedX = _builtin("PhasedX", [("q0", QUBIT), ("theta", F64), ("phi", F64)])
ZZPhase = _builtin("ZZPhase", [("q0", QUBIT), ("q1", QUBIT), ("theta", F64)])
PhasedXX = _builtin(
    "PhasedXX", [("q0", QUBIT), ("q1", QUBIT), ("theta", F64), ("phi", F64)]
)

HeliosGateSet: Gateset = Gateset(RZ, PhasedX, ZZPhase)
SolGateSet: Gateset = Gateset(RZ, PhasedX, PhasedXX)
QuantinuumGateSet: Gateset = HeliosGateSet.union(SolGateSet)


def builtin_gateset() -> Gateset:
    return QuantinuumGateSet


def rz(q0: int, theta: float) -> Gate:
    return Gate(RZ.semantic_id, [GateValue.qubit(q0), GateValue.f64(theta)])


def phased_x(q0: int, theta: float, phi: float) -> Gate:
    return Gate(
        PhasedX.semantic_id,
        [GateValue.qubit(q0), GateValue.f64(theta), GateValue.f64(phi)],
    )


def zz_phase(q0: int, q1: int, theta: float) -> Gate:
    return Gate(
        ZZPhase.semantic_id,
        [GateValue.qubit(q0), GateValue.qubit(q1), GateValue.f64(theta)],
    )


def phased_xx(q0: int, q1: int, theta: float, phi: float) -> Gate:
    return Gate(
        PhasedXX.semantic_id,
        [
            GateValue.qubit(q0),
            GateValue.qubit(q1),
            GateValue.f64(theta),
            GateValue.f64(phi),
        ],
    )
