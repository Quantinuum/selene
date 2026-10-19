# Plugin API versions

Runtime, simulator and error-model APIs each have their own version history.
The parent Rust module exposes the current contract, so new code can import
`selene_core::runtime::RuntimeInterface`, for example. The same contract is
also available through its versioned module. If an implementation targets an
older API, it imports that version explicitly rather than following the default.

| Plugin | Current Rust module | Versioned Rust module | Versioned C header |
| ------ | ------------------- | --------------------- | ------------------ |
| Runtime | `runtime` | `runtime::v0_4` | `selene/runtime/v0_4.h` |
| Runtime, API 0.3 | | `runtime::v0_3` | `selene/runtime/v0_3.h` |
| Simulator | `simulator` | `simulator::v0_1` | `selene/simulator/v0_1.h` |
| Error model | `error_model` | `error_model::v0_3` | `selene/error_model/v0_3.h` |

Versioned modules cover a compatible major/minor API family. For example, the
simulator's `v0_1` module describes API 0.1.1. We don't create another module for
a compatible patch addition. Each module keeps its traits, FFI declarations,
export helpers and version checks together, so changing the default cannot
change what an older implementation exports.

The descriptor suffix is a separate version number. A descriptor describes how
to find and construct a plugin, while the API version identifies its contract.
Runtime API 0.3 uses `SeleneRuntimePluginDescriptorV1`; API 0.4 uses
`SeleneRuntimePluginDescriptorV2`. The simulator and error-model descriptors are
still V1. Their layouts and exported symbols haven't changed.

## Implementing a plugin

New Rust runtimes use the current interface and export macro:

```rust,ignore
use selene_core::runtime::{RuntimeInterface, export_runtime_plugin};
```

An existing batch-based runtime selects its original interface and matching macro:

```rust,ignore
use selene_core::runtime::v0_3::{RuntimeInterface, export_runtime_plugin};
```

Both macros are named `export_runtime_plugin!` at their module paths. The API 0.3
macro exports descriptor V1, and the current macro exports descriptor V2. The
simulator and error-model modules follow the same convention, with their current
export macros also available at the crate root.

In C, `selene/runtime.h`, `selene/simulator.h` and `selene/error_model.h` select
the current contracts. Their `SELENE_*_CURRENT_API_VERSION` constants follow
that selection. To pin an API, include its versioned header and use its matching
constant, such as `SELENE_RUNTIME_V0_3_API_VERSION`. Versioned headers can be
included together, so a host can recognise and load several API versions.

`selene/operations.h` contains the shared batch and result exchange tables.
These are used by the runtime, simulator and error model without making the
current runtime header depend on an older runtime's contract.

## Loading and adapting plugins

The parent `plugin` modules handle loading and version selection. The host asks
for the current interface and doesn't need to select a plugin's historical API
itself. A version-specific native loader understands just that version's ABI.

The runtime loader prefers API 0.4. If only API 0.3 is advertised, it loads that
contract and wraps the instance with `runtime::adapters::v0_3_to_v0_4::LegacyRuntime`.
The wrapper implements the current interface, including peripheral execution,
using the old scheduler's batch polling. An invalid advertised API 0.4 descriptor
is an error, rather than a reason to fall back to API 0.3.

Simulators and error models currently have one supported contract each, so their
loaders need no adapters. We can add another version when its contract exists.
An adapter belongs alongside the supported versions when it can preserve their
semantics; the layout doesn't promise that every future API change can be
adapted transparently.

The [runtime architecture](runtime/README.md) explains peripheral ownership,
threading, printing and compatibility in more detail.
