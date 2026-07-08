from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from io import BytesIO
from pathlib import Path
from typing import Any, BinaryIO, Protocol

from .trace import DebugStackFrame, GateEvent, Trace

QIS_MODULE_METADATA = "qis.call_site.module"
QIS_MODULE_OFFSET_METADATA = "qis.call_site.module_offset"
QIS_RETURN_ADDRESS_METADATA = "qis.call_site.return_address"
ELF_MAGIC = b"\x7fELF"
MACHO_MAGICS = {
    b"\xfe\xed\xfa\xce",
    b"\xfe\xed\xfa\xcf",
    b"\xce\xfa\xed\xfe",
    b"\xcf\xfa\xed\xfe",
    b"\xca\xfe\xba\xbe",
}
PE_MAGIC = b"MZ"


class _ObjectFormat(Enum):
    ELF = "elf"
    MACHO = "mach-o"
    PE = "pe"
    UNKNOWN = "unknown"


@dataclass(frozen=True)
class _LineEntry:
    start: int
    end: int
    file: str | None
    line: int | None
    column: int | None


@dataclass(frozen=True)
class _FunctionRange:
    start: int
    end: int
    name: str


@dataclass(frozen=True)
class _SymbolicSite:
    function: str
    offset: int


class _DebugInfo(Protocol):
    def close(self) -> None: ...

    def symbolize(
        self, module_offset: int | None, return_address: int | None
    ) -> list[DebugStackFrame]: ...


class _CompositeDebugInfo:
    def __init__(self, primary: _DebugInfo | None, fallbacks: list[_DebugInfo]):
        self.primary = primary
        self.fallbacks = fallbacks

    def close(self) -> None:
        if self.primary is not None:
            self.primary.close()
        for fallback in self.fallbacks:
            fallback.close()

    def symbolize(
        self, module_offset: int | None, return_address: int | None
    ) -> list[DebugStackFrame]:
        if self.primary is not None:
            stack = self.primary.symbolize(module_offset, return_address)
            if any(frame.file is not None or frame.line is not None for frame in stack):
                return stack

        for fallback in self.fallbacks:
            stack = fallback.symbolize(module_offset, return_address)
            if stack:
                return stack

        if isinstance(self.primary, _SymbolicDebugInfo):
            site = self.primary.symbolic_site(module_offset, return_address)
            if site is not None:
                for fallback in self.fallbacks:
                    if isinstance(fallback, _DwarfDebugInfo):
                        frame = fallback.symbolize_function_offset(
                            site.function, site.offset
                        )
                        if frame is not None:
                            return [frame]

        if self.primary is not None:
            return self.primary.symbolize(module_offset, return_address)
        return []


class _SymbolicDebugInfo:
    def __init__(self, path: Path):
        from symbolic.debuginfo import Archive

        self.archive = Archive.open(str(path))
        self.symcache = next(self.archive.iter_objects()).make_symcache()
        self._cache: dict[tuple[int | None, int | None], list[DebugStackFrame]] = {}

    def close(self) -> None:
        pass

    def symbolize(
        self, module_offset: int | None, return_address: int | None
    ) -> list[DebugStackFrame]:
        key = (module_offset, return_address)
        if key in self._cache:
            return self._cache[key]

        for address in self._address_candidates(module_offset, return_address):
            stack = [
                DebugStackFrame(
                    function=_symbolic_function_name(location.symbol),
                    file=location.full_path or None,
                    line=location.line or None,
                )
                for location in self.symcache.lookup(address)
            ]
            if stack:
                self._cache[key] = stack
                return stack

        self._cache[key] = []
        return []

    def symbolic_site(
        self, module_offset: int | None, return_address: int | None
    ) -> _SymbolicSite | None:
        for address in self._address_candidates(module_offset, return_address):
            for location in self.symcache.lookup(address):
                if (
                    location.symbol
                    and location.sym_addr is not None
                    and location.instr_addr is not None
                    and location.instr_addr >= location.sym_addr
                ):
                    return _SymbolicSite(
                        function=_symbolic_function_name(location.symbol)
                        or location.symbol,
                        offset=int(location.instr_addr - location.sym_addr),
                    )
        return None

    @staticmethod
    def _address_candidates(
        module_offset: int | None, return_address: int | None
    ) -> list[int]:
        candidates = []
        for address in (module_offset, return_address):
            if address is not None and address > 0 and address - 1 not in candidates:
                candidates.append(address - 1)
        for address in (module_offset, return_address):
            if address is not None and address not in candidates:
                candidates.append(address)
        return candidates


