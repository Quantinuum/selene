# Writing an Error Model Plugin in C

C error models implement `SeleneErrorModelPluginDescriptorV1` from
`selene/error_model.h`. They also use `selene/gatewire.h` for gateset
negotiation and gate decoding.

The C error-model callback is the most callback-heavy plugin API. It receives:

- A runtime batch extraction handle.
- A simulator operation handle.
- A result-setting handle.

Your job is to extract runtime operations, call the simulator with any original
or injected operations, and set measurement results by result ID.

## 1. Define Instance State

```c
#include <selene/error_model.h>
#include <selene/gatewire.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct {
    uint64_t n_qubits;
    uint64_t rng_state;
    uint64_t injected_errors;
    double probability;
} MyErrorModel;
```

Initialize and free the instance:

```c
static SeleneErrno my_error_model_init(SeleneErrorModelInstance *out,
                                       uint64_t n_qubits,
                                       uint32_t argc,
                                       const char *const *argv) {
    MyErrorModel *model = calloc(1, sizeof(MyErrorModel));
    if (model == NULL) {
        return 1;
    }
    model->n_qubits = n_qubits;
    model->probability = argc > 0 ? atof(argv[0]) : 0.0;
    *out = model;
    return 0;
}

static SeleneErrno my_error_model_exit(SeleneErrorModelInstance handle) {
    free((MyErrorModel *)handle);
    return 0;
}
```

## 2. Negotiate Gates

Return every gate your model may send to the simulator. If you inject `ZZPhase`,
include it even when the runtime does not emit it:

```c
static SeleneErrno my_error_model_negotiate_gateset(SeleneErrorModelInstance handle,
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

    GwGateSet *out_set = NULL;
    gw_gateset_new(&out_set);
    gw_gateset_add_builtin_rz(out_set);
    gw_gateset_add_builtin_phased_x(out_set);
    gw_gateset_add_builtin_zz_phase(out_set);

    /* Validate incoming here if your model only accepts a subset. */

    size_t required = 0;
    gw_gateset_serialized_len(out_set, &required);
    if (output == NULL || output_len == 0) {
        *written = required;
        gw_gateset_free(incoming);
        gw_gateset_free(out_set);
        return 0;
    }

    GwStatus status = gw_gateset_serialize(out_set, output, output_len, written);
    gw_gateset_free(incoming);
    gw_gateset_free(out_set);
    return status == GW_STATUS_OK ? 0 : 1;
}
```

## 3. Understand Batch Extraction

Selene does not expose the runtime batch as a raw array. Instead, the error
model passes a collector to `batch.interface.extract_fn`. Selene replays the
batch into that collector through callbacks such as `gate_fn`, `measure_fn`, and
`reset_fn`.

A minimal collector looks like this:

```c
typedef struct {
    struct SimulatorHandle simulator;
    struct ErrorModelSetResultHandle results;
    MyErrorModel *model;
} Collector;

static void collect_gate(SeleneRuntimeGetOperationInstance instance,
                         const uint8_t *data,
                         size_t len) {
    Collector *collector = (Collector *)instance;

    collector->simulator.interface.gate_fn(
        collector->simulator.instance,
        data,
        len
    );

    /* You can decode data with gw_gate_deserialize and inject extra gates here. */
}

static void collect_measure(SeleneRuntimeGetOperationInstance instance,
                            uint64_t qubit,
                            uint64_t result_id) {
    Collector *collector = (Collector *)instance;
    SeleneErrno measured = collector->simulator.interface.measure_fn(
        collector->simulator.instance,
        qubit
    );

    if (measured == 0 || measured == 1) {
        collector->results.interface.set_bool_result_fn(
            collector->results.instance,
            result_id,
            measured == 1
        );
    }
}

static void collect_reset(SeleneRuntimeGetOperationInstance instance,
                          uint64_t qubit) {
    Collector *collector = (Collector *)instance;
    collector->simulator.interface.reset_fn(collector->simulator.instance, qubit);
}

static void collect_measure_leaked(SeleneRuntimeGetOperationInstance instance,
                                   uint64_t qubit,
                                   uint64_t result_id) {
    Collector *collector = (Collector *)instance;
    SeleneErrno measured = collector->simulator.interface.measure_fn(
        collector->simulator.instance,
        qubit
    );
    if (measured == 0 || measured == 1) {
        collector->results.interface.set_u64_result_fn(
            collector->results.instance,
            result_id,
            (uint64_t)measured
        );
    }
}

static void collect_custom(SeleneRuntimeGetOperationInstance instance,
                           size_t tag,
                           const void *data,
                           size_t len) {
    (void)instance;
    (void)tag;
    (void)data;
    (void)len;
    /* Return an error from the enclosing handle call in production code. */
}

static void collect_batch_time(SeleneRuntimeGetOperationInstance instance,
                               uint64_t start,
                               uint64_t duration) {
    (void)instance;
    (void)start;
    (void)duration;
    /* Store timing if the model has time-dependent noise. */
}
```

