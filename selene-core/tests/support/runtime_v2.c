#ifdef WITH_V2
#include <selene/runtime.h>

/* Stateless, concurrent v2 fixture; its allocation result identifies this ABI. */
static int init(RuntimeInstanceV2 *out, uint64_t n, uint64_t start,
                uint32_t argc, const char *const *argv) { *out = NULL; return 0; }
static int finish(RuntimeInstanceV2 handle) { return 0; }
static int shot_start(RuntimeInstanceV2 handle, uint64_t shot, uint64_t seed) { return 0; }
static int nop(RuntimeInstanceV2 handle) { return 0; }
static int unary(RuntimeInstanceV2 handle, uint64_t id) { return 0; }
static int qalloc(RuntimeInstanceV2 handle, uint64_t *out) { *out = 999; return 0; }
static int local_barrier(RuntimeInstanceV2 handle, const uint64_t *qubits,
                         uint64_t len, uint64_t delay) { return 0; }
static int rz(RuntimeInstanceV2 handle, uint64_t q, double theta) { return 0; }
static int rxy(RuntimeInstanceV2 handle, uint64_t q, double theta, double phi) { return 0; }
static int rzz(RuntimeInstanceV2 handle, uint64_t a, uint64_t b, double theta) { return 0; }
static int rpp(RuntimeInstanceV2 handle, uint64_t a, uint64_t b, double theta, double phi) { return 0; }
static int measure(RuntimeInstanceV2 handle, uint64_t q, uint64_t *out) { *out = 999; return 0; }
static int force(RuntimeInstanceV2 handle, uint64_t id) { return 0; }
static int next(RuntimeInstanceV2 handle, RuntimeGetOperationHandle ops) { return 0; }
static int get_bool(RuntimeInstanceV2 handle, uint64_t id, int8_t *out) { *out = -1; return 0; }
static int get_u64(RuntimeInstanceV2 handle, uint64_t id, uint64_t *out) { *out = UINT64_MAX; return 0; }
static int set_bool(RuntimeInstanceV2 handle, uint64_t id, bool value) { return 0; }
static int set_u64(RuntimeInstanceV2 handle, uint64_t id, uint64_t value) { return 0; }

#define FIELDS \
    .struct_size = sizeof(SeleneRuntimePluginDescriptorV2), .api_version = SELENE_RUNTIME_CURRENT_API_VERSION, \
    .init_fn = init, .exit_fn = finish, .get_next_operations_fn = next, \
    .shot_start_fn = shot_start, .shot_end_fn = nop, .get_metrics_fn = NULL, \
    .qalloc_fn = qalloc, .qfree_fn = unary, .local_barrier_fn = local_barrier, \
    .global_barrier_fn = unary, .rxy_gate_fn = rxy, .rzz_gate_fn = rzz, \
    .rz_gate_fn = rz, .rpp_gate_fn = rpp, .measure_fn = measure, \
    .measure_leaked_fn = measure, .reset_fn = unary, .force_result_fn = force, \
    .get_bool_result_fn = get_bool, .get_u64_result_fn = get_u64, \
    .set_bool_result_fn = set_bool, .set_u64_result_fn = set_u64, \
    .increment_future_refcount_fn = unary, .decrement_future_refcount_fn = unary


#ifdef DATA_SYMBOL
const SeleneRuntimePluginDescriptorV2 selene_runtime_plugin_descriptor_v2 = { FIELDS };
#else
static const SeleneRuntimePluginDescriptorV2 descriptor = { FIELDS };
const SeleneRuntimePluginDescriptorV2 *selene_runtime_get_plugin_descriptor_v2(void) {
    return &descriptor;
}
#endif
#endif
