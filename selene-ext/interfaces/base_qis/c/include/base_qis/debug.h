#ifndef BASE_QIS_DEBUG_H
#define BASE_QIS_DEBUG_H

#include <stdint.h>

#include <base_qis/cl_types.h>
#include <base_qis/macros.h>

EXPORT void print_state_result(
    cl_string tag,
    uint64_t unused,
    struct cl_array* qubits
);

#endif
