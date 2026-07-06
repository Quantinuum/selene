# Selene-Core

Selene is designed to be extensible through compiled plugins, link-time
utilities, custom gate definitions, and lightweight Python interfaces that
provide configuration for the `selene-sim` frontend. We achieve this through the
`selene-core` Rust crate and Python package.

Each plugin should comprise a python component and a compiled library component.
The compiled library implements the Selene descriptor ABI, and the Python
component provides configuration, link information, and the path to the compiled
library to the Selene frontend.

## The Python Module

The `selene-core` Python module provides base classes for plugin packages to
adhere to. It also provides a bundled include directory containing the C headers
for the plugin ABI and gatewire.

To access the C headers in the build stage of a python package, depend on selene-core
as a build dependency and call `selene_core.get_include_directory()`. The resulting
path can be provided to a build system for C or C++ and the plugin APIs can be included
through:
```c
#include <selene/simulator.h>   # for the simulator API
#include <selene/error_model.h> # for the error model API
#include <selene/runtime.h>     # for the runtime API
#include <selene/gatewire.h>    # for gatesets and serialized gates
```

By exporting the relevant descriptor, the plugin can be dynamically loaded by
Selene at runtime.

## The Rust Crate

The `selene-core` Rust crate defines the compiled plugin interfaces for the Selene
backend to use. It additionally provides helper functionality for Rust-based plugins
to expose the Selene plugin APIs while providing a more idiomatic trait
interface. The same crate owns the gatewire Rust API, including builtin gatesets
such as `HeliosGateSet`, `SolGateSet`, and `QuantinuumGateSet`.

For current plugin documentation, start with
[the extensibility docs](https://github.com/quantinuum/selene/tree/main/docs/extensibility).
For a complete custom-gateset project, see
[the Clifford+T stack example](https://github.com/quantinuum/selene/tree/main/examples/clifford_t_stack).
