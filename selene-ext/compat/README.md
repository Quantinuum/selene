# Selene 0.2 Compatibility Adapters

These crates provide explicit 0.3 plugins that load 0.2-series plugin shared
objects and translate between the old typed gate ABI and the current generic
gatewire ABI.

They are intentionally kept in `selene-ext` rather than `selene-core`. The 0.3
core should only know the 0.3 plugin model; these adapters are transitional
plugins that can be removed once downstream plugins have migrated.

## Adapter Crates

- `v02-simulator` builds `libselene_v02_compat_simulator.so`.
- `v02-runtime` builds `libselene_v02_compat_runtime.so`.
- `v02-error-model` builds `libselene_v02_compat_error_model.so`.
- `v02-common` contains the shared ABI definitions and gate translation helpers.

Each adapter accepts:

```text
--old-plugin=/path/to/libold_plugin.so
--old-arg=...
```

Use one `--old-arg` per argument that should be forwarded to the 0.2 plugin.
For example, an old simulator that used `--shots=10 --mode=test` would be
wrapped with:

```text
--old-plugin=/path/to/libold_simulator.so
--old-arg=--shots=10
--old-arg=--mode=test
```

## Gateset Contract

Selene 0.2 only understood the historical `rz/rxy/rzz` gateset. The adapters
therefore negotiate the equivalent 0.3 builtin gateset:

- `RZ`
- `PhasedX`
- `ZZPhase`

If a QIS interface or upstream plugin negotiates any other gate, such as
`PhasedXX` or a custom gate, the adapter rejects the handshake.

## Error Models

Selene 0.2 error models owned their simulator. Selene 0.3 error models receive
a simulator handle during `handle_operations` instead.

The `v02-error-model` adapter bridges this by exporting a tiny 0.2 simulator ABI
from the same shared object. During legacy error-model initialization, the
adapter gives the old error model that bridge as its simulator plugin. During
`handle_operations`, bridge calls are forwarded to the real 0.3 simulator handle.

The bridge intentionally no-ops shot start/end because the real 0.3 simulator is
already started and ended by Selene itself.

If automatic discovery of the bridge library path is unavailable on a platform,
pass it explicitly:

```text
--bridge-simulator=/path/to/libselene_v02_compat_error_model.so
```

## Build

Build the adapters with the devenv toolchain:

```bash
PATH="$PWD/.devenv/profile/bin:$PATH" cargo build --manifest-path selene-ext/compat/v02-simulator/Cargo.toml
PATH="$PWD/.devenv/profile/bin:$PATH" cargo build --manifest-path selene-ext/compat/v02-runtime/Cargo.toml
PATH="$PWD/.devenv/profile/bin:$PATH" cargo build --manifest-path selene-ext/compat/v02-error-model/Cargo.toml
```
