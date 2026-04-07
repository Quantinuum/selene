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
            # MachO: undefined symbols are marked as external, and defined symbols are not.
            is_defined = not macho_symbol.is_external
            symbol_table.add_function(demangle(str(macho_symbol.name)), is_defined)
        return symbol_table

    elif isinstance(binary, lief.PE.Binary):
        symbol_table = SymbolTable()
        for s in binary.symbols:
            # PE: undefined symbols have value == 0 and section number == 0
            is_defined = not (s.value == 0 and s.section_number == 0)
            symbol_table.add_function(str(s.name), is_defined)
        return symbol_table

    elif isinstance(binary, lief.COFF.Binary):
        symbol_table = SymbolTable()
        for s in binary.symbols:
            # COFF: undefined symbols have value == 0 and section number == 0
            is_defined = not (s.value == 0 and s.section_number == 0)
            symbol_table.add_function(str(s.name), is_defined)
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
    from llvmlite import binding as llvm

    mod: llvm.ModuleRef

    if isinstance(contents, Path):
        if contents.suffix == ".ll":
            mod = llvm.parse_assembly(contents.read_text())
        elif contents.suffix == ".bc":
            mod = llvm.parse_bitcode(contents.read_bytes())
        else:
            raise ValueError(
                f"Unsupported file extension for LLVM contents: {contents.suffix}"
            )
    elif isinstance(contents, str):
        mod = llvm.parse_assembly(contents)
    elif isinstance(contents, bytes):
        mod = llvm.parse_bitcode(contents)
    else:
        raise TypeError(f"Unsupported type for LLVM contents: {type(contents)}")

    symbol_table = SymbolTable()
    for func in mod.functions:
        name = str(func.name)
        if name.startswith("llvm."):
            # skip llvm intrinsics
            continue
        symbol_table.add_function(name, not func.is_declaration)
    return symbol_table
