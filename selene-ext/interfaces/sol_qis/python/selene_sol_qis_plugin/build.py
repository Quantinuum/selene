from selene_core.build_utils import (
    BuildCtx,
    Artifact,
    Step,
)
from selene_core.build_utils.builtins import (
    HUGREnvelopeBytesKind,
    SolLLVMIRStringKind,
    SolLLVMBitcodeStringKind,
)

from selene_hugr_qis_compiler import (
    compile_to_llvm_ir,
    compile_to_bitcode,
)

# Steps


class SeleneCompileHUGRToLLVMIRStringStep(Step):
    """
    Convert a HUGR file to LLVM IR text (.ll)
    """

    input_kind = HUGREnvelopeBytesKind
    output_kind = SolLLVMIRStringKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        if "platform" in build_ctx.cfg and build_ctx.cfg["platform"] != "sol":
            return float("inf")

        if (
            "build_method" in build_ctx.cfg
            and build_ctx.cfg["build_method"] == "via-llvm-ir"
        ):
            return 101
        return 103

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        if build_ctx.verbose:
            print("Converting HUGR envelope bytes to LLVM IR string")
        ir = compile_to_llvm_ir(input_artifact.resource, platform="sol")
        return cls._make_artifact(ir)


class SeleneCompileHUGRToLLVMBitcodeStringStep(Step):
    """
    Convert a HUGR file to LLVM Bitcode (.bc)
    """

    input_kind = HUGREnvelopeBytesKind
    output_kind = SolLLVMBitcodeStringKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        if "platform" in build_ctx.cfg and build_ctx.cfg["platform"] != "sol":
            return float("inf")

        if (
            "build_method" in build_ctx.cfg
            and build_ctx.cfg["build_method"] == "via-llvm-bitcode"
        ):
            return 101
        return 102  # weakly preferred over IR string

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        if build_ctx.verbose:
            print("Converting HUGR envelope bytes to LLVM Bitcode")
        bitcode = compile_to_bitcode(input_artifact.resource, platform="sol")
        return cls._make_artifact(bitcode)
