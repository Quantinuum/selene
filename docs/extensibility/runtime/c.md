# Writing a Runtime Plugin in C

C runtimes implement the descriptor ABI directly. You include
`selene/runtime.h` for the runtime descriptor and `selene/gatewire.h` for gate
transport.

## 1. Define Instance State

The instance pointer is owned by your plugin:

```c
#include <selene/runtime.h>
#include <selene/gatewire.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct {
    uint64_t n_qubits;
    uint8_t *allocated;
    uint64_t next_result;
    /* Your operation queue and result storage go here. */
} MyRuntime;
```

Allocate it in `init` and free it in `exit`:

```c
static SeleneErrno my_runtime_init(RuntimeInstance *out,
                                   uint64_t n_qubits,
                                   uint64_t start,
                                   uint32_t argc,
                                   const char *const *argv) {
    (void)start;
    (void)argc;
    (void)argv;

    MyRuntime *runtime = calloc(1, sizeof(MyRuntime));
    if (runtime == NULL) {
        return 1;
    }
    runtime->n_qubits = n_qubits;
    runtime->allocated = calloc((size_t)n_qubits, sizeof(uint8_t));
    if (runtime->allocated == NULL) {
        free(runtime);
        return 1;
    }

    *out = runtime;
    return 0;
}

static SeleneErrno my_runtime_exit(RuntimeInstance handle) {
    MyRuntime *runtime = (MyRuntime *)handle;
    free(runtime->allocated);
    free(runtime);
    return 0;
}
```

## 2. Negotiate Gates

The runtime receives the interface gateset and returns the gates it may emit.
This example accepts and emits `RZ`, `PhasedX`, and `ZZPhase`:

```c
static SeleneErrno my_runtime_negotiate_gateset(RuntimeInstance handle,
                                                const uint8_t *input,
                                                size_t input_len,
                                                uint8_t *output,
                                                size_t output_len,
                                                size_t *written) {
    (void)handle;

    GwGateSet *incoming = NULL;
    if (gw_gateset_deserialize(input, input_len, &incoming) != GW_STATUS_OK) {
        return 1;
    }

    GwGateSet *accepted = NULL;
    gw_gateset_new(&accepted);
    gw_gateset_add_builtin_rz(accepted);
    gw_gateset_add_builtin_phased_x(accepted);
    gw_gateset_add_builtin_zz_phase(accepted);

    size_t len = 0;
    gw_gateset_len(incoming, &len);
    for (size_t i = 0; i < len; i++) {
        GwGateDeclInfo decl;
        uint8_t contains = 0;
        gw_gateset_decl_at(incoming, i, &decl);
        gw_gateset_contains(accepted, decl.semantic_id, &contains);
        if (!contains) {
            gw_gateset_free(incoming);
            gw_gateset_free(accepted);
            return 1;
        }
    }

    size_t required = 0;
    gw_gateset_serialized_len(accepted, &required);
    if (output == NULL || output_len == 0) {
        *written = required;
        gw_gateset_free(incoming);
        gw_gateset_free(accepted);
        return 0;
    }

    GwStatus status = gw_gateset_serialize(accepted, output, output_len, written);
    gw_gateset_free(incoming);
    gw_gateset_free(accepted);
    return status == GW_STATUS_OK ? 0 : 1;
}
```

If your runtime lowers gates, validate against the input gates you accept and
serialize a different gateset for the gates you emit.

## 3. Accept Gates

`gate_fn` receives a serialized gate instance:

```c
static SeleneErrno my_runtime_gate(RuntimeInstance handle,
                                   const uint8_t *data,
                                   size_t len) {
    MyRuntime *runtime = (MyRuntime *)handle;
    GwDecodedGate *gate = NULL;
    if (gw_gate_deserialize(data, len, &gate) != GW_STATUS_OK) {
        return 1;
    }

    GwSemanticId id;
    gw_decoded_gate_semantic_id(gate, &id);
    if (gw_semantic_id_eq(id, gw_builtin_rz_semantic_id())) {
        /* Decode operands and append an RZ operation to your queue. */
    } else if (gw_semantic_id_eq(id, gw_builtin_phased_x_semantic_id())) {
        /* Append PhasedX. */
    } else if (gw_semantic_id_eq(id, gw_builtin_zz_phase_semantic_id())) {
        /* Append ZZPhase. */
    } else {
        gw_decoded_gate_free(gate);
        return 1;
    }

    (void)runtime;
    gw_decoded_gate_free(gate);
    return 0;
}
```

