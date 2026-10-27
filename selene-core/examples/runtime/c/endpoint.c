/* A C host and endpoint driving an independently loaded runtime plugin.
 * No simulator or error-model API is needed on this side of the boundary. */
#include <selene/runtime.h>

#include <assert.h>
#include <dlfcn.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <threads.h>

struct Endpoint {
    thrd_t owner;
    bool started;
    bool value;
    unsigned calls;
    unsigned ends;
    unsigned prints;
    unsigned exits;
    SeleneEndpointResultHandle results;
};

static void check_thread(struct Endpoint *endpoint) {
    assert(endpoint->started);
    assert(thrd_equal(endpoint->owner, thrd_current()));
}

static void reset(void *instance, uint64_t qubit) {
    struct Endpoint *endpoint = instance;
    (void)qubit;
    check_thread(endpoint);
    endpoint->value = false;
}

static void rxy(void *instance, uint64_t qubit, double theta, double phi) {
    struct Endpoint *endpoint = instance;
    (void)qubit;
    (void)theta;
    (void)phi;
    check_thread(endpoint);
    endpoint->value = !endpoint->value;
}

static void measure(void *instance, uint64_t qubit, uint64_t result_id) {
    struct Endpoint *endpoint = instance;
    (void)qubit;
    check_thread(endpoint);
    endpoint->results.interface.set_bool_result_fn(
        endpoint->results.instance, result_id, endpoint->value);
}

static void batch_time(void *instance, uint64_t start, uint64_t duration) {
    (void)start;
    (void)duration;
    check_thread(instance);
}

/* The extractor's operation table requires every callback, even for operations
 * our little test endpoint doesn't implement. Leaving unused entries null
 * would violate the batch ABI before any operation was actually called. */
static void unsupported_rz(void *instance, uint64_t qubit, double theta) {
    (void)qubit;
    (void)theta;
    check_thread(instance);
    abort();
}

static void unsupported_rzz(void *instance, uint64_t q0, uint64_t q1, double theta) {
    (void)q0;
    (void)q1;
    unsupported_rz(instance, 0, theta);
}

static void unsupported_rpp(void *instance, uint64_t q0, uint64_t q1,
                            double theta, double phi) {
    (void)phi;
    unsupported_rzz(instance, q0, q1, theta);
}

static void unsupported_measure_leaked(void *instance, uint64_t qubit, uint64_t result) {
    (void)qubit;
    (void)result;
    check_thread(instance);
    abort();
}

static void unsupported_custom(void *instance, size_t tag, const void *data, size_t length) {
    (void)tag;
    (void)data;
    (void)length;
    check_thread(instance);
    abort();
}

static int32_t execute(void *instance, RuntimeExtractOperationHandle batch,
                       SeleneEndpointResultHandle results) {
    struct Endpoint *endpoint = instance;
    check_thread(endpoint);
    endpoint->results = results;
    endpoint->calls++;
    RuntimeGetOperationHandle operations = {
        .instance = endpoint,
        .interface = {
            .reset_fn = reset,
            .rxy_fn = rxy,
            .measure_fn = measure,
            .measure_leaked_fn = unsupported_measure_leaked,
            .custom_fn = unsupported_custom,
            .rz_fn = unsupported_rz,
            .rzz_fn = unsupported_rzz,
            .rpp_fn = unsupported_rpp,
            .set_batch_time_fn = batch_time,
        },
    };
    batch.interface.extract_fn(batch.instance, operations);
    /* The result sink belongs to this call. We must not use it afterwards. */
    memset(&endpoint->results, 0, sizeof(endpoint->results));
    return 0;
}

static int32_t dump_state(void *instance, const char *file,
                          const uint64_t *qubits, uint64_t count) {
    struct Endpoint *endpoint = instance;
    (void)qubits;
    (void)count;
    check_thread(endpoint);
    FILE *output = fopen(file, "w");
    if (output == NULL) return -1;
    fprintf(output, "%d", endpoint->value);
    return fclose(output);
}

static int32_t start_endpoint(void *context) {
    struct Endpoint *endpoint = context;
    if (endpoint->ends != 0) {
        assert(thrd_equal(endpoint->owner, thrd_current()));
    }
    endpoint->owner = thrd_current();
    endpoint->started = true;
    endpoint->value = false;
    endpoint->calls = 0;
    return 0;
}

