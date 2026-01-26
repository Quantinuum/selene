from pathlib import Path
import struct
from typing import Generic, TypeVar

import numpy as np
from enum import Enum
from dataclasses import dataclass


T = TypeVar("T")


class Phase(Enum):
    # Representation: quarter turns of the unit complex circle
    REAL_POSITIVE = 0
    IMAGINARY_POSITIVE = 1
    REAL_NEGATIVE = 2
    IMAGINARY_NEGATIVE = 3

    def __init__(self, value: int) -> None:
        self._value = value

    def is_imaginary(self) -> bool:
        return self._value % 2 == 1

    def is_real(self) -> bool:
        return self._value % 2 == 0

    def get_complex(self) -> complex:
        match self:
            case Phase.REAL_POSITIVE:
                return 1 + 0j
            case Phase.REAL_NEGATIVE:
                return -1 + 0j
            case Phase.IMAGINARY_POSITIVE:
                return 0 + 1j
            case Phase.IMAGINARY_NEGATIVE:
                return 0 - 1j

    def __str__(self) -> str:
        match self:
            case Phase.REAL_POSITIVE:
                return "+"
            case Phase.REAL_NEGATIVE:
                return "-"
            case Phase.IMAGINARY_POSITIVE:
                return "+i"
            case Phase.IMAGINARY_NEGATIVE:
                return "-i"

    def __add__(self, other: object) -> "Phase":
        assert isinstance(other, Phase), f"Can only add another Phase, got {other!r}"

        return Phase((self._value + other._value) % 4)

    def __sub__(self, other: object) -> "Phase":
        assert isinstance(other, Phase), (
            f"Can only subtract another Phase, got {other!r}"
        )
        return Phase((self._value - other._value) % 4)

    def __neg__(self) -> "Phase":
        return self + Phase.REAL_NEGATIVE


class Pauli(Enum):
    X = 1
    Y = 2
    Z = 3
    I = 4  # noqa: E741

    @classmethod
    def from_char(cls, c: str) -> "Pauli":
        match c:
            case "_":
                return cls.I
            case "X":
                return cls.X
            case "Y":
                return cls.Y
            case "Z":
                return cls.Z
            case _:
                raise ValueError(f"Invalid Pauli character: {c}")

    def __repr__(self) -> str:
        match self:
            case Pauli.I:
                return "_"
            case Pauli.X:
                return "X"
            case Pauli.Y:
                return "Y"
            case Pauli.Z:
                return "Z"

    def as_matrix(self) -> np.ndarray:
        match self:
            case Pauli.I:
                return np.array([[1, 0], [0, 1]], dtype=complex)
            case Pauli.X:
                return np.array([[0, 1], [1, 0]], dtype=complex)
            case Pauli.Y:
                return np.array([[0, -1j], [1j, 0]], dtype=complex)
            case Pauli.Z:
                return np.array([[1, 0], [0, -1]], dtype=complex)

    def multiply(self, other: "Pauli") -> tuple["Pauli", Phase]:
        """Multiply two Pauli operators, returning the result and the phase change."""
        assert isinstance(other, Pauli), (
            f"Can only multiply with another Pauli, got {other!r}"
        )
        match (self, other):
            # Identity cases
            case (Pauli.I, _):
                return other, Phase.REAL_POSITIVE
            case (_, Pauli.I):
                return self, Phase.REAL_POSITIVE
            # Equality cases
            case (Pauli.X, Pauli.X):
                return Pauli.I, Phase.REAL_POSITIVE
            case (Pauli.Y, Pauli.Y):
                return Pauli.I, Phase.REAL_POSITIVE
            case (Pauli.Z, Pauli.Z):
                return Pauli.I, Phase.REAL_POSITIVE
            # Positive cycles
            case (Pauli.X, Pauli.Y):
                return Pauli.Z, Phase.IMAGINARY_POSITIVE
            case (Pauli.Y, Pauli.Z):
                return Pauli.X, Phase.IMAGINARY_POSITIVE
            case (Pauli.Z, Pauli.X):
                return Pauli.Y, Phase.IMAGINARY_POSITIVE
            # Negative cycles
            case (Pauli.Y, Pauli.X):
                return Pauli.Z, Phase.IMAGINARY_NEGATIVE
            case (Pauli.Z, Pauli.Y):
                return Pauli.X, Phase.IMAGINARY_NEGATIVE
            case (Pauli.X, Pauli.Z):
                return Pauli.Y, Phase.IMAGINARY_NEGATIVE
            case _:
                raise ValueError(f"Unhandled Pauli multiplication: {self}, {other}")


