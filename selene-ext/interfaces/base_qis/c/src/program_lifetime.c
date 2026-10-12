#include <base_qis/program_lifetime.h>

#include "program_context.h"
#include <stdatomic.h>
#include <assert.h>

context_attrs RunContext program_context = {0};

// A compiled runner has one root; it remains active until all workers join.
static atomic_bool root_program_active = false;

static struct user_program_result_t run_program(
    user_program_t user_program, uint64_t arg, bool retain_root_heap
){
    program_context.heap = mi_heap_new();
    int jump_code = setjmp(program_context.program_end);
    user_program_result_t result = {0};
    if(jump_code == 0){
        uint64_t program_return = user_program(arg);
        result.exited_early = false;
        result.result_or_error_code = program_return;
    }else{
        result.exited_early = true;
        result.result_or_error_code = program_context.error_code;
    }
    if (retain_root_heap) {
        // Captures transferred to workers can still point into the root heap.
        program_context.retired_root_heap = program_context.heap;
    } else if (program_context.heap != NULL) {
        if (atomic_load_explicit(&root_program_active, memory_order_acquire)) {
            // A worker can return owned heap values. Delete the heap while
            // retaining its live allocations for the receiving code to free.
            mi_heap_delete(program_context.heap);
        } else {
            // Preserve the standalone wrapper's automatic allocation cleanup.
            mi_heap_destroy(program_context.heap);
        }
    }
    program_context.heap = NULL;
    return result;
}

struct user_program_result_t user_program_wrapper(user_program_t program, uint64_t arg) {
    return run_program(program, arg, false);
}

struct user_program_result_t user_program_root_wrapper(user_program_t program, uint64_t arg) {
    assert(program_context.retired_root_heap == NULL);
    atomic_store_explicit(&root_program_active, true, memory_order_release);
    return run_program(program, arg, true);
}

void user_program_release_root_heap(void) {
    // The runner calls this on the root thread after runtime shutdown joined workers.
    if (program_context.retired_root_heap != NULL) {
        mi_heap_destroy(program_context.retired_root_heap);
        program_context.retired_root_heap = NULL;
    }
    atomic_store_explicit(&root_program_active, false, memory_order_release);
}

void early_exit(uint32_t error_code){
    program_context.error_code = error_code;
    longjmp(program_context.program_end, 1);
}
