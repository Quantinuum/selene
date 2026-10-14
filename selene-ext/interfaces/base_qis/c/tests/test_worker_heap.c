#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdint.h>
#include <base_qis/heap.h>
#include <base_qis/program_lifetime.h>
#include <base_qis/selene_lifetime.h>
#include <selene/selene.h>

static atomic_bool root_returned = false;
static pthread_t worker;
static uint64_t worker_value;

bool selene_has_worker_boundary(struct SeleneInstance *instance) { return instance != NULL; }
struct selene_bool_result_t selene_worker_enter(struct SeleneInstance *instance) {
    assert(instance != NULL);
    return (struct selene_bool_result_t){0, true};
}
void selene_worker_leave(struct SeleneInstance *instance) { assert(instance != NULL); }
struct selene_void_result_t selene_on_shot_end(struct SeleneInstance *instance) {
    assert(instance != NULL);
    atomic_store_explicit(&root_returned, true, memory_order_release);
    assert(pthread_join(worker, NULL) == 0);
    // The returned worker allocation outlives its boundary and native thread.
    assert(*(uint64_t *)(uintptr_t)worker_value != UINT64_MAX);
    heap_free((void *)(uintptr_t)worker_value);
    return (struct selene_void_result_t){0};
}

static void callback(void *capture, void *out) {
    // The root has returned before this capture is read.
    uint64_t value = *(uint64_t *)capture;
    uint64_t *result = heap_alloc(sizeof(*result));
    assert(result != NULL);
    *result = value + 1;
    *(uint64_t *)out = (uint64_t)(uintptr_t)result;
}

static void *run(void *capture) {
    while (!atomic_load_explicit(&root_returned, memory_order_acquire)) {}
    user_program_result_t result = selene_run_worker(callback, capture, &worker_value);
    assert(!result.exited_early && result.result_or_error_code == 0);
    assert(*(uint64_t *)(uintptr_t)worker_value == *(uint64_t *)capture + 1);
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
    selene_instance = (struct SeleneInstance *)(uintptr_t)1;
    for (uint64_t iteration = 0; iteration < 128; ++iteration) {
        atomic_store_explicit(&root_returned, false, memory_order_relaxed);
        user_program_result_t result = user_program_wrapper(root, iteration);
        assert(!result.exited_early && result.result_or_error_code == iteration);
    }
    return 0;
}
