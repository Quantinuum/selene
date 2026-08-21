import platform
from dataclasses import dataclass, field
from pathlib import Path
import json
from typing import Optional
from subprocess import run, PIPE, CalledProcessError


def extract_symbols_from_program(program: Path, addresses: list[int]) -> list[dict]:
    dist_dir = Path(__file__).parent / "_dist"
    llvm_symbolizer = dist_dir / "bin/llvm-symbolizer"
    if platform.system() == "Windows":
        llvm_symbolizer = llvm_symbolizer.with_suffix(".exe")
    command = [
        f"{llvm_symbolizer}",
        "--functions=short",
        "--inlines",
        "--output-style=JSON",
        f"--obj={program}",
    ] + [f"{address:#x}" for address in addresses]
    try:
        result = run(command, stdout=PIPE, stderr=PIPE, check=True, text=True)
        output = result.stdout
        return json.loads(output)

    except CalledProcessError as e:
        print(f"Error running llvm-symbolizer: {e.stderr}")
        raise


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
        # TODO: remove this, just for debugging actions on macos/windows
        print(data)
        return None


@dataclass
class StackTraceEntry:
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

    def __str__(self) -> str:
        return "\n".join(f"  at {entry}" for entry in self.entries if entry.symbols)

    def add_entry(self, address: int) -> None:
        self.entries.append(StackTraceEntry(address=address))

    def symbolize(self, executable: Path) -> None:
        if not self.entries:
            return
        addresses = [entry.address for entry in self.entries]
        all_symbols = extract_symbols_from_program(executable, addresses)
        for entry, symbols in zip(self.entries, all_symbols):
            entry.symbols = list(
                filter(
                    None,
                    [
                        Symbol.from_llvm_symbolizer_dict(symbol)
                        for symbol in symbols["Symbol"]
                    ],
                )
            )
