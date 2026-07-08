# utilities to help kinds and steps with common behaviour

import platform
import sys
from pathlib import Path
import os


def get_target_triple(arch: str | None = None, system: str | None = None) -> str | None:
    """
    MacOS needs pointing to libSystem compatible with 11.0,
    as the default is the current platform which selene components
    might be incompatible with.

    Windows uses MinGW to align with selene wheel artifacts.

    Linux doesn't need further specification, as the default behaviour
    is correct. Using e.g. "x86_64-linux-gnu" would fail on nixos, for
    example.
    """

    if arch is None:
        arch = platform.machine()
    if system is None:
        system = platform.system()

    target_system = ""
    target_arch = ""

    match system.lower():
        case "linux":
            return None
        case "darwin" | "macos":
            target_system = "macos.11.0-none"
        case "windows":
            target_system = "windows-gnu"
        case _:
            raise RuntimeError(f"Unsupported OS: {system}")

    match arch.lower():
        case "arm64" | "aarch64":
            target_arch = "aarch64"
        case "amd64" | "x86_64":
            target_arch = "x86_64"
        case _:
            raise RuntimeError(f"Unsupported architecture: {arch}")
    return f"{target_arch}-{target_system}"


def invoke_zig(
    *args,
    handle_triple: bool = True,
    verbose: bool = False,
    cache_dir: Path | None = None,
) -> None:
    """
    Invoke zig with the given arguments, after conversion to strings.

    When verbose is True, zig's stdout is forwarded to the console so that
    long-running builds remain observable. stderr is always captured so that
    a helpful message can be included in any RuntimeError raised on failure.
    """
    import subprocess

    args_str = [str(arg) for arg in args]
    if handle_triple:
        target_triple = get_target_triple()
        if target_triple is not None:
            args_str += ["-target", target_triple]
    argv = [sys.executable, "-m", "ziglang"] + args_str
    if verbose:
        print(f"zig command: {' '.join(argv)}")
    env = os.environ.copy()
    if cache_dir is not None:
        env["ZIG_LOCAL_CACHE_DIR"] = str(cache_dir)
    # Inherit stdout when verbose so progress is visible; suppress it otherwise.
    # Always capture stderr so we can include it in any error message.
    stdout_target = None if verbose else subprocess.DEVNULL
    handle = subprocess.Popen(
        argv, stdout=stdout_target, stderr=subprocess.PIPE, env=env
    )
    _, stderr = handle.communicate()
    if handle.returncode != 0:
        raise RuntimeError(
            f"zig command failed:\n  Command: {' '.join(argv)}\n  Error: {stderr.decode()}"
        )


def debug_objects_for_executable(input_object: Path, executable: Path) -> list[Path]:
    """
    Return debug-information artifacts associated with a linked executable.

    The input object usually remains useful debug provenance on platforms where
    the final linked image keeps only a debug map. Some linkers also emit
    sidecar debug files next to the executable, such as PDBs on Windows.
    """
    debug_objects = [input_object]
    pdb_path = executable.with_suffix(".pdb")
    if pdb_path.is_file():
        debug_objects.append(pdb_path)
    return debug_objects
