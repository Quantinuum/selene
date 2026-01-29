import pytest
from dataclasses import dataclass
from selene_stim_plugin.state import StabilizerList, SeleneStimState, TracedState
import numpy as np


@dataclass
class ReductionExample:
    input_stabilizer_strings: list[str]
    specified_qubits: list[int]
    expected_reduced_stabilizers: list[str]
    # Statevector and density matrix tests are encouraged for small examples, but optional for larger ones
    expected_full_statevector: np.ndarray | None = None
    expected_reduced_density_matrix: np.ndarray | None = None
    expected_reduced_state_distribution: list[tuple[float, np.ndarray]] | None = None


N_QUBITS_LARGE_EXAMPLE = 200


EXAMPLES = [
    ReductionExample(
        # (|0000> + |1111>)/sqrt(2)
        input_stabilizer_strings=["+XXXX", "+ZZ__", "+_ZZ_", "+__ZZ"],
        specified_qubits=[1, 3],
        expected_full_statevector=np.array([1] + [0] * 14 + [1]) / np.sqrt(2),
        expected_reduced_stabilizers=["+ZZ"],
        expected_reduced_density_matrix=np.array(
            [
                [0.5, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.5],
            ]
        ),
        expected_reduced_state_distribution=[
            (0.5, np.array([1, 0, 0, 0])),
            (0.5, np.array([0, 0, 0, 1])),
        ],
    ),
    ReductionExample(
        # (|++++> - |---->)/sqrt(2)
        input_stabilizer_strings=["-ZZZZ", "+XX__", "+_XX_", "+__XX"],
        specified_qubits=[1, 3],
        expected_full_statevector=np.array(
            [0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0]
        )
        / np.sqrt(8),
        expected_reduced_stabilizers=["+XX"],
        expected_reduced_density_matrix=np.array(
            [
                [0.25, 0.0, 0.0, 0.25],
                [0.0, 0.25, 0.25, 0.0],
                [0.0, 0.25, 0.25, 0.0],
                [0.25, 0.0, 0.0, 0.25],
            ]
        ),
        expected_reduced_state_distribution=[
            (0.5, np.array([1, 0, 0, 1]) / np.sqrt(2)),
            (0.5, np.array([0, 1, 1, 0]) / np.sqrt(2)),
        ],
    ),
    ReductionExample(
        # (|+01> - |-10>)/sqrt(2) \otimes |->
        input_stabilizer_strings=[
            "-___X",
            "-ZXX_",
            "+XZ__",
            "-_ZZ_",
        ],
        expected_full_statevector=np.array(
            [0, 0, 1, -1, -1, 1, 0, 0, 0, 0, 1, -1, 1, -1, 0, 0]
        )
        / np.sqrt(8),
        specified_qubits=[1, 2],
        expected_reduced_stabilizers=[
            "-ZZ",
        ],
        expected_reduced_density_matrix=np.array(
            [
                [0.0, 0.0, 0.0, 0.0],
                [0.0, 0.5, 0.0, 0.0],
                [0.0, 0.0, 0.5, 0.0],
                [0.0, 0.0, 0.0, 0.0],
            ]
        ),
        expected_reduced_state_distribution=[
            (0.5, np.array([0, 1, 0, 0])),
            (0.5, np.array([0, 0, 1, 0])),
        ],
    ),
    ReductionExample(
        # (|+0> - |-1>)/sqrt(2) \otimes |0->
        input_stabilizer_strings=[
            "-___X",
            "+__Z_",
            "-ZX__",
            "+XZ__",
        ],
        expected_full_statevector=np.array(
            [1, -1, 0, 0, -1, 1, 0, 0, 1, -1, 0, 0, 1, -1, 0, 0]
        )
        / np.sqrt(8),
        specified_qubits=[0, 1],
        expected_reduced_stabilizers=[
            "-ZX",
            "+XZ",
        ],
        expected_reduced_density_matrix=np.array(
            [
                [0.25, -0.25, 0.25, 0.25],
                [-0.25, 0.25, -0.25, -0.25],
                [0.25, -0.25, 0.25, 0.25],
                [0.25, -0.25, 0.25, 0.25],
            ]
        ),
        expected_reduced_state_distribution=[
            (1.0, np.array([1, -1, 1, 1]) / np.sqrt(4)),
        ],
    ),
    ReductionExample(
        # Same as above, but with a different specified qubit order
        input_stabilizer_strings=[
            "-___X",
            "+__Z_",
            "-ZX__",
            "+XZ__",
        ],
        expected_full_statevector=np.array(
            [1, -1, 0, 0, -1, 1, 0, 0, 1, -1, 0, 0, 1, -1, 0, 0]
        )
        / np.sqrt(8),
        specified_qubits=[1, 0],
        expected_reduced_stabilizers=[
            "-XZ",
            "+ZX",
        ],
        expected_reduced_density_matrix=np.array(
            [
                [0.25, 0.25, -0.25, 0.25],
                [0.25, 0.25, -0.25, 0.25],
                [-0.25, -0.25, 0.25, -0.25],
                [0.25, 0.25, -0.25, 0.25],
            ]
        ),
        expected_reduced_state_distribution=[
            (1.0, np.array([1, 1, -1, 1]) / np.sqrt(4)),
        ],
    ),
    ReductionExample(
        # |+++++.....+++> (N_QUBITS_LARGE_EXAMPLE qubits)
        input_stabilizer_strings=(
            ["+" + "X" * N_QUBITS_LARGE_EXAMPLE]
            + [
                "+" + "_" * i + "ZZ" + "_" * (N_QUBITS_LARGE_EXAMPLE - 2 - i)
                for i in range(N_QUBITS_LARGE_EXAMPLE - 1)
            ]
        ),
        # keep the first and last qubits
        specified_qubits=[0, N_QUBITS_LARGE_EXAMPLE - 1],
        expected_reduced_stabilizers=["+ZZ"],
        # Skipping full statevector check for this large example
        expected_full_statevector=None,
        # TODO: density matrix and distribution checks could be added later if desired
        expected_reduced_density_matrix=np.array(
            [
                [0.5, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.5],
            ]
        ),
        expected_reduced_state_distribution=[
            (0.5, np.array([1, 0, 0, 0])),
            (0.5, np.array([0, 0, 0, 1])),
        ],
    ),
]


