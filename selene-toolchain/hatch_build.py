"""Bundle the native tools and link inputs, independently of Selene releases."""

import json
import hashlib
import os
import platform
import shlex
import shutil
import subprocess
from pathlib import Path

from hatchling.builders.hooks.plugin.interface import BuildHookInterface
from packaging.tags import sys_tags


class ToolchainBuildHook(BuildHookInterface):
    def initialize(self, version: str, build_data: dict) -> None:
        if self.target_name != "wheel":
            return
        root = Path(self.root)
        dist = root / "python/selene_toolchain/_dist"
        if dist.exists():
            shutil.rmtree(dist)
        (dist / "bin").mkdir(parents=True)
        runtime = dist / "runtime"
        runtime.mkdir()
        hugrenv = Path(os.environ.get("HUGRENV_PATH", root.parent / ".hugrenv"))
        if not hugrenv.is_absolute():
            hugrenv = root / hugrenv
        system = platform.system()
        if system == "Windows":
            self._windows_llvm_runtime(hugrenv, dist)
        machine = platform.machine().lower()
        machine = {"amd64": "x86_64", "arm64": "aarch64"}.get(machine, machine)
        if machine not in ("x86_64", "aarch64"):
            raise RuntimeError(f"Unsupported architecture: {machine}")
        if system == "Windows" and machine != "x86_64":
            raise RuntimeError("Windows toolchain wheels currently require x86_64")
        tools = ["llc", "llvm-symbolizer"]
        tools += ["ld64.lld", "dsymutil"] if system == "Darwin" else ["ld.lld"]
        for tool in tools:
            name = tool + (".exe" if system == "Windows" else "")
            source = self._resolve(hugrenv / "bin" / name)
            if not source.is_file():
                raise RuntimeError(f"Hugrenv tool not found: {source}")
            # Resolve the symlink before copying, but keep the driver's name:
            # LLD chooses its command-line syntax from that name.
            shutil.copy2(source, dist / "bin" / name)

        self._build_inspector(root, hugrenv, dist, system)

        config = {
            "system": system,
            "machine": machine,
            "llvm": subprocess.check_output(
                [
                    str(dist / "bin" / ("llc.exe" if system == "Windows" else "llc")),
                    "--version",
                ],
                text=True,
            )
            .splitlines()[1]
            .strip(),
            "before": [],
            "after": [],
            "libraries": [],
        }
        if system == "Darwin":
            shutil.copy2(root / "vendor/darwin/libSystem.tbd", runtime)
        else:
            compiler = shlex.split(
                os.environ.get("CC", "gcc").replace("\\", "/")
                if system == "Windows"
                else os.environ.get("CC", "gcc")
            )
            if system == "Windows":
                # Use the same MinGW compiler for the inspector and the user's
                # startup and runtime files, matching hugrenv's LLVM build.
                triple = subprocess.check_output(
                    [*compiler, "-dumpmachine"], text=True
                ).strip()
                if "mingw" not in triple or not triple.startswith("x86_64"):
                    raise RuntimeError(f"Expected x86_64 MinGW GCC, found {triple}")
                self._windows_runtime(compiler, runtime, config)
            elif system == "Linux":
                self._linux_runtime(compiler, runtime, config)
            else:
                raise RuntimeError(f"Unsupported operating system: {system}")
            config["compiler"] = subprocess.check_output(
                [*compiler, "--version"], text=True
            ).splitlines()[0]
        (dist / "link.json").write_text(json.dumps(config, indent=2) + "\n")
        shutil.copytree(root / "vendor/licenses", dist / "licenses")
        shutil.copy2(root / "vendor/README.md", dist / "licenses/PROVENANCE.md")
        if system == "Linux":
            self._source_manifest(root, dist, machine)
        elif system == "Windows":
            self._windows_source_links(root, dist, compiler)

        build_data["pure_python"] = False
        tag = next(tag for tag in sys_tags() if tag.platform != "any")
        target_platform = tag.platform
        if system == "Darwin":
            from hatchling.builders.macos import process_macos_plat_tag

            target_platform = process_macos_plat_tag(target_platform, compat=False)
        build_data["tag"] = f"py3-none-{target_platform}"
        build_data["artifacts"] += [
            str(path.relative_to(root)) for path in dist.rglob("*") if path.is_file()
        ]
        build_data["artifacts"].append("python/selene_toolchain/py.typed")

    def _source_manifest(self, root: Path, dist: Path, machine: str) -> None:
        manifest_path = root / "source-bundles" / f"linux-{machine}.json"
        if not os.environ.get("CIBUILDWHEEL"):
            # A local Nix build uses different runtime files from a manylinux
            # release. We mustn't give it the release build's source links.
            return
        if not manifest_path.is_file():
            raise RuntimeError("Release wheels require matching runtime source links")
        manifest = json.loads(manifest_path.read_text())
        if (
            manifest["version"] != self.metadata.version
            or manifest["machine"] != machine
        ):
            raise RuntimeError("The runtime source manifest is for a different release")
        runtime = dist / "runtime"
        if set(manifest["inputs"]) != {path.name for path in runtime.iterdir()}:
            raise RuntimeError(
                "The runtime source manifest doesn't cover all link inputs"
            )
        for name, entry in manifest["inputs"].items():
            if (
                hashlib.sha256((runtime / name).read_bytes()).hexdigest()
                != entry["sha256"]
            ):
                raise RuntimeError(
                    f"Runtime sources don't match the copied input: {name}"
                )
            if entry["source"] not in manifest["sources"]:
                raise RuntimeError(f"Missing source reference for {name}")
        for name, entry in manifest["sources"].items():
            source = root / "source-bundles" / name
            if hashlib.sha256(source.read_bytes()).hexdigest() != entry["sha256"]:
                raise RuntimeError(f"Runtime source archive changed: {name}")
        shutil.copy2(manifest_path, dist / "sources.json")

    @staticmethod
    def _windows_source_links(root: Path, dist: Path, compiler: list[str]) -> None:
        links = json.loads((root / "vendor/windows-sources.json").read_text())
        actual = subprocess.check_output(
            [*compiler, "-dumpfullversion"], text=True
        ).strip()
        info = (
            Path(shutil.which(compiler[0]) or compiler[0]).resolve().parent.parent
            / "build-info.txt"
        )
        if (
            actual != links["compiler_version"]
            or not info.is_file()
            or hashlib.sha256(info.read_bytes()).hexdigest()
            != links["build_information_sha256"]
        ):
            if os.environ.get("CIBUILDWHEEL"):
                raise RuntimeError(
                    "Update the Windows runtime source links for this compiler build"
                )
            return
        # The CI compiler records its configure arguments and applied patches.
        # Keep that information with the links to GCC and the build recipes.
        shutil.copy2(info, dist / "licenses/MinGW-build-info.txt")
        (dist / "sources.json").write_text(json.dumps(links, indent=2) + "\n")

    @staticmethod
    def _windows_llvm_runtime(hugrenv: Path, dist: Path) -> None:
        compiler = shlex.split(os.environ.get("CC", "gcc").replace("\\", "/"))
        compiler_root = (
            Path(shutil.which(compiler[0]) or compiler[0]).resolve().parent.parent
        )
        compiler_info = compiler_root / "build-info.txt"
        llvm_info = hugrenv / "share/mingw/build-info.txt"
        if not llvm_info.is_file():
            raise RuntimeError("Windows requires hugrenv's win_mingw_amd64 LLVM build")
        if (
            not compiler_info.is_file()
            or compiler_info.read_bytes() != llvm_info.read_bytes()
        ):
            raise RuntimeError(
                "The MinGW compiler must match hugrenv's LLVM build information"
            )
        # These DLLs are needed when we run llc during the build, before wheel
        # repair can collect dependencies. They also serve the inspector.
        for name in ("libgcc_s_seh-1.dll", "libstdc++-6.dll", "libwinpthread-1.dll"):
            shutil.copy2(hugrenv / "bin" / name, dist / "bin" / name)

    @staticmethod
    def _build_inspector(root: Path, hugrenv: Path, dist: Path, system: str) -> None:
        # Devenv's hugrenv is a tree of absolute Nix-store symlinks. Inside
        # cibuildwheel we can reach their targets under /host, so resolve the
        # config file before asking CMake to load its neighbouring files.
        llvm_config = ToolchainBuildHook._resolve(
            hugrenv / "lib/cmake/llvm/LLVMConfig.cmake"
        )
        if not llvm_config.is_file():
            raise RuntimeError(
                f"Hugrenv LLVM CMake package not found: {llvm_config}. "
                "Check HUGRENV_PATH points to the LLVM development installation."
            )
        build = root / "_native-build"
        if build.exists():
            shutil.rmtree(build)
        command = [
            "cmake",
            "-S",
            str(root / "native"),
            "-B",
            str(build),
            f"-DLLVM_DIR={llvm_config.parent}",
            "-DCMAKE_BUILD_TYPE=Release",
        ]
        env = os.environ.copy()
        if system == "Windows":
            compilers = []
            for variable, fallback in (("CC", "gcc"), ("CXX", "g++")):
                compiler = shlex.split(env.get(variable, fallback).replace("\\", "/"))
                if len(compiler) != 1:
                    raise RuntimeError(
                        f"{variable} must name a MinGW compiler executable"
                    )
                compilers.append(
                    Path(shutil.which(compiler[0]) or compiler[0]).resolve()
                )
            if compilers[0].parent != compilers[1].parent:
                raise RuntimeError(
                    "CC and CXX must come from the same MinGW installation"
                )
            command += [
                "-G",
                "Ninja",
                f"-DCMAKE_C_COMPILER={compilers[0].as_posix()}",
                f"-DCMAKE_CXX_COMPILER={compilers[1].as_posix()}",
            ]
        elif system == "Darwin":
            command += ["-DCMAKE_OSX_DEPLOYMENT_TARGET=11.0"]
        subprocess.run(command, env=env, check=True)
        subprocess.run(
            ["cmake", "--build", str(build), "--config", "Release", "--parallel", "2"],
            env=env,
            check=True,
        )
        subprocess.run(
            [
                "cmake",
                "--install",
                str(build),
                "--config",
                "Release",
                "--prefix",
                str(dist),
            ],
            env=env,
            check=True,
        )

    @staticmethod
    def _resolve(path: Path) -> Path:
        seen = set()
        while path.is_symlink():
            if path in seen:
                raise RuntimeError(f"Symlink loop at {path}")
            seen.add(path)
            target = path.readlink()
            if target.is_absolute():
                if str(path).startswith("/host/"):
                    target = Path("/host") / target.relative_to("/")
                path = target
            else:
                path = path.parent / target
        return path

    @staticmethod
    def _compiler_file(compiler: list[str], name: str) -> Path:
        result = subprocess.check_output(
            [*compiler, f"-print-file-name={name}"], text=True
        ).strip()
        path = Path(result)
        if result == name or not path.is_file():
            raise RuntimeError(
                f"Build compiler cannot find required link input: {name}"
            )
        return path

    def _linux_runtime(self, compiler: list[str], runtime: Path, config: dict) -> None:
        config["before"] = ["Scrt1.o", "crti.o", "crtbeginS.o"]
        config["after"] = ["crtendS.o", "crtn.o"]
        # Use GCC's static helper libraries so the generated executable doesn't
        # acquire a dependency on a particular libgcc_s installation.
        config["libraries"] = ["-lc", "-lm", "-lgcc", "-lgcc_eh"]
        for name in [
            *config["before"],
            *config["after"],
            "libgcc.a",
            "libgcc_eh.a",
            "libc_nonshared.a",
        ]:
            shutil.copy2(self._compiler_file(compiler, name), runtime / name)

    def _windows_runtime(
        self, compiler: list[str], runtime: Path, config: dict
    ) -> None:
        config["before"] = ["crt2.o", "crtbegin.o"]
        config["after"] = ["crtend.o"]
        config["libraries"] = [
            "-lmingw32",
            "-lmingwex",
            "-lmoldname",
            "-lmsvcrt",
            "-ladvapi32",
            "-lshell32",
            "-luser32",
            "-lkernel32",
            "-lgcc",
            "-lgcc_eh",
        ]
        for name in [*config["before"], *config["after"]]:
            shutil.copy2(self._compiler_file(compiler, name), runtime / name)
        # The import libraries describe the Windows DLLs already supplied by
        # the OS. Include the MinGW library directory so plugins can also ask
        # for libraries such as userenv without a local MinGW installation.
        directories = {
            self._compiler_file(compiler, name).parent
            for name in ("libmingw32.a", "libgcc.a")
        }
        for directory in sorted(directories):
            for source in directory.glob("*.a"):
                destination = runtime / source.name
                if (
                    destination.exists()
                    and destination.read_bytes() != source.read_bytes()
                ):
                    raise RuntimeError(f"Conflicting MinGW link inputs: {source.name}")
                shutil.copy2(source, destination)
