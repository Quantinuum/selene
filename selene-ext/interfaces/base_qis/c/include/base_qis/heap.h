#ifndef BASE_QIS_HEAP_H
#define BASE_QIS_HEAP_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <inttypes.h>

#include <base_qis/macros.h>

// Allocations belong to the current program invocation. Standalone wrappers
// reclaim leftovers on return. Compiled roots retain their heap until shot_end
// joins managed workers. Workers may transfer live allocations to a receiver,
// which must free them when their owned values are consumed.
EXPORT void* heap_alloc(size_t size);
EXPORT void heap_free(void* ptr);

#endif
