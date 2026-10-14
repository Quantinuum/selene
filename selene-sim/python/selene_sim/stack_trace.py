import json
import platform
from dataclasses import dataclass, field
from pathlib import Path
from subprocess import PIPE, CalledProcessError, run
from typing import Optional
from selene_toolchain import tool_environment, tool_path


def create_dsym(executable: Path) -> Path | None:
    """Create or reuse a dSYM bundle without exposing failures to the caller."""
    dsym_path = Path(f"{executable}.dSYM")
    try:
        if (
            dsym_path.exists()
            and dsym_path.stat().st_mtime >= executable.stat().st_mtime
        ):
            return dsym_path
        run(
            [
                str(tool_path("dsymutil")),
                "-o",
                str(dsym_path),
                str(executable),
            ],
            stdout=PIPE,
            stderr=PIPE,
            check=True,
            env=tool_environment(),
        )
    except (OSError, CalledProcessError, RuntimeError):
        return None
    return dsym_path


def run_llvm_symbolizer(
    module: Path,
    addresses: list[int],
    dsym_hint: Path | None = None,
) -> tuple[list[dict] | None, str | None]:
    """Runs llvm-symbolizer on the given module for the given addresses.

    Returns the decoded output and no failure step on success, or no output and a
    concise description of the failed step. Failure is not considered exceptional.
    """
    assert module
    try:
        llvm_symbolizer = tool_path("llvm-symbolizer")
    except RuntimeError:
        return None, "running llvm-symbolizer"

    command = [
        f"{llvm_symbolizer}",
        "--functions=short",
        "--inlines",
        "--output-style=JSON",
        f"--obj={module}",
    ]
    if platform.system() == "Windows":
        # Windows stack frames contain RVAs. llvm-symbolizer will add the PE
        # image base before looking them up.
        command.append("--relative-address")
    if dsym_hint is not None:
        command.append(f"--dsym-hint={dsym_hint}")
    command += [f"{address:#x}" for address in addresses]
    try:
        result = run(
            command,
            stdout=PIPE,
            stderr=PIPE,
            check=True,
            text=True,
            env=tool_environment(),
        )
    except (OSError, CalledProcessError):
        return None, "running llvm-symbolizer"
    try:
        output = json.loads(result.stdout)
        if not isinstance(output, list):
            return None, "reading llvm-symbolizer output"
        return output, None
    except json.JSONDecodeError:
        return None, "reading llvm-symbolizer output"


def extract_symbols_from_module(
    module: Path, addresses: list[int], dsym_hint: Path | None = None
) -> tuple[list[dict] | None, str | None]:
    """Tries to extract symbols from the given module for the given addresses using
    llvm-symbolizer.

    Returns symbol information and any concise failure step.
    """
    assert module
    return run_llvm_symbolizer(module, addresses, dsym_hint)


@dataclass
class Symbol:
    column: int
    line: int
    filename: str
    function_name: str

    @classmethod
    def from_llvm_symbolizer_dict(cls, data: dict) -> Optional["Symbol"]:
        result = cls(
            column=data.get("Column", 0),
            line=data.get("Line", 0),
            filename=data.get("FileName", ""),
            function_name=data.get("FunctionName", ""),
        )
        if result.line > 0:
            # Only return symbols that have a valid line number, as these are meaningful for debugging.
            return result
        return None


@dataclass
class StackTraceEntry:
    module: Path
    address: int
    symbols: list[Symbol] = field(default_factory=list)

    def __str__(self) -> str:
        if self.symbols:
            symbol_strs = [
                f"{symbol.function_name} ({symbol.filename}:{symbol.line}:{symbol.column})"
                for symbol in self.symbols
            ]
            return f"{self.address:#x}: " + " -> ".join(symbol_strs)
        else:
            return f"{self.address:#x}: <no symbols>"


@dataclass
class StackTrace:
    entries: list[StackTraceEntry] = field(default_factory=list)
    symbolization_attempted: bool = False
    symbolization_failure: str | None = None

    def __str__(self) -> str:
        return "\n".join(f"  at {entry}" for entry in self.entries if entry.symbols)

    def add_entry(self, module: Path, address: int) -> None:
        self.entries.append(StackTraceEntry(module=module, address=address))

    def symbolize(self, executable: Path) -> None:
        if not self.entries:
            return
        self.symbolization_attempted = True
        try:
            dsym_hint = None
            if platform.system() == "Darwin":
                dsym_hint = create_dsym(executable)
                if dsym_hint is None:
                    self.symbolization_failure = "creating macOS debug symbols"

            modules = {entry.module for entry in self.entries}
            for module in modules:
                relevant_entries = [
                    entry for entry in self.entries if entry.module == module
                ]
                addresses = [entry.address for entry in relevant_entries]
                all_symbols, failure = extract_symbols_from_module(
                    module, addresses, dsym_hint
                )
                if failure is not None:
                    if self.symbolization_failure is None:
                        self.symbolization_failure = failure
                    continue
                if all_symbols is None:
                    continue

                parsed_symbols: list[list[Symbol]] = []
                for entry, symbols in zip(relevant_entries, all_symbols, strict=True):
                    entry_symbols = []
                    for symbol in symbols["Symbol"]:
                        parsed_symbol = Symbol.from_llvm_symbolizer_dict(symbol)
                        if parsed_symbol is not None:
                            entry_symbols.append(parsed_symbol)
                    parsed_symbols.append(entry_symbols)
                for entry, entry_symbols in zip(
                    relevant_entries, parsed_symbols, strict=True
                ):
                    entry.symbols = entry_symbols
        except (AttributeError, KeyError, TypeError, ValueError):
            self.symbolization_failure = "processing llvm-symbolizer output"
        except Exception:
            # Stack traces are supplementary: never mask the original exception.
            self.symbolization_failure = "processing stack trace information"