The simulator measurement convention is the same as the simulator C API:
`0` means false, `1` means true, and any other value is an error.

## 4. Handle a Runtime Batch

Build a `RuntimeGetOperationHandle` from your collector and ask Selene to
extract the batch:

```c
static SeleneErrno my_error_model_handle_operations(
    SeleneErrorModelInstance handle,
    struct RuntimeExtractOperationHandle batch,
    struct SimulatorHandle simulator,
    struct ErrorModelSetResultHandle results
) {
    Collector collector = {
        .simulator = simulator,
        .results = results,
        .model = (MyErrorModel *)handle,
    };

    struct RuntimeGetOperationInterface interface = {
        .measure_fn = collect_measure,
        .measure_leaked_fn = collect_measure_leaked,
        .reset_fn = collect_reset,
        .custom_fn = collect_custom,
        .set_batch_time_fn = collect_batch_time,
        .gate_fn = collect_gate,
    };

    struct RuntimeGetOperationHandle sink = {
        .instance = &collector,
        .interface = interface,
    };

    batch.interface.extract_fn(batch, sink);
    return 0;
}
```

Production code should collect errors from callbacks and return nonzero if any
simulator call fails. A small collector struct is usually the cleanest way to
store that error state.

## 5. Inject Gates

To inject a gate, serialize a `GwGateInstanceView` and call the simulator's
`gate_fn`:

```c
static SeleneErrno inject_rz(struct SimulatorHandle simulator,
                             uint32_t qubit,
                             double theta) {
    GwGateValue values[2] = {
        {
            .abi_size = sizeof(GwGateValue),
            .kind = GW_OPERAND_KIND_QUBIT,
            .data.qubit = qubit,
        },
        {
            .abi_size = sizeof(GwGateValue),
            .kind = GW_OPERAND_KIND_F64,
            .data.f64_value = theta,
        },
    };

    GwGateInstanceView gate = {
        .abi_size = sizeof(GwGateInstanceView),
        .semantic_id = gw_builtin_rz_semantic_id(),
        .values_ptr = values,
        .values_len = 2,
    };

    size_t len = 0;
    if (gw_gate_serialized_len(&gate, &len) != GW_STATUS_OK) {
        return 1;
    }

    uint8_t *buffer = malloc(len);
    if (buffer == NULL) {
        return 1;
    }

    size_t written = 0;
    GwStatus status = gw_gate_serialize(&gate, buffer, len, &written);
    if (status == GW_STATUS_OK) {
        status = simulator.interface.gate_fn(simulator.instance, buffer, written) == 0
            ? GW_STATUS_OK
            : GW_STATUS_PANIC;
    }

    free(buffer);
    return status == GW_STATUS_OK ? 0 : 1;
}
```

## 6. Reseed and Report Metrics

```c
static SeleneErrno my_error_model_shot_start(SeleneErrorModelInstance handle,
                                             uint64_t shot_id,
                                             uint64_t seed) {
    MyErrorModel *model = (MyErrorModel *)handle;
    (void)shot_id;
    model->rng_state = seed;
    model->injected_errors = 0;
    return 0;
}

static SeleneErrno my_error_model_get_metrics(SeleneErrorModelInstance handle,
                                              uint8_t nth_metric,
                                              char *tag,
                                              uint8_t *datatype,
                                              uint64_t *value) {
    MyErrorModel *model = (MyErrorModel *)handle;
    if (nth_metric != 0) {
        return 1;
    }
    strcpy(tag, "injected_errors");
    *datatype = 2; /* u64 */
    *value = model->injected_errors;
    return 0;
}
```

## 7. Export the Descriptor

```c
const SeleneErrorModelPluginDescriptorV1 selene_error_model_plugin_descriptor_v1 = {
    .struct_size = sizeof(SeleneErrorModelPluginDescriptorV1),
    .api_version = SELENE_ERROR_MODEL_CURRENT_API_VERSION,
    .init_fn = my_error_model_init,
    .exit_fn = my_error_model_exit,
    .shot_start_fn = my_error_model_shot_start,
    .shot_end_fn = my_error_model_shot_end,
    .handle_operations_fn = my_error_model_handle_operations,
    .get_metrics_fn = my_error_model_get_metrics,
    .negotiate_gateset_fn = my_error_model_negotiate_gateset,
};
```

The descriptor should make the plugin's contract obvious: what it accepts, what
it emits, and how it reports failures.
