# Writing a Simulator Plugin in C

C simulators implement `SeleneSimulatorPluginDescriptorV1` from
`selene/simulator.h`. Use `selene/gatewire.h` to negotiate and decode gates.

## 1. Define Instance State

```c
#include <selene/simulator.h>
#include <selene/gatewire.h>
#include <stdlib.h>

typedef struct {
    uint64_t n_qubits;
    uint64_t measurements;
    /* Backend state goes here. */
} MySimulator;
```

Allocate state in `init`:

```c
static SeleneErrno my_simulator_init(SeleneSimulatorInstance *out,
                                     uint64_t n_qubits,
                                     uint32_t argc,
                                     const char *const *argv) {
    (void)argc;
    (void)argv;

    MySimulator *sim = calloc(1, sizeof(MySimulator));
    if (sim == NULL) {
        return 1;
    }
    sim->n_qubits = n_qubits;
    *out = sim;
    return 0;
}

static SeleneErrno my_simulator_exit(SeleneSimulatorInstance handle) {
    free((MySimulator *)handle);
    return 0;
}
```

## 2. Negotiate Supported Gates

The simulator receives the final gateset. Validate it and return it unchanged:

```c
static SeleneErrno my_simulator_negotiate_gateset(SeleneSimulatorInstance handle,
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

    GwGateSet *supported = NULL;
    gw_gateset_new(&supported);
    gw_gateset_add_builtin_rz(supported);
    gw_gateset_add_builtin_phased_x(supported);
    gw_gateset_add_builtin_zz_phase(supported);
    gw_gateset_add_builtin_phased_xx(supported);

    size_t len = 0;
    gw_gateset_len(incoming, &len);
    for (size_t i = 0; i < len; i++) {
        GwGateDeclInfo decl;
        uint8_t contains = 0;
        gw_gateset_decl_at(incoming, i, &decl);
        gw_gateset_contains(supported, decl.semantic_id, &contains);
        if (!contains) {
            gw_gateset_free(incoming);
            gw_gateset_free(supported);
            return 1;
        }
    }

    size_t required = 0;
    gw_gateset_serialized_len(incoming, &required);
    if (output == NULL || output_len == 0) {
        *written = required;
        gw_gateset_free(incoming);
        gw_gateset_free(supported);
        return 0;
    }

    GwStatus status = gw_gateset_serialize(incoming, output, output_len, written);
    gw_gateset_free(incoming);
    gw_gateset_free(supported);
    return status == GW_STATUS_OK ? 0 : 1;
}
```

For a restricted simulator, build a smaller supported set and reject anything
outside it.

## 3. Handle Operation Batches

The simulator's first-class operation entry point is `handle_operations_fn`.
Selene passes a batch extractor and a result writer. Your simulator provides a
small collector, asks Selene to replay the batch into it, and writes measurement
results as they are produced.

