import pickle
from pathlib import Path

import pytest

from selene_sim.exceptions import (
    SeleneBuildError,
    SeleneStartupError,
    SeleneRuntimeError,
    SelenePanicError,
)
from selene_sim.result_handling.exception_encoding import (
    encode_exception,
    extract_exception_from_results,
)
from selene_sim.stack_trace import StackTrace, Symbol


def test_exception_reports_stack_trace_without_symbols():
    stack_trace = StackTrace(symbolization_attempted=True)
    stack_trace.add_entry(Path("program"), 0x123)

    message = str(SeleneRuntimeError("Exception", stack_trace=stack_trace))

    assert message == "Exception\nNo symbols were obtained from the stack trace."


def test_exception_reports_stack_trace_not_symbolized():
    stack_trace = StackTrace()
    stack_trace.add_entry(Path("program"), 0x123)

    message = str(SeleneRuntimeError("Exception", stack_trace=stack_trace))

    assert message == (
        "Exception\nStack trace addresses were captured, but symbolization was not "
        "attempted."
    )


def test_exception_reports_stack_trace_symbolization_failure():
    stack_trace = StackTrace(symbolization_failure="running llvm-symbolizer")
    stack_trace.add_entry(Path("program"), 0x123)

    message = str(SeleneRuntimeError("Exception", stack_trace=stack_trace))

    assert message == (
        "Exception\nAn attempt was made to establish the stack trace, but it failed "
        "while running llvm-symbolizer."
    )


def test_exception_encoding_preserves_symbolized_stack_trace(tmp_path):
    stdout = tmp_path / "stdout.txt"
    stderr = tmp_path / "stderr.txt"
    stdout.write_text("")
    stderr.write_text("")

    stack_trace = StackTrace(
        symbolization_attempted=True,
        symbolization_failure="creating macOS debug symbols",
    )
    stack_trace.add_entry(Path("program"), 0x123)
    stack_trace.entries[0].symbols.append(
        Symbol(
            column=4,
            line=7,
            filename="program.py",
            function_name="main",
        )
    )
    error = SelenePanicError("panic", 1001)

    encoded = list(encode_exception(error, stdout, stderr, stack_trace))
    trace_metadata_tags = [tag for tag, _ in encoded if tag.startswith("_TRACE_")]
    assert all("{" not in tag and "}" not in tag for tag in trace_metadata_tags)
    results, decoded = extract_exception_from_results(encoded)

    assert results == []
    assert isinstance(decoded, SelenePanicError)
    assert decoded.stack_trace is not None
    assert decoded.stack_trace.symbolization_attempted
    assert decoded.stack_trace.symbolization_failure == "creating macOS debug symbols"
    assert decoded.stack_trace.entries == stack_trace.entries


@pytest.mark.parametrize(
    "error_class, kwargs",
    [
        (
            SeleneBuildError,
            {
                "message": "Exception",
                "stdout": "stdout",
                "stderr": "stderr",
            },
        ),
        (
            SeleneStartupError,
            {
                "message": "Exception",
                "stdout": "stdout",
                "stderr": "stderr",
            },
        ),
        (
            SeleneRuntimeError,
            {
                "message": "Exception",
                "stdout": "stdout",
                "stderr": "stderr",
            },
        ),
        (
            SelenePanicError,
            {
                "message": "Exception",
                "code": "foo",
                "stdout": "stdout",
                "stderr": "stderr",
            },
        ),
    ],
)
def test_pickle_and_unpickle_selene_startup_error(error_class, kwargs):
    error = error_class(**kwargs)
    unpickled = pickle.loads(pickle.dumps(error))

    assert isinstance(unpickled, error_class)

    for k, v in kwargs.items():
        assert getattr(unpickled, k) == v
