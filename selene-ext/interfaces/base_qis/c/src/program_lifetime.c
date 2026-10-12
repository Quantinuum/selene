#include <base_qis/program_lifetime.h>
#include <base_qis/selene_lifetime.h>
#include <selene/selene.h>

#include "program_context.h"
#include <stdatomic.h>
#include <assert.h>

context_attrs RunContext program_context = {0};

// The runner has one compiled root. Native drain/join protects delayed entry.
static atomic_bool root_program_active = false;

enum program_kind { LEGACY_PROGRAM, MANAGED_ROOT, RETAINED_ROOT };

static void release_heap(bool retain) {
    if (retain) {
        program_context.retired_root_heap = program_context.heap;
    } else if (program_context.heap != NULL) {
        if (atomic_load_explicit(&root_program_active, memory_order_acquire)) {
            // Live values returned by workers remain owned by their receivers.
            mi_heap_delete(program_context.heap);
        } else {
            mi_heap_destroy(program_context.heap);
        }
    }
    program_context.heap = NULL;
}

static user_program_result_t run_program(user_program_t program, uint64_t arg,
                                         enum program_kind kind) {
    assert(!program_context.active);
    program_context.active = true;
    program_context.managed = kind == MANAGED_ROOT
        || (kind == RETAINED_ROOT && selene_has_worker_boundary(selene_instance));
    program_context.heap = mi_heap_new();
    int jump_code = setjmp(program_context.program_end);
    user_program_result_t result = {0};
    if (jump_code == 0) {
        result.result_or_error_code = program(arg);
    } else {
        result.exited_early = true;
        result.result_or_error_code = program_context.error_code;
    }
    if (kind == MANAGED_ROOT) {
        // Keep root captures alive through native drain, including callbacks
        // that have been created but have not entered Selene yet. End runs on
        // this thread, while the separate consumer continues delivering QMC.
        struct selene_void_result_t ended = selene_on_shot_end(selene_instance);
        if (!result.exited_early && ended.error_code != 0) {
            result.exited_early = true;
            result.result_or_error_code = ended.error_code;
        }
        atomic_store_explicit(&root_program_active, false, memory_order_release);
    }
    release_heap(kind == RETAINED_ROOT);
    program_context.managed = false;
    program_context.active = false;
    return result;
}

user_program_result_t user_program_wrapper(user_program_t program, uint64_t arg) {
    bool managed_root = !atomic_load_explicit(&root_program_active, memory_order_acquire)
        && selene_has_worker_boundary(selene_instance);
    if (managed_root) {
        atomic_store_explicit(&root_program_active, true, memory_order_release);
    }
    return run_program(program, arg, managed_root ? MANAGED_ROOT : LEGACY_PROGRAM);
}

user_program_result_t selene_run_worker(selene_worker_program_t callback,
                                      void *data, void *result) {
    // Do not overwrite an already live frame on this thread.
    if (program_context.active) {
        return (user_program_result_t){true, 100001};
    }
    program_context.active = true;
    program_context.managed = false;
    program_context.counted = false;
    program_context.heap = mi_heap_new();
    int jump_code = setjmp(program_context.program_end);
    user_program_result_t status = {0};
    if (jump_code == 0) {
#ifndef USER_PROGRAM_THREADING
        early_exit(100001);
#else
        // The native backend must retain the root through drain/join. The
        // active flag detects invalid entry after that lifetime has ended.
        if (!atomic_load_explicit(&root_program_active, memory_order_acquire)) {
            early_exit(100001);
        }
        struct selene_bool_result_t entry = selene_worker_enter(selene_instance);
        program_context.counted = entry.value;
        program_context.managed = entry.value;
        if (entry.error_code != 0) early_exit(entry.error_code);
        if (callback == NULL || result == NULL) early_exit(100001);
        callback(data, result);
#endif
    } else {
        status.exited_early = true;
        status.result_or_error_code = program_context.error_code;
    }
    release_heap(false);
    if (program_context.counted) {
        selene_worker_leave(selene_instance);
        program_context.counted = false;
    }
    program_context.managed = false;
    program_context.active = false;
    return status;
}

// Compatibility entrypoints retain the previous deferred-heap contract. The
// current Sol/Helios runners use user_program_wrapper instead.
user_program_result_t user_program_root_wrapper(user_program_t program, uint64_t arg) {
    assert(program_context.retired_root_heap == NULL);
    atomic_store_explicit(&root_program_active, true, memory_order_release);
    return run_program(program, arg, RETAINED_ROOT);
}

void user_program_release_root_heap(void) {
    if (program_context.retired_root_heap != NULL) {
        mi_heap_destroy(program_context.retired_root_heap);
        program_context.retired_root_heap = NULL;
    }
    atomic_store_explicit(&root_program_active, false, memory_order_release);
}

void early_exit(uint32_t error_code) {
    assert(program_context.active);
    program_context.error_code = error_code;
    if (program_context.managed) {
        // Rust cancellation returns normally before this C-local jump.
        selene_cancel(selene_instance, error_code);
    }
    longjmp(program_context.program_end, 1);
}
