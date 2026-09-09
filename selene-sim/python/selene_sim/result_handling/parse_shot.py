from typing import Iterator, Iterable, Literal, TypeGuard, overload

from ..process import SeleneProcess
from ..event_hooks import EventHook
from ..exceptions import (
    SelenePanicError,
    SeleneRuntimeError,
    SeleneStartupError,
    SeleneTimeoutError,
    StackTrace,
)
from .result_stream import ResultStream, TaggedResult, TaggedStreamEntry
from .exception_encoding import (
    encode_exception,
    detect_exception,
    decode_exception,
)
from .extract_shot import (
    extract_shot,
    ShotEntry,
    UserResult,
    UserStateResult,
    ShotExitMessage,
    FullPanicMessage,
    DebugTraceMessage,
    MetricValue,
    InstructionLogEntry,
    ShotMeasurements,
)


@overload
def parse_shot(
    stream: ResultStream,
    event_hook: EventHook,
    full: Literal[True],
    process: SeleneProcess,
) -> Iterator[TaggedResult]: ...


@overload
def parse_shot(
    stream: ResultStream,
    event_hook: EventHook,
    full: Literal[False],
    process: SeleneProcess,
) -> Iterator[TaggedStreamEntry]: ...


@overload
def parse_shot(
    stream: ResultStream,
    event_hook: EventHook,
    full: bool,
    process: SeleneProcess,
) -> Iterator[TaggedResult] | Iterator[TaggedStreamEntry]: ...


def parse_shot(
    stream: ResultStream,
    event_hook: EventHook,
    full: bool,
    process: SeleneProcess,
) -> Iterator[TaggedResult] | Iterator[TaggedStreamEntry]:
    """
    Parses a shot from the results stream, yielding tagged results one by one.
    If `full` is True, the results are parsed and provide a pythonic interface
    (e.g. with exceptions upon different kinds of errors).

    If `full` is False, the results are simply interpreted, and exceptions are
    encoded as special entries in the results stream. This is handy if processing
    of the results is desired even in the presence of errors.
    """
    shot_entries = extract_shot(stream)
    if full:
        return parsed_interface(shot_entries, event_hook, stream, process)
    else:
        return unparsed_interface(shot_entries, stream, process)


# There are two modes of outputting shots. One is "parsed", another is "unparsed",
# the former targeting users who are interacting with a local selene instance, and
# the latter targetting services which aim to provide selene functionality remotely.
def parsed_interface(
    shot_entries: Iterable[ShotEntry],
    event_hook: EventHook,
    stream: ResultStream,
    process: SeleneProcess,
) -> Iterator[TaggedResult]:
    """
    Filters the shot entries for tagged results within one shot, stripping them
    of system prefixes and yielding them one by one.

    Standard shot exits are passed through as results for visibility, while
    panics are provided as SelenePanicErrors. Other exceptions that emerge are
    also raised, with contextual information via the stdout and stderr
    corresponding to the process that is feeding the results stream.
    """
    stack_trace = StackTrace()
    pending_panic: SelenePanicError | None = None
    try:
        for entry in shot_entries:
            match entry:
                case UserResult(tag=tag, value=value):
                    tag_split = tag.split(":", maxsplit=2)
                    if len(tag_split) != 3:
                        raise SeleneRuntimeError(
                            f"Expected user result tag to have three parts, got {tag}"
                        )
                    yield ((tag_split[2], value))
                case UserStateResult(tag=tag, path=path):
                    tag_split = tag.split(":", maxsplit=1)
                    if len(tag_split) != 2:
                        raise SeleneRuntimeError(
                            f"Expected user state result tag to have two parts, got {tag}"
                        )
                    # TODO: this is a string, but TaggedResult currently expects an int,
                    # float, bool, or a list of those.
                    yield ((tag_split[1], path))  # type: ignore
                case DebugTraceMessage(module=module, address=address):
                    stack_trace.add_entry(module=module, address=address)
                case ShotExitMessage(message=message, code=code):
                    message_split = message.split(":", maxsplit=2)
                    if len(message_split) != 3:
                        raise SeleneRuntimeError(
                            f"Expected exit message tag to have three parts, got {message}"
                        )
                    yield ((f"exit: {message_split[2]}", code))
                case FullPanicMessage(message=message, code=code):
                    if pending_panic is None:
                        pending_panic = SelenePanicError(message=message, code=code)
                case MetricValue(name=name, value=value):
                    event_hook.try_invoke(name, [value])
                case InstructionLogEntry(tag=tag, values=values):
                    event_hook.try_invoke(tag, values)
                case ShotMeasurements(tag=tag, values=values):
                    event_hook.try_invoke(tag, values)
        if pending_panic is not None:
            raise pending_panic
    except Exception as caught_error:
        # Once a panic has been reported, failures while draining the remainder
        # of the shot must not mask it.
        error = pending_panic or caught_error
        # taint the stream to prevent further reading
        stream.taint()

        # if the error is not a selene exception, wrap it in a selene-specific runtime error
        if not isinstance(
            error,
            (
                SelenePanicError,
                SeleneRuntimeError,
                SeleneStartupError,
                SeleneTimeoutError,
            ),
        ):
            error = SeleneRuntimeError(message=str(error))
        if error.message.startswith("EXIT:INT:"):
            error.message = error.message[len("EXIT:INT:") :]

        # attach stdout and stderr to the exception
        process.terminate(
            expected_natural_exit=isinstance(
                error, (SeleneStartupError, SelenePanicError)
            )
        )
        stack_trace.symbolize(process.executable)
        error.stdout = process.stdout.read_text()
        error.stderr = process.stderr.read_text()
        error.stack_trace = stack_trace
        raise error from None


