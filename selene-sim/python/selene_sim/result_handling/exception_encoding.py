from pathlib import Path
from typing import Iterator, Iterable
from selene_sim.exceptions import (
    SelenePanicError,
    SeleneRuntimeError,
    SeleneStartupError,
    SeleneTimeoutError,
)
from selene_sim.stack_trace import StackTrace, Symbol
from . import TaggedResult


# when encoding exceptions through the result stream,
# these prefixes are used to identify metadata surrounding
# the error.
EXCEPTION_TYPE_PREFIX = "_EXCEPTION:INT:"
STDERR_PREFIX = "_STDERR:INT:"
STDOUT_PREFIX = "_STDOUT:INT:"
TRACE_PREFIX = "_TRACE:INT:"
TRACE_SYMBOL_ENTRY_TAG = "_TRACE_SYMBOL_ENTRY:INT"
TRACE_SYMBOL_LINE_TAG = "_TRACE_SYMBOL_LINE:INT"
TRACE_SYMBOL_COLUMN_TAG = "_TRACE_SYMBOL_COLUMN:INT"
TRACE_SYMBOL_FILENAME_PREFIX = "_TRACE_SYMBOL_FILENAME:INT:"
TRACE_SYMBOL_FUNCTION_PREFIX = "_TRACE_SYMBOL_FUNCTION:INT:"
TRACE_ATTEMPTED_TAG = "_TRACE_SYMBOLIZATION_ATTEMPTED:BOOL"
TRACE_FAILURE_PREFIX = "_TRACE_SYMBOLIZATION_FAILURE:INT:"


def _read_metadata_value(results: Iterator[TaggedResult], expected_tag: str) -> int:
    tag, value = next(results)
    if tag != expected_tag or not isinstance(value, int):
        raise ValueError(f"Expected {expected_tag} stack trace metadata")
    return value


def _read_metadata_string(results: Iterator[TaggedResult], expected_prefix: str) -> str:
    tag, value = next(results)
    if not tag.startswith(expected_prefix) or not isinstance(value, int):
        raise ValueError(f"Expected {expected_prefix} stack trace metadata")
    return tag.removeprefix(expected_prefix)


def _decode_symbol(
    entry_index: int,
    results: Iterator[TaggedResult],
    stack_trace: StackTrace,
) -> None:
    if not 0 <= entry_index < len(stack_trace.entries):
        raise ValueError(f"Invalid stack trace entry index {entry_index}")
    line = _read_metadata_value(results, TRACE_SYMBOL_LINE_TAG)
    column = _read_metadata_value(results, TRACE_SYMBOL_COLUMN_TAG)
    filename = _read_metadata_string(results, TRACE_SYMBOL_FILENAME_PREFIX)
    function_name = _read_metadata_string(results, TRACE_SYMBOL_FUNCTION_PREFIX)
    stack_trace.entries[entry_index].symbols.append(
        Symbol(
            column=column,
            line=line,
            filename=filename,
            function_name=function_name,
        )
    )


def encode_stacktrace(stacktrace: StackTrace | None) -> Iterator[TaggedResult]:
    if stacktrace is None:
        return
    for trace_entry in stacktrace.entries:
        yield (
            f"{TRACE_PREFIX}{trace_entry.module}",
            trace_entry.address,
        )
    # Keep raw trace entries first so older consumers still recover every
    # module/address pair before encountering metadata they do not understand.
    for entry_index, trace_entry in enumerate(stacktrace.entries):
        for symbol in trace_entry.symbols:
            yield (TRACE_SYMBOL_ENTRY_TAG, entry_index)
            yield (TRACE_SYMBOL_LINE_TAG, symbol.line)
            yield (TRACE_SYMBOL_COLUMN_TAG, symbol.column)
            yield (f"{TRACE_SYMBOL_FILENAME_PREFIX}{symbol.filename}", 0)
            yield (f"{TRACE_SYMBOL_FUNCTION_PREFIX}{symbol.function_name}", 0)
    yield (TRACE_ATTEMPTED_TAG, stacktrace.symbolization_attempted)
    if stacktrace.symbolization_failure is not None:
        yield (
            f"{TRACE_FAILURE_PREFIX}{stacktrace.symbolization_failure}",
            0,
        )


def encode_exception(
    exception: Exception,
    stdout_file: Path,
    stderr_file: Path,
    stack_trace: StackTrace | None = None,
) -> Iterator[TaggedResult]:
    """
    Given an exception that occurs during a shot, encode it as a series
    of result stream entries with specific prefixes, so that it can be
    recovered on the other end of the stream.
    """
    match exception:
        case SelenePanicError(message=message, code=code):
            # The EXIT:INT: prefix is already present
            # in the message. The code is provided by
            # the user program or Selene.
            yield (f"{EXCEPTION_TYPE_PREFIX}SelenePanicError", 0)
            yield (message, code)
            yield (f"{STDERR_PREFIX}{stderr_file}", 0)
            yield (f"{STDOUT_PREFIX}{stdout_file}", 0)
            yield from encode_stacktrace(stack_trace)
        case SeleneRuntimeError(message=message):
            # We need to encode the EXIT:INT: prefix here,
            # and provide a generic code.
            yield (f"{EXCEPTION_TYPE_PREFIX}SeleneRuntimeError", 0)
            yield (f"EXIT:INT:{message}", 110000)
            yield (f"{STDERR_PREFIX}{stderr_file}", 0)
            yield (f"{STDOUT_PREFIX}{stdout_file}", 0)
            yield from encode_stacktrace(stack_trace)
        case SeleneStartupError(message=message):
            # We need to encode the EXIT:INT: prefix here,
            # and provide a generic code.
            yield (f"{EXCEPTION_TYPE_PREFIX}SeleneStartupError", 0)
            yield (f"EXIT:INT:{message}", 110001)
            yield (f"{STDERR_PREFIX}{stderr_file}", 0)
            yield (f"{STDOUT_PREFIX}{stdout_file}", 0)
            yield from encode_stacktrace(stack_trace)
        case SeleneTimeoutError(message=message):
            # We need to encode the EXIT:INT: prefix here,
            # and provide a generic code.
            yield (f"{EXCEPTION_TYPE_PREFIX}SeleneTimeoutError", 0)
            yield (f"EXIT:INT:{message}", 110002)
            yield (f"{STDERR_PREFIX}{stderr_file}", 0)
            yield (f"{STDOUT_PREFIX}{stdout_file}", 0)
            yield from encode_stacktrace(stack_trace)
        case other:
            # Encapsulate any other exception into a
            # SeleneRuntimeError for consistent parsing
            # on the other end.
            yield (f"{EXCEPTION_TYPE_PREFIX}SeleneRuntimeError", 0)
            yield (f"EXIT:INT:{other}", 110000)
            yield (f"{STDERR_PREFIX}{stderr_file}", 0)
            yield (f"{STDOUT_PREFIX}{stdout_file}", 0)
            yield from encode_stacktrace(stack_trace)