class _DwarfDebugInfo:
    """DWARF symbolizer.

    This backend is intentionally in-process and does not shell out to tools like
    addr2line. ELF is read directly through pyelftools. Mach-O and PE files are
    parsed with filebytes to expose their embedded DWARF sections to pyelftools.
    """

    def __init__(
        self,
        path: Path,
        dwarf,
        min_load_address: int | None,
        file: BinaryIO | None = None,
    ):
        self.path = path
        self._file = file
        self._dwarf = dwarf
        self._lines = self._collect_lines()
        self._functions = self._collect_functions()
        self._cache: dict[tuple[int | None, int | None], list[DebugStackFrame]] = {}
        self._min_load_address = min_load_address

    @classmethod
    def from_elf(cls, path: Path) -> "_DwarfDebugInfo":
        from elftools.elf.elffile import ELFFile

        file = path.open("rb")
        try:
            elf = ELFFile(file)
            dwarf = elf.get_dwarf_info() if elf.has_dwarf_info() else None
            min_load_address = _elf_min_load_address(elf)
            return cls(path, dwarf, min_load_address, file=file)
        except Exception:
            file.close()
            raise

    @classmethod
    def from_macho(cls, path: Path) -> "_DwarfDebugInfo":
        from filebytes.mach_o import MachO

        macho = MachO(str(path))
        if macho.isFat:
            for thin in macho.fatArches:
                section_map = _macho_dwarf_sections(thin)
                if section_map:
                    return cls(
                        path,
                        _dwarf_info_from_sections(
                            section_map,
                            little_endian=_macho_is_little_endian(thin),
                            address_size=_macho_address_size(thin),
                            machine_arch="x64",
                        ),
                        max(thin.imageBase, 0),
                    )
            return cls(path, None, None)

        section_map = _macho_dwarf_sections(macho)
        return cls(
            path,
            _dwarf_info_from_sections(
                section_map,
                little_endian=_macho_is_little_endian(macho),
                address_size=_macho_address_size(macho),
                machine_arch="x64",
            ),
            max(macho.imageBase, 0),
        )

    @classmethod
    def from_pe(cls, path: Path) -> "_DwarfDebugInfo":
        from filebytes.pe import PE

        pe = PE(str(path))
        section_map = _pe_dwarf_sections(pe)
        return cls(
            path,
            _dwarf_info_from_sections(
                section_map,
                little_endian=True,
                address_size=8 if pe.imageBase > 0xFFFFFFFF else 4,
                machine_arch="x64",
            ),
            pe.imageBase,
        )

    def close(self) -> None:
        if self._file is not None:
            self._file.close()

    def symbolize(
        self, module_offset: int | None, return_address: int | None
    ) -> list[DebugStackFrame]:
        key = (module_offset, return_address)
        if key in self._cache:
            return self._cache[key]

        for address in self._address_candidates(module_offset, return_address):
            frame = self._symbolize_address(address)
            if frame is not None:
                self._cache[key] = [frame]
                return [frame]

        self._cache[key] = []
        return []

    def _address_candidates(
        self, module_offset: int | None, return_address: int | None
    ) -> list[int]:
        candidates = []
        raw_candidates = [
            return_address,
            module_offset,
            (
                self._min_load_address + module_offset
                if self._min_load_address is not None and module_offset is not None
                else None
            ),
        ]
        for address in raw_candidates:
            if address is not None and address > 0 and address - 1 not in candidates:
                candidates.append(address - 1)
        for address in raw_candidates:
            if address is not None and address not in candidates:
                candidates.append(address)
        return candidates

    def _symbolize_address(self, address: int) -> DebugStackFrame | None:
        line = self._find_line(address)
        function = self._find_function(address)
        if line is None and function is None:
            return None
        return DebugStackFrame(
            function=function.name if function is not None else None,
            file=line.file if line is not None else None,
            line=line.line if line is not None else None,
            column=line.column if line is not None else None,
        )

    def symbolize_function_offset(
        self, function_name: str, offset: int
    ) -> DebugStackFrame | None:
        function = self._find_named_function(function_name)
        if function is None:
            return None
        return self._symbolize_address(function.start + offset)

    def _find_line(self, address: int) -> _LineEntry | None:
        for line in self._lines:
            if line.start <= address < line.end:
                return line
        return None

    def _find_function(self, address: int) -> _FunctionRange | None:
        matches = [
            function
            for function in self._functions
            if function.start <= address < function.end
        ]
        if not matches:
            return None
        return min(matches, key=lambda function: function.end - function.start)

    def _find_named_function(self, name: str) -> _FunctionRange | None:
        matches = [function for function in self._functions if function.name == name]
        if not matches:
            return None
        return min(matches, key=lambda function: function.end - function.start)

    def _collect_lines(self) -> list[_LineEntry]:
        if self._dwarf is None:
            return []
        result = []
        for cu in self._dwarf.iter_CUs():
            line_program = self._dwarf.line_program_for_CU(cu)
            if line_program is None:
                continue
            previous_state = None
            for entry in line_program.get_entries():
                state = entry.state
                if state is None:
                    continue
                if previous_state is not None and not previous_state.end_sequence:
                    if previous_state.address <= state.address:
                        result.append(
                            _LineEntry(
                                start=previous_state.address,
                                end=state.address,
                                file=self._resolve_line_file(
                                    cu, line_program, previous_state.file
                                ),
                                line=previous_state.line,
                                column=previous_state.column,
                            )
                        )
                previous_state = None if state.end_sequence else state
        return result

    def _collect_functions(self) -> list[_FunctionRange]:
        if self._dwarf is None:
            return []
        result = []
        for cu in self._dwarf.iter_CUs():
            for die in cu.iter_DIEs():
                if die.tag not in {"DW_TAG_subprogram", "DW_TAG_inlined_subroutine"}:
                    continue
                name = self._die_name(die)
                bounds = self._die_bounds(die)
                if name is not None and bounds is not None:
                    result.append(_FunctionRange(bounds[0], bounds[1], name))
        return result

    def _die_name(self, die) -> str | None:
        name_attr = die.attributes.get("DW_AT_name")
        if name_attr is not None:
            return self._decode(name_attr.value)
        return None

    def _die_bounds(self, die) -> tuple[int, int] | None:
        from elftools.dwarf.descriptions import describe_form_class

        low_pc = die.attributes.get("DW_AT_low_pc")
        high_pc = die.attributes.get("DW_AT_high_pc")
        if low_pc is None or high_pc is None:
            return None
        start = int(low_pc.value)
        if describe_form_class(high_pc.form) == "address":
            end = int(high_pc.value)
        else:
            end = start + int(high_pc.value)
        if end <= start:
            return None
        return start, end

    def _resolve_line_file(self, cu, line_program, file_index: int) -> str | None:
        if file_index <= 0:
            return None
        files = line_program.header.get("file_entry") or line_program.header.get(
            "file_names"
        )
        if not files or file_index > len(files):
            return None
        file_entry = files[file_index - 1]
        name = self._decode(file_entry.name)
        if not name:
            return None
        path = Path(name)
        if path.is_absolute():
            return str(path)

        directory = self._line_file_directory(cu, line_program, file_entry)
        if directory:
            return str(Path(directory) / path)
        return str(path)

    def _line_file_directory(self, cu, line_program, file_entry) -> str | None:
        dir_index = getattr(file_entry, "dir_index", 0)
        if dir_index:
            directories = (
                line_program.header.get("include_directory")
                or line_program.header.get("directories")
                or []
            )
            if 0 < dir_index <= len(directories):
                return self._decode(directories[dir_index - 1])

        top_die = cu.get_top_DIE()
        comp_dir = top_die.attributes.get("DW_AT_comp_dir")
        if comp_dir is not None:
            return self._decode(comp_dir.value)
        return None

    @staticmethod
    def _decode(value) -> str:
        if isinstance(value, bytes):
            return value.decode("utf-8", errors="replace")
        return str(value)