# This isn't always suitable for remote services, which may want to inspect tags,
# rely on exception-free operation, and may wish to receive metadata (that would
# otherwise be handled by event hooks) directly as tagged information. This is
# provided through `generate_unparsed_shots`. Users of this may then choose to
# use `postprocess_unparsed_stream` to extract a (shots, error) tuple from the
# unparsed stream.


# Unparsed interface
def unparsed_interface(
    shot_entries: Iterator[ShotEntry],
    stream: ResultStream,
    process: SeleneProcess,
) -> Iterator[TaggedStreamEntry]:
    """
    Filters the shot entries for tagged results within one shot, yielding them
    one by one, without stripping tags or raising exceptions. When exceptions
    are encountered, they are caught and encoded with special tags such that
    they can be decoded further down the line (e.g. with postprocess_unparsed_stream).

    Each entry is (tag, values), where values is the complete argument list.
    A scalar result has values=[value], an array result has values=[array],
    and a log record retains all of its arguments directly.
    """
    stack_trace: StackTrace = StackTrace()
    pending_panic: SelenePanicError | None = None
    try:
        for entry in shot_entries:
            match entry:
                case UserResult(tag=tag, value=value):
                    yield (tag, [value])
                case UserStateResult():
                    yield (entry.tag, [entry.path])
                case ShotExitMessage(message=message, code=code):
                    yield (message, [code])
                case FullPanicMessage(message=message, code=code):
                    if pending_panic is None:
                        pending_panic = SelenePanicError(message=message, code=code)
                case MetricValue(name=name, value=value):
                    yield (name, [value])
                case DebugTraceMessage(module=module, address=address):
                    stack_trace.add_entry(module=module, address=address)
                case InstructionLogEntry():
                    yield ((entry.tag, entry.values))
                case ShotMeasurements():
                    yield ((entry.tag, entry.values))
        if pending_panic is not None:
            raise pending_panic
    except Exception as caught_error:
        # Preserve a reported panic if draining its supplementary records fails.
        error = pending_panic or caught_error
        # taint the stream to prevent further reading
        stream.taint()
        process.terminate(
            expected_natural_exit=isinstance(
                error, (SelenePanicError, SeleneStartupError)
            )
        )
        process.wait(check_return_code=False)
        # This machine has the executable and its debug artifacts. Symbolize
        # before encoding the exception for transport to another machine.
        stack_trace.symbolize(process.executable)
        # encode the exception as tagged results
        for tag, value in encode_exception(
            error, process.stdout, process.stderr, stack_trace
        ):
            yield (tag, [value])


def _is_tagged_result(value: object) -> TypeGuard[TaggedResult]:
    """Check whether a raw entry contains a supported user-result value."""
    if not isinstance(value, tuple) or len(value) != 2:
        return False
    tag, data = value
    return isinstance(tag, str) and (
        isinstance(data, (int, float, bool))
        or (
            isinstance(data, list)
            and all(isinstance(part, (int, float, bool)) for part in data)
        )
    )


# Post-processing for unparsed streams
def postprocess_unparsed_stream(
    shot_results: Iterable[Iterable[TaggedStreamEntry]],
    event_hook: EventHook | None = None,
) -> tuple[list[list[TaggedResult]], Exception | None]:
    """
    Post-processes a stream of unparsed shots, extracting errors and filtering
    out error-related tags. Returns a list of results for each shot, along with
    any exception that occurred during processing. Raw argument lists are
    unwrapped to the original single-value results; result tags are retained.

    In some cases, results will be stripped out. These cases are as follows:
    - An event_hook is provided that accepts and processes the result entry
      For example, if a MetricStore is provided, then METRICS: tags will accumulate
      in the MetricStore and there will be no METRICS: entries in the final output.
      On the other hand, if no MetricStore is provided, then METRICS: entries will
      remain in the final output.
    - The result type does not conform to TaggedResult
      For example, suppose InstructionLogEntries are present in the result stream.
      These do not have an encoding that matches int|float|bool or a list of these,
      and as such will be stripped out of the final output. However, if an event_hook
      is provided that accepts and processes these entries (e.g. CircuitExtractor),
      then the results will still be available within that hook.
    """
    results: list[list[TaggedResult]] = []

    for shot in shot_results:
        if event_hook is not None:
            event_hook.on_new_shot()
        filtered_shot: list[TaggedResult] = []
        entries = iter(shot)
        for tag, values in entries:
            # Exception metadata consists of single-value records. Keep the
            # existing decoder and its error reporting at this boundary.
            if detect_exception((tag, values)):
                exception = decode_exception((tag, values), _exception_results(entries))
                if isinstance(exception, SelenePanicError):
                    filtered_shot.append(
                        (f"EXIT:INT:{exception.message}", exception.code)
                    )
                if filtered_shot:
                    results.append(filtered_shot)
                return results, exception
            if event_hook is not None and event_hook.try_invoke(tag, values):
                continue
            if len(values) == 1:
                result = (tag, values[0])
                if _is_tagged_result(result):
                    filtered_shot.append(result)
        results.append(filtered_shot)
    return results, None


def _exception_results(entries: Iterator[TaggedStreamEntry]) -> Iterator[TaggedResult]:
    """Unwrap transported exception metadata for the single-value decoder."""
    for tag, values in entries:
        if len(values) != 1:
            raise ValueError(f"Expected a single result value for exception tag {tag}")
        result = (tag, values[0])
        if not _is_tagged_result(result):
            raise ValueError(f"Unsupported result value for exception tag {tag}")
        yield result