static int32_t end_endpoint(void *context) {
    struct Endpoint *endpoint = context;
    check_thread(endpoint);
    endpoint->started = false;
    endpoint->ends++;
    return 0;
}

struct Inspection {
    struct Endpoint *endpoint;
    bool expected_value;
    unsigned expected_calls;
    unsigned calls;
};

static int32_t inspect(void *context, SeleneQuantumEndpoint borrowed) {
    struct Inspection *inspection = context;
    struct Endpoint *endpoint = inspection->endpoint;
    check_thread(endpoint);
    assert(borrowed.instance == endpoint);
    assert(endpoint->value == inspection->expected_value);
    assert(endpoint->calls == inspection->expected_calls);
    inspection->calls++;
    return 0;
}

static int32_t print_records(void *context, uint64_t timestamp,
                             const SelenePrintRequest *records, uint64_t length) {
    struct Endpoint *state = context;
    check_thread(state);
    assert(timestamp == 123);
    assert(length == 1);
    const SelenePrintRequest *record = &records[0];
    assert(record->value.datatype == SeleneOutputDatatype_U64);
    if (record->value.is_array) {
        const uint64_t *values = record->value.data;
        assert(record->value.length == 2);
        assert(values[0] == 42 && values[1] == 64);
        state->prints++;
    } else {
        assert(*(const uint64_t *)record->value.data == 72);
        /* Exit must have executed the preceding reset before printing. */
        assert(!state->value);
        state->exits++;
    }
    return 0;
}

static int32_t flush_output(void *context) {
    check_thread(context);
    return 0;
}

static SeleneRuntimeInstructionResult instruction(
    const SeleneRuntimePluginDescriptorV2 *runtime, RuntimeInstance instance,
    uint32_t tag, SeleneRuntimeInstructionPayload payload) {
    SeleneRuntimeInstruction request = {
        .struct_size = sizeof(request), .tag = tag, .payload = payload,
    };
    SeleneRuntimeInstructionResult result = {0};
    assert(runtime->handle_instruction_fn(instance, &request, &result) == 0);
    return result;
}

