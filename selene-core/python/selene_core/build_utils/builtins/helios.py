from pathlib import Path
import platform
from typing import Any
from ..types import (
    ArtifactKind,
    BuildCtx,
    Artifact,
    Step,
)
from ..utils import invoke_zig
from ..symbols import get_symbols_from_object, get_symbols_from_llvm, SymbolTable
from ..planner import BuildPlanner

from .selene import SeleneExecutableKind


def _match_helios_qis(symbol_table: SymbolTable) -> bool:
    # all programs targeting helios start with a setup call
    if not symbol_table.has_defined_function("qmain"):
        return False
    if not symbol_table.has_undefined_function("setup"):
        return False
    # These are functions for a different platform to Helios
    if any(
        symbol_table.has_undefined_function(f)
        for f in ("___rpp", "___rp", "___rxxyyzz")
    ):
        return False
    # otherwise we may assume this targets helios, for now.
    # Ideally QIS will gain a platform identifier so we can
    # be more confident.
    return True


class HeliosLLVMIRStringKind(ArtifactKind):
    @classmethod
    def matches(cls, resource: Any) -> bool:
        if not isinstance(resource, str):
            return False
        symbols = get_symbols_from_llvm(resource)
        if not _match_helios_qis(symbols):
            return False
        return True


class HeliosLLVMIRFileKind(ArtifactKind):
    @classmethod
    def matches(cls, resource: Any) -> bool:
        if not isinstance(resource, Path):
            return False
        if not resource.is_file():
            return False
        if resource.suffix != ".ll":
            return False
        symbols = get_symbols_from_llvm(resource)
        if not _match_helios_qis(symbols):
            return False
        return True


class HeliosLLVMBitcodeStringKind(ArtifactKind):
    @classmethod
    def matches(cls, resource: Any) -> bool:
        # we accept normal bytes, and also a BitcodeWrapper type that has a bitcode attribute
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
        symbols = get_symbols_from_llvm(resource)
        if not _match_helios_qis(symbols):
            return False
        return True


class HeliosLLVMBitcodeFileKind(ArtifactKind):
    @classmethod
    def matches(cls, resource: Any) -> bool:
        if not isinstance(resource, Path):
            return False
        if not resource.is_file():
            return False
        if resource.suffix != ".bc":
            return False
        content = resource.read_bytes()
        magic_numbers = [
            b"BC\xc0\xde",  # modern bitcode stream, observed on linux and windows runs
            b"\xde\xc0\x17\x0b",  # legacy bitcode wrapper, observed on macOS runs
        ]
        if not any(content.startswith(magic) for magic in magic_numbers):
            return False
        symbols = get_symbols_from_llvm(content)
        if not _match_helios_qis(symbols):
            return False
        return True


class HeliosObjectFileKind(ArtifactKind):
    @classmethod
    def matches(cls, resource: Any) -> bool:
        if not isinstance(resource, Path):
            return False
        if resource.suffix not in [".o", ".obj"]:
            return False
        try:
            symbols = get_symbols_from_object(resource)
        except Exception:
            # unable to parse object file
            return False
        if not _match_helios_qis(symbols):
            return False
        return True


class HeliosObjectStringKind(ArtifactKind):
    @classmethod
    def matches(cls, resource: Any) -> bool:
        if not isinstance(resource, bytes):
            return False
        magic_numbers = [
            b"\x7fELF",  # ELF
            b"MZ",  # PE
            b"\xcf\xfa\xed\xfe",  # Mach-O Little Endian 64-bit
            b"\x64\x86",  # COFF for AMD64
        ]
        if not any(resource.startswith(magic) for magic in magic_numbers):
            return False
        try:
            symbols = get_symbols_from_object(resource)
        except RuntimeError:
            # unable to parse object file
            return False
        if not _match_helios_qis(symbols):
            return False
        return True


# Steps


class LLVMBitcodeStringToLLVMBitcodeFileStep(Step):
    """
    Convert a bitcode string to a file (by writing the bytes)
    """

    input_kind = HeliosLLVMBitcodeStringKind
    output_kind = HeliosLLVMBitcodeFileKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        return 100

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        out_path = build_ctx.artifact_dir / "program.helios.bc"
        if build_ctx.verbose:
            print(f"Writing LLVM bitcode file: {out_path}")
        bitcode = input_artifact.resource
        if hasattr(bitcode, "bitcode"):  # handle wrapper types
            bitcode = bitcode.bitcode
        out_path.write_bytes(bitcode)
        return cls._make_artifact(out_path)


class LLVMIRStringToLLVMIRFileStep(Step):
    """
    Convert a LLVM IR string to a file (by writing the text)
    """

    input_kind = HeliosLLVMIRStringKind
    output_kind = HeliosLLVMIRFileKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        return 100

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        out_path = build_ctx.artifact_dir / "program.helios.ll"
        if build_ctx.verbose:
            print(f"Writing LLVM IR file: {out_path}")
        out_path.write_text(input_artifact.resource)
        return cls._make_artifact(out_path)


