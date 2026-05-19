#ifndef BASE_QIS_PRINT_H
#define BASE_QIS_PRINT_H

#include <stdint.h>
#include <base_qis/cl_types.h>
#include <base_qis/macros.h>

EXPORT void print_bool(cl_string tag, uint64_t _unused, char value);
EXPORT void print_int(cl_string tag, uint64_t _unused, int64_t value);
EXPORT void print_uint(cl_string tag, uint64_t _unused, uint64_t value);
EXPORT void print_float(cl_string tag, uint64_t _unused, double value);
EXPORT void print_bool_arr(cl_string tag, uint64_t _unused, struct cl_array* arr);
EXPORT void print_int_arr(cl_string tag, uint64_t _unused, struct cl_array* arr);
EXPORT void print_uint_arr(cl_string tag, uint64_t _unused, struct cl_array* arr);
EXPORT void print_float_arr(cl_string tag, uint64_t _unused, struct cl_array* arr);

#endif
