from __future__ import annotations

import platform
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from selene_core import BuildPlanner, QuantumInterface
from selene_core.build_utils import Artifact, ArtifactKind, BuildCtx, Step
from selene_core.build_utils.builtins import SeleneObjectFileKind
from selene_core.build_utils.utils import invoke_zig

from .plugins import _dist_root, _source_root


class CliffordTCSourceKind(ArtifactKind[Path]):
    priority = 10_000

    @classmethod
    def matches(cls, resource: Any) -> bool:
        return (
            isinstance(resource, Path)
            and resource.is_file()
            and resource.suffixes[-2:]
            == [
                ".ct",
                ".c",
            ]
        )


class CliffordTCToSeleneObjectStep(Step):
    input_kind = CliffordTCSourceKind
    output_kind = SeleneObjectFileKind

    @classmethod
    def apply(
        cls, build_ctx: BuildCtx, input_artifact: Artifact[Path]
    ) -> Artifact[Path]:
        source_root = _source_root()
        dist_root = _dist_root()
        include_root = (
            source_root / "c" / "include" if source_root else dist_root / "include"
        )
        shim_source = (
            source_root / "c" / "src" / "clifford_t_interface.c"
            if source_root
            else dist_root / "src" / "clifford_t_interface.c"
        )
        object_suffix = ".obj" if platform.system() == "Windows" else ".o"
        user_obj = build_ctx.artifact_dir / f"user_program{object_suffix}"
        interface_obj = build_ctx.artifact_dir / f"clifford_t_interface{object_suffix}"
        out_path = build_ctx.artifact_dir / f"program.clifford_t{object_suffix}"
        cache_dir = build_ctx.artifact_dir / "zig-cache"
        cache_dir.mkdir(exist_ok=True)

        include_dirs = [include_root]
        if source_root is not None:
            repo_root = source_root.parents[1]
            include_dirs.extend(
                [
                    repo_root / "selene-sim" / "c" / "include",
                    repo_root / "selene-core" / "c" / "include",
                ]
            )
        try:
            import selene_sim

            include_dirs.append(
                Path(selene_sim.__file__).resolve().parent / "_dist" / "include"
            )
        except ImportError:
            pass
        try:
            import selene_core

            include_dirs.append(
                Path(selene_core.__file__).resolve().parent / "_dist" / "include"
            )
        except ImportError:
            pass
        include_flags = [
            flag for include_dir in include_dirs for flag in ("-I", include_dir)
        ]

        common_flags = [
            "-std=c11",
            "-fPIC",
            *include_flags,
        ]

        invoke_zig(
            "cc",
            "-c",
            input_artifact.resource,
            "-o",
            user_obj,
            *common_flags,
            verbose=build_ctx.verbose,
            cache_dir=cache_dir,
        )
        invoke_zig(
            "cc",
            "-c",
            shim_source,
            "-o",
            interface_obj,
            *common_flags,
            verbose=build_ctx.verbose,
            cache_dir=cache_dir,
        )
        invoke_zig(
            "cc",
            "-r",
            "-o",
            out_path,
            user_obj,
            interface_obj,
            verbose=build_ctx.verbose,
            cache_dir=cache_dir,
        )
        return cls._make_artifact(out_path)


@dataclass
class CliffordTInterface(QuantumInterface):
    @property
    def library_file(self) -> Path:
        source_root = _source_root()
        if source_root is not None:
            return source_root / "c" / "src" / "clifford_t_interface.c"
        return _dist_root() / "src" / "clifford_t_interface.c"

    def register_build_steps(self, planner: BuildPlanner) -> None:
        planner.add_kind(CliffordTCSourceKind)
        planner.add_step(CliffordTCToSeleneObjectStep)