class HeliosLLVMIRFileToHeliosObjectFileStep(Step):
    """
    Convert LLVM IR text (.ll) to a Helios object file (.o)
    """

    input_kind = HeliosLLVMIRFileKind
    output_kind = HeliosObjectFileKind

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        out_path = build_ctx.artifact_dir / "program.helios.o"
        if build_ctx.verbose:
            print(f"Compiling LLVM IR to Helios-QIS object: {out_path}")
        zig_cache_dir = build_ctx.artifact_dir / "zig-cache"
        zig_cache_dir.mkdir(exist_ok=True)
        invoke_zig(
            "cc",
            "-c",
            input_artifact.resource,
            "-o",
            out_path,
            verbose=build_ctx.verbose,
            cache_dir=zig_cache_dir,
        )
        return cls._make_artifact(out_path)


class HeliosLLVMBitcodeFileToHeliosObjectFileStep(Step):
    """
    Convert LLVM Bitcode (.bc) to a Helios object file (.o)
    """

    input_kind = HeliosLLVMBitcodeFileKind
    output_kind = HeliosObjectFileKind

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        out_path = build_ctx.artifact_dir / "program.helios.o"
        if build_ctx.verbose:
            print(f"Compiling LLVM Bitcode to Helios-QIS object: {out_path}")
        zig_cache_dir = build_ctx.artifact_dir / "zig-cache"
        zig_cache_dir.mkdir(exist_ok=True)
        invoke_zig(
            "cc",
            "-c",
            input_artifact.resource,
            "-o",
            out_path,
            cache_dir=zig_cache_dir,
        )
        return cls._make_artifact(out_path)


class HeliosObjectStringToHeliosObjectFileStep(Step):
    """
    Convert Helios object bytes to a Helios object file (.o)
    """

    input_kind = HeliosObjectStringKind
    output_kind = HeliosObjectFileKind

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        out_path = build_ctx.artifact_dir / "program.helios.o"
        if build_ctx.verbose:
            print(f"Writing Helios object file: {out_path}")
        out_path.write_bytes(input_artifact.resource)
        return cls._make_artifact(out_path)


class HeliosObjectFileToHeliosObjectStringStep(Step):
    """
    Convert Helios object file (.o) to Helios object bytes
    """

    input_kind = HeliosObjectFileKind
    output_kind = HeliosObjectStringKind

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:
        if build_ctx.verbose:
            print(f"Reading Helios object file: {input_artifact.resource}")
        content = input_artifact.resource.read_bytes()
        return cls._make_artifact(content)


class HeliosObjectFileToSeleneExecutableStep(Step):
    """
    Link helios object with the shared Helios runtime and any shared utilities.
    """

    input_kind = HeliosObjectFileKind
    output_kind = SeleneExecutableKind

    @classmethod
    def get_cost(cls, build_ctx: BuildCtx) -> float:
        return 90

    @classmethod
    def apply(cls, build_ctx: BuildCtx, input_artifact: Artifact) -> Artifact:

        match platform.system():
            case "Linux":
                executable_filename = "program.selene.x"
            case "Darwin":
                executable_filename = "program.selene.x"
            case "Windows":
                executable_filename = "program.selene.exe"
            case _:
                raise RuntimeError(f"Unsupported OS: {platform.system()}")
        out_path = build_ctx.artifact_dir / executable_filename
        if build_ctx.verbose:
            print("Linking helios object file with shared Helios runtime")

        link_flags = ["-lc"]
        try:
            from selene_sim import dist_dir as selene_dist
        except ImportError:
            raise ImportError(
                "Selene simulation library not found. Please install selene_sim."
            )
        selene_lib_dir = selene_dist / "lib"
        library_search_dirs = [selene_lib_dir]
        libraries = []

        for dep in build_ctx.deps:
            link_flags.extend(dep.link_flags)
            library_search_dirs.extend(dep.library_search_dirs)
            libraries.append(dep.path)

        for search_dir in library_search_dirs:
            link_flags.append(f"-L{search_dir}")

        zig_cache_dir = build_ctx.artifact_dir / "zig-cache"
        zig_cache_dir.mkdir(exist_ok=True)
        invoke_zig(
            "build-exe",
            f"-femit-bin={out_path}",
            input_artifact.resource,
            *libraries,
            *link_flags,
            verbose=build_ctx.verbose,
            cache_dir=zig_cache_dir,
        )
        return Artifact(
            out_path,
            SeleneExecutableKind,
            metadata={"library_search_dirs": library_search_dirs},
        )


def register_helios_builtins(planner: BuildPlanner) -> None:
    planner.add_kind(HeliosLLVMIRStringKind)
    planner.add_kind(HeliosLLVMIRFileKind)
    planner.add_kind(HeliosLLVMBitcodeStringKind)
    planner.add_kind(HeliosLLVMBitcodeFileKind)
    planner.add_kind(HeliosObjectFileKind)
    planner.add_kind(HeliosObjectStringKind)
    planner.add_step(LLVMBitcodeStringToLLVMBitcodeFileStep)
    planner.add_step(LLVMIRStringToLLVMIRFileStep)
    planner.add_step(HeliosLLVMIRFileToHeliosObjectFileStep)
    planner.add_step(HeliosLLVMBitcodeFileToHeliosObjectFileStep)
    planner.add_step(HeliosObjectStringToHeliosObjectFileStep)
    planner.add_step(HeliosObjectFileToHeliosObjectStringStep)
    planner.add_step(HeliosObjectFileToSeleneExecutableStep)