class StabilizerGenerator:
    phase: Phase  # In intermediate calculations only, this may be imaginary.
    paulis: tuple[Pauli, ...]  # len: total_qubits

    def __init__(self, stabilizer_string: str) -> None:
        # We expect that the stabilizer string starts with +, -, +i, or -i.
        # For raw inputs we should only accept real phases (+ or -), but as it
        # may be useful to have imaginary phases in intermediate calculations,
        # we support reading them.
        if stabilizer_string.startswith("+i"):
            self.phase = Phase.IMAGINARY_POSITIVE
            pauli_string = stabilizer_string[2:]
        elif stabilizer_string.startswith("-i"):
            self.phase = Phase.IMAGINARY_NEGATIVE
            pauli_string = stabilizer_string[2:]
        elif stabilizer_string.startswith("+"):
            self.phase = Phase.REAL_POSITIVE
            pauli_string = stabilizer_string[1:]
        elif stabilizer_string.startswith("-"):
            self.phase = Phase.REAL_NEGATIVE
            pauli_string = stabilizer_string[1:]
        else:
            raise ValueError(
                f"Invalid stabilizer string prefix (expecting +, -, +i, or -i): {stabilizer_string}"
            )

        self.paulis = tuple(Pauli.from_char(c) for c in pauli_string)

    def is_valid(self) -> bool:
        return self.phase.is_real()

    def remove_qubit(self, qubit_index: int) -> None:
        """Remove the specified qubit from the stabilizer generator.

        No checks are performed; the caller is responsible for ensuring that
        the qubit can be removed."""
        self.paulis = tuple(p for i, p in enumerate(self.paulis) if i != qubit_index)

    def permute_qubits(self, permutation: list[int]) -> None:
        """Permute the qubits of the stabilizer generator according to the given permutation.

        No checks are performed; the caller is responsible for ensuring that
        the permutation is valid."""
        self.paulis = tuple(self.paulis[i] for i in permutation)

    def as_matrix(self) -> np.ndarray:
        result = self.phase.get_complex() * np.eye(1, dtype=complex)
        for p in self.paulis:
            result = np.kron(result, p.as_matrix())
        return result

    def __repr__(self) -> str:
        pauli_str = "".join(repr(p) for p in self.paulis)
        return f"{self.phase}{pauli_str}"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, StabilizerGenerator):
            return NotImplemented
        return self.phase == other.phase and self.paulis == other.paulis

    def __mul__(self, other: object) -> "StabilizerGenerator":
        assert isinstance(other, StabilizerGenerator), (
            f"Can only multiply with another StabilizerGenerator, got {other!r}"
        )
        assert len(self.paulis) == len(other.paulis), (
            "Stabilizers must have the same number of qubits to multiply"
        )
        new_phase = self.phase + other.phase
        new_paulis = []
        for p1, p2 in zip(self.paulis, other.paulis):
            new_pauli, phase_change = p1.multiply(p2)
            new_paulis.append(new_pauli)
            new_phase += phase_change
        result = StabilizerGenerator("+" + "_" * len(new_paulis))  # placeholder
        result.phase = new_phase
        result.paulis = tuple(new_paulis)
        return result


