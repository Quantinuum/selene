from pathlib import Path


class SymbolTable:
    undefined_functions: set[str]
    defined_functions: set[str]

    def __init__(self):
        self.undefined_functions = set()
        self.defined_functions = set()

    def add_function(self, symbol: str, is_defined: bool):
        if is_defined:
            self.defined_functions.add(symbol)
        else:
            self.undefined_functions.add(symbol)

    def has_defined_function(self, symbol: str) -> bool:
        return symbol in self.defined_functions

    def has_undefined_function(self, symbol: str) -> bool:
        return symbol in self.undefined_functions


def get_symbols_from_object(object: Path | bytes) -> SymbolTable:
    """
    Extract defined and undefined linker symbols from an object file or bytes.

    This function is useful for inspection of object files, such as in the `matches`
    methods of ArtifactKind specialisations.
    """
    from selene_toolchain import inspect_object

    symbols = inspect_object(object)
    symbol_table = SymbolTable()
    for name in symbols.defined_symbols:
        symbol_table.add_function(name, True)
    for name in symbols.undefined_symbols:
        symbol_table.add_function(name, False)
    return symbol_table


def get_symbols_from_llvm(contents: str | Path | bytes) -> SymbolTable:
    """
    Extract symbols from LLVM (IR as a string or path, or bitcode as a string or path).
    """
    from selene_toolchain import inspect_module

    symbols = inspect_module(contents)
    symbol_table = SymbolTable()
    for name in symbols.defined_functions:
        symbol_table.add_function(name, True)
    for name in symbols.declared_functions:
        symbol_table.add_function(name, False)
    return symbol_table
