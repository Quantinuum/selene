import pytest
import platform
import hashlib
import importlib.util
from pathlib import Path


def pytest_addoption(parser: pytest.Parser) -> None:
    parser.addoption(
        "--compile-guppy",
        action="store_true",
        default=False,
        help="Regenerate checked-in LLVM IR files from inline guppy source in tests.",
    )


@pytest.fixture
def compile_guppy(pytestconfig: pytest.Config) -> bool:
    return bool(pytestconfig.getoption("--compile-guppy"))


def get_platform_suffix() -> str:
    arch = platform.machine()
    system = platform.system()

    match arch.lower():
        case "arm64" | "aarch64":
            target_arch = "aarch64"
        case "amd64" | "x86_64":
            target_arch = "x86_64"
        case _:
            raise RuntimeError(f"Unsupported architecture: {arch}")
    match system.lower():
        case "linux":
            target_system = "unknown-linux-gnu"
        case "darwin" | "macos":
            target_system = "apple-darwin"
        case "windows":
            target_system = "windows-gnu"
        case _:
            raise RuntimeError(f"Unsupported OS: {system}")
    return f"{target_arch}-{target_system}"


SUPPORTED_TARGETS = [
    "aarch64-apple-darwin",
    "aarch64-unknown-linux-gnu",
    "x86_64-apple-darwin",
    "x86_64-unknown-linux-gnu",
    "x86_64-windows-gnu",
]


def _compile_inline_guppy_source_to_hugr_bytes(guppy_source: str) -> bytes:
    # check if guppy is installed
    if importlib.util.find_spec("guppylang") is None:
        raise RuntimeError(
            "Guppy is not installed. Please install guppylang to compile inline guppy source."
        )

    # This executes trusted inline source defined in this repository's test files.
    standalone_file = f"""
{guppy_source}

from pathlib import Path
compiled_hugr = main.compile()
current_dir = Path(__file__).parent
output_file = current_dir / "output.hugr"
output_file.write_bytes(compiled_hugr.to_bytes())
"""
    # make temporary directory
    import tempfile

    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir) / "temp_guppy_source.py"
        temp_path.write_text(standalone_file)
        # execute the file in a subprocess to avoid any issues with stateful execution of guppy code in the same process
        import subprocess
        import sys

        subprocess.run([sys.executable, f"{temp_path}"], check=True)
        return (Path(temp_dir) / "output.hugr").read_bytes()


def _compile_hugr_to_llvm_ir_for_target(hugr_bytes: bytes, target: str) -> str:
    try:
        from selene_hugr_qis_compiler import compile_to_llvm_ir
    except ImportError as exc:
        raise RuntimeError(
            "--compile-guppy requires selene_hugr_qis_compiler and guppylang to be installed."
        ) from exc

    return compile_to_llvm_ir(hugr_bytes, target_triple=target)


def _hash_guppy(guppy_source: str) -> str:
    return hashlib.sha256(guppy_source.encode()).hexdigest()


def _compile_inline_guppy_source_to_llvm_ir(guppy_source: str, *, target: str) -> str:
    hugr_bytes = _compile_inline_guppy_source_to_hugr_bytes(guppy_source)
    return _compile_hugr_to_llvm_ir_for_target(hugr_bytes, target=target)


@pytest.fixture
def compiled_guppy(compile_guppy: bool, request: pytest.FixtureRequest):
    def _resolve(
        *,
        program_name: str,
        guppy_source: str,
    ) -> Path | bytes:
        test_name = request.node.name
        test_path = Path(request.node.fspath)

        resources_dir = (
            test_path.parent / "resources" / "from_guppy" / test_path.stem / test_name
        )
        platform_file = resources_dir / f"{program_name}-{get_platform_suffix()}.ll"
        sha_file = resources_dir / f"{program_name}.sha256"
        input_sha256 = _hash_guppy(guppy_source)

        if compile_guppy:
            resources_dir.mkdir(parents=True, exist_ok=True)
            sha_file.write_text(input_sha256)
            for target in SUPPORTED_TARGETS:
                llvm_ir = _compile_inline_guppy_source_to_llvm_ir(
                    guppy_source, target=target
                )
                (resources_dir / f"{program_name}-{target}.ll").write_text(llvm_ir)
        else:
            if not sha_file.exists():
                raise FileNotFoundError(
                    f"Missing SHA256 file for checked-in LLVM snapshot: {sha_file}. "
                    "Run pytest with --compile-guppy to generate it."
                )
            if not platform_file.exists():
                raise FileNotFoundError(
                    f"Missing checked-in LLVM snapshot file: {platform_file}. "
                    "Run pytest with --compile-guppy to generate it."
                )
            stored_sha256 = sha_file.read_text()
            if stored_sha256 != input_sha256:
                raise ValueError(
                    f"SHA256 mismatch for {platform_file}. Expected {stored_sha256}, got {input_sha256}. "
                    "This likely means the inline guppy source was modified without regenerating the LLVM snapshot. "
                    "Run pytest with --compile-guppy to regenerate it."
                )
        return platform_file

    return _resolve
