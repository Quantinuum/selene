from pathlib import Path
import struct
from typing import Callable, Generic, Iterable, TypeVar
from typing_extensions import Self
from enum import Enum

import numpy as np
from dataclasses import dataclass


T = TypeVar("T")

@dataclass
class Pauli:
    x: bool
    z: bool
    @classmethod
    def from_char(cls, c: str) -> Self:
        match c:
            case "_":
                return cls(False, False)
            case "X":
                return cls(True, False)
            case "Y":
                return cls(True, True)
            case "Z":
                return cls(False, True)
            case _:
                raise ValueError(f"Invalid Pauli character: {c}")
    def __repr__(self) -> str:
        if not self.x and not self.z:
            return "_"
        elif self.x and not self.z:
            return "X"
        elif self.x and self.z:
            return "Y"
        elif not self.x and self.z:
            return "Z"
        else:
            raise ValueError("Invalid Pauli operator")
    def multiply(self, other: "Pauli") -> tuple[Self, bool]:
        """Multiply two Pauli operators. If the result involves a sign flip, return True as the second element."""
        new_x = self.x ^ other.x
        new_z = self.z ^ other.z
        sign_flip = (self.x and other.z and not other.x) or (self.z and other.x and not other.z)
        return Pauli(new_x, new_z), sign_flip

    
class Stabilizer:
    sign: bool # True for +1, False for -1
    paulis: list[Pauli]  # len: total_qubits
    def __init__(self, stabilizer_string: str):
        self.sign = stabilizer_string[0] == "+"
        self.paulis = [Pauli.from_char(c) for c in stabilizer_string[1:]]
        
    def __repr__(self) -> str:
        sign_char = "+" if self.sign else "-"
        pauli_str = "".join(repr(p) for p in self.paulis)
        return f"{sign_char}{pauli_str}"
    
    def __mul__(self, other: "Stabilizer") -> "Stabilizer":
        assert len(self.paulis) == len(other.paulis), "Stabilizers must have the same number of qubits to multiply"
        new_sign = self.sign ^ other.sign
        new_paulis = []
        for p1, p2 in zip(self.paulis, other.paulis):
            new_p, sign_flip = p1.multiply(p2)
            if sign_flip:
                new_sign = not new_sign
            new_paulis.append(new_p)
        result = Stabilizer("+" + "_" * len(new_paulis))  # placeholder
        result.sign = new_sign
        result.paulis = new_paulis
        return result

