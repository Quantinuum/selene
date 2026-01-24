import pytest
from dataclasses import dataclass
from selene_stim_plugin.state import Tableau


@dataclass
class ReductionExample:
    stabilizer_strings: list[str]
    specified_qubits: list[int]
    final_stabilizer_strings: list[str]


EXAMPLES = [
    ReductionExample(
        # (|0000> + |1111>)/sqrt(2)
        stabilizer_strings=["+XXXX", "+ZZ__", "+_ZZ_", "+__ZZ"],
        specified_qubits=[1, 3],
        final_stabilizer_strings=["+ZZ"],
    ),
    ReductionExample(
        # (|++++> - |---->)/sqrt(2)
        stabilizer_strings=["-ZZZZ", "+XX__", "+_XX_", "+__XX"],
        specified_qubits=[1, 3],
        final_stabilizer_strings=[
            "+XX",
        ],
    ),
    ReductionExample(
        # (|+01> - |-10>)/sqrt(2) \otimes |->
        stabilizer_strings=[
            "-___X",
            "-ZXX_",
            "+XZ__",
            "-_ZZ_",
        ],
        specified_qubits=[1, 2],
        final_stabilizer_strings=[
            "-ZZ",
        ],
    ),
    ReductionExample(
        # (|+0> - |-1>)/sqrt(2) \otimes |0->
        stabilizer_strings=[
            "-___X",
            "+__Z_",
            "-ZX__",
            "+XZ__",
        ],
        specified_qubits=[0, 1],
        final_stabilizer_strings=[
            "-ZX",
            "+XZ",
        ],
    ),
    ReductionExample(
        # Same as above, but with a different specified qubit order
        stabilizer_strings=[
            "-___X",
            "+__Z_",
            "-ZX__",
            "+XZ__",
        ],
        specified_qubits=[1, 0],
        final_stabilizer_strings=[
            "-XZ",
            "+ZX",
        ],
    ),
]


@pytest.mark.parametrize("example", EXAMPLES)
def test_stabilizer_reduction(example: ReductionExample):
    tab = Tableau(example.stabilizer_strings)
    tab.reduced_to_specified(example.specified_qubits)
    final_tab = Tableau(example.final_stabilizer_strings)
    assert tab == final_tab