class StabilizerList:
    entries: list[StabilizerGenerator]  # le n: specified_qubits

    def __init__(self, stabilizer_strings: list[str]):
        n_qubits_known = len(stabilizer_strings)
        self.entries = [
            StabilizerGenerator(stabilizer_strings[i]) for i in range(n_qubits_known)
        ]
        assert all(
            len(stab.paulis) == len(self.entries[0].paulis) for stab in self.entries
        ), "All stabilizers must have the same number of qubits, but got: " + ", ".join(
            str(len(stab.paulis)) for stab in self.entries
        )

    def clone(self) -> "StabilizerList":
        return StabilizerList([repr(stab) for stab in self.entries])

    def __repr__(self) -> str:
        return "\n".join(repr(stab) for stab in self.entries)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, StabilizerList):
            return NotImplemented
        return self.entries == other.entries

    def trace_out_qubit(self, qubit_index: int) -> None:
        """Eliminate the specified qubit from the tableau by tracing it out."""

        # First we wish to establish a basis of at most two paulis on the qubit to be traced out.
        # We iterate through each stabilizer string and check the Pauli operator at qubit_index.
        # In the process, we aim to span the space of possible Pauli operators on that qubit with
        # a basis of at most two stabilizers (e.g., X and Z, X and Y, or Y and Z). We do this
        # iteratively.
        rows_to_remove = []
        multiply_rules: dict[Pauli, StabilizerGenerator] = {}
        for i, stab in enumerate(self.entries):
            if stab.paulis[qubit_index] == Pauli.I:
                # Nothing to do here.
                continue
            if stab.paulis[qubit_index] not in multiply_rules:
                # We have found a new basis stabilizer for this qubit.
                if len(multiply_rules) == 1:
                    # We already have a different basis stabilizer; we can figure out the third.
                    other_known_pauli: Pauli = next(iter(multiply_rules.keys()))
                    new_pauli, _ = stab.paulis[qubit_index].multiply(other_known_pauli)
                    multiply_rules[new_pauli] = stab * multiply_rules[other_known_pauli]
                multiply_rules[stab.paulis[qubit_index]] = stab
                # We know we have to remove this row later.
                rows_to_remove.append(i)
                continue
            assert stab.paulis[qubit_index] in multiply_rules, (
                "Should have found a basis stabilizer."
            )
            # We can eliminate this stabilizer's pauli on the qubit by multiplying
            # with the known basis stabilizer.
            self.entries[i] = stab * multiply_rules[stab.paulis[qubit_index]]
            assert self.entries[i].paulis[qubit_index] == Pauli.I, (
                "Failed to eliminate pauli on traced out qubit."
            )

        for row_to_remove in reversed(rows_to_remove):
            del self.entries[row_to_remove]
        for i in range(len(self.entries)):
            # Delete the traced out qubit from each remaining stabilizer
            self.entries[i].remove_qubit(qubit_index)

    def reduced_to_qubits(self, wanted_qubits: list[int]) -> "StabilizerList":
        # Trace out unspecified qubits from highest to lowest index
        result = self.clone()
        for qubit_index in reversed(range(len(self.entries[0].paulis))):
            if qubit_index not in wanted_qubits:
                result.trace_out_qubit(qubit_index)

        wanted_sorted = sorted(wanted_qubits)
        wanted_permutation = [wanted_sorted.index(q) for q in wanted_qubits]

        for stab in result.entries:
            assert stab.is_valid(), (
                "Resulting stabilizer contains imaginary phase after reduction: "
                + repr(stab)
            )
            assert len(stab.paulis) == len(wanted_qubits), (
                "Resulting stabilizer has incorrect number of qubits after reduction: "
                + f"expected {len(wanted_qubits)}, got {len(stab.paulis)}"
            )
            if wanted_permutation != list(range(len(wanted_qubits))):
                stab.permute_qubits(wanted_permutation)

        return result

    def as_density_matrix(self) -> np.ndarray:
        """Get the density matrix represented by the stabilizer list. Only to be used for small numbers of qubits."""
        n_qubits = len(self.entries[0].paulis)
        dim = 2**n_qubits
        result = np.zeros((dim, dim), dtype=complex)
        generator_matrices = [stab.as_matrix() for stab in self.entries]
        # for every combination of stabilizer generators, add their product to the density matrix
        for i in range(2 ** len(generator_matrices)):
            stab_product = np.eye(dim, dtype=complex)
            for j in range(len(generator_matrices)):
                if (i >> j) & 1:
                    stab_product = stab_product @ generator_matrices[j]
            result += stab_product
        result /= dim
        return result


@dataclass(frozen=True)
class TracedState(Generic[T]):
    """The result of tracing out qubits from a SeleneStimState, leaving a probabilistic
    mix of states. This class represents a single state in the mix."""

    #: The probability of this state in the mix
    probability: float
    #: The state vector of remaining qubits after tracing out.
    state: T


