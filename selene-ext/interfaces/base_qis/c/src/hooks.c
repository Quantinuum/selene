#include <base_qis/hooks.h>

#include <selene/selene.h> // selene_custom_runtime_call, selene_log_utility_call, selene_simulate_delay
#include <base_qis/selene_lifetime.h> // selene_instance
#include <base_qis/unwrap.h> // unwrap

#include "logging.h"

uint64_t custom_runtime_call(uint64_t tag, void* data, uint64_t data_len) {
    DIAGNOSTIC("custom_runtime_call(%" PRIu64 ", %p, %" PRIu64 ")\n", tag, data, data_len);
    DIAGNOSTIC("Data:\n");
    for (uint64_t i = 0; i < data_len; ++i) {
        DIAGNOSTIC("   %02X ", ((uint8_t*)data)[i]);
    }
    return unwrap(selene_custom_runtime_call(selene_instance, tag, data, data_len));
}

uint32_t custom_runtime_call_fallible(uint64_t tag, const void* data,
                                    uint64_t data_len, uint64_t* value_out) {
    *value_out = 0;
    struct selene_u64_result_t result =
        selene_custom_runtime_call(selene_instance, tag, data, data_len);
    if (result.error_code == 0) {
        *value_out = result.value;
    }
    return result.error_code;
}

void simulate_delay(uint64_t delay_ns) {
    DIAGNOSTIC("simulate_delay(%" PRIu64 ")\n", delay_ns);
    unwrap(selene_simulate_delay(selene_instance, delay_ns));
    DIAGNOSTIC("   [done]\n");
}

void log_utility_call(uint64_t tag, void* data, uint64_t data_len) {
    DIAGNOSTIC("log_utility_call(%" PRIu64 ", %p, %" PRIu64 ")\n", tag, data, data_len);
    DIAGNOSTIC("Data:\n");
    for (uint64_t i = 0; i < data_len; ++i) {
        DIAGNOSTIC("   %02X ", ((uint8_t*)data)[i]);
    }
    unwrap(selene_log_utility_call(selene_instance, tag, data, data_len));
}