int main(int argc, char **argv) {
    assert(argc == 3);
    void *library = dlopen(argv[1], RTLD_NOW | RTLD_LOCAL);
    if (library == NULL) {
        fprintf(stderr, "%s\n", dlerror());
        return 1;
    }
    const SeleneRuntimePluginDescriptorV2 *runtime =
        dlsym(library, "selene_runtime_plugin_descriptor_v2");
    assert(runtime != NULL);
    assert(runtime->struct_size == sizeof(*runtime));
    assert(runtime->api_version == SELENE_RUNTIME_CURRENT_API_VERSION);
    char scheduler_arg[4096];
    assert(snprintf(scheduler_arg, sizeof(scheduler_arg), "--scheduler=%s", argv[2]) > 0);
    const char *args[] = {
        scheduler_arg,
        "--duration-ns-rxy=0", "--duration-ns-rzz=0",
        "--duration-ns-rz=0", "--duration-ns-rpp=0", "--duration-ns-measure=0",
        "--duration-ns-reset=0", "--duration-ns-measure-leaked=0",
    };
    RuntimeInstance instance = NULL;
    assert(runtime->init_fn(&instance, 1, 0, sizeof(args) / sizeof(args[0]), args) == 0);
    struct Endpoint state = {0};
    SeleneQuantumEndpoint endpoint = {
        .instance = &state,
        .interface = { .handle_operations_fn = execute, .dump_state_fn = dump_state },
    };
    SeleneOutputSink output = { .context = &state, .write_fn = print_records, .flush_fn = flush_output };
    for (uint64_t shot = 0; shot < 2; ++shot) {
        /* The host owns lifecycle policy. The runtime merely runs these opaque
         * callbacks on the thread where it will later use the endpoint. */
        assert(runtime->on_execution_thread_fn(instance, start_endpoint, &state) == 0);
        assert(!thrd_equal(state.owner, thrd_current()));
        assert(runtime->shot_start_fn(instance, shot, 123, endpoint, output) == 0);
        instruction(runtime, instance, SeleneRuntimeInstructionTag_SetTimeCursor,
            (SeleneRuntimeInstructionPayload){ .set_time_cursor = { .time_cursor = 123 } });
        SeleneRuntimeInstructionResult cursor = instruction(runtime, instance,
            SeleneRuntimeInstructionTag_GetTimeCursor, (SeleneRuntimeInstructionPayload){0});
        assert(cursor.tag == SeleneRuntimeInstructionResultTag_U64 && cursor.available);
        assert(cursor.value == 123);
        SeleneRuntimeInstructionResult allocated = instruction(runtime, instance,
            SeleneRuntimeInstructionTag_QAlloc, (SeleneRuntimeInstructionPayload){0});
        assert(allocated.tag == SeleneRuntimeInstructionResultTag_Qubit && allocated.available);
        uint64_t qubit = allocated.value;
        instruction(runtime, instance, SeleneRuntimeInstructionTag_Reset,
            (SeleneRuntimeInstructionPayload){ .reset = { .qubit_id = qubit } });
        instruction(runtime, instance, SeleneRuntimeInstructionTag_RXYGate,
            (SeleneRuntimeInstructionPayload){ .rxy_gate = {
                .qubit_id = qubit, .theta = 3.141592653589793, .phi = 0 } });
        uint64_t values[] = {42, 64};
        SelenePrintRequest print = {
            .struct_size = sizeof(print),
            .tag = { .data = "example", .length = 7 },
            .value = { .datatype = SeleneOutputDatatype_U64, .is_array = true, .data = values, .length = 2 },
        };
        instruction(runtime, instance, SeleneRuntimeInstructionTag_Print,
            (SeleneRuntimeInstructionPayload){ .print = &print });
        values[0] = 999; /* Queued requests must already own their input. */
        SeleneEndpointBorrowRequest request = {
            .struct_size = sizeof(request), .force_flush = false,
        };
        struct Inspection inspection = { .endpoint = &state };
        assert(runtime->borrow_endpoint_fn(instance, &request, inspect, &inspection) == 0);
        assert(inspection.calls == 1);
        request.force_flush = true;
        inspection.expected_value = true;
        inspection.expected_calls = 2;
        assert(runtime->borrow_endpoint_fn(instance, &request, inspect, &inspection) == 0);
        assert(inspection.calls == 2);
        SeleneRuntimeInstructionResult future = instruction(runtime, instance,
            SeleneRuntimeInstructionTag_Measure,
            (SeleneRuntimeInstructionPayload){ .measure = { .qubit_id = qubit } });
        assert(future.tag == SeleneRuntimeInstructionResultTag_Future && future.available);
        instruction(runtime, instance, SeleneRuntimeInstructionTag_ForceResult,
            (SeleneRuntimeInstructionPayload){ .force_result = { .result_id = future.value } });
        SeleneRuntimeInstructionResult measured = instruction(runtime, instance,
            SeleneRuntimeInstructionTag_GetBoolResult,
            (SeleneRuntimeInstructionPayload){ .get_bool_result = { .result_id = future.value } });
        assert(measured.tag == SeleneRuntimeInstructionResultTag_Bool && measured.available && measured.value == 1);
        instruction(runtime, instance, SeleneRuntimeInstructionTag_Reset,
            (SeleneRuntimeInstructionPayload){ .reset = { .qubit_id = qubit } });
        SeleneExitRequest exit = {
            .struct_size = sizeof(exit), .error_code = 72,
            .message = { .data = "done", .length = 4 },
        };
        instruction(runtime, instance, SeleneRuntimeInstructionTag_Exit,
            (SeleneRuntimeInstructionPayload){ .exit = &exit });
        assert(state.prints == shot + 1 && state.exits == shot + 1);
        SeleneRuntimeInstruction rejected = {
            .struct_size = sizeof(rejected), .tag = SeleneRuntimeInstructionTag_QAlloc,
        };
        SeleneRuntimeInstructionResult ignored;
        assert(runtime->handle_instruction_fn(instance, &rejected, &ignored) != 0);
        cursor = instruction(runtime, instance,
            SeleneRuntimeInstructionTag_GetTimeCursor, (SeleneRuntimeInstructionPayload){0});
        assert(cursor.tag == SeleneRuntimeInstructionResultTag_U64 && cursor.available);
        assert(cursor.value == 123);
        assert(runtime->shot_end_fn(instance) == 0);
        assert(runtime->on_execution_thread_fn(instance, end_endpoint, &state) == 0);
    }
    assert(state.ends == 2);
    assert(runtime->destroy_fn(instance) == 0);
    dlclose(library);
    return 0;
}
