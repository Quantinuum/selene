import pytest
import subprocess
from pathlib import Path
from hugr.qsystem.result import QsysResult
from selene_sim import Quest, Stim
from selene_sim.build import build
from selene_sim.exceptions import SelenePanicError
from selene_sim.result_handling.parse_shot import postprocess_unparsed_stream
from selene_sim import stack_trace as stack_trace_module


def test_windows_symbolizer_uses_relative_addresses(monkeypatch):
    recorded_command = None

    def fake_run(command, **_kwargs):
        nonlocal recorded_command
        recorded_command = command
        return subprocess.CompletedProcess(command, 0, stdout="[]", stderr="")

    monkeypatch.setattr(stack_trace_module.platform, "system", lambda: "Windows")
    monkeypatch.setattr(stack_trace_module, "run", fake_run)

    assert stack_trace_module.run_llvm_symbolizer(Path("program.exe"), [0x123]) == (
        [],
        None,
    )
    assert recorded_command is not None
    assert recorded_command[0].endswith("llvm-symbolizer.exe")
    assert "--relative-address" in recorded_command
    assert recorded_command[-1] == "0x123"


def test_dsym_is_created_while_symbolizing(monkeypatch):
    recorded_commands = []

    def fake_run(command, **_kwargs):
        recorded_commands.append(command)
        if str(command[0]).endswith("dsymutil"):
            return subprocess.CompletedProcess(command, 0, stdout=b"", stderr=b"")
        return subprocess.CompletedProcess(
            command, 0, stdout='[{"Symbol": []}]', stderr=""
        )

    monkeypatch.setattr(stack_trace_module.platform, "system", lambda: "Darwin")
    monkeypatch.setattr(stack_trace_module, "run", fake_run)

    stack_trace = stack_trace_module.StackTrace()
    stack_trace.add_entry(Path("program.selene.x"), 0x123)
    stack_trace.symbolize(Path("program.selene.x"))

    assert recorded_commands[0][-3:] == [
        "-o",
        "program.selene.x.dSYM",
        "program.selene.x",
    ]
    assert "--dsym-hint=program.selene.x.dSYM" in recorded_commands[1]
    assert stack_trace.symbolization_failure is None


def test_dsym_failure_does_not_raise(monkeypatch):
    def fake_run(command, **_kwargs):
        if str(command[0]).endswith("dsymutil"):
            raise subprocess.CalledProcessError(1, command)
        return subprocess.CompletedProcess(
            command, 0, stdout='[{"Symbol": []}]', stderr=""
        )

    monkeypatch.setattr(stack_trace_module.platform, "system", lambda: "Darwin")
    monkeypatch.setattr(stack_trace_module, "run", fake_run)

    stack_trace = stack_trace_module.StackTrace()
    stack_trace.add_entry(Path("program.selene.x"), 0x123)
    stack_trace.symbolize(Path("program.selene.x"))

    assert stack_trace.symbolization_failure == "creating macOS debug symbols"


def test_backtrace_always_panic(compiled_guppy):
    """
    This test verifies the behaviour of panic(), which should stop the shot
    and should not allow any further shots to be performed. On the python
    client side, this should result in an Exception rather than being added
    into the results.
    """

    # note: to preserve line numbers and columns, this is stripped
    # and dedent is avoided.
    guppy_source = """
from guppylang.decorator import guppy
from guppylang.std.builtins import result, panic
from guppylang.std.quantum import qubit, h, measure

@guppy
def always_panic() -> None:
    panic("This should always panic")
#   ^ that's line 7, column 4

@guppy
def main() -> None:
    always_panic()
""".strip()

    llvm_file = compiled_guppy(
        program_name="panic",
        guppy_source=guppy_source,
        emit_debug=True,
    )

    runner = build(llvm_file)
    with pytest.raises(
        SelenePanicError, match="This should always panic"
    ) as exception_info:
        shots = QsysResult(
            runner.run_shots(
                Quest(),
                n_qubits=1,
                n_shots=100,
                random_seed=0,
            )
        )
    the_exception = exception_info.value
    # note: in pytests, we store the guppy in a file and sanitize
    # debug info point to /sanitized/path/program.py
    assert "Stack trace:" in str(the_exception)
    stack_trace = the_exception.stack_trace
    assert len(stack_trace.entries) > 0
    filtered_trace = [entry for entry in stack_trace.entries if entry.symbols]
    assert len(filtered_trace) == 1
    entry = filtered_trace[0]
    assert entry.symbols[0].line == 7
    assert entry.symbols[0].column == 4
    # At the time of writing, the actual function that calls
    # panic isn't preserved because of optimisations on the hugr.
    assert entry.symbols[0].function_name == "main"

    _, unparsed_error = postprocess_unparsed_stream(
        runner.run_shots(
            Quest(),
            n_qubits=1,
            n_shots=1,
            random_seed=0,
            parse_results=False,
        )
    )
    assert isinstance(unparsed_error, SelenePanicError)
    assert unparsed_error.stack_trace is not None
    unparsed_symbols = [
        entry for entry in unparsed_error.stack_trace.entries if entry.symbols
    ]
    assert len(unparsed_symbols) == 1
    assert unparsed_symbols[0].symbols[0].function_name == "main"
    assert unparsed_symbols[0].symbols[0].line == 7
    assert unparsed_symbols[0].symbols[0].column == 4
    # this is because the output LLVM looks like:
    # ```
    # ; Function Attrs: noreturn
    # define noundef i64 @qmain(i64 %0) local_unnamed_addr #0 !dbg !9 {
    # entry:
    #   tail call void @setup(i64 %0), !dbg !14
    #   tail call void @panic(i32 1001, ptr nonnull @"s_This shoul.4464F519.0"), !dbg !15
    #   unreachable
    # }
    # ```
    # in particular, note how always_panic isn't in the output LLVM, so it's not
    # preserved in the stack trace.
    #
    # if this is every changed, run pytest --compile-guppy and change
    # this test to assert the function_name is "always_panic".