def detect_exception(
    result: TaggedResult,
) -> bool:
    """
    Given a single tagged result, check if it is part of an encoded exception.
    """
    return result[0].startswith("_EXCEPTION")


def decode_exception(
    detected_entry: TaggedResult,
    remaining_results: Iterator[TaggedResult],
) -> Exception:
    exception_type = detected_entry[0].removeprefix(EXCEPTION_TYPE_PREFIX)
    try:
        error_message, error_code = next(remaining_results)
        error_message = error_message.removeprefix("EXIT:INT:")
        assert isinstance(error_code, int)  # satisfy mypy
    except Exception as e:
        return SeleneRuntimeError(
            message=f"Error while decoding exception: Missing error message/code for exception type {exception_type}: {e}.",
        )

    try:
        stderr_path = next(remaining_results)[0].removeprefix(STDERR_PREFIX)
        stderr_content = Path(stderr_path).read_text()
    except Exception as e:
        return SeleneRuntimeError(
            message=f"Error while decoding exception: Missing stderr for exception type {exception_type} and message {error_message}: {e}.",
        )

    try:
        stdout_path = next(remaining_results)[0].removeprefix(STDOUT_PREFIX)
        stdout_content = Path(stdout_path).read_text()
    except Exception as e:
        return SeleneRuntimeError(
            message=f"Error while decoding exception: Missing stdout for exception type {exception_type} and message {error_message}: {e}.",
        )

    stack_trace = StackTrace()
    while True:
        try:
            trace_entry = next(remaining_results)
            tag = trace_entry[0]
            value = trace_entry[1]
            if tag.startswith(TRACE_PREFIX):
                if not isinstance(value, int):
                    raise TypeError("Stack trace address must be an integer")
                module = Path(tag.removeprefix(TRACE_PREFIX))
                stack_trace.add_entry(
                    module=module,
                    address=value,
                )
            elif tag == TRACE_SYMBOL_ENTRY_TAG:
                if not isinstance(value, int):
                    raise TypeError("Stack trace entry index must be an integer")
                _decode_symbol(value, remaining_results, stack_trace)
            elif tag == TRACE_ATTEMPTED_TAG:
                if not isinstance(value, bool):
                    raise TypeError("Stack trace attempted status must be a boolean")
                stack_trace.symbolization_attempted = value
            elif tag.startswith(TRACE_FAILURE_PREFIX):
                if not isinstance(value, int):
                    raise TypeError("Stack trace failure value must be an integer")
                stack_trace.symbolization_failure = tag.removeprefix(
                    TRACE_FAILURE_PREFIX
                )
            else:
                break
        except StopIteration:
            break
        except Exception as e:
            return SeleneRuntimeError(
                message=f"Error while decoding exception: Malformed stack trace entry for exception type {exception_type} and message {error_message}: {e}.",
                stdout=stdout_content,
                stderr=stderr_content,
            )

    match exception_type:
        case "SelenePanicError":
            return SelenePanicError(
                message=error_message,
                code=error_code,
                stdout=stdout_content,
                stderr=stderr_content,
                stack_trace=stack_trace,
            )
        case "SeleneRuntimeError":
            return SeleneRuntimeError(
                message=error_message,
                stdout=stdout_content,
                stderr=stderr_content,
                stack_trace=stack_trace,
            )
        case "SeleneStartupError":
            return SeleneStartupError(
                message=error_message,
                stdout=stdout_content,
                stderr=stderr_content,
                stack_trace=stack_trace,
            )
        case "SeleneTimeoutError":
            return SeleneTimeoutError(
                message=error_message,
                stdout=stdout_content,
                stderr=stderr_content,
                stack_trace=stack_trace,
            )
        case _:
            return SeleneRuntimeError(
                message=f"Unknown exception type: {exception_type}",
                stdout=stdout_content,
                stderr=stderr_content,
                stack_trace=stack_trace,
            )


def extract_exception_from_results(
    shot_results: Iterable[TaggedResult],
) -> tuple[list[TaggedResult], Exception | None]:
    """
    Given a list of shot results, check if the last four entries correspond
    to an encoded exception. If so, decode it and return the exception object.
    If not, return None.
    """
    result_list: list[TaggedResult] = []
    result_iterator = iter(shot_results)
    for result in result_iterator:
        if detect_exception(result):
            return result_list, decode_exception(result, result_iterator)
        else:
            result_list.append(result)

    return result_list, None
