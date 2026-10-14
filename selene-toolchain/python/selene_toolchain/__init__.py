"""Inspect LLVM modules, compile objects, and link with the packaged LLVM tools."""

import json
import ctypes
import os
import platform
import struct
import subprocess
import sys
from pathlib import Path
from dataclasses import dataclass
from typing import Iterable

dist_dir = Path(__file__).parent / "_dist"


@dataclass(frozen=True)
class ModuleSymbols:
    """Function definitions and declarations found in an LLVM module."""

    defined_functions: frozenset[str]
    declared_functions: frozenset[str]


@dataclass(frozen=True)
class ObjectSymbols:
    """Defined and undefined linker symbols, including functions and data."""

    defined_symbols: frozenset[str]
    undefined_symbols: frozenset[str]


def inspect_module(contents: str | Path | bytes) -> ModuleSymbols:
    """Read functions from LLVM IR or bitcode using the packaged LLVM parser."""
    if isinstance(contents, Path):
        if contents.suffix not in (".ll", ".bc"):
            raise ValueError(
                f"Unsupported file extension for LLVM contents: {contents.suffix}"
            )
    elif isinstance(contents, str):
        contents = contents.encode("utf-8")
    elif not isinstance(contents, bytes):
        raise TypeError(f"Unsupported type for LLVM contents: {type(contents)}")
    definitions, declarations = _inspect_symbols(
        contents, "inspect", "defined_functions", "declared_functions", "LLVM module"
    )
    return ModuleSymbols(definitions, declarations)


def inspect_object(contents: Path | bytes) -> ObjectSymbols:
    """Read linker symbols from ELF, Mach-O or PE/COFF files or bytes."""
    if not isinstance(contents, (Path, bytes)):
        raise TypeError(f"Unsupported type for object contents: {type(contents)}")
    definitions, declarations = _inspect_symbols(
        contents, "inspect-object", "defined_symbols", "undefined_symbols", "Object"
    )
    return ObjectSymbols(definitions, declarations)


def _inspect_symbols(
    contents: Path | bytes,
    subcommand: str,
    defined_key: str,
    undefined_key: str,
    kind: str,
) -> tuple[frozenset[str], frozenset[str]]:
    command = [str(tool_path("selene-llvm")), subcommand]
    data = contents if isinstance(contents, bytes) else None
    if isinstance(contents, Path):
        command.append(str(contents))
    try:
        result = subprocess.run(
            command,
            input=data,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=tool_environment(),
        )
    except OSError as error:
        raise RuntimeError(f"Unable to run selene-llvm: {error}") from error
    if result.returncode:
        diagnostic = result.stderr.decode("utf-8", errors="replace")
        raise RuntimeError(
            f"{kind} inspection failed (exit {result.returncode}):\n{diagnostic}"
        )
    try:
        symbols = json.loads(result.stdout)
        if symbols["schema_version"] != 1:
            raise ValueError("Unsupported inspection schema version")
        definitions = symbols[defined_key]
        declarations = symbols[undefined_key]
        for names in (definitions, declarations):
            if not isinstance(names, list) or not all(
                isinstance(name, str) for name in names
            ):
                raise ValueError("Expected a list of symbol names")
        return frozenset(definitions), frozenset(declarations)
    except (ValueError, KeyError, TypeError) as error:
        raise RuntimeError(f"Invalid response from selene-llvm: {error}") from error


def tool_environment() -> dict[str, str]:
    """Make repaired wheel DLLs available to tools launched as subprocesses."""
    env = os.environ.copy()
    if platform.system() == "Windows":
        # delvewheel's Python DLL loading patch doesn't apply to child EXEs.
        # They need the vendored DLL directory in their own search path.
        dll_dir = dist_dir.parent.parent / "selene_toolchain.libs"
        env["PATH"] = os.pathsep.join(
            [
                str(dist_dir / "bin"),
                str(dll_dir),
                str(Path(sys.executable).parent),
                env.get("PATH", ""),
            ]
        )
    return env


def tool_path(name: str) -> Path:
    """Return a packaged tool without searching the user's PATH."""
    if platform.system() == "Windows":
        name += ".exe"
    path = dist_dir / "bin" / name
    if not path.is_file():
        raise RuntimeError(f"Missing selene-toolchain tool: {path}")
    return path


def target_triple() -> str:
    machine = platform.machine().lower()
    if machine in ("amd64", "x86_64"):
        arch = "x86_64"
    elif machine in ("arm64", "aarch64"):
        arch = "aarch64"
    else:
        raise RuntimeError(f"Unsupported architecture: {machine}")
    system = platform.system()
    if system == "Linux":
        return f"{arch}-unknown-linux-gnu"
    if system == "Darwin":
        return f"{arch}-apple-macosx11.0.0"
    if system == "Windows" and arch == "x86_64":
        return "x86_64-w64-windows-gnu"
    raise RuntimeError(f"Unsupported platform: {system} {arch}")


def _run(name: str, args: Iterable[str | Path], *, verbose: bool) -> None:
    command = [str(tool_path(name)), *(str(arg) for arg in args)]
    if verbose:
        print(f"LLVM command: {subprocess.list2cmdline(command)}")
    try:
        result = subprocess.run(
            command,
            stdout=None if verbose else subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
            env=tool_environment(),
        )
    except OSError as error:
        raise RuntimeError(f"Unable to run {name}: {error}") from error
    if result.returncode:
        raise RuntimeError(
            f"{name} command failed:\n"
            f"  Command: {subprocess.list2cmdline(command)}\n"
            f"  Error: {result.stderr}"
        )


