/* Deliberately compiled against runtime.h from 34d2ecf^ (API 0.3.0).
 * Keep runtime_v1.h frozen: regenerating it would weaken the binary ABI test. */
#include "runtime_v1.h"
#include <stdlib.h>
#include <string.h>

static _Thread_local int owner_token;
static unsigned exits;
struct State {
    int *owner;
    uint64_t allocations;
    unsigned batch;
    bool forced;
    int8_t boolean;
    uint64_t integer;
};
#define STATE(handle) struct State *s = (handle); if (s->owner != &owner_token) return -1

unsigned test_exit_count(void) { return exits; }
static int init(RuntimeInstance *out, uint64_t n, uint64_t start,
                uint32_t argc, const char *const *argv) {
    (void)n; (void)start;
    if (argc && !strcmp(argv[0], "fail")) return -1;
    struct State *s = calloc(1, sizeof(*s));
    if (!s) return -1;
    s->owner = &owner_token;
    s->boolean = -1;
    s->integer = UINT64_MAX;
    *out = s;
    return 0;
}
static int finish(RuntimeInstance handle) {
    STATE(handle);
    ++exits;
    free(s);
    return 0;
}
static int shot_start(RuntimeInstance handle, uint64_t shot, uint64_t seed) {
    STATE(handle); (void)shot; (void)seed; return 0;
}
static int nop(RuntimeInstance handle) { STATE(handle); return 0; }
static int unary(RuntimeInstance handle, uint64_t id) {
    STATE(handle); (void)id; return 0;
}
static int qalloc(RuntimeInstance handle, uint64_t *out) {
    STATE(handle); *out = s->allocations++; return 0;
}
static int local_barrier(RuntimeInstance handle, const uint64_t *qubits,
                         uint64_t len, uint64_t delay) {
    STATE(handle); (void)delay;
    return len == 2 && qubits[0] == 3 && qubits[1] == 4 ? 0 : -1;
}
static int rz(RuntimeInstance handle, uint64_t q, double theta) {
    STATE(handle); (void)q; (void)theta; return 0;
}
static int rxy(RuntimeInstance handle, uint64_t q, double theta, double phi) {
    STATE(handle); (void)q; (void)theta; (void)phi; return 0;
}
static int rzz(RuntimeInstance handle, uint64_t a, uint64_t b, double theta) {
    STATE(handle); (void)a; (void)b; (void)theta; return 0;
}
static int rpp(RuntimeInstance handle, uint64_t a, uint64_t b, double theta, double phi) {
    STATE(handle); (void)a; (void)b; (void)theta; (void)phi; return 0;
}
static int measure(RuntimeInstance handle, uint64_t q, uint64_t *out) {
    STATE(handle); (void)q; *out = 42; return 0;
}
static int force(RuntimeInstance handle, uint64_t id) {
    STATE(handle); (void)id; s->forced = true; return 0;
}
static int next(RuntimeInstance handle, RuntimeGetOperationHandle ops) {
    STATE(handle);
    if (!s->forced) return 0;
    if (s->batch == 0) {
        ops.interface.reset_fn(ops.instance, 0);
        ops.interface.set_batch_time_fn(ops.instance, 10, 20);
    } else if (s->batch == 1) {
        ops.interface.measure_fn(ops.instance, 0, 42);
    }
    ++s->batch;
    return 0;
}
static int get_bool(RuntimeInstance handle, uint64_t id, int8_t *out) {
    STATE(handle); (void)id; *out = s->boolean; return 0;
}
static int get_u64(RuntimeInstance handle, uint64_t id, uint64_t *out) {
    STATE(handle); (void)id; *out = s->integer; return 0;
}
static int set_bool(RuntimeInstance handle, uint64_t id, bool value) {
    STATE(handle); (void)id; s->boolean = value; return 0;
}
static int set_u64(RuntimeInstance handle, uint64_t id, uint64_t value) {
    STATE(handle); (void)id; s->integer = value; return 0;
}
static int metric(RuntimeInstance handle, uint8_t nth, char *tag, uint8_t *type, uint64_t *out) {
    STATE(handle);
    if (nth) return 1;
    strcpy(tag, "allocations"); *type = 2; *out = s->allocations; return 0;
}
static int custom(RuntimeInstance handle, uint64_t tag, const void *data, size_t len, uint64_t *out) {
    STATE(handle);
    const uint8_t *bytes = data;
    *out = tag;
    for (size_t i = 0; i < len; ++i) *out += bytes[i];
    return 0;
}
#ifndef API_VERSION
#define API_VERSION SELENE_RUNTIME_CURRENT_API_VERSION
#endif
#define FIELDS \
    .struct_size = sizeof(SeleneRuntimePluginDescriptorV1), .api_version = API_VERSION, \
    .init_fn = init, .exit_fn = finish, .get_next_operations_fn = next, \
    .shot_start_fn = shot_start, .shot_end_fn = nop, .get_metrics_fn = metric, \
    .qalloc_fn = qalloc, .qfree_fn = unary, .local_barrier_fn = local_barrier, \
    .global_barrier_fn = unary, .rxy_gate_fn = rxy, .rzz_gate_fn = rzz, \
    .rz_gate_fn = rz, .rpp_gate_fn = rpp, .measure_fn = measure, \
    .measure_leaked_fn = measure, .reset_fn = unary, .force_result_fn = force, \
    .get_bool_result_fn = get_bool, .get_u64_result_fn = get_u64, \
    .set_bool_result_fn = set_bool, .set_u64_result_fn = set_u64, \
    .increment_future_refcount_fn = unary, .decrement_future_refcount_fn = unary

#ifdef DATA_SYMBOL
const SeleneRuntimePluginDescriptorV1 selene_runtime_plugin_descriptor_v1 = {
#else
static const SeleneRuntimePluginDescriptorV1 descriptor = {
#endif
    FIELDS,
#ifndef NO_OPTIONALS
    .custom_call_fn = custom, .simulate_delay_fn = unary,
#endif
};
#ifndef DATA_SYMBOL
const SeleneRuntimePluginDescriptorV1 *selene_runtime_get_plugin_descriptor_v1(void) {
    return &descriptor;
}
#endif

/* A v2 advertisement must be validated, never silently bypassed for v1. */
#ifdef BAD_V2
const void *selene_runtime_get_plugin_descriptor_v2(void) {
#if BAD_V2 == 1
    return NULL;
#elif BAD_V2 == 2
    static const uint64_t too_small = sizeof(uint64_t);
    return &too_small;
#else
    return &descriptor; /* Full descriptor, but API 0.3 is invalid for v2. */
#endif
}
#endif
