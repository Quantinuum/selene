import pytest
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

    class _StubQirQis:
        @staticmethod
        def get_entry_attributes(_: bytes) -> dict[str, None]:
            return {"entry_point": None}

    monkeypatch.setattr(
        "selene_core.build_utils.builtins.qir._load_qir_qis",
        lambda: _StubQirQis(),
    )

    assert not QIRBitcodeStringKind.matches(qis_bc)
    assert DEFAULT_BUILD_PLANNER.identify_kind(qis_bc) is HeliosLLVMBitcodeStringKind


def test_missing_qir_qis_surfaces_optional_dependency_error(monkeypatch):
    qir_bc = qir_ll_to_bc(LLVM_IR)

    monkeypatch.setattr(
        "selene_core.build_utils.builtins.qir._load_qir_qis",
        lambda: (_ for _ in ()).throw(
            ModuleNotFoundError(
                "QIR support requires the optional `qir-qis` dependency.",
                name="qir_qis",
            )
        ),
    )

    with pytest.raises(ModuleNotFoundError) as exc:
        DEFAULT_BUILD_PLANNER.identify_kind(qir_bc)

    assert exc.value.name == "qir_qis"
