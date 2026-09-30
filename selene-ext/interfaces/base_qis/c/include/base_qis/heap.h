#ifndef BASE_QIS_HEAP_H
#define BASE_QIS_HEAP_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <inttypes.h>

#include <base_qis/macros.h>

// Allocations belong to the current shot. Anything the user hasn't freed
// is freed by user_program_wrapper when the program returns or exits early.
EXPORT void* heap_alloc(size_t size);
EXPORT void heap_free(void* ptr);

#endif
