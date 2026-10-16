import itertools

import numpy as np
import pytest
from selene_quest_plugin.state import SeleneQuestState


def test_computational_basis_ordering():
    """Verify that get_global_state correctly respects user-specified qubit ordering

    for computational basis states where .state would otherwise return incorrect ordering.
    """
    # 2 qubits. In QuEST internal convention:
    # qubit 0 is LSB (bit 0), qubit 1 is MSB (bit 1).
    # Suppose qubit 0 is in state |1> and qubit 1 is in state |0>.
    # QuEST internal array index is (0 * 2 + 1) = 1.
    raw_state = np.array([0.0, 1.0, 0.0, 0.0], dtype=np.complex128)

    # When specified_qubits is [0, 1]:
    # qubit 0 is MSB and qubit 1 is LSB.
    # The expected basis state is |10> = index 2.
    state_01 = SeleneQuestState(
        state=raw_state.copy(), total_qubits=2, specified_qubits=[0, 1]
    )
    expected_01 = np.array([0.0, 0.0, 1.0, 0.0], dtype=np.complex128)
    np.testing.assert_allclose(state_01.get_global_state(), expected_01)

    # When specified_qubits is [1, 0]:
    # qubit 1 is MSB and qubit 0 is LSB.
    # The expected basis state is |01> = index 1.
    state_10 = SeleneQuestState(
        state=raw_state.copy(), total_qubits=2, specified_qubits=[1, 0]
    )
    expected_10 = np.array([0.0, 1.0, 0.0, 0.0], dtype=np.complex128)
    np.testing.assert_allclose(state_10.get_global_state(), expected_10)

    # Verify that raw .state does NOT adapt to specified_qubits (regression check for #109/#130)
    assert not np.allclose(state_01.state, expected_01)


@pytest.mark.parametrize("angle", [0.1, np.pi / 4, np.pi / 3, np.pi / 2, np.pi])
def test_superposition_without_phase_normalization(angle):
    """Verify that get_global_state returns the underlying simulator statevector

    without applying phase normalization, unlike get_single_state which
    normalizes the first non-zero component to be real.
    """
    global_phase = np.exp(1j * angle)
    raw_state = np.zeros(4, dtype=np.complex128)
    raw_state[0] = global_phase * (1.0 / np.sqrt(2))
    raw_state[3] = global_phase * (1j / np.sqrt(2))

    state = SeleneQuestState(
        state=raw_state.copy(), total_qubits=2, specified_qubits=[0, 1]
    )

    result = state.get_global_state()

    # Exact complex amplitudes match the underlying simulator statevector
    np.testing.assert_allclose(result, raw_state)
    assert np.isclose(result[0], global_phase / np.sqrt(2))
    assert np.isclose(result[3], global_phase * 1j / np.sqrt(2))

    # Regression check: verify that get_single_state() normalizes the phase of the first non-zero component
    # (when angle is not a multiple of 2*pi where phase is already real 1)
    if not np.isclose(np.sin(angle), 0.0) or np.isclose(np.cos(angle), -1.0):
        single_state = state.get_single_state()
        assert np.isreal(single_state[0])
        assert not np.allclose(single_state, raw_state)


def test_three_qubit_all_permutations():
    """Verify 3-qubit state under all 6 possible permutations of specified_qubits."""
    # State: (|100> + i|010> - |001>)/sqrt(3) with labels (q0, q1, q2).
    # In QuEST internal representation:
    # q0 is bit 0, q1 is bit 1, q2 is bit 2.
    # q0=1, q1=0, q2=0 -> bit pattern 001_2 = index 1
    # q0=0, q1=1, q2=0 -> bit pattern 010_2 = index 2
    # q0=0, q1=0, q2=1 -> bit pattern 100_2 = index 4
    raw_state = np.zeros(8, dtype=np.complex128)
    raw_state[1] = 1.0 / np.sqrt(3)
    raw_state[2] = 1j / np.sqrt(3)
    raw_state[4] = -1.0 / np.sqrt(3)

    # For any permutation [s0, s1, s2]:
    # Basis state index is: b(s0)*4 + b(s1)*2 + b(s2)*1
    for perm in itertools.permutations([0, 1, 2]):
        specified = list(perm)
        s = SeleneQuestState(
            state=raw_state.copy(), total_qubits=3, specified_qubits=specified
        )
        result = s.get_global_state()

        expected = np.zeros(8, dtype=np.complex128)
        # Contribution from q0=1 (q1=0, q2=0):
        idx_q0 = (
            (1 if specified[0] == 0 else 0) * 4
            + (1 if specified[1] == 0 else 0) * 2
            + (1 if specified[2] == 0 else 0) * 1
        )
        expected[idx_q0] = 1.0 / np.sqrt(3)

        # Contribution from q1=1 (q0=0, q2=0):
        idx_q1 = (
            (1 if specified[0] == 1 else 0) * 4
            + (1 if specified[1] == 1 else 0) * 2
            + (1 if specified[2] == 1 else 0) * 1
        )
        expected[idx_q1] = 1j / np.sqrt(3)

        # Contribution from q2=1 (q0=0, q1=0):
        idx_q2 = (
            (1 if specified[0] == 2 else 0) * 4
            + (1 if specified[1] == 2 else 0) * 2
            + (1 if specified[2] == 2 else 0) * 1
        )
        expected[idx_q2] = -1.0 / np.sqrt(3)

        np.testing.assert_allclose(result, expected)


def test_single_qubit():
    """Verify single qubit state."""
    raw_state = np.array([0.6j, 0.8], dtype=np.complex128)
    s = SeleneQuestState(state=raw_state.copy(), total_qubits=1, specified_qubits=[0])
    result = s.get_global_state()
    np.testing.assert_allclose(result, raw_state)


def test_invalid_specified_qubits_raises():
    """Verify that get_global_state raises ValueError when not all qubits are specified

    or when specified_qubits contains duplicates or out-of-range indices.
    """
    raw_state = np.zeros(8, dtype=np.complex128)

    # Fewer qubits than total_qubits
    s_partial = SeleneQuestState(
        state=raw_state, total_qubits=3, specified_qubits=[0, 1]
    )
    with pytest.raises(ValueError, match="All 3 qubits must be specified"):
        s_partial.get_global_state()

    # Duplicate qubits
    s_dup = SeleneQuestState(
        state=raw_state, total_qubits=3, specified_qubits=[0, 1, 1]
    )
    with pytest.raises(ValueError, match="without duplicates"):
        s_dup.get_global_state()

    # Out of range qubits
    s_out = SeleneQuestState(
        state=raw_state, total_qubits=3, specified_qubits=[0, 1, 3]
    )
    with pytest.raises(ValueError, match="All 3 qubits must be specified"):
        s_out.get_global_state()


def test_zero_qubits_edge_case():
    """Verify 0-qubit state edge case."""
    raw_state = np.array([0.6 + 0.8j], dtype=np.complex128)
    s_zero = SeleneQuestState(state=raw_state, total_qubits=0, specified_qubits=[])
    result = s_zero.get_global_state()
    np.testing.assert_allclose(result, raw_state)