def compile_object(source: Path, output: Path, *, verbose: bool = False) -> None:
    """Compile LLVM IR or bitcode without a C compiler or its headers."""
    _run(
        "llc",
        [
            f"-mtriple={target_triple()}",
            "-filetype=obj",
            "-relocation-model=pic",
            "--frame-pointer=all",
            "-O=0",
            source,
            "-o",
            output,
        ],
        verbose=verbose,
    )


def _linux_interpreter() -> str:
    # Python is already running on this machine, so its ELF interpreter tells
    # us which loader to use. This also works on NixOS, where the usual /lib64
    # path doesn't exist. We only support 64-bit little-endian Linux targets.
    with open(sys.executable, "rb") as executable:
        header = executable.read(64)
        if header[:6] != b"\x7fELF\x02\x01":
            raise RuntimeError("Cannot determine the host's ELF interpreter")
        offset = struct.unpack_from("<Q", header, 32)[0]
        entry_size, count = struct.unpack_from("<HH", header, 54)
        for index in range(count):
            executable.seek(offset + index * entry_size)
            entry = executable.read(entry_size)
            if struct.unpack_from("<I", entry)[0] == 3:  # PT_INTERP
                path_offset = struct.unpack_from("<Q", entry, 8)[0]
                size = struct.unpack_from("<Q", entry, 32)[0]
                executable.seek(path_offset)
                return executable.read(size).rstrip(b"\0").decode()
    raise RuntimeError("Python's executable does not have an ELF interpreter")


def _linux_link_flag(flag: str) -> str:
    # A glibc runtime installation has versioned shared objects, but generally
    # doesn't have the unversioned lib*.so files supplied by development
    # packages. Ask the loader for the actual library so LLD can read its
    # symbols without needing those development packages or an ldconfig command.
    sonames = {
        "-lc": "libc.so.6",
        "-lm": "libm.so.6",
        "-lpthread": "libpthread.so.0",
        "-ldl": "libdl.so.2",
        "-lrt": "librt.so.1",
        "-lresolv": "libresolv.so.2",
        "-lutil": "libutil.so.1",
        "-lanl": "libanl.so.1",
    }
    soname = sonames.get(flag)
    if soname is None:
        return flag

    class LinkMap(ctypes.Structure):
        _fields_ = [("address", ctypes.c_void_p), ("name", ctypes.c_char_p)]

    try:
        library = ctypes.CDLL(soname)
        libdl = ctypes.CDLL("libdl.so.2")
        dlinfo = libdl.dlinfo
        dlinfo.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
        dlinfo.restype = ctypes.c_int
        link_map = ctypes.POINTER(LinkMap)()
        if dlinfo(library._handle, 2, ctypes.byref(link_map)) != 0:  # RTLD_DI_LINKMAP
            raise RuntimeError(f"Cannot find the loaded path for {soname}")
        name = link_map.contents.name
        if not name:
            raise RuntimeError(f"The loader did not return a path for {soname}")
        path = Path(os.fsdecode(name)).resolve()
        if not path.is_file():
            raise RuntimeError(f"The loaded library does not exist at {path}")
        return str(path)
    except (OSError, AttributeError) as error:
        raise RuntimeError(
            f"Cannot locate the host glibc library {soname}: {error}"
        ) from error


def link_executable(
    objects: Iterable[Path],
    output: Path,
    *,
    libraries: Iterable[Path] = (),
    library_search_dirs: Iterable[Path] = (),
    link_flags: Iterable[str] = (),
    verbose: bool = False,
) -> None:
    """Link a native executable using this wheel's startup and runtime inputs."""
    target_triple()
    config = json.loads((dist_dir / "link.json").read_text())
    if config["system"] != platform.system():
        raise RuntimeError(
            "selene-toolchain was built for a different operating system"
        )
    if config["machine"] != target_triple().split("-")[0]:
        raise RuntimeError("selene-toolchain was built for a different architecture")
    runtime = dist_dir / "runtime"
    search_dirs = [runtime, *library_search_dirs]
    user_inputs = [*objects, *libraries]
    flags = list(link_flags)
    # Plugins currently use compiler-style -Wl flags. LLD takes those options
    # directly, so we remove the compiler driver's wrapper here.
    flags = [
        part
        for flag in flags
        for part in (flag[4:].split(",") if flag.startswith("-Wl,") else [flag])
    ]
    system = platform.system()
    args: list[str | Path]
    if system == "Darwin":
        arch = "arm64" if config["machine"] == "aarch64" else "x86_64"
        args = [
            "-arch",
            arch,
            "-platform_version",
            "macos",
            "11.0",
            "11.0",
            "-o",
            output,
            *(f"-L{path}" for path in search_dirs),
            *user_inputs,
            *flags,
            # QIS defines panic, which libSystem also exports. We need to
            # search our archives first so that calls use the QIS definition.
            "-lSystem",
        ]
        linker = "ld64.lld"
    else:
        before = [runtime / name for name in config["before"]]
        after = [runtime / name for name in config["after"]]
        args = ["-o", output, *(f"-L{path}" for path in search_dirs)]
        if system == "Linux":
            # The runtime unwinder needs the ELF frame index to find unwind
            # information for user functions. A compiler driver normally adds
            # this option, but we're invoking LLD directly.
            args += ["-pie", "--eh-frame-hdr", "--dynamic-linker", _linux_interpreter()]
        else:
            args += ["-m", "i386pep", "--subsystem", "console"]
        runtime_libraries = list(config["libraries"])
        if system == "Linux":
            flags = [_linux_link_flag(flag) for flag in flags]
            runtime_libraries = [_linux_link_flag(flag) for flag in runtime_libraries]
            runtime_libraries.append(runtime / "libc_nonshared.a")
        args += [
            *before,
            "--start-group",
            *user_inputs,
            *flags,
            *runtime_libraries,
            "--end-group",
            *after,
        ]
        linker = "ld.lld"
    _run(linker, args, verbose=verbose)
