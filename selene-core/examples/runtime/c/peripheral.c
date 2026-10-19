/* A C host and peripheral driving an independently loaded runtime plugin.
 * No simulator or error-model API is needed on this side of the boundary. */
#include <selene/pipeline_runtime.h>

#include <assert.h>
#include <dlfcn.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <threads.h>

struct Peripheral {
    thrd_t owner;
    bool started;
    bool value;
    unsigned calls;
    unsigned ends;
    SelenePeripheralResultHandle results;
};

static void check_thread(struct Peripheral *peripheral) {
    assert(peripheral->started);
    assert(thrd_equal(peripheral->owner, thrd_current()));
}

static void reset(void *instance, uint64_t qubit) {
    struct Peripheral *peripheral = instance;
    (void)qubit;
    check_thread(peripheral);
    peripheral->value = false;
}

static void rxy(void *instance, uint64_t qubit, double theta, double phi) {
    struct Peripheral *peripheral = instance;
    (void)qubit;
    (void)theta;
    (void)phi;
    check_thread(peripheral);
    peripheral->value = !peripheral->value;
}

static void measure(void *instance, uint64_t qubit, uint64_t result_id) {
    struct Peripheral *peripheral = instance;
    (void)qubit;
    check_thread(peripheral);
    peripheral->results.interface.set_bool_result_fn(
        peripheral->results.instance, result_id, peripheral->value);
}

static void batch_time(void *instance, uint64_t start, uint64_t duration) {
    (void)start;
    (void)duration;
    check_thread(instance);
}

/* The extractor's operation table requires every callback, even for operations
 * our little test peripheral doesn't implement. Leaving unused entries null
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
                       SelenePeripheralResultHandle results) {
    struct Peripheral *peripheral = instance;
    check_thread(peripheral);
    peripheral->results = results;
    peripheral->calls++;
    RuntimeGetOperationHandle operations = {
        .instance = peripheral,
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
    memset(&peripheral->results, 0, sizeof(peripheral->results));
    return 0;
}

static int32_t dump_state(void *instance, const char *file,
                          const uint64_t *qubits, uint64_t count) {
    struct Peripheral *peripheral = instance;
    (void)qubits;
    (void)count;
    check_thread(peripheral);
    FILE *output = fopen(file, "w");
    if (output == NULL) return -1;
    fprintf(output, "%d", peripheral->value);
    return fclose(output);
}

static int32_t start_peripheral(void *context) {
    struct Peripheral *peripheral = context;
    if (peripheral->ends != 0) {
        assert(thrd_equal(peripheral->owner, thrd_current()));
    }
    peripheral->owner = thrd_current();
    peripheral->started = true;
    peripheral->value = false;
    peripheral->calls = 0;
    return 0;
}

static int32_t end_peripheral(void *context) {
    struct Peripheral *peripheral = context;
    check_thread(peripheral);
    peripheral->started = false;
    peripheral->ends++;
    return 0;
}

struct Inspection {
    struct Peripheral *peripheral;
    bool expected_value;
    unsigned expected_calls;
    unsigned calls;
};

static int32_t inspect(void *context, SeleneQuantumPeripheral borrowed) {
    struct Inspection *inspection = context;
    struct Peripheral *peripheral = inspection->peripheral;
    check_thread(peripheral);
    assert(borrowed.instance == peripheral);
    assert(peripheral->value == inspection->expected_value);
    assert(peripheral->calls == inspection->expected_calls);
    inspection->calls++;
    return 0;
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
    assert(runtime->api_version == SELENE_RUNTIME_V2_API_VERSION);
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
    struct Peripheral state = {0};
    SeleneQuantumPeripheral peripheral = {
        .instance = &state,
        .interface = { .handle_operations_fn = execute, .dump_state_fn = dump_state },
    };
    for (uint64_t shot = 0; shot < 2; ++shot) {
        /* The host owns lifecycle policy. The runtime merely runs these opaque
         * callbacks on the thread where it will later use the peripheral. */
        assert(runtime->on_execution_thread_fn(instance, start_peripheral, &state) == 0);
        assert(!thrd_equal(state.owner, thrd_current()));
        assert(runtime->shot_start_fn(instance, shot, 123, peripheral) == 0);
        uint64_t qubit = UINT64_MAX;
        assert(runtime->qalloc_fn(instance, &qubit) == 0);
        assert(runtime->reset_fn(instance, qubit) == 0);
        assert(runtime->rxy_gate_fn(instance, qubit, 3.141592653589793, 0) == 0);
        SelenePeripheralBorrowRequest request = {
            .struct_size = sizeof(request), .force_flush = false,
        };
        struct Inspection inspection = { .peripheral = &state };
        assert(runtime->borrow_peripheral_fn(instance, &request, inspect, &inspection) == 0);
        assert(inspection.calls == 1);
        request.force_flush = true;
        inspection.expected_value = true;
        inspection.expected_calls = 2;
        assert(runtime->borrow_peripheral_fn(instance, &request, inspect, &inspection) == 0);
        assert(inspection.calls == 2);
        uint64_t future = UINT64_MAX;
        assert(runtime->measure_fn(instance, qubit, &future) == 0);
        assert(runtime->force_result_fn(instance, future) == 0);
        int8_t measured = -1;
        assert(runtime->get_bool_result_fn(instance, future, &measured) == 0);
        assert(measured == 1);
        assert(runtime->shot_end_fn(instance) == 0);
        assert(runtime->on_execution_thread_fn(instance, end_peripheral, &state) == 0);
    }
    assert(state.ends == 2);
    assert(runtime->exit_fn(instance) == 0);
    dlclose(library);
    return 0;
}
