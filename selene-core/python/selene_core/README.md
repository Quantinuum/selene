# Selene-Core

Selene is designed to be extensible through the use of plugins, in the form
of compiled libraries and lightweight python interfaces that provide configuration
for the selene-sim frontend. We achieve this through this selene-core crate and
python module.

Each plugin should comprise a python component and a compiled library component.
The compiled library implements the Selene plugin API, and the python component
provides configuration, link information and the path to the compiled library to
the selene frontend.

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

## Runtime plugin concurrency (API 0.4.0)

New runtime plugins export `SeleneRuntimePluginDescriptorV2` through
`selene_runtime_plugin_descriptor_v2` or `selene_runtime_get_plugin_descriptor_v2`.
They use `SELENE_RUNTIME_CURRENT_API_VERSION` (0.4.0) and `RuntimeInstanceV2`
(`const void *`) handles. The Rust `export_runtime_plugin!` macro exports v2.
Operational calls on the same instance must be thread-safe, including submission,
forcing, and result publication. Rust implementations use shared receivers for every method, including
lifecycle and metrics, and implement `Send + Sync`. Synchronize mutable state
internally so even overlapping lifecycle calls remain memory-safe; the host still
coordinates shot boundaries and metric collection for correct behavior. Constness alone does not
provide synchronization. Output pointers, including the initialization output,
remain mutable.

One consumer drains and executes batches in order. Forcing a result guarantees
that draining exposes the work needed to resolve it, unless already dispatched
or resolved. The consumer executes that work and publishes the result; callers
wait for the result itself. Concurrent submissions must not indefinitely postpone
forced work.

Initialization completes before sharing. The host excludes other calls during
shot start/end and exit, and throughout metric collection. See `selene/runtime.h`
for the complete ABI contract.

### Legacy runtime compatibility

Existing v1 / API 0.3.x plugin binaries remain supported. The v1 descriptor retains
its `RuntimeInstance` (`void *`) handle and original function signatures. When
building a v1 descriptor with the current header, use `SELENE_RUNTIME_V1_API_VERSION`
(0.3.0), rather than the concurrent API's current-version constant.

The loader prefers v2 and falls back to v1 only when neither v2 descriptor symbol
nor v2 getter is present. An invalid advertised v2 interface is an error. Other
API minor versions are rejected; patch versions within each supported minor are
accepted.

Each legacy instance is initialized, called, and cleaned up on one owning thread.
Calls through the current Rust trait block until that thread replies. This preserves
thread affinity as well as exclusive access, at the cost of request/response
coordination for each call. Batch callbacks and borrowed foreign buffers stay on
that thread; returned batches and values are owned by the host. Explicit exit or
dropping the adapter calls the legacy cleanup function at most once. Later calls
through an exited adapter return errors.

Legacy result getters must return unavailability rather than wait for the host to
publish a result. The host forces work, drains batches, executes them, and publishes
results through separate calls. The adapter does not make a blocking legacy plugin
reentrant or provide parallel execution inside that plugin. Existing Rust plugin
source must still adopt the new trait when upgrading its `selene-core` dependency;
binary compatibility does not preserve the old Rust trait.
