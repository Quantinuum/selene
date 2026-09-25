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

The runtime and error-model headers declare their getter names too. New runtime
plugins use the v2 descriptor. If you're maintaining a v1 runtime plugin, use
`SELENE_RUNTIME_V1_API_VERSION` instead of the current-version constant, as
explained under [Using an older runtime plugin](#using-an-older-runtime-plugin).

## The rust crate

The selene-core rust crate defines the compiled plugin interfaces for the Selene
backend to use. It additionally provides helper functionality for rust-based plugins
to expose the Selene plugin APIs while providing a more idiomatic trait interface.

See the following for examples:
- [example simulator](examples/simulator/rust/lib.rs)
- [example error model](examples/error_model/rust/lib.rs)
- [example runtime](examples/runtime/rust/lib.rs)

## Writing a runtime plugin

A runtime decides when quantum operations are ready to execute. User programs
submit gates and measurements to it, and Selene asks it for batches of work to
run on the simulator. Several user threads can submit work at once, so a runtime
needs to protect the state they share.

If you're writing your plugin in Rust, implement `RuntimeInterface` and use
`export_runtime_plugin!` to expose it to Selene. The trait requires `Send + Sync`,
and every method takes `&self`. You'll need to synchronize changes to your
runtime's state yourself. The simple runtime and the example runtime show how
to do this with locks.

### How a measurement becomes a result

Scheduling a measurement gives the user program a result ID. Its value might
not be ready yet: the runtime may still be collecting operations into a batch.
When the program needs that value, it calls `force_result` to ask the runtime
to make the necessary work available.

Selene runs those batches on the simulator in order, then writes the measurement
values back to the runtime. One thread does this work, which we call the consumer.
Calling `force_result` must make the required work available to that thread,
even if other threads keep submitting operations. It may take several batches
to reach the measurement. If the consumer already has the work, the runtime
doesn't need to queue it again.

If you're waiting for a result, check whether its value is ready. An empty queue
only tells you there's no more work to collect right now. The consumer might
still be executing a measurement it collected earlier. Don't hold a lock while
waiting if that would stop the consumer from producing the value you need.

### Starting and stopping shots

Selene finishes initializing an instance before sharing it with user threads.
It also keeps other calls out while starting or ending a shot, collecting
metrics, or exiting the runtime. Metric collection needs this pause for the
whole collection, including the gaps between calls for individual metrics.

Rust implementations still need to remain memory-safe if these methods overlap:
`&self` lets Rust callers make concurrent calls. The host's coordination gives
shots their intended behavior, but it cannot replace synchronization inside a
safe Rust implementation.

### Exporting the C interface

New plugins use API 0.4.0 and `SeleneRuntimePluginDescriptorV2`. Export either
`selene_runtime_plugin_descriptor_v2` or the getter
`selene_runtime_get_plugin_descriptor_v2`, and set the descriptor's version to
`SELENE_RUNTIME_CURRENT_API_VERSION`. The Rust export macro does this for you.

The v2 instance handle is `RuntimeInstanceV2`, a `const void *`. This allows
shared access to the instance. It doesn't make the runtime's state immutable or
synchronize access to it. Output pointers are still writable, including the
pointer where initialization stores the new handle. See `selene/runtime.h` for
the full C interface and its safety requirements.

### Using an older runtime plugin

You can still load a compiled v1 plugin built for API 0.3.x. Selene gives each
legacy instance its own thread and uses that thread to initialize it, make every
call, and clean it up. Calls from other threads send a request and wait for the
reply. This keeps the old plugin on one thread and prevents overlapping calls,
at the cost of that extra communication.

The adapter copies inputs and collects returned batches and values into memory
owned by the host. Callbacks and borrowed plugin buffers stay on the plugin's
thread. Calling `exit` runs its cleanup at most once, and later calls return
errors. Dropping the adapter also runs cleanup if it hasn't already happened.

A legacy result getter must return "not ready" when a value is unavailable.
If it waits for the value instead, it blocks the same thread that needs to
accept the result from Selene. The adapter cannot make such a plugin work by
running another call alongside it.

If you're building a v1 descriptor with the current headers, keep the original
`RuntimeInstance` handle and use `SELENE_RUNTIME_V1_API_VERSION`, which is 0.3.0.
Selene looks for v2 first and tries v1 only if neither v2 export is present.
A broken v2 export is reported as an error. Each descriptor accepts patches of
its supported API minor version: 0.4.x for v2 and 0.3.x for v1.

This compatibility is for compiled plugins. If you upgrade the `selene-core`
dependency in an older Rust plugin, you'll need to update its source to
implement the current trait.
