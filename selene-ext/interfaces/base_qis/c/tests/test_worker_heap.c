#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdint.h>
#include <base_qis/heap.h>
#include <base_qis/program_lifetime.h>

static atomic_bool root_returned = false;
static pthread_t worker;
static uint64_t worker_value;

static uint64_t callback(uint64_t capture) {
    // The root has returned before this capture is read.
    uint64_t value = *(uint64_t *)(uintptr_t)capture;
    uint64_t *result = heap_alloc(sizeof(*result));
    assert(result != NULL);
    *result = value + 1;
    return (uint64_t)(uintptr_t)result;
}

static void *run(void *capture) {
    while (!atomic_load_explicit(&root_returned, memory_order_acquire)) {}
    user_program_result_t result = user_program_wrapper(callback, (uint64_t)(uintptr_t)capture);
    assert(!result.exited_early);
    worker_value = result.result_or_error_code;
    return NULL;
}

static uint64_t root(uint64_t arg) {
    uint64_t *capture = heap_alloc(sizeof(*capture));
    assert(capture != NULL);
    *capture = arg;
    assert(pthread_create(&worker, NULL, run, capture) == 0);
    return arg;
}

int main(void) {
    for (uint64_t iteration = 0; iteration < 128; ++iteration) {
        atomic_store_explicit(&root_returned, false, memory_order_relaxed);
        user_program_result_t result = user_program_root_wrapper(root, iteration);
        assert(!result.exited_early);
        atomic_store_explicit(&root_returned, true, memory_order_release);
        assert(pthread_join(worker, NULL) == 0);
        // Returned worker storage remains live after its wrapper and thread exit.
        assert(*(uint64_t *)(uintptr_t)worker_value == iteration + 1);
        heap_free((void *)(uintptr_t)worker_value);
        user_program_release_root_heap();
    }
    return 0;
}