class Tableau:
    entries: list[Stabilizer]  # len: specified_qubits
    def __init__(self, stabilizers_string: str):
        lines = stabilizers_string.splitlines()
        n_qubits_known = len(lines)
        self.entries = [Stabilizer(lines[i]) for i in range(n_qubits_known)]
        assert all(len(stab.paulis) == len(self.entries[0].paulis) for stab in self.entries), (
            "All stabilizers must have the same number of qubits, but got: " +
            ", ".join(str(len(stab.paulis)) for stab in self.entries
        )
    def __repr__(self) -> str:
        return "\n".join(repr(stab) for stab in self.entries)
    def reduced_to_specified(self, specified_qubits: set[int]) -> None:
        # For each non-specified qubit, we permit:
        # - zero or one X
        # - zero or one Z
        # - zero Y
        # in the stabilizers corresponding to that qubit.
        # Others must be eliminated by multiplication.
        for i in range(len(self.entries[0].paulis)):
            if i in specified_qubits:
                continue
            matches = lambda stab, x, z: stab.paulis[i].x == x and stab.paulis[i].z == z
            x_stabs = [i for i,stab in enumerate(self.entries) if matches(stab, True, False)]
            y_stabs = [i for i,stab in enumerate(self.entries) if matches(stab, True, True)]
            z_stabs = [i for i,stab in enumerate(self.entries) if matches(stab, False, True)]
            for idx in y_stabs:
                # Eliminate Y by multiplying with an X or Z if available
                if x_stabs:
                    self.entries[idx] = self.entries[idx] * self.entries[x_stabs[0]]
                    z_stabs.push(idx)  # now it's a Z
                elif z_stabs:
                    self.entries[idx] = self.entries[idx] * self.entries[z_stabs[0]]
                    x_stabs.push(idx)  # now it's an X
            y_stabs = []
            if len(x_stabs) > 1:
                # Eliminate extra Xs
                for idx in x_stabs[1:]:
                    self.entries[idx] = self.entries[idx] * self.entries[x_stabs[0]]
            if len(z_stabs) > 1:
                # Eliminate extra Zs
                for idx in z_stabs[1:]:
                    self.entries[idx] = self.entries[idx] * self.entries[z_stabs[0]]
        # Now remove any row where a non-specified qubit has an identity pauli
        rows_to_remove = set()
        for i in range(len(self.entries[0].paulis)):
            if i in specified_qubits:
                continue
            for row_idx, stab in enumerate(self.entries):
                if not stab.paulis[i].x and not stab.paulis[i].z:
                    rows_to_remove.add(row_idx)
        self.entries = [stab for idx, stab in enumerate(self.entries) if idx not in rows_to_remove]
        
            
                
            




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

    #: Complex vector of size 2^total_qubits
    full_tableau: np.ndarray
    #: Total number of qubits in the state, i.e. n_qubits param to run_shots
    total_qubits: int
    #: User-specified qubits, in order of their specification
    specified_qubits: list[int]

    #def get_density_matrix(self, zero_threshold: float = 1e-12) -> np.ndarray:
    #    """
    #    Get the reduced density matrix of the state, tracing out unspecified qubits.

    #    Parameters:
    #    ----------
    #    zero_threshold: float
    #        The threshold for setting small values to zero. This is used to remove numerical noise.
    #        Any component that is less than max_magnitude * zero_threshold will be reset to zero.
    #        Default is 1e-12.

    #    """
    #    state_tensor = self.state.reshape([2] * self.total_qubits)

    #    # move all specified qubits to the end, in the user-specified order
    #    n_specified = len(self.specified_qubits)
    #    n_unspecified = self.total_qubits - n_specified
    #    permutation_lhs = []
    #    permutation_rhs = [-1 for _ in range(n_specified)]
    #    # Note: QuEST uses the convention that qubit 0 is the least significant bit.
    #    # Thus to iterate over qubits and corresponding statevector indices, we need
    #    # to iterate from left to right in one, right to left in the other.
    #    for qubit_id, bit_index in enumerate(reversed(range(self.total_qubits))):
    #        if qubit_id in self.specified_qubits:
    #            specified_index = self.specified_qubits.index(qubit_id)
    #            permutation_rhs[specified_index] = bit_index
    #        else:
    #            permutation_lhs.append(bit_index)
    #    assert -1 not in permutation_rhs, "All specified qubits must be assigned"
    #    permutation = permutation_lhs + permutation_rhs
    #    permuted = np.transpose(state_tensor, permutation)
    #    # state_tensor is now in the shape ([2]*n_unspecified + [2]*n_specified).
    #    # reshape to a matrix
    #    reshaped = permuted.reshape((2**n_unspecified, 2**n_specified))
    #    # and trace out the unspecified qubits
    #    result = np.einsum("ai,aj->ij", reshaped, np.conj(reshaped))
    #    # the shape is now (2**n_specified, 2**n_specified)
    #    assert result.shape == (2**n_specified, 2**n_specified)

    #    if zero_threshold > 0:
    #        # set small (relative) values to zero for a cleaner output
    #        max_magnitude = np.max(np.abs(result))
    #        zero_threshold = max_magnitude * zero_threshold
    #        im = result.imag
    #        re = result.real
    #        im[np.abs(im) < zero_threshold] = 0
    #        re[np.abs(re) < zero_threshold] = 0
    #        result = re + 1j * im
    #    return result

    #def get_state_vector_distribution(
    #    self, zero_threshold=1e-12
    #) -> list[TracedState[np.ndarray]]:
    #    """
    #    The reduced density matrix may be written as
    #    :math:`\\rho = \\sum_i p_i |i\\rangle \\langle i|`,
    #    where |i\\rangle are state vectors in the Hilbert space of the specified qubits,
    #    and p_i is the classical probability of the specified qubits being in the respective
    #    state after others have been measured.

    #    This is not a unique representation (by the Schrodinger-HJW theorem), but we here use
    #    a canonical decomposition.
    #    """
    #    density_matrix = self.get_density_matrix()
    #    result = []
    #    eigenvalues, eigenstates = np.linalg.eig(density_matrix)
    #    if zero_threshold > 0:
    #        # set small (relative) values to zero for a cleaner output
    #        max_magnitude = np.max(np.abs(eigenstates))
    #        zero_threshold_mag = max_magnitude * zero_threshold
    #        im = eigenstates.imag
    #        re = eigenstates.real
    #        im[np.abs(im) < zero_threshold_mag] = 0
    #        re[np.abs(re) < zero_threshold_mag] = 0
    #        eigenstates = re + 1j * im
    #        # apply a global phase shift to make the first
    #        # non-zero component real and positive
    #        for state_idx in range(eigenstates.shape[1]):
    #            # find phase of the first non-zero component
    #            phase = 1
    #            for component in eigenstates[:, state_idx]:
    #                if np.abs(component) > 0:
    #                    phase = component / np.abs(component)
    #                    break
    #            # shift the whole state by its conjugate to
    #            # make the first component real and positive
    #            eigenstates[:, state_idx] *= np.conj(phase)

    #    max_eigenvalue = np.max(np.abs(eigenvalues))
    #    for i, eigenvalue in enumerate(eigenvalues):
    #        if abs(eigenvalue) < max_eigenvalue * zero_threshold:
    #            continue
    #        result.append(
    #            TracedState(
    #                probability=abs(eigenvalue),
    #                state=eigenstates[:, i],
    #            )
    #        )
    #    return result

    #def get_single_state(self, zero_threshold=1e-12) -> np.ndarray:
    #    """
    #    Assume that the state is a pure state and return it.

    #    This is meant to be used when the user is requesting the state on all
    #    qubits, or on a subset that is not entangled with the rest.

    #    This function is a shorthand for ``get_state_vector_distribution`` that checks
    #    that there is a single vector with non-zero probability in the distribution of
    #    eigenvectors of the reduced density matrix, implying that it is a pure state.

    #    Raises ValueError if the state is not a pure state.

    #    """

    #    return self._get_single(
    #        all_getter=self.get_state_vector_distribution,
    #        zero_threshold=zero_threshold,
    #    )

    #def _get_single(
    #    self,
    #    all_getter: Callable[[float], Iterable[TracedState[T]]],
    #    zero_threshold: float,
    #) -> T:
    #    """
    #    Get the single state of the specified qubits, assuming that the state is a pure state.
    #    This is a helper method for get_single_state.
    #    """
    #    all_states = list(all_getter(zero_threshold))

    #    if len(all_states) != 1:
    #        raise ValueError("The state is not a pure state.")
    #    return all_states[0].state

    #def get_dirac_notation(self, zero_threshold=1e-12) -> list[TracedState]:
    #    try:
    #        from sympy import nsimplify, Add
    #        from sympy.physics.quantum.state import Ket

    #        width = len(self.specified_qubits)

    #        def simplify_state(tr_st: TracedState[np.ndarray]) -> TracedState:
    #            terms = []
    #            probability = nsimplify(tr_st.probability)
    #            max_amplitude = np.max(np.abs(tr_st.state))
    #            for i, amplitude in enumerate(tr_st.state):
    #                if abs(amplitude) < max_amplitude * zero_threshold:
    #                    continue
    #                coefficient = nsimplify(amplitude)
    #                basis_str = f"{i:0{width}b}"
    #                ket = Ket(basis_str)
    #                terms.append(coefficient * ket)
    #            assert len(terms) > 0, (
    #                "At least one ket state must have non-zero amplitude"
    #            )
    #            return TracedState(probability=probability, state=Add(*terms))
    #    except ImportError:
    #        import sys

    #        print(
    #            "Note: Install sympy to see prettier dirac notation output.",
    #            file=sys.stderr,
    #        )

    #        def simplify_state(
    #            tr_st: TracedState[np.ndarray],
    #        ) -> TracedState:
    #            terms = []
    #            max_amplitude = np.max(np.abs(tr_st.state))
    #            for i, amplitude in enumerate(tr_st.state):
    #                if abs(amplitude) < max_amplitude * zero_threshold:
    #                    continue
    #                ket = f"{amplitude}|{bin(i)[2:]}>"
    #                terms.append(ket)
    #            assert len(terms) > 0, (
    #                "At least one ket state must have non-zero amplitude"
    #            )
    #            return TracedState(
    #                probability=tr_st.probability, state=" + ".join(terms)
    #            )

    #    state_vector = self.get_state_vector_distribution(zero_threshold=zero_threshold)
    #    result = [simplify_state(tr_st) for tr_st in state_vector]
    #    return result

    #def get_single_dirac_notation(self, zero_threshold=1e-12) -> TracedState:
    #    """
    #    Get the single state of the specified qubits in Dirac notation,
    #    assuming that the state is a pure state.
    #    """
    #    return self._get_single(
    #        all_getter=self.get_dirac_notation,
    #        zero_threshold=zero_threshold,
    #    )

    @staticmethod
    def parse_from_file(filename: Path, cleanup: bool = True) -> "SeleneStimState":
        with open(filename, "rb") as f:
            magic = f.read(11)
            if magic != b"selene-stim":
                raise ValueError("Invalid state file format")
            header_head = f.read(16)
            total_qubits, n_specified_qubits = struct.unpack("<QQ", header_head)
            specified_qubits = []
            for i in range(n_specified_qubits):
                specified_qubits.append(struct.unpack("<Q", f.read(8))[0])
            full_tableau = f.read()
        if cleanup:
            filename.unlink()
        return SeleneStimState(full_tableau, total_qubits, specified_qubits)
