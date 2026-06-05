#include <base_qis/heap.h>

#include <stdlib.h> // malloc, free

#include "logging.h" // DIAGNOSTIC

void* heap_alloc(size_t size) {
    DIAGNOSTIC("heap_alloc(%zu)\n", size);
    // Later we might want to make a classical runtime plugin
    // and route heap usage to that via selene. However, for
    // now we just use malloc.
    void* ptr = malloc(size);
    DIAGNOSTIC("   allocated %p\n", ptr);
    return ptr;
}

void heap_free(void* ptr) {
    DIAGNOSTIC("heap_free(%p)\n", ptr);
    // Again, we just use free for now.
    free(ptr);
    DIAGNOSTIC("   [done]\n");
}
