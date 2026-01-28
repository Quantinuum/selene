from pathlib import Path
from typing import Any

from .helios import HeliosLLVMBitcodeStringKind
from ..planner import BuildPlanner
from ..types import ArtifactKind, Step, BuildCtx, Artifact

from qir_qis import qir_ll_to_bc, qir_to_qis, validate_qir

QIR_MATCHES = [
    "__quantum__qis",
    "__quantum__rt",
    "entry_point",
]


class QIRIRFileKind(ArtifactKind):
    priority = 2000

    @classmethod
    def matches(cls, resource: Any) -> bool:
        if not isinstance(resource, Path):
            return False
        if not resource.is_file():
            return False
        if resource.suffix != ".ll":
            return False
        contents = resource.read_text()
        return any(match in contents for match in QIR_MATCHES)


class QIRIRStringKind(ArtifactKind):
    priority = 2000

    @classmethod
    def matches(cls, resource: Any) -> bool:
        if hasattr(resource, "ir"):
            resource = resource.ir
        if not isinstance(resource, str):
            return False
        return any(match in resource for match in QIR_MATCHES)


class QIRBitcodeFileKind(ArtifactKind):
    priority = 2000

    @classmethod
    def matches(cls, resource: Any) -> bool:
        if not isinstance(resource, Path):
            return False
        if not resource.is_file():
            return False
        if resource.suffix != ".bc":
            return False
        contents = resource.read_bytes()
        return any(match.encode("utf-8") in contents for match in QIR_MATCHES)


class QIRBitcodeStringKind(ArtifactKind):
    priority = 2000

    @classmethod
    def matches(cls, resource: Any) -> bool:
        if hasattr(resource, "bitcode"):
            resource = resource.bitcode
        if not isinstance(resource, bytes):
            return False
        magic_numbers = [
            b"BC\xc0\xde",  # modern bitcode stream, observed on linux and windows runs
            b"\xde\xc0\x17\x0b",  # legacy bitcode wrapper, observed on macOS runs
        ]
        if not any(resource.startswith(magic) for magic in magic_numbers):
            return False
        return any(match.encode("utf-8") in resource for match in QIR_MATCHES)


class QIRIRStringToQIRIRFileStep(Step):
    """
    Convert a QIR IR string to a file (by writing the text)
    """

    input_kind = QIRIRStringKind
    output_kind = QIRIRFileKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        return 100

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        out_path = build_ctx.artifact_dir / "input.ll"
        out_path.write_text(input_artifact.resource)
        return cls._make_artifact(out_path)


class QIRIRFileToQIRIRStringStep(Step):
    """
    Convert a QIR IR file to a string (by reading the text)
    """

    input_kind = QIRIRFileKind
    output_kind = QIRIRStringKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        return 100

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        contents = input_artifact.resource.read_text()
        return cls._make_artifact(contents)


class QIRBitcodeStringToQIRBitcodeFileStep(Step):
    """
    Convert a QIR bitcode string to a file (by writing the bytes)
    """

    input_kind = QIRBitcodeStringKind
    output_kind = QIRBitcodeFileKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        return 100

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        out_path = build_ctx.artifact_dir / "input.bc"
        out_path.write_bytes(input_artifact.resource)
        return cls._make_artifact(out_path)


class QIRBitcodeFileToQIRBitcodeStringStep(Step):
    """
    Convert a QIR bitcode file to a string (by reading the bytes)
    """

    input_kind = QIRBitcodeFileKind
    output_kind = QIRBitcodeStringKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        return 100

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        contents = input_artifact.resource.read_bytes()
        return cls._make_artifact(contents)


class QIRIRFileToQIRBitcodeFileStep(Step):
    """
    Convert a QIR IR file to a string (by reading the text)
    """

    input_kind = QIRIRFileKind
    output_kind = QIRBitcodeFileKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        return 100

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        result = qir_ll_to_bc(input_artifact.resource.read_text())
        out_path = build_ctx.artifact_dir / "input.bc"
        out_path.write_bytes(result)
        return cls._make_artifact(out_path)


class QIRBitcodeStringToHeliosBitcodeStringStep(Step):
    """
    Convert a QIR bitcode string to a Helios bitcode string.
    """

    input_kind = QIRBitcodeStringKind
    output_kind = HeliosLLVMBitcodeStringKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        return 100

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        validate_qir(input_artifact.resource)
        result = qir_to_qis(input_artifact.resource)
        return cls._make_artifact(result)


def register_qir_builtins(planner: BuildPlanner) -> None:
    """
    Register the QIR kinds and steps with the given build planner.
    """
    planner.add_kind(QIRIRFileKind)
    planner.add_kind(QIRIRStringKind)
    planner.add_kind(QIRBitcodeFileKind)
    planner.add_kind(QIRBitcodeStringKind)

    planner.add_step(QIRIRStringToQIRIRFileStep)
    planner.add_step(QIRIRFileToQIRIRStringStep)
    planner.add_step(QIRBitcodeStringToQIRBitcodeFileStep)
    planner.add_step(QIRBitcodeFileToQIRBitcodeStringStep)
    planner.add_step(QIRIRFileToQIRBitcodeFileStep)
    planner.add_step(QIRBitcodeFileToQIRBitcodeStringStep)
    planner.add_step(QIRBitcodeStringToHeliosBitcodeStringStep)
