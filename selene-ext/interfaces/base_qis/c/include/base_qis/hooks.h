#ifndef BASE_QIS_HOOKS_H
#define BASE_QIS_HOOKS_H

#include <stdint.h>

#include <base_qis/macros.h>

EXPORT void simulate_delay(uint64_t delay_ns);
EXPORT uint64_t custom_runtime_call(uint64_t tag, void* data, uint64_t data_len);
EXPORT void log_utility_call(uint64_t tag, void* data, uint64_t data_len);

#endif