class QisCallSiteSymbolizer:
    def __init__(self) -> None:
        self._modules: dict[Path, _DebugInfo | None] = {}

    def close(self) -> None:
        for module in self._modules.values():
            if module is not None:
                module.close()
        self._modules.clear()

    def symbolize_event(self, event: GateEvent) -> list[DebugStackFrame]:
        module_path = event.metadata.get(QIS_MODULE_METADATA)
        if not isinstance(module_path, str):
            return []

        module_offset = self._metadata_int(event, QIS_MODULE_OFFSET_METADATA)
        return_address = self._metadata_int(event, QIS_RETURN_ADDRESS_METADATA)
        if module_offset is None and return_address is None:
            return []

        module = self._module(Path(module_path))
        if module is None:
            return []
        return module.symbolize(module_offset, return_address)

    def _module(self, path: Path) -> _DebugInfo | None:
        if path in self._modules:
            return self._modules[path]
        object_format = _detect_object_format(path)
        module: _DebugInfo | None
        fallbacks: list[_DebugInfo] = []
        try:
            primary = _SymbolicDebugInfo(path)
        except Exception:
            primary = None
        try:
            match object_format:
                case _ObjectFormat.ELF:
                    fallbacks.append(_DwarfDebugInfo.from_elf(path))
                case _ObjectFormat.MACHO:
                    fallbacks.append(_DwarfDebugInfo.from_macho(path))
                case _ObjectFormat.PE:
                    fallbacks.append(_DwarfDebugInfo.from_pe(path))
                case _:
                    pass
        except Exception:
            pass

        fallbacks.extend(_load_debug_object_modules(path))

        if primary is not None or fallbacks:
            module = _CompositeDebugInfo(primary, fallbacks)
        else:
            module = None
        self._modules[path] = module
        return module

    @staticmethod
    def _metadata_int(event: GateEvent, key: str) -> int | None:
        value = event.metadata.get(key)
        if isinstance(value, bool):
            return None
        if isinstance(value, int):
            return value
        return None


