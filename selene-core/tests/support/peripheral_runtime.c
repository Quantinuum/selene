#include <selene/pipeline_runtime.h>

#ifndef TEST_VERSION
#define TEST_VERSION SELENE_RUNTIME_V2_API_VERSION
#endif
#ifndef TEST_SIZE
#define TEST_SIZE sizeof(SeleneRuntimePluginDescriptorV2)
#endif

static int32_t initialise(RuntimeInstance *instance, uint64_t n_qubits,
                           uint64_t start, uint32_t argc, const char *const *argv) {
    (void)instance;
    (void)n_qubits;
    (void)start;
    (void)argc;
    (void)argv;
    /* Validation should reject this fixture before initialisation. */
    return 99;
}

static const SeleneRuntimePluginDescriptorV2 descriptor = {
    .struct_size = TEST_SIZE,
    .api_version = TEST_VERSION,
    .init_fn = initialise,
};

const SeleneRuntimePluginDescriptorV2 *selene_runtime_get_plugin_descriptor_v2(void) {
#ifdef TEST_NULL
    return NULL;
#else
    return &descriptor;
#endif
}

/* Advertising a legacy getter must not hide an invalid v2 descriptor. */
const SeleneRuntimePluginDescriptorV1 *selene_runtime_get_plugin_descriptor_v1(void) {
    return NULL;
}
