import platform
from dataclasses import dataclass, field
from pathlib import Path
import json
from typing import Optional
from subprocess import run, PIPE, CalledProcessError


def extract_symbols_from_module(module: Path, addresses: list[int]) -> list[dict]:
    import lief

    binary = lief.parse(module)
    if binary is None:
        raise ValueError(f"Failed to parse binary module: {module}")
    imagebase = binary.imagebase
    print(f"IMAGE BASE FOR {module}: {imagebase:#x}")
    rebased_addresses = [binary.imagebase + address for address in addresses]
    dist_dir = Path(__file__).parent / "_dist"
    llvm_symbolizer = dist_dir / "bin/llvm-symbolizer"
    if platform.system() == "Windows":
        llvm_symbolizer = llvm_symbolizer.with_suffix(".exe")
    command = [
        f"{llvm_symbolizer}",
        "--functions=short",
        "--inlines",
        "--output-style=JSON",
        f"--obj={module}",
    ] + [f"{address:#x}" for address in rebased_addresses]
    try:
        print("----------------------------------------------------")
        print(command)
        print("....................................................")
        result = run(command, stdout=PIPE, stderr=PIPE, check=True, text=True)
        output = result.stdout
        print(output)
        print("----------------------------------------------------")
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

    def __str__(self) -> str:
        return "\n".join(f"  at {entry}" for entry in self.entries if entry.symbols)

    def add_entry(self, module: Path, address: int) -> None:
        self.entries.append(StackTraceEntry(module=module, address=address))

    def symbolize(self, executable: Path) -> None:
        if not self.entries:
            return
        modules = {entry.module for entry in self.entries}
        for module in modules:
            relevant_entries = [
                entry for entry in self.entries if entry.module == module
            ]
            addresses = [entry.address for entry in relevant_entries]
            all_symbols = extract_symbols_from_module(module, addresses)
            for entry, symbols in zip(relevant_entries, all_symbols):
                entry.symbols = list(
                    filter(
                        None,
                        [
                            Symbol.from_llvm_symbolizer_dict(symbol)
                            for symbol in symbols["Symbol"]
                        ],
                    )
                )
