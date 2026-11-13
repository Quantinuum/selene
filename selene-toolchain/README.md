# selene-toolchain

Native LLVM builds described in Rust or Python. The library knows about LLVM
modules, objects, libraries and executables; Selene's planner still decides
which transformations its programs need. There are no Selene runtime or QIS
conventions in the toolchain.

Compilation, object inspection and linking call LLVM and LLD libraries linked
into the Rust library through a small C++ bridge with a C interface. They don't launch `llc`, LLD or an
inspection executable. The remaining packaged executables, `llvm-symbolizer`
and macOS's `dsymutil`, serve debugging and symbolisation.

## Python

```python
from pathlib import Path
from selene_toolchain import Bitcode, Executor, Store, Toolchain

toolchain = Toolchain.bundled()
store = Store.default()
executor = Executor(store=store, jobs=4)

module = Bitcode.from_bytes(b"define i32 @main() { ret i32 0 }")
object_plan = toolchain.compile(module).optimisation(0).plan()
plan = toolchain.link_executable().object(object_plan).plan()

result = executor.build(plan)
result.artifact.copy_to(Path("program"))
print(result.cache_hit, result.key)
```

`link_shared_library()` builds a shared library. Linking builders accept
`.library(StaticLibrary.from_path(...))`, `.library(SharedLibrary.from_path(...))`
and `.system_library("m")`. Inputs remain ordered. Native platform startup and
runtime inputs come from the distribution's `link.json`.

Artifact constructors capture bytes, so later edits to an original file don't
change existing artifacts or plans. Constructors assign an explicit kind;
LLVM validation happens when inspecting the artifact or planning compilation.
There is no automatic interface detection. `Bitcode` accepts textual IR as
well as binary bitcode. `ObjectFile.symbols()` returns defined and undefined
linker names; `Bitcode.functions()` returns module functions, including unused
declarations. Those queries have different semantics. Static archives can be
linked, but member-level archive inspection isn't implemented yet.

`.plan()` constructs an immutable description; it doesn't compile or link.
`plan.describe()` returns its versioned description, including dependencies,
settings and content identities. Debug metadata in input modules is preserved,
and generated objects retain frame pointers. No debug metadata is fabricated
for modules that don't contain it.

New compilation plans reject incompatible target triples and data layouts.
`.retarget(True)` explicitly replaces that metadata when the caller knows its
IR is suitable for the host. Selene's compatibility adapter uses this to
preserve its existing behaviour for QIR generated with another target label.
Thin archives and linker scripts aren't accepted as explicit static-library
artifacts because their contents don't capture their external file references.

`compile_object()` and `link_executable()` remain compatibility adapters for
Selene's existing planner. They construct these plans and use the same store.

Link failures raise `LinkError`, a subclass of `RuntimeError`. Its `entries`
contains `LinkDiagnostic` objects with severity, kind, message, optional symbol,
references and details. Undefined and duplicate symbols are recognised by kind;
other failures use `other`. References describe the source file, line and column
when supplied, the object or archive member, and the referring function or
linker context. These are Rust structs exposed as read-only Python objects.
Symbol and context strings keep LLD's spelling, including decoration or
demangling.

`diagnostics` is a readable rendering of those structures. `raw_diagnostics`
keeps the original LLD output, and `inputs` lists the input labels. Internal
store paths are replaced by those labels before parsing. Equally named inputs
with different contents get a short digest to distinguish them. The parser
handles ELF, Mach-O and COFF forms, and keeps unfamiliar messages and details
visible when it cannot classify them.

Artifacts loaded from paths keep their filenames. Give in-memory inputs a name
with `Bitcode.from_bytes(data, name="caller.ll")`; compilation carries that
through to `caller.o`. Names participate in plan identities because they affect
diagnostics and can affect generated object contents. Existing source filenames
and debug information inside LLVM modules remain intact.

```python
from selene_toolchain import LinkError

try:
    executor.build(plan)
except LinkError as error:
    print(error)                  # readable diagnostic
    for entry in error.entries:
        if entry.kind == "undefined_symbol":
            print(entry.symbol, entry.references)
    print(error.raw_diagnostics)  # original LLD output for further investigation
```

## Rust and the LLVM development prefix

The crate is a member of this repository's Cargo workspace. Python bindings
are an optional `python` feature; ordinary Rust applications don't need Python.

Before building, point Cargo at an LLVM 21 installation that also provides LLD:

```sh
export SELENE_TOOLCHAIN_LLVM_PREFIX=/path/to/llvm
cargo build
```

`HUGRENV_PATH` is the fallback when `SELENE_TOOLCHAIN_LLVM_PREFIX` isn't set.
Our devenv and CI use that fallback. An explicitly supplied LLVM prefix takes
precedence, so other projects can use compatible installations without adopting
hugrenv. Cargo tracks both variables and rebuilds when the selected prefix changes.

The prefix must contain `bin/llvm-config`, LLVM/LLD headers and their static
libraries. A compatible C++ compiler is also needed. `build.rs` uses llvm-config
to find the headers and link dependencies, compiles the small C++ bridge, and
links it with LLVM/LLD. No runtime is downloaded and no backend library needs
to be located or installed at runtime. The native C++ source is inside the Rust
crate, so Cargo path and Git dependencies contain everything needed to build it.

```rust,no_run
use selene_toolchain::{Bitcode, Executor, Store, Toolchain};

# fn example() -> selene_toolchain::Result<()> {
let toolchain = Toolchain::new()?;
let module = Bitcode::from_bytes(b"define i32 @main() { ret i32 0 }".to_vec());
let plan = toolchain.compile(module).optimisation(0).plan()?;
let executor = Executor::new(Store::default_location()?).with_jobs(4)?;
let result = executor.build(&plan)?;
result.artifact.copy_to("program.o")?;
# Ok(())
# }
```