def test_backtrace_sometimes_panic(compiled_guppy):
    """
    This test verifies the behaviour of panic(), which should stop the shot
    and should not allow any further shots to be performed. On the python
    client side, this should result in an Exception rather than being added
    into the results.
    """

    # note: to preserve line numbers and columns, this is stripped
    # and dedent is avoided.
    guppy_source = """
from guppylang.decorator import guppy
from guppylang.std.builtins import result, panic, owned
from guppylang.std.quantum import qubit, h, measure

@guppy
def maybe_panic(q: qubit @owned) -> None:
    if measure(q).read():
        panic("The bad event has been triggered")
#       ^ that's line 8, column 8

@guppy
def main() -> None:
    q = qubit()
    h(q)
    maybe_panic(q)
""".strip()

    llvm_file = compiled_guppy(
        program_name="panic",
        guppy_source=guppy_source,
        emit_debug=True,
    )

    runner = build(llvm_file)
    with pytest.raises(
        SelenePanicError, match="The bad event has been triggered"
    ) as exception_info:
        shots = QsysResult(
            runner.run_shots(
                Quest(),
                n_qubits=1,
                n_shots=100,
                random_seed=0,
            )
        )
    the_exception = exception_info.value
    # note: in pytests, we store the guppy in a file and sanitize
    # debug info point to /sanitized/path/program.py
    assert "Stack trace:" in str(the_exception)
    stack_trace = the_exception.stack_trace
    filtered_trace = [entry for entry in stack_trace.entries if entry.symbols]
    assert len(filtered_trace) == 1
    entry = filtered_trace[0]
    assert entry.symbols[0].line == 8
    assert entry.symbols[0].column == 8
    # as in the previous test, optimisations mean that the function name
    # isn't preserved.
    assert entry.symbols[0].function_name == "main"


def test_backtrace_qalloc(compiled_guppy):
    """
    This test verifies the behaviour of panic() when it is called as a result
    of a failed qalloc. On the python client side, this should result in an
    Exception rather than being added into the results.
    """

    # note: to preserve line numbers and columns, this is stripped
    # and dedent is avoided.
    guppy_source = """
from guppylang.decorator import guppy
from guppylang.std.builtins import result
from guppylang.std.quantum import qubit, cx, measure, h

@guppy
def recursive_cx(source: qubit, n: int) -> None:
    q = qubit()
    #   ^ line 7, column 8
    cx(source, q)
    if n > 0:
        recursive_cx(q, n - 1)
    #   ^ line 11, column 8
    result("q", measure(q).read())

@guppy
def prep(q: qubit) -> None:
    h(q)

@guppy
def main() -> None:
    q = qubit()
    prep(q)
    recursive_cx(q, 1000)
  # ^ line 23, column 4
    result("q", measure(q).read())
""".strip()

    llvm_file = compiled_guppy(
        program_name="panic",
        guppy_source=guppy_source,
        emit_debug=True,
    )

    runner = build(llvm_file)
    with pytest.raises(
        SelenePanicError, match="No more qubits available to allocate"
    ) as exception_info:
        shots = QsysResult(
            runner.run_shots(
                Stim(),
                n_qubits=500,
                n_shots=10,
                random_seed=0,
            )
        )
    the_exception = exception_info.value
    assert "Stack trace:" in str(the_exception)
    filtered_trace = [
        entry for entry in the_exception.stack_trace.entries if entry.symbols
    ]
    assert len(filtered_trace) == 501
    assert filtered_trace[0].symbols[0].line == 7
    assert filtered_trace[0].symbols[0].column == 8
    assert filtered_trace[0].symbols[0].function_name == "recursive_cx"
    for i in range(1, 500):
        assert filtered_trace[i].symbols[0].line == 11
        assert filtered_trace[i].symbols[0].column == 8
        assert filtered_trace[i].symbols[0].function_name == "recursive_cx"
    assert filtered_trace[500].symbols[0].line == 23
    assert filtered_trace[500].symbols[0].column == 4
    assert filtered_trace[500].symbols[0].function_name == "main"
