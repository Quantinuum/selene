from qir_qis import qir_ll_to_bc, qir_to_qis

from selene_core.build_utils import DEFAULT_BUILD_PLANNER
from selene_core.build_utils.builtins.helios import HeliosLLVMBitcodeStringKind
from selene_core.build_utils.builtins.qir import QIRBitcodeStringKind


LLVM_IR = """
%Qubit = type opaque
%Result = type opaque

define void @ENTRYPOINT__main() #0 {
entry:
  ret void
}

attributes #0 = { "entry_point" "output_labeling_schema"="schema_id" "required_num_qubits"="1" "required_num_results"="1" "qir_profiles"="adaptive_profile" }
"""


def test_qir_bitcode_is_classified_as_qir():
    qir_bc = qir_ll_to_bc(LLVM_IR)

    assert QIRBitcodeStringKind.matches(qir_bc)
    assert DEFAULT_BUILD_PLANNER.identify_kind(qir_bc) is QIRBitcodeStringKind


def test_translated_qis_bitcode_is_classified_as_helios():
    qis_bc = qir_to_qis(qir_ll_to_bc(LLVM_IR))

    assert not QIRBitcodeStringKind.matches(qis_bc)
    assert HeliosLLVMBitcodeStringKind.matches(qis_bc)
    assert DEFAULT_BUILD_PLANNER.identify_kind(qis_bc) is HeliosLLVMBitcodeStringKind


def test_helios_shape_wins_even_if_stale_qir_entrypoint_metadata_remains(monkeypatch):
    qis_bc = qir_to_qis(qir_ll_to_bc(LLVM_IR))

    monkeypatch.setattr(
        "selene_core.build_utils.builtins.qir.get_entry_attributes",
        lambda _: {"entry_point": None},
    )

    assert not QIRBitcodeStringKind.matches(qis_bc)
    assert DEFAULT_BUILD_PLANNER.identify_kind(qis_bc) is HeliosLLVMBitcodeStringKind
