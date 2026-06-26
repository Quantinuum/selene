from __future__ import annotations

from selene_core import Gate, GateDefinition, Gateset, OperandDefinition, QUBIT


def _gate(name: str, operands: list[str]) -> GateDefinition:
    return GateDefinition(
        f"example.clifford_t.{name}.v1",
        name,
        [OperandDefinition(operand, QUBIT) for operand in operands],
    )


H = _gate("H", ["q0"])
S = _gate("S", ["q0"])
Sdg = _gate("Sdg", ["q0"])
T = _gate("T", ["q0"])
Tdg = _gate("Tdg", ["q0"])
X = _gate("X", ["q0"])
CNOT = _gate("CNOT", ["control", "target"])

CLIFFORD_T = Gateset(H, S, Sdg, T, Tdg, X, CNOT)


def clifford_t_gateset() -> Gateset:
    return CLIFFORD_T


def h(q0: int) -> Gate:
    return CLIFFORD_T.H(q0=q0)


def s(q0: int) -> Gate:
    return CLIFFORD_T.S(q0=q0)


def sdg(q0: int) -> Gate:
    return CLIFFORD_T.Sdg(q0=q0)


def t(q0: int) -> Gate:
    return CLIFFORD_T.T(q0=q0)


def tdg(q0: int) -> Gate:
    return CLIFFORD_T.Tdg(q0=q0)


def x(q0: int) -> Gate:
    return CLIFFORD_T.X(q0=q0)


def cnot(control: int, target: int) -> Gate:
    return CLIFFORD_T.CNOT(control=control, target=target)
