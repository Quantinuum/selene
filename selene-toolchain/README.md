# selene-toolchain

This package supplies LLVM code generation, LLD, symbolisation tools, and the
startup and runtime files needed to link Selene executables. Its releases are
independent of selene-core and selene-sim, so upgrading Selene doesn't require
downloading another copy of LLVM.

`compile_object(source, output)` accepts LLVM IR or bitcode. `link_executable`
accepts native objects, plugin libraries, library search directories and linker
flags. Both use packaged tools by absolute path and support verbose output.
The tools are native to the wheel's platform; this isn't a general-purpose
cross-compilation SDK.

`inspect_module(contents)` accepts an IR string, bitcode bytes, or a `.ll`/`.bc`
path. It returns immutable sets of function definitions and declarations.
The packaged `selene-llvm inspect [FILE|-]` executable uses LLVM's own parser
and emits JSON with schema version 1. It includes unused declarations and
internal functions, and excludes LLVM intrinsics, globals and aliases.

`inspect_object(contents)` accepts a path or bytes containing an ELF, Mach-O
or PE/COFF object. It returns immutable sets of defined and undefined linker
symbols, including data and aliases. The same helper provides this through
`selene-llvm inspect-object [FILE|-]`, with `defined_symbols` and
`undefined_symbols` in its version 1 JSON response. Mach-O names have their
platform underscore removed, so `qmain` has the same name on every platform.
Object inspection uses LLVM's object reader and doesn't depend on LIEF.

Linux uses ELF LLD, position-independent executables, and packaged glibc startup
objects and GCC compiler helpers. It links against the host's glibc and libm,
locating their versioned runtime files through the system loader rather than
requiring development packages. The executable uses the host's dynamic loader.
Windows uses the MinGW LLD driver and packaged MinGW startup/import libraries,
with hugrenv's `win_mingw_amd64` LLVM build. macOS uses Mach-O LLD and a
vendored libSystem text stub, with a deployment target of macOS 11.0.

Build from the project root inside devenv:

```sh
devenv shell -- bash -c 'uv build --package selene-toolchain --wheel'
```

The build needs CMake, a C++ compiler, `HUGRENV_PATH`, and, on Linux/Windows,
a target GCC toolchain. On Windows, the inspector and user programs use MinGW.
CI installs the compiler distribution pinned in `vendor/windows-sources.json`,
and checks that its build information matches hugrenv's LLVM distribution.
For a local Windows build, use that same distribution and set `CC` and `CXX`
to its `gcc.exe` and `g++.exe`. The Windows inspector uses CMake's Ninja generator.
End users don't need these build tools. Release Linux wheels must be built in the same
manylinux_2_28 environment as Selene. Local Nix builds use the development
environment's glibc and aren't portable release artifacts.

The Python API can stay stable across LLVM upgrades, but LLVM bitcode producers
and consumers still need compatible versions. Inspection and object generation
use the same packaged LLVM version, without depending on llvmlite or Python's ABI.

Matching Linux glibc and GCC sources, including distribution patches and RPM
build recipes, are separate assets beside the wheels on the
[toolchain release pages](https://github.com/Quantinuum/selene/releases).
Each release wheel's `_dist/sources.json` gives direct download links and
checksums for its sources. The sources are free to download and don't have to
be downloaded to use Selene. We keep them available while distributing the
wheels. Local development wheels don't have release source links and must not
be published. See the bundled provenance and licence files for other inputs.

Windows wheels link to the matching GCC source archive and MinGW build scripts
in `_dist/sources.json`, and include the compiler's original build information
with its configure arguments and patch list. The build checks that this
information still matches the compiler distribution for which we recorded the
source links. LLVM's permissive licence requires notices rather than a source
archive, so we don't add an LLVM source download to the wheel.
