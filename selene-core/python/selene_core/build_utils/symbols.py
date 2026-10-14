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
    Extract undefined symbols from an object file or bytes, with help from
    the `lief` library.

    This function is useful for inspection of object files, such as in the `matches`
    methods of ArtifactKind specialisations.
    """
    import lief

    # lief.parse() can take a path or the bytes in the form of a list[int].
    # It can take a bytes type directly, but this is assumed to be a file path
    # rather than raw bytes.
    lief_input: Path | list[int] = list(object) if isinstance(object, bytes) else object
    binary = lief.parse(lief_input)

    if isinstance(binary, lief.ELF.Binary):
        symbol_table = SymbolTable()
        for elf_symbol in binary.symbols:
            # ELF: undefined symbols have shndx == 0 (SHN_UNDEF)
            is_defined = not (elf_symbol.shndx == 0 and elf_symbol.value == 0)
            symbol_table.add_function(str(elf_symbol.name), is_defined)
        return symbol_table

    elif isinstance(binary, lief.MachO.Binary):

        def demangle(name: str):
            return str(name[1:] if name.startswith("_") else name)

        symbol_table = SymbolTable()
        for macho_symbol in binary.symbols:
            # Mach-O: undefined symbols can be identified by their symbol type being "UNDEFINED"
            is_defined = macho_symbol.type.name != "UNDEFINED"
            symbol_table.add_function(demangle(str(macho_symbol.name)), is_defined)
        return symbol_table

    elif isinstance(binary, (lief.PE.Binary, lief.COFF.Binary)):
        symbol_table = SymbolTable()
        for s in binary.symbols:
            symbol_table.add_function(str(s.name), not s.is_undefined)
        return symbol_table

    if binary is not None:
        # lief.parse() didn't return None, but it didn't return a binary type we can handle
        # in selene yet. If we reach this error, it's possible that adding support is low-
        # hanging fruit.
        raise NotImplementedError(
            f"Unsupported binary format {type(object)} for undefined symbol extraction"
        )
    else:
        # lief.parse() returned None, which means the binary format is not supported (yet),
        # and we can't add support in Selene unless it does (or we find another approach).
        raise RuntimeError(
            "The provided binary format of is not yet supported by Lief, which is used by Selene for identifying undefined symbols."
        )


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