Store enough information in your own queue to emit the operation later from
`get_next_operations`.

## 4. Allocate Qubits and Create Result IDs

Qubit allocation returns `UINT64_MAX` when no qubits are available:

```c
static SeleneErrno my_runtime_qalloc(RuntimeInstance handle, uint64_t *out) {
    MyRuntime *runtime = (MyRuntime *)handle;
    for (uint64_t q = 0; q < runtime->n_qubits; q++) {
        if (!runtime->allocated[q]) {
            runtime->allocated[q] = 1;
            *out = q;
            return 0;
        }
    }
    *out = UINT64_MAX;
    return 0;
}
```

Measurements return a future result ID and queue a measurement operation:

```c
static SeleneErrno my_runtime_measure(RuntimeInstance handle,
                                      uint64_t qubit,
                                      uint64_t *result_id) {
    MyRuntime *runtime = (MyRuntime *)handle;
    *result_id = runtime->next_result++;
    /* Queue a measurement of qubit with this result ID. */
    return 0;
}
```

Implement `set_bool_result_fn`, `get_bool_result_fn`, and the reference-count
callbacks so the interface can safely observe results.

## 5. Emit a Batch

`get_next_operations_fn` receives a `RuntimeGetOperationHandle`. Use its
callbacks to populate the batch:

```c
static SeleneErrno my_runtime_get_next_operations(RuntimeInstance handle,
                                                  struct RuntimeGetOperationHandle ops) {
    MyRuntime *runtime = (MyRuntime *)handle;

    /* For each queued operation: */
    /* ops.interface.gate_fn(ops.instance, gate_bytes, gate_len); */
    /* ops.interface.measure_fn(ops.instance, qubit, result_id); */
    /* ops.interface.reset_fn(ops.instance, qubit); */

    (void)runtime;
    return 0;
}
```

An empty callback sequence means the runtime has no work ready.

## 6. Export the Descriptor

The descriptor is the public ABI Selene loads:

```c
const SeleneRuntimePluginDescriptorV1 selene_runtime_plugin_descriptor_v1 = {
    .header = {
        .struct_size = sizeof(SeleneRuntimePluginDescriptorV1),
        .api_version = SELENE_RUNTIME_CURRENT_API_VERSION,
        .last_error_fn = my_runtime_last_error,
        .get_name_fn = my_runtime_get_name,
    },
    .init_fn = my_runtime_init,
    .exit_fn = my_runtime_exit,
    .get_next_operations_fn = my_runtime_get_next_operations,
    .shot_start_fn = my_runtime_shot_start,
    .shot_end_fn = my_runtime_shot_end,
    .get_metrics_fn = my_runtime_get_metrics,
    .qalloc_fn = my_runtime_qalloc,
    .qfree_fn = my_runtime_qfree,
    .local_barrier_fn = my_runtime_local_barrier,
    .global_barrier_fn = my_runtime_global_barrier,
    .measure_fn = my_runtime_measure,
    .measure_leaked_fn = my_runtime_measure_leaked,
    .reset_fn = my_runtime_reset,
    .force_result_fn = my_runtime_force_result,
    .get_bool_result_fn = my_runtime_get_bool_result,
    .get_u64_result_fn = my_runtime_get_u64_result,
    .set_bool_result_fn = my_runtime_set_bool_result,
    .set_u64_result_fn = my_runtime_set_u64_result,
    .increment_future_refcount_fn = my_runtime_increment_future_refcount,
    .decrement_future_refcount_fn = my_runtime_decrement_future_refcount,
    .custom_call_fn = my_runtime_custom_call,
    .simulate_delay_fn = my_runtime_simulate_delay,
    .gate_fn = my_runtime_gate,
    .negotiate_gateset_fn = my_runtime_negotiate_gateset,
};
```

Use clear failures for unsupported features. For example, if your runtime does
not support `custom_call`, return nonzero rather than silently ignoring it.
