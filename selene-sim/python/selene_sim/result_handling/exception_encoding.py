from pathlib import Path
from typing import Iterator, Iterable
from selene_sim.exceptions import (
    SelenePanicError,
    SeleneRuntimeError,
    SeleneStartupError,
    SeleneTimeoutError,
)
from selene_sim.stack_trace import StackTrace
from . import TaggedResult


# when encoding exceptions through the result stream,
# these prefixes are used to identify metadata surrounding
# the error.
EXCEPTION_TYPE_PREFIX = "_EXCEPTION:INT:"
STDERR_PREFIX = "_STDERR:INT:"
STDOUT_PREFIX = "_STDOUT:INT:"
TRACE_PREFIX = "_TRACE:INT:"


def encode_stacktrace(stacktrace: StackTrace | None) -> Iterator[TaggedResult]:
    if stacktrace is None:
        return
    for trace_entry in stacktrace.entries:
        yield (
            f"{TRACE_PREFIX}{trace_entry.address}",
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
            trace_entry = next(remaining_results)[0]
            if not trace_entry.startswith(TRACE_PREFIX):
                break
            trace_info = trace_entry.removeprefix(TRACE_PREFIX)
            address = int(trace_info)
            stack_trace.add_entry(
                address=address,
            )
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
