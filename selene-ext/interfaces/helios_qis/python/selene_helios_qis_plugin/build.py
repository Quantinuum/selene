from selene_core.build_utils import (
    BuildCtx,
    Artifact,
    Step,
)
from selene_core.build_utils.builtins import (
    HUGREnvelopeBytesKind,
    HeliosLLVMIRStringKind,
    HeliosLLVMBitcodeStringKind,
)

try:
    from selene_hugr_qis_compiler import (
        compile_to_llvm_ir,
        compile_to_bitcode,
    )

    HAS_HUGR_QIS_COMPILER = True
except ImportError:
    HAS_HUGR_QIS_COMPILER = False


class SeleneCompileHUGRToLLVMIRStringStep(Step):
    """
    Convert a HUGR file to LLVM IR text (.ll)
    """

    input_kind = HUGREnvelopeBytesKind
    output_kind = HeliosLLVMIRStringKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        if "platform" in build_ctx.cfg and build_ctx.cfg["platform"] != "helios":
            return float("inf")

        if (
            "build_method" in build_ctx.cfg
            and build_ctx.cfg["build_method"] == "via-llvm-ir"
        ):
            return 98
        return 100

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        if build_ctx.verbose:
            print("Converting HUGR envelope bytes to LLVM IR string")
        if not HAS_HUGR_QIS_COMPILER:
            raise RuntimeError(
                "selene-hugr-qis-compiler with appropriate support for multiple QIS targets"
                " is required for building. Please install it via pip."
            )
        ir = compile_to_llvm_ir(input_artifact.resource, platform="helios")
        return cls._make_artifact(ir)


class SeleneCompileHUGRToLLVMBitcodeStringStep(Step):
    """
    Convert a HUGR file to LLVM Bitcode (.bc)
    """

    input_kind = HUGREnvelopeBytesKind
    output_kind = HeliosLLVMBitcodeStringKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        if "platform" in build_ctx.cfg and build_ctx.cfg["platform"] != "helios":
            return float("inf")

        if (
            "build_method" in build_ctx.cfg
            and build_ctx.cfg["build_method"] == "via-llvm-bitcode"
        ):
            return 98
        return 99  # weakly preferred over IR string

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        if build_ctx.verbose:
            print("Converting HUGR envelope bytes to LLVM Bitcode")
        if not HAS_HUGR_QIS_COMPILER:
            raise RuntimeError(
                "selene-hugr-qis-compiler with appropriate support for multiple QIS targets"
                " is required for building. Please install it via pip."
            )
        bitcode = compile_to_bitcode(input_artifact.resource, platform="helios")
        return cls._make_artifact(bitcode)
