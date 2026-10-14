import platform
import subprocess
from pathlib import Path

import pytest

from selene_toolchain import compile_object, link_executable


@pytest.mark.parametrize("directory", ["build", "build with spaces"])
@pytest.mark.parametrize("source_kind", ["ir", "bitcode"])
def test_executable_without_a_system_compiler(
    tmp_path, monkeypatch, directory, source_kind
):
    build_dir = tmp_path / directory
    build_dir.mkdir()
    source = build_dir / "program.ll"
    source.write_text(
        """
        @message = private constant [3 x i8] c"ok\\00"
        declare i32 @puts(ptr)
        define i32 @main(i32 %argc, ptr %argv) {
            %result = call i32 @puts(ptr @message)
            ret i32 0
        }
        """
    )
    if source_kind == "bitcode":
        # This fixture was assembled with LLVM 21 from resources/program.ll.
        # We don't need a compiler or an assembler installed to use it here.
        source = build_dir / "program.bc"
        source.write_bytes(
            (Path(__file__).parent / "resources/program.bc").read_bytes()
        )
    obj = build_dir / "program.o"
    executable = build_dir / (
        "program.exe" if platform.system() == "Windows" else "program"
    )
    # We should be able to compile, link, and call the host's C library even
    # when PATH doesn't contain a compiler, a linker, or any LLVM tools.
    monkeypatch.setenv("PATH", str(tmp_path / "empty-path"))
    monkeypatch.delenv("HUGRENV_PATH", raising=False)
    compile_object(source, obj)
    link_executable([obj], executable)
    result = subprocess.run(
        [str(executable)], capture_output=True, text=True, check=True
    )
    assert result.stdout.strip() == "ok"


def test_compiler_helpers_and_initialisers(tmp_path):
    source = tmp_path / "program.ll"
    source.write_text(
        """
        @value = global i32 1
        @quotient = global i128 0
        @llvm.global_ctors = appending global [1 x { i32, ptr, ptr }]
            [{ i32, ptr, ptr } { i32 65535, ptr @initialise, ptr null }]
        define void @initialise() {
            store i32 0, ptr @value
            ret void
        }
        define i32 @main(i32 %argc, ptr %argv) {
            %a = zext i32 %argc to i128
            %b = udiv i128 123456789123456789123456789, %a
            store i128 %b, ptr @quotient
            %result = load i32, ptr @value
            ret i32 %result
        }
        """
    )
    obj = tmp_path / "program.o"
    executable = tmp_path / "program.exe"
    # The division can need a compiler runtime helper, and the constructor must
    # run before main. Linking a trivial main alone wouldn't check either case.
    compile_object(source, obj)
    link_executable([obj], executable)
    subprocess.run([str(executable)], check=True)


def test_missing_symbol_is_reported_at_link_time(tmp_path):
    source = tmp_path / "program.ll"
    source.write_text(
        """
        declare i32 @selene_missing_function()
        define i32 @main(i32 %argc, ptr %argv) {
            %result = call i32 @selene_missing_function()
            ret i32 %result
        }
        """
    )
    obj = tmp_path / "program.o"
    compile_object(source, obj)
    with pytest.raises(RuntimeError, match="selene_missing_function"):
        link_executable([obj], tmp_path / "program.exe")


def test_invalid_ir_has_a_useful_error(tmp_path):
    source = tmp_path / "invalid.ll"
    source.write_text("this is not LLVM IR")
    with pytest.raises(RuntimeError, match="llc command failed"):
        compile_object(source, tmp_path / "invalid.o")


@pytest.mark.skipif(platform.system() != "Darwin", reason="macOS symbol collision")
def test_panic_comes_from_our_archive(tmp_path):
    source = tmp_path / "program.ll"
    source.write_text(
        """
        declare i32 @panic()
        define i32 @main() {
            %value = call i32 @panic()
            %wrong = icmp ne i32 %value, 42
            %status = zext i1 %wrong to i32
            ret i32 %status
        }
        """
    )
    obj = tmp_path / "program.o"
    executable = tmp_path / "program"
    arch = "arm64" if platform.machine().lower() == "arm64" else "x86_64"
    # These archives were built with LLVM 21 from resources/panic.ll. Using
    # an archive means the linker must choose to extract our panic function.
    # If libSystem satisfies the call first, we'll call its unrelated panic
    # function instead, so the program won't return the expected status.
    library = Path(__file__).parent / f"resources/panic-{arch}.a"
    compile_object(source, obj)
    link_executable([obj], executable, libraries=[library])
    subprocess.run([str(executable)], check=True)
