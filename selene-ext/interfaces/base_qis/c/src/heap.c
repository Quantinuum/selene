#include <base_qis/heap.h>

#include "logging.h" // DIAGNOSTIC
#include "program_context.h"

void* heap_alloc(size_t size) {
    DIAGNOSTIC("heap_alloc(%zu)\n", size);
    // If we couldn't create the shot's heap, report allocation failure in
    // the same way as malloc would by returning NULL.
    void* ptr = program_context.heap == NULL
        ? NULL : mi_heap_malloc(program_context.heap, size);
    DIAGNOSTIC("   allocated %p\n", ptr);
    return ptr;
}

void heap_free(void* ptr) {
    DIAGNOSTIC("heap_free(%p)\n", ptr);
    mi_free(ptr);
    DIAGNOSTIC("   [done]\n");
}