def _detect_object_format(path: Path) -> _ObjectFormat:
    try:
        with path.open("rb") as fh:
            magic = fh.read(4)
    except OSError:
        return _ObjectFormat.UNKNOWN

    if magic == ELF_MAGIC:
        return _ObjectFormat.ELF
    if magic[:2] == PE_MAGIC:
        return _ObjectFormat.PE
    if magic in MACHO_MAGICS:
        return _ObjectFormat.MACHO
    return _ObjectFormat.UNKNOWN


def _symbolic_function_name(name: str | None) -> str | None:
    if name is None:
        return None
    bare_name, separator, _signature = name.partition("(")
    if (
        separator
        and name.endswith(")")
        and bare_name
        and (bare_name[0].isalpha() or bare_name[0] == "_")
        and all(char.isalnum() or char == "_" for char in bare_name)
    ):
        return bare_name
    return name


def _load_debug_object_modules(module_path: Path) -> list[_DebugInfo]:
    modules: list[_DebugInfo] = []
    for debug_object in _debug_object_paths(module_path):
        if debug_object.suffix.lower() == ".pdb":
            try:
                modules.append(_SymbolicDebugInfo(debug_object))
                continue
            except Exception:
                pass
        try:
            match _detect_object_format(debug_object):
                case _ObjectFormat.ELF:
                    modules.append(_DwarfDebugInfo.from_elf(debug_object))
                case _ObjectFormat.MACHO:
                    modules.append(_DwarfDebugInfo.from_macho(debug_object))
                case _ObjectFormat.PE:
                    modules.append(_DwarfDebugInfo.from_pe(debug_object))
                case _:
                    pass
        except Exception:
            pass
    return modules


def _debug_object_paths(module_path: Path) -> list[Path]:
    paths = []
    seen = set()
    for path in [
        *_manifest_debug_objects(module_path),
        *_sibling_debug_objects(module_path),
    ]:
        try:
            key = path.resolve(strict=False)
        except OSError:
            key = path
        if key not in seen:
            paths.append(path)
            seen.add(key)
    return paths


def _sibling_debug_objects(module_path: Path) -> list[Path]:
    pdb_path = module_path.with_suffix(".pdb")
    return [pdb_path] if pdb_path.is_file() else []


def _manifest_debug_objects(module_path: Path) -> list[Path]:
    manifest_path = _manifest_path_for_module(module_path)
    if manifest_path is None:
        return []

    try:
        import yaml

        manifest = yaml.safe_load(manifest_path.read_text())
    except Exception:
        return []

    if not isinstance(manifest, dict):
        return []
    artifacts = manifest.get("artifacts")
    if not isinstance(artifacts, list):
        return []

    for artifact in artifacts:
        if not isinstance(artifact, dict):
            continue
        resource = artifact.get("resource")
        if not isinstance(resource, str):
            continue
        if not _same_path(Path(resource), module_path):
            continue
        metadata = artifact.get("metadata")
        if not isinstance(metadata, dict):
            return []
        return _coerce_debug_object_paths(metadata.get("debug_objects"), manifest_path)
    return []


def _manifest_path_for_module(module_path: Path) -> Path | None:
    for candidate in (
        module_path.parent.parent / "selene.yaml",
        module_path.parent / "selene.yaml",
    ):
        if candidate.is_file():
            return candidate
    return None


def _same_path(left: Path, right: Path) -> bool:
    try:
        return left.resolve(strict=False) == right.resolve(strict=False)
    except OSError:
        return left == right


def _coerce_debug_object_paths(value: Any, manifest_path: Path) -> list[Path]:
    if not isinstance(value, list):
        return []
    result = []
    for item in value:
        if not isinstance(item, str):
            continue
        path = Path(item)
        if not path.is_absolute():
            path = manifest_path.parent / path
        if path.is_file():
            result.append(path)
    return result