Rust callers can name byte-based artifacts with `.with_name("caller.ll")?`,
inspect their `.name()`, and match `Error::Link(error)` to access the same
`entries`, `diagnostics`, `raw_diagnostics` and `inputs` fields.

The prefix supplies the compiler implementation. Startup objects and platform
runtime libraries for linking user programs are configured separately:

```rust,no_run
use selene_toolchain::{LinkRuntime, Toolchain};

# fn linking() -> selene_toolchain::Result<()> {
let runtime = LinkRuntime::from_directory("/path/to/runtime-inputs")?;
let toolchain = Toolchain::new()?.with_runtime(runtime);
# Ok(())
# }
```

This directory contains `link.json` and a `runtime/` directory of link inputs,
using the same layout as a Python wheel's `_dist`. It doesn't supply an LLVM
backend. Compilation and inspection work without a `LinkRuntime`; attempting
to link without one reports that the runtime inputs are missing. Python wheels
continue to bundle these inputs and configure them through `Toolchain.bundled()`.

The `build` example links using an explicitly supplied runtime directory:

```sh
cargo run -p selene-toolchain --example build -- \
  selene-toolchain/python/selene_toolchain/_dist ./program
```

## Store and cache

The store describes where artifacts and cached results live. An executor
describes how plans run. Use `Executor(store=Store.local(path), jobs=4)` in
Python, or `Executor::new(Store::local(path)?).with_jobs(4)?` in Rust to compile
independent inputs in parallel. Executors use one worker by default;
`Store.build(plan)` remains a convenience that uses a default single-worker
executor. Python's `Executor()` uses `Store.default()` when no store is supplied.

Executors with different worker limits can share a store and reuse its cached
results. Clones of a Rust executor share its worker pool, including when several
callers build concurrently. Nested dependencies use that same bounded pool.
Changing the worker limit doesn't change a plan's cache key or linker input order.

LLVM compilations use separate contexts and can overlap. Linking takes an
exclusive native lock because LLD changes shared LLVM state, so it waits for
active compilations and runs one link at a time. LLD also has its own internal
worker threads; `jobs` bounds our plan workers rather than the total number
of threads inside LLVM and LLD.

From the repository environment, run
`python selene-toolchain/benchmarks/parallel_builds.py` to compare uncached and
cached multi-module builds with one, two and four workers.

The default local store is under the platform's cache directory; override it
with `SELENE_TOOLCHAIN_CACHE` or `Store.local(path)`. Build keys include the
linked bridge and LLVM/LLD archive digests, Rust implementation fingerprint,
schema version, target, settings and captured input identities. Link keys use
dependency output contents, so different compilation
plans that produce identical objects can reuse a link result.

The store keeps content-addressed artifacts and successful build records with
their descriptions and diagnostics. Writes are atomic, concurrent requests for
the same key share one build, and cached output corruption is reported. Failed
builds don't produce successful cache entries. Shared libraries are retained
under stable store paths; ELF links use library names and runtime search paths
so libraries without SONAMEs don't refer to deleted temporary files.

System libraries are resolved during planning and their contents are captured.
Linux uses the host's loader and glibc family of libraries. The loader's path
and contents participate in the key. This records the host dependencies; it
doesn't make execution independent of the host or promise hermetic builds.
The current cache is local and isn't relocatable.

`.link_flag()` and `.search_directory()` are escape hatches for existing Selene
plugins. Plans using either bypass link-result caching because arbitrary
arguments can refer to undeclared files. Compilation dependencies still cache.
Prefer explicit library artifacts and `.system_library()` for cached builds.

```sh
python -m selene_toolchain clean --dry-run
python -m selene_toolchain clean
```

Cleaning evicts build records and temporary files, waiting for active builds.
Captured artifacts are preserved because exported executables may depend on
stored shared libraries. Full artifact garbage collection needs retention
roots and is deliberately deferred, along with remote caches and reproducers.

## Platforms and builds

Public plans build for the native platform only. Foreign object inspection is
supported. Linux uses ELF LLD and glibc/GCC startup inputs, Windows uses MinGW
LLVM and its startup/import libraries, and macOS uses Mach-O LLD and the bundled
libSystem stub. The existing panic archive ordering is preserved.

LLVM and LLD entry are serialised across callers, with the Python GIL released
while native work runs. Normal parsing and linker errors become exceptions.
LLD's recovery result is checked and a damaged backend is disabled. LLVM is
still native code in the caller's process: arbitrary compiler crashes cannot
be guaranteed to become recoverable Python errors.

Build inside the repository's devenv:

```sh
devenv shell -- bash -c 'uv build --package selene-toolchain --wheel'
```

The build needs Rust, a C++ compiler and the LLVM development prefix described
above. Cargo builds the bridge; a separate CMake build isn't used. Rust uses its
C interface directly, keeping LLVM's C++ types out of the public Rust and Python
interfaces. Python wheels use PyO3's Python 3.10+ stable ABI. Linux statically
links the C++ runtime to avoid requiring a newer libstdc++ on the user's machine.
Windows builds require the GNU Rust target and a MinGW C++ compiler compatible
with the LLVM installation. Our wheels use the pinned MinGW compiler matching
hugrenv's LLVM build; no MSVC LLVM bindings are used.

Release Linux wheels use manylinux_2_28. Local Nix wheels aren't portable release
artifacts. Matching Linux GCC and glibc sources remain separate GitHub release
assets referenced by `_dist/sources.json`. Windows wheels retain compiler
provenance and source links. LLVM notices and Rust dependency licences are
included under `_dist/licenses`.
