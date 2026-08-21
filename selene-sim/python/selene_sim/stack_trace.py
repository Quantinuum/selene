import platform
from dataclasses import dataclass, field
from pathlib import Path
import json
from typing import Optional
from subprocess import run, PIPE, CalledProcessError


def run_llvm_symbolizer(module: Path, addresses: list[int]) -> list[dict] | None:
    """Runs llvm-symbolizer on the given module for the given addresses.

    Returns a list of dictionaries containing symbol information if successful, or None
    otherwise (failure is not considered exceptional).
    """
    assert module
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
    ] + [f"{address:#x}" for address in addresses]
    try:
        result = run(command, stdout=PIPE, stderr=PIPE, check=True, text=True)
        output = result.stdout
        return json.loads(output)
    except CalledProcessError:
        # There are many reasons why llvm-symbolizer could fail, so we just
        # accept it and return None to passively indicate failure.
        return None


def extract_symbols_from_module(
    module: Path, addresses: list[int]
) -> list[dict] | None:
    """Tries to extract symbols from the given module for the given addresses using
    llvm-symbolizer. On macOS, this will also attempt to generate a dSYM file if one does
    not already exist.

    Returns a list of dictionaries containing symbol information if successful, or None
    otherwise (failure is not considered exceptional).
    """
    assert module
    import lief

    dist_dir = Path(__file__).parent / "_dist"

    module_details = lief.parse(module)
    if module_details is None:
        # This is taken as a pretty good sign not to proceed with
        # symbolization, so we return None to indicate failure.
        return None

    if isinstance(module_details, lief.MachO.Binary):
        # we instead need to look at the accompanying .dSYM file.
        dsym_path = module.with_suffix(".dSYM")
        if not dsym_path.exists() or dsym_path.stat().st_mtime < module.stat().st_mtime:
            # We can try to create it with dsymutil.
            try:
                # don't write to stderr
                run(
                    [dist_dir / "bin/dsymutil", str(module)],
                    stdout=PIPE,
                    stderr=PIPE,
                    check=True,
                )
            except CalledProcessError:
                # There are many reasons why dsymutil could fail, so we just
                # accept it and return None to passively indicate failure.
                return None
            module = dsym_path

    if hasattr(module_details, "imagebase"):
        image_base = module_details.imagebase
    else:
        image_base = 0

    rebased_addresses = [image_base + address for address in addresses]
    return run_llvm_symbolizer(module, rebased_addresses)


@dataclass
class Symbol:
    column: int
    line: int
    filename: str
    function_name: str

    @classmethod
    def from_llvm_symbolizer_dict(cls, data: dict) -> Optional["Symbol"]:
        print("from_llvm_symbolizer_dict", data)
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
            if all_symbols is None:
                # If symbolization fails, we leave the entry as it was.
                continue

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
