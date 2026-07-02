#ifndef BASE_QIS_HOOKS_H
#define BASE_QIS_HOOKS_H

#include <stdint.h>

#include <base_qis/macros.h>
#include <selene/selene.h>

EXPORT void simulate_delay(uint64_t delay_ns);
EXPORT uint64_t custom_runtime_call(uint64_t tag, void* data, uint64_t data_len);
EXPORT void log_utility_call(uint64_t tag, void* data, uint64_t data_len);
EXPORT struct selene_void_result_t register_utility_event_callbacks(
    SeleneInstance* instance,
    SeleneUtilityEventCallbacksV1 callbacks
);

#endif
