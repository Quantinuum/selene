#ifndef BASE_QIS_HOOKS_H
#define BASE_QIS_HOOKS_H

#include <stdint.h>

#include <base_qis/macros.h>

EXPORT void simulate_delay(uint64_t delay_ns);
EXPORT uint64_t custom_runtime_call(uint64_t tag, void* data, uint64_t data_len);
// Returns the runtime error without exiting the program. data must remain readable
// through this synchronous call; value_out must be writable and is zero on error.
// Callers can release owned buffers before passing an error to early_exit.
EXPORT uint32_t custom_runtime_call_fallible(uint64_t tag, const void* data,
                                           uint64_t data_len, uint64_t* value_out);
EXPORT void log_utility_call(uint64_t tag, void* data, uint64_t data_len);

#endif
