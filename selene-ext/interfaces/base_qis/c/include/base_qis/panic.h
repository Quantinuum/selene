#ifndef BASE_QIS_PANIC_H
#define BASE_QIS_PANIC_H

#include <stdint.h>

#include <base_qis/macros.h>
#include <base_qis/cl_types.h>

EXPORT void panic(int32_t error_code, cl_string message);
EXPORT void panic_str(int32_t error_code, char const* message);
// Reports without exiting or retaining message. Returns the requested code when
// reporting succeeds, or the reporting error otherwise. The caller can release
// its message storage before passing the returned code to early_exit.
EXPORT uint32_t panic_str_fallible(uint32_t error_code, char const* message);

#endif