@dataclass
class SeleneStimState:
    """A quantum state in the Selene Stim simulator, as reported by `state_result` calls."""

    # Stabilizers of the entire register - not of just the specified qubits.
    unreduced_stabilizer_list: StabilizerList
    # Total number of qubits in the state, i.e. n_qubits param to run_shots
    total_qubits: int
    # User-specified qubits, in order of their specification
    specified_qubits: list[int]

    def get_reduced_stabilizers(self) -> StabilizerList:
        """Get the stabilizers reduced to the specified qubits."""
        return self.unreduced_stabilizer_list.reduced_to_qubits(self.specified_qubits)

    def get_density_matrix(self) -> np.ndarray:
        """
        Get the reduced density matrix of the state, tracing out unspecified qubits.
        """
        return self.get_reduced_stabilizers().as_density_matrix()

    def get_state_vector_distribution(
        self,
        zero_threshold: float = 1e-12,
    ) -> list[TracedState[np.ndarray]]:
        """
        The reduced density matrix may be written as
        :math:`\\rho = \\sum_i p_i |i\\rangle \\langle i|`,
        where |i\\rangle are state vectors in the Hilbert space of the specified qubits,
        and p_i is the classical probability of the specified qubits being in the respective
        state after others have been measured.

        This is not a unique representation (by the Schrodinger-HJW theorem), but we here use
        a canonical decomposition.
        """
        density_matrix = self.get_density_matrix()
        result = []
        eigenvalues, eigenstates = np.linalg.eig(density_matrix)

        im = eigenstates.imag
        re = eigenstates.real
        eigenstates = re + 1j * im
        # apply a global phase shift to make the first
        # non-zero component real and positive
        for state_idx in range(eigenstates.shape[1]):
            # find phase of the first non-zero component
            phase = 1
            for component in eigenstates[:, state_idx]:
                if np.abs(component) > 0:
                    phase = component / np.abs(component)
                    break
            # shift the whole state by its conjugate to
            # make the first component real and positive
            eigenstates[:, state_idx] *= np.conj(phase)

        for i, eigenvalue in enumerate(eigenvalues):
            if abs(eigenvalue) > zero_threshold:
                result.append(
                    TracedState(
                        probability=abs(eigenvalue),
                        state=eigenstates[:, i],
                    )
                )
        return result

    def get_single_state(self) -> np.ndarray:
        """
        Assume that the state is a pure state and return it.

        This is meant to be used when the user is requesting the state on all
        qubits, or on a subset that is not entangled with the rest.

        This function is a shorthand for ``get_state_vector_distribution`` that checks
        that there is a single vector with non-zero probability in the distribution of
        eigenvectors of the reduced density matrix, implying that it is a pure state.

        Raises ValueError if the state is not a pure state.

        """

        distribution = self.get_state_vector_distribution()
        assert len(distribution) == 1, (
            f"Expected a pure state with a single vector in the distribution. Got {len(distribution)} states: {distribution}"
        )
        return distribution[0].state

    def get_dirac_notation(self) -> list[TracedState]:
        try:
            from sympy import nsimplify, Add
            from sympy.physics.quantum.state import Ket

            width = len(self.specified_qubits)

            def simplify_state(tr_st: TracedState[np.ndarray]) -> TracedState:
                terms = []
                probability = nsimplify(tr_st.probability)
                for i, amplitude in enumerate(tr_st.state):
                    coefficient = nsimplify(amplitude)
                    basis_str = f"{i:0{width}b}"
                    ket = Ket(basis_str)
                    terms.append(coefficient * ket)
                assert len(terms) > 0, (
                    "At least one ket state must have non-zero amplitude"
                )
                return TracedState(probability=probability, state=Add(*terms))
        except ImportError:
            import sys

            print(
                "Note: Install sympy to see prettier dirac notation output.",
                file=sys.stderr,
            )

            def simplify_state(
                tr_st: TracedState[np.ndarray],
            ) -> TracedState:
                terms = []
                for i, amplitude in enumerate(tr_st.state):
                    ket = f"{amplitude}|{bin(i)[2:]}>"
                    terms.append(ket)
                assert len(terms) > 0, (
                    "At least one ket state must have non-zero amplitude"
                )
                return TracedState(
                    probability=tr_st.probability, state=" + ".join(terms)
                )

        state_vector = self.get_state_vector_distribution()
        result = [simplify_state(tr_st) for tr_st in state_vector]
        return result

    def get_single_dirac_notation(self) -> TracedState:
        """
        Get the single state of the specified qubits in Dirac notation,
        assuming that the state is a pure state.
        """
        distribution = self.get_dirac_notation()
        assert len(distribution) == 1, (
            "Expected a pure state with a single vector in the distribution."
        )
        return distribution[0].state

    @staticmethod
    def parse_from_stabilizer_strings(
        stabilizer_strings: list[str],
        specified_qubits: list[int],
    ) -> "SeleneStimState":
        total_qubits = len(stabilizer_strings[0]) - 1  # minus phase character
        return SeleneStimState(
            StabilizerList(stabilizer_strings),
            total_qubits,
            specified_qubits,
        )

    @staticmethod
    def parse_from_file(filename: Path, cleanup: bool = True) -> "SeleneStimState":
        with open(filename, "rb") as f:
            magic = f.read(11)
            if magic != b"selene-stim":
                raise ValueError("Invalid state file format")
            header_head = f.read(16)
            _, n_specified_qubits = struct.unpack("<QQ", header_head)
            specified_qubits = []
            for i in range(n_specified_qubits):
                specified_qubits.append(struct.unpack("<Q", f.read(8))[0])
            stabilizers = f.read()
        if cleanup:
            filename.unlink()
        return SeleneStimState.parse_from_stabilizer_strings(
            stabilizer_strings=stabilizers.decode("utf-8").strip().split("\n"),
            specified_qubits=specified_qubits,
        )
