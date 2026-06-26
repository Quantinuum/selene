import os
import shutil
import subprocess
import sys
from pathlib import Path

from hatchling.builders.hooks.plugin.interface import BuildHookInterface
from packaging.tags import sys_tags


class CliffordTExampleBuildHook(BuildHookInterface):
    package_dir = Path("python/selene_example_clifford_t_stack")
    qrack_build_dir = Path("target/qrack-simulator-release")

    def get_cargo_release_dir(self) -> Path:
        target = os.environ.get("CARGO_BUILD_TARGET")
        if target:
            candidate = Path(self.root) / "target" / target / "release"
            if candidate.exists():
                return candidate
        return Path(self.root) / "target" / "release"

    def rust_library_filenames(self) -> list[str]:
        lib_name = "selene_example_clifford_t_stack"
        match sys.platform:
            case "darwin":
                return [f"lib{lib_name}.dylib"]
            case "linux":
                return [f"lib{lib_name}.so"]
            case "win32":
                return [f"{lib_name}.dll", f"lib{lib_name}.dll.a"]
            case _:
                raise RuntimeError(f"Unsupported platform: {sys.platform}")

    def qrack_library_filename(self) -> str:
        lib_name = "selene_example_clifford_t_qrack"
        match sys.platform:
            case "darwin":
                return f"lib{lib_name}.dylib"
            case "linux":
                return f"lib{lib_name}.so"
            case "win32":
                return f"{lib_name}.dll"
            case _:
                raise RuntimeError(f"Unsupported platform: {sys.platform}")

    def build_cargo_library(self) -> None:
        self.app.display_mini_header("Building Clifford+T example library")
        try:
            subprocess.run(
                [
                    "cargo",
                    "build",
                    "--manifest-path",
                    str(Path(self.root) / "Cargo.toml"),
                    "--release",
                    "--locked",
                ],
                cwd=self.root,
                check=True,
                capture_output=True,
            )
        except subprocess.CalledProcessError as error:
            self.app.display_error(error.stderr.decode())
            raise

    def build_qrack_simulator(self) -> None:
        self.app.display_mini_header("Building Qrack Clifford+T simulator")
        build_dir = Path(self.root) / self.qrack_build_dir
        build_dir.mkdir(parents=True, exist_ok=True)
        env = os.environ.copy()
        try:
            subprocess.run(
                [
                    "cmake",
                    "-S",
                    str(Path(self.root) / "cpp"),
                    "-B",
                    str(build_dir),
                    "-DCMAKE_BUILD_TYPE=Release",
                ],
                cwd=self.root,
                env=env,
                check=True,
                capture_output=True,
            )
            subprocess.run(
                [
                    "cmake",
                    "--build",
                    str(build_dir),
                    "--config",
                    "Release",
                    "--target",
                    "selene_example_clifford_t_qrack",
                    "--parallel",
                ],
                cwd=self.root,
                env=env,
                check=True,
                capture_output=True,
            )
        except FileNotFoundError as error:
            raise RuntimeError(
                "Building the Qrack simulator requires CMake and a C++ compiler "
                "from the devenv shell."
            ) from error
        except subprocess.CalledProcessError as error:
            self.app.display_error(error.stdout.decode())
            self.app.display_error(error.stderr.decode())
            raise

    def copy_tree_contents(self, source: Path, destination: Path) -> None:
        if destination.exists():
            shutil.rmtree(destination)
        shutil.copytree(source, destination)

    def collect_dist(self) -> list[str]:
        package_root = Path(self.root) / self.package_dir
        dist_dir = package_root / "_dist"
        if dist_dir.exists():
            shutil.rmtree(dist_dir)

        lib_dir = dist_dir / "lib"
        lib_dir.mkdir(parents=True)
        release_dir = self.get_cargo_release_dir()
        for filename in self.rust_library_filenames():
            source = release_dir / filename
            if not source.exists():
                raise FileNotFoundError(
                    f"Compiled library {source} not found after cargo build"
                )
            self.app.display_info(f"Copying {source} to {lib_dir}")
            shutil.copy(source, lib_dir / filename)

        qrack_library = (
            Path(self.root) / self.qrack_build_dir / self.qrack_library_filename()
        )
        if not qrack_library.exists():
            raise FileNotFoundError(
                f"Compiled Qrack simulator {qrack_library} not found after CMake build"
            )
        self.app.display_info(f"Copying {qrack_library} to {lib_dir}")
        shutil.copy(qrack_library, lib_dir / qrack_library.name)

        self.copy_tree_contents(Path(self.root) / "c" / "include", dist_dir / "include")
        self.copy_tree_contents(Path(self.root) / "c" / "src", dist_dir / "src")

        return [
            str(path.relative_to(self.root).as_posix())
            for path in dist_dir.rglob("*")
            if path.is_file()
        ]

    def initialize(self, version: str, build_data: dict) -> None:
        self.build_cargo_library()
        self.build_qrack_simulator()
        artifacts = self.collect_dist()
        build_data["artifacts"] += artifacts
        build_data["pure_python"] = False

        tag = next(
            iter(
                tag
                for tag in sys_tags()
                if "manylinux" not in tag.platform and "musllinux" not in tag.platform
            )
        )
        build_data["tag"] = f"py3-none-{tag.platform}"
