/**
 * This file defines a shim for running Selene with a compiled
 * program for the Helios Quantum Instruction Set.
 *
 * The user's program is expected to have a `qmain` function.
 * This is invoked on each shot, and the calls it makes are
 * routed to the selene library.
 */

#include <stdlib.h>

#include <selene/selene.h>
#include <base_qis/heap.h>

#include "logging.h"

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
