"""Bundle the native tools and link inputs, independently of Selene releases."""

import json
import hashlib
import os
import platform
import shlex
import shutil
import subprocess
import sys
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
        hugrenv = Path(
            os.environ.get("SELENE_TOOLCHAIN_LLVM_PREFIX")
            or os.environ.get("HUGRENV_PATH")
            or root.parent / ".hugrenv"
        )
        if not hugrenv.is_absolute():
            hugrenv = root / hugrenv
        elif (
            not hugrenv.exists() and (Path("/host") / hugrenv.relative_to("/")).is_dir()
        ):
            hugrenv = Path("/host") / hugrenv.relative_to("/")
        system = platform.system()
        if system == "Windows":
            self._windows_llvm_runtime(hugrenv, dist)
        machine = platform.machine().lower()
        machine = {"amd64": "x86_64", "arm64": "aarch64"}.get(machine, machine)
        if machine not in ("x86_64", "aarch64"):
            raise RuntimeError(f"Unsupported architecture: {machine}")
        if system == "Windows" and machine != "x86_64":
            raise RuntimeError("Windows toolchain wheels currently require x86_64")
        tools = ["llvm-symbolizer"]
        if system == "Darwin":
            tools.append("dsymutil")
        for tool in tools:
            name = tool + (".exe" if system == "Windows" else "")
            source = self._resolve(hugrenv / "bin" / name)
            if not source.is_file():
                raise RuntimeError(f"LLVM tool not found: {source}")
            shutil.copy2(source, dist / "bin" / name)

        self._build_rust(root, system, hugrenv)

        llvm_version = subprocess.check_output(
            [
                str(
                    self._resolve(
                        hugrenv
                        / "bin"
                        / ("llvm-config.exe" if system == "Windows" else "llvm-config")
                    )
                ),
                "--version",
            ],
            text=True,
        ).strip()

        config: dict = {
            "system": system,
            "machine": machine,
            "llvm": llvm_version,
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
        self._rust_licenses(root, dist)
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
        build_data["tag"] = f"cp310-abi3-{target_platform}"
        build_data["artifacts"] += [
            str(path.relative_to(root)) for path in dist.rglob("*") if path.is_file()
        ]
        build_data["artifacts"].append("python/selene_toolchain/py.typed")
        build_data["artifacts"] += [
            str(path.relative_to(root))
            for path in (root / "python/selene_toolchain").glob("_native.*")
            if path.suffix in (".so", ".pyd")
        ]

    @staticmethod
    def _rust_licenses(root: Path, dist: Path) -> None:
        metadata = json.loads(
            subprocess.check_output(
                [
                    "cargo",
                    "metadata",
                    "--manifest-path",
                    str(root / "rust/Cargo.toml"),
                    "--features",
                    "python",
                    "--format-version",
                    "1",
                    "--locked",
                ],
                cwd=root.parent,
                text=True,
            )
        )
        packages = {package["id"]: package for package in metadata["packages"]}
        nodes = {node["id"]: node for node in metadata["resolve"]["nodes"]}
        start = next(
            key
            for key, package in packages.items()
            if package["name"] == "selene-toolchain"
        )
        pending, visited, notices = [start], set(), []
        while pending:
            key = pending.pop()
            if key in visited:
                continue
            visited.add(key)
            pending.extend(dependency["pkg"] for dependency in nodes[key]["deps"])
            package = packages[key]
            if key == start:
                continue
            source = Path(package["manifest_path"]).parent
            destination = (
                dist / "licenses/rust" / f"{package['name']}-{package['version']}"
            )
            destination.mkdir(parents=True, exist_ok=True)
            for path in source.iterdir():
                if path.is_file() and path.name.upper().startswith(
                    ("LICENSE", "LICENCE", "NOTICE", "COPYRIGHT")
                ):
                    shutil.copy2(path, destination / path.name)
            notices.append(
                {
                    "name": package["name"],
                    "version": package["version"],
                    "license": package["license"],
                    "repository": package.get("repository"),
                }
            )
        (dist / "licenses/rust/dependencies.json").write_text(
            json.dumps(notices, indent=2) + "\n"
        )

    @staticmethod
    def _build_rust(root: Path, system: str, prefix: Path) -> None:
        env = os.environ.copy()
        env["PYO3_PYTHON"] = sys.executable
        env["SELENE_TOOLCHAIN_LLVM_PREFIX"] = str(prefix)
        command = [
            "cargo",
            "build",
            "--manifest-path",
            str(root / "rust/Cargo.toml"),
            "--package",
            "selene-toolchain",
            "--features",
            "python",
            "--release",
            "--locked",
        ]
        target = root.parent / "target"
        if system == "Windows":
            compilers = [
                Path(shutil.which(command[0]) or command[0]).resolve()
                for command in (
                    shlex.split(env.get("CC", "gcc").replace("\\", "/")),
                    shlex.split(env.get("CXX", "g++").replace("\\", "/")),
                )
            ]
            if compilers[0].parent != compilers[1].parent:
                raise RuntimeError(
                    "CC and CXX must come from the same MinGW installation"
                )
            command += ["--target", "x86_64-pc-windows-gnu"]
            env["CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER"] = shlex.split(
                env.get("CC", "gcc").replace("\\", "/")
            )[0]
            target = target / "x86_64-pc-windows-gnu"
        subprocess.run(command, env=env, cwd=root.parent, check=True)
        source_name = {
            "Linux": "libselene_toolchain.so",
            "Darwin": "libselene_toolchain.dylib",
            "Windows": "selene_toolchain.dll",
        }[system]
        destination = (
            root
            / "python/selene_toolchain"
            / ("_native.pyd" if system == "Windows" else "_native.abi3.so")
        )
        shutil.copy2(target / "release" / source_name, destination)

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
        for name in [*config["before"], *config["after"], "dllcrt2.o"]:
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
