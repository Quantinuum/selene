from selene_sim.stack_trace import StackTrace


def maybe_provide_stack_trace(stack_trace: StackTrace | None) -> str:
    if stack_trace is None or not stack_trace.entries:
        return ""

    rendered_stack_trace = str(stack_trace)
    failure = stack_trace.symbolization_failure

    if not rendered_stack_trace:
        if failure is not None:
            return (
                "\nAn attempt was made to establish the stack trace, but it failed "
                f"while {failure}."
            )
        if not stack_trace.symbolization_attempted:
            return (
                "\nStack trace addresses were captured, but symbolization was not "
                "attempted."
            )
        return ""

    result = f"\nStack trace:\n{rendered_stack_trace}"
    if failure is None:
        return result
    return (
        f"{result}\nSome stack trace information may be unavailable because "
        f"the attempt failed while {failure}."
    )


def maybe_provide_log(name, contents):
    if len(contents) == 0:
        return ""
    return f"""
----- {name} -----
{contents}
------------------
"""


class SeleneBuildError(Exception):
    """
    Raised when selene fails to build the user program.
    """

    def __init__(
        self,
        message: str,
        stdout: str = "",
        stderr: str = "",
        stack_trace: StackTrace | None = None,
    ):
        self.message = message
        self.stdout = stdout
        self.stderr = stderr
        self.stack_trace = stack_trace

    def __reduce__(self):
        return (
            self.__class__,
            (self.message, self.stdout, self.stderr, self.stack_trace),
        )

    def __str__(self):
        return (
            self.message
            + maybe_provide_stack_trace(self.stack_trace)
            + maybe_provide_log("stdout", self.stdout)
            + maybe_provide_log("stderr", self.stderr)
        )


class SeleneStartupError(Exception):
    """
    Raised when selene fails to start up, and closes before it
    connects to the result stream. This is is likely to be a
    sign of invalid arguments being passed in.
    """

    def __init__(
        self,
        message: str,
        stdout: str = "",
        stderr: str = "",
        stack_trace: StackTrace | None = None,
    ):
        self.message = message
        self.stdout = stdout
        self.stderr = stderr
        self.stack_trace = stack_trace

    def __reduce__(self):
        return (
            self.__class__,
            (self.message, self.stdout, self.stderr, self.stack_trace),
        )

    def __str__(self):
        return (
            self.message
            + maybe_provide_stack_trace(self.stack_trace)
            + maybe_provide_log("stdout", self.stdout)
            + maybe_provide_log("stderr", self.stderr)
        )


class SeleneRuntimeError(Exception):
    """
    Raised when the user program and/or selene crash during execution,
    without a panic being issued through the results channel.
    """

    def __init__(
        self,
        message: str,
        stdout: str = "",
        stderr: str = "",
        stack_trace: StackTrace | None = None,
    ):
        self.message = message
        self.stdout = stdout
        self.stderr = stderr
        self.stack_trace = stack_trace

    def __reduce__(self):
        return (
            self.__class__,
            (self.message, self.stdout, self.stderr, self.stack_trace),
        )

    def __str__(self):
        return (
            self.message
            + maybe_provide_stack_trace(self.stack_trace)
            + maybe_provide_log("stdout", self.stdout)
            + maybe_provide_log("stderr", self.stderr)
        )


class SelenePanicError(Exception):
    """
    Raised when the user program issues a panic with error_code
    > 1000, i.e. all remaining shots are halted.
    """

    def __init__(
        self,
        message: str,
        code: int,
        stdout: str = "",
        stderr: str = "",
        stack_trace: StackTrace | None = None,
    ):
        self.message = message
        self.code = code
        self.stdout = stdout
        self.stderr = stderr
        self.stack_trace = stack_trace

    def __reduce__(self):
        return (
            self.__class__,
            (self.message, self.code, self.stdout, self.stderr, self.stack_trace),
        )

    def __str__(self):
        return (
            f"Panic (#{self.code}): {self.message}"
            + maybe_provide_stack_trace(self.stack_trace)
            + maybe_provide_log("stdout", self.stdout)
            + maybe_provide_log("stderr", self.stderr)
        )


class SeleneTimeoutError(Exception):
    """
    Raised when the user program times out.
    """

    def __init__(
        self,
        message: str,
        stdout: str = "",
        stderr: str = "",
        stack_trace: StackTrace | None = None,
    ):
        self.message = message
        self.stdout = stdout
        self.stderr = stderr
        self.stack_trace = stack_trace

    def __reduce__(self):
        return (
            self.__class__,
            (self.message, self.stdout, self.stderr, self.stack_trace),
        )

    def __str__(self):
        return (
            f"Timeout: {self.message}"
            + maybe_provide_stack_trace(self.stack_trace)
            + maybe_provide_log("stdout", self.stdout)
            + maybe_provide_log("stderr", self.stderr)
        )