@pytest.mark.parametrize("example", EXAMPLES)
def test_stabilizer_reduction(example: ReductionExample):
    full_register = SeleneStimState.parse_from_stabilizer_strings(
        example.input_stabilizer_strings,
        list(range(len(example.input_stabilizer_strings[0]) - 1)),
    )
    reduced_case = SeleneStimState.parse_from_stabilizer_strings(
        example.input_stabilizer_strings,
        example.specified_qubits,
    )

    if example.expected_full_statevector is not None:
        input_statevector = full_register.get_single_state()
        np.testing.assert_allclose(
            input_statevector,
            example.expected_full_statevector,
            atol=1e-8,
        )

    reduced_stabs = reduced_case.get_reduced_stabilizers()
    expected_stabs = StabilizerList(example.expected_reduced_stabilizers)
    assert reduced_stabs == expected_stabs

    if example.expected_reduced_density_matrix is not None:
        reduced_dm = reduced_stabs.as_density_matrix()
        np.testing.assert_allclose(
            reduced_dm,
            example.expected_reduced_density_matrix,
            atol=1e-8,
        )

    if example.expected_reduced_state_distribution is not None:
        reduced_distribution = reduced_case.get_state_vector_distribution()
        expected_distribution = [
            TracedState(probability=p, state=s)
            for p, s in example.expected_reduced_state_distribution
        ]
        assert len(reduced_distribution) == len(expected_distribution)
        for got, expected in zip(reduced_distribution, expected_distribution):
            assert abs(got.probability - expected.probability) < 1e-8
            np.testing.assert_allclose(
                got.state,
                expected.state,
                atol=1e-8,
            )
