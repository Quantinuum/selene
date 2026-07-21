# Selene-Core

Selene is designed to be extensible through the use of plugins, in the form
of compiled libraries and lightweight python interfaces that provide configuration
for the selene-sim frontend. We achieve this through this selene-core crate and
python module.

Each plugin should comprise a python component and a compiled library component.
The compiled library implements the Selene plugin API, and the python component
provides configuration, link information and the path to the compiled library to
the selene frontend.

## The python module

The selene-core python module provides interfaces for plugins to adhere to. It also
provides a bundled include directory, containing C headers for the Selene plugin API
for each type of component.

To access the C headers in the build stage of a python package, depend on selene-core
as a build dependency and call `selene_core.get_include_directory()`. The resulting
path can be provided to a build system for C or C++ and the plugin APIs can be included
through:
```c
#include <selene/simulator.h>   # for the simulator API
#include <selene/error_model.h> # for the error model API
#include <selene/runtime.h>     # for the runtime API
```

Each header defines a descriptor structure and a packed current-version constant:

- `SELENE_SIMULATOR_CURRENT_API_VERSION`
- `SELENE_ERROR_MODEL_CURRENT_API_VERSION`
- `SELENE_RUNTIME_CURRENT_API_VERSION`

Populate `struct_size` with `sizeof` the descriptor, use the corresponding version
constant for `api_version`, and populate every function pointer that is not documented
as optional. A plugin must export either the descriptor symbol documented in its header
or, preferably, the accessor function. For example, a simulator plugin should export:

```c
static const SeleneSimulatorPluginDescriptorV1 descriptor = {
    .struct_size = sizeof(SeleneSimulatorPluginDescriptorV1),
    .api_version = SELENE_SIMULATOR_CURRENT_API_VERSION,
    /* function pointers */
};

const SeleneSimulatorPluginDescriptorV1 *
selene_simulator_get_plugin_descriptor_v1(void) {
    return &descriptor;
}
```

The equivalent runtime and error-model accessor names are declared in their respective
headers.

## The rust crate

The selene-core rust crate defines the compiled plugin interfaces for the Selene
backend to use. It additionally provides helper functionality for rust-based plugins
to expose the Selene plugin APIs while providing a more idiomatic trait interface.

See the following for examples:
- [example simulator](examples/simulator/rust/lib.rs)
- [example error model](examples/error_model/rust/lib.rs)
- [example runtime](examples/runtime/rust/lib.rs)