```c
typedef struct {
    MySimulator *sim;
    struct OperationResultHandle results;
} SimulatorCollector;

static int apply_gate(MySimulator *sim, const uint8_t *data, size_t len) {
    GwDecodedGate *gate = NULL;
    if (gw_gate_deserialize(data, len, &gate) != GW_STATUS_OK) {
        return 1;
    }

    GwSemanticId id;
    gw_decoded_gate_semantic_id(gate, &id);

    if (gw_semantic_id_eq(id, gw_builtin_rz_semantic_id())) {
        GwGateValue q0;
        GwGateValue theta;
        gw_decoded_gate_value_at(gate, 0, &q0);
        gw_decoded_gate_value_at(gate, 1, &theta);
        /* backend_apply_rz(sim, q0.data.qubit, theta.data.f64_value); */
    } else if (gw_semantic_id_eq(id, gw_builtin_phased_x_semantic_id())) {
        /* Decode q0, theta, phi and apply. */
    } else {
        gw_decoded_gate_free(gate);
        return 1;
    }

    (void)sim;
    gw_decoded_gate_free(gate);
    return 0;
}

static bool apply_measure(MySimulator *sim, uint64_t qubit) {
    (void)qubit;
    sim->measurements++;
    return false;
}

static void collect_gate(RuntimeGetOperationInstance instance,
                         const uint8_t *data,
                         size_t len) {
    SimulatorCollector *collector = (SimulatorCollector *)instance;
    (void)apply_gate(collector->sim, data, len);
}

static void collect_measure(RuntimeGetOperationInstance instance,
                            uint64_t qubit,
                            uint64_t result_id) {
    SimulatorCollector *collector = (SimulatorCollector *)instance;
    bool result = apply_measure(collector->sim, qubit);
    collector->results.interface.set_bool_result_fn(
        collector->results.instance,
        result_id,
        result
    );
}

static void collect_measure_leaked(RuntimeGetOperationInstance instance,
                                   uint64_t qubit,
                                   uint64_t result_id) {
    SimulatorCollector *collector = (SimulatorCollector *)instance;
    bool result = apply_measure(collector->sim, qubit);
    collector->results.interface.set_u64_result_fn(
        collector->results.instance,
        result_id,
        result ? 1 : 0
    );
}

static void collect_postselect(RuntimeGetOperationInstance instance,
                               uint64_t qubit,
                               bool target_value) {
    SimulatorCollector *collector = (SimulatorCollector *)instance;
    (void)collector;
    (void)qubit;
    (void)target_value;
    /* backend_postselect(collector->sim, qubit, target_value); */
}

static void collect_reset(RuntimeGetOperationInstance instance,
                          uint64_t qubit) {
    SimulatorCollector *collector = (SimulatorCollector *)instance;
    (void)collector;
    (void)qubit;
    /* backend_reset(collector->sim, qubit); */
}

static void collect_custom(RuntimeGetOperationInstance instance,
                           size_t tag,
                           const void *data,
                           size_t len) {
    (void)instance;
    (void)tag;
    (void)data;
    (void)len;
}

static void collect_batch_time(RuntimeGetOperationInstance instance,
                               uint64_t start,
                               uint64_t duration) {
    (void)instance;
    (void)start;
    (void)duration;
}

static SeleneErrno my_simulator_handle_operations(
    SeleneSimulatorInstance handle,
    struct RuntimeExtractOperationHandle batch,
    struct OperationResultHandle results
) {
    SimulatorCollector collector = {(MySimulator *)handle, results};
    struct RuntimeGetOperationHandle output = {
        .instance = &collector,
        .interface = {
            .measure_fn = collect_measure,
            .measure_leaked_fn = collect_measure_leaked,
            .postselect_fn = collect_postselect,
            .reset_fn = collect_reset,
            .custom_fn = collect_custom,
            .set_batch_time_fn = collect_batch_time,
            .gate_fn = collect_gate,
        },
    };
    batch.interface.extract_fn(&batch, output);
    return 0;
}
```

Validate operand kinds before using them in production code. Postselection is
part of the same operation batch as gates, measurements, and resets.

## 4. Metrics and Lifecycle

`shot_start` should initialize the quantum state for a shot and seed any RNG.
`shot_end` should validate and clean up per-shot state. `get_metrics_fn` is
called with increasing `nth_metric` until it returns nonzero.

```c
static SeleneErrno my_simulator_get_metrics(SeleneSimulatorInstance handle,
                                            uint8_t nth_metric,
                                            char *tag,
                                            uint8_t *datatype,
                                            uint64_t *value) {
    MySimulator *sim = (MySimulator *)handle;
    if (nth_metric != 0) {
        return 1;
    }
    strcpy(tag, "measurements");
    *datatype = 2; /* u64 */
    *value = sim->measurements;
    return 0;
}
```

## 5. Export the Descriptor

```c
const SeleneSimulatorPluginDescriptorV1 selene_simulator_plugin_descriptor_v1 = {
    .header = {
        .struct_size = sizeof(SeleneSimulatorPluginDescriptorV1),
        .api_version = SELENE_SIMULATOR_CURRENT_API_VERSION,
        .last_error_fn = my_simulator_last_error,
        .get_name_fn = my_simulator_get_name,
    },
    .init_fn = my_simulator_init,
    .exit_fn = my_simulator_exit,
    .shot_start_fn = my_simulator_shot_start,
    .shot_end_fn = my_simulator_shot_end,
    .handle_operations_fn = my_simulator_handle_operations,
    .get_metrics_fn = my_simulator_get_metrics,
    .dump_state_fn = my_simulator_dump_state,
    .negotiate_gateset_fn = my_simulator_negotiate_gateset,
};
```

Use `NULL` only for callbacks documented as optional. Required callbacks are
validated when Selene loads the plugin.
