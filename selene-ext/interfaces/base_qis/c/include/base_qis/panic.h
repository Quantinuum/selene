#ifndef BASE_QIS_PANIC_H
#define BASE_QIS_PANIC_H

#include <stdint.h>

#include <base_qis/macros.h>
#include <base_qis/cl_types.h>

EXPORT void panic(int32_t error_code, cl_string message);
EXPORT void panic_str(int32_t error_code, char const* message);

#endif