@dataclass(frozen=True)
class _DebugSection:
    data: bytes
    offset: int
    address: int


def _elf_min_load_address(elf) -> int | None:
    addresses = []
    for segment in elf.iter_segments():
        if segment.header.p_type == "PT_LOAD":
            addresses.append(int(segment.header.p_vaddr))
    return min(addresses) if addresses else None


def _macho_dwarf_sections(macho) -> dict[str, _DebugSection]:
    sections = {}
    for command in macho.loadCommands:
        if not hasattr(command, "sections"):
            continue
        for section in command.sections:
            if section.name.startswith("__debug_"):
                name = "." + section.name[2:]
            elif section.name == "__eh_frame":
                name = ".eh_frame"
            else:
                continue
            sections[name] = _DebugSection(
                data=bytes(section.raw)[: section.header.size],
                offset=int(section.header.offset),
                address=int(section.header.addr),
            )
    return sections


def _macho_is_little_endian(macho) -> bool:
    magic = int(macho.machHeader.header.magic)
    return magic in {0xFEEDFACE, 0xFEEDFACF}


def _macho_address_size(macho) -> int:
    magic = int(macho.machHeader.header.magic)
    return 8 if magic in {0xFEEDFACF, 0xCFFAEDFE} else 4


def _pe_dwarf_sections(pe) -> dict[str, _DebugSection]:
    sections = {}
    for section in pe.sections:
        if not section.name.startswith(".debug_"):
            continue
        size = int(section.header.PhysicalAddress_or_VirtualSize)
        sections[section.name] = _DebugSection(
            data=bytes(section.raw)[:size],
            offset=int(section.header.PointerToRawData),
            address=int(pe.imageBase + section.header.VirtualAddress),
        )
    return sections


def _dwarf_info_from_sections(
    sections: dict[str, _DebugSection],
    *,
    little_endian: bool,
    address_size: int,
    machine_arch: str,
):
    if ".debug_info" not in sections or ".debug_abbrev" not in sections:
        return None

    from elftools.dwarf.dwarfinfo import (
        DWARFInfo,
        DebugSectionDescriptor,
        DwarfConfig,
    )

    def descriptor(name: str):
        section = sections.get(name)
        if section is None:
            return None
        return DebugSectionDescriptor(
            BytesIO(section.data),
            name,
            section.offset,
            len(section.data),
            section.address,
        )

    return DWARFInfo(
        config=DwarfConfig(
            little_endian=little_endian,
            machine_arch=machine_arch,
            default_address_size=address_size,
        ),
        debug_info_sec=descriptor(".debug_info"),
        debug_aranges_sec=descriptor(".debug_aranges"),
        debug_abbrev_sec=descriptor(".debug_abbrev"),
        debug_frame_sec=descriptor(".debug_frame"),
        eh_frame_sec=descriptor(".eh_frame"),
        debug_str_sec=descriptor(".debug_str"),
        debug_loc_sec=descriptor(".debug_loc"),
        debug_ranges_sec=descriptor(".debug_ranges"),
        debug_line_sec=descriptor(".debug_line"),
        debug_pubtypes_sec=descriptor(".debug_pubtypes"),
        debug_pubnames_sec=descriptor(".debug_pubnames"),
        debug_addr_sec=descriptor(".debug_addr"),
        debug_str_offsets_sec=descriptor(".debug_str_offsets"),
        debug_line_str_sec=descriptor(".debug_line_str"),
        debug_loclists_sec=descriptor(".debug_loclists"),
        debug_rnglists_sec=descriptor(".debug_rnglists"),
        debug_sup_sec=descriptor(".debug_sup"),
        gnu_debugaltlink_sec=descriptor(".gnu_debugaltlink"),
        debug_types_sec=descriptor(".debug_types"),
    )


def symbolize_qis_call_sites(
    trace: Trace, symbolizer: QisCallSiteSymbolizer | None = None
) -> Trace:
    """Return a copy of ``trace`` with QIS PC metadata expanded to debug frames.

    The current implementation supports ELF, Mach-O, and PE binaries with DWARF
    debug info. Native Windows PDB symbolization is not supported.
    """

    owns_symbolizer = symbolizer is None
    symbolizer = symbolizer or QisCallSiteSymbolizer()
    try:
        enriched = trace.model_copy(deep=True)
        for record in enriched.events:
            if isinstance(record.event, GateEvent):
                stack = symbolizer.symbolize_event(record.event)
                if stack:
                    record.event.debug_stack = stack
        return enriched
    finally:
        if owns_symbolizer:
            symbolizer.close()
