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

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t ready = PTHREAD_COND_INITIALIZER;
static bool root_returned;
static bool child_released;
static pthread_t workers[2];
static atomic_uint cancelled;
static atomic_uint entered;
static atomic_uint retired;
static atomic_uint callbacks;
static atomic_uint mode;
static uint64_t results[2];

bool selene_has_worker_boundary(struct SeleneInstance *instance) {
    return instance != NULL;
}
struct selene_bool_result_t selene_worker_enter(struct SeleneInstance *instance) {
    assert(instance != NULL);
    atomic_fetch_add(&entered, 1);
    return (struct selene_bool_result_t){atomic_load(&cancelled), true};
}
void selene_worker_leave(struct SeleneInstance *instance) {
    assert(instance != NULL);
    atomic_fetch_add(&retired, 1);
}
void selene_cancel(struct SeleneInstance *instance, uint32_t code) {
    assert(instance != NULL);
    unsigned expected = 0;
    atomic_compare_exchange_strong(&cancelled, &expected, code ? code : 100001);
}
static void leaf(void *data, void *out) {
    atomic_fetch_add(&callbacks, 1);
    *(uint64_t *)out = *(uint64_t *)data + 2;
}
static void *descendant(void *data) {
    pthread_mutex_lock(&lock);
    while (!child_released) pthread_cond_wait(&ready, &lock);
    pthread_mutex_unlock(&lock);
    user_program_result_t status = selene_run_worker(leaf, data, &results[1]);
    assert(!status.exited_early && status.result_or_error_code == 0);
    return NULL;
}
static void callback(void *data, void *out) {
    atomic_fetch_add(&callbacks, 1);
    if (atomic_load(&mode) == 2) early_exit(71);
    if (atomic_load(&mode) == 3) {
        assert(pthread_create(&workers[1], NULL, descendant, data) == 0);
    }
    *(uint64_t *)out = *(uint64_t *)data + 1;
}
static void *worker(void *data) {
    // Delay actual Selene entry until root return: entered count is still zero.
    pthread_mutex_lock(&lock);
    while (!root_returned) pthread_cond_wait(&ready, &lock);
    pthread_mutex_unlock(&lock);
    user_program_result_t status = selene_run_worker(callback, data, &results[0]);
    unsigned selected = atomic_load(&mode);
    assert(status.exited_early == (selected == 1 || selected == 2));
    assert(status.result_or_error_code == (selected == 1 ? 53 : selected == 2 ? 71 : 0));
    return NULL;
}
struct selene_void_result_t selene_on_shot_end(struct SeleneInstance *instance) {
    assert(instance != NULL);
    assert(atomic_load(&entered) == 0);
    if (atomic_load(&mode) == 1) selene_cancel(instance, 53);
    pthread_mutex_lock(&lock);
    root_returned = true;
    pthread_cond_broadcast(&ready);
    pthread_mutex_unlock(&lock);
    // The external backend joins. The root heap must still hold the capture.
    assert(pthread_join(workers[0], NULL) == 0);
    assert(atomic_load(&entered) == 1 && atomic_load(&retired) == 1);
    if (atomic_load(&mode) == 3) {
        // The parent has retired but its created child has not entered yet.
        // Backend ownership still protects the root until the child is joined.
        pthread_mutex_lock(&lock);
        child_released = true;
        pthread_cond_broadcast(&ready);
        pthread_mutex_unlock(&lock);
        assert(pthread_join(workers[1], NULL) == 0);
        assert(atomic_load(&entered) == 2 && atomic_load(&retired) == 2);
    }
    return (struct selene_void_result_t){0};
}
static uint64_t root(uint64_t arg) {
    uint64_t *capture = heap_alloc(sizeof(*capture));
    assert(capture != NULL);
    *capture = arg;
    assert(pthread_create(&workers[0], NULL, worker, capture) == 0);
    return arg;
}
int main(void) {
    // Mock only returning Selene bookkeeping; exercise the actual C boundary,
    // TLS/setjmp, mimalloc root capture and external native join ordering.
    selene_instance = (struct SeleneInstance *)(uintptr_t)1;
    for (unsigned i = 0; i != 96; ++i) {
        unsigned selected = i % 4;
        atomic_store(&mode, selected);
        atomic_store(&cancelled, 0);
        atomic_store(&entered, 0);
        atomic_store(&retired, 0);
        atomic_store(&callbacks, 0);
        root_returned = false;
        child_released = false;
        user_program_result_t status = user_program_wrapper(root, i);
        assert(!status.exited_early && status.result_or_error_code == i);
        assert(atomic_load(&callbacks) == (selected == 1 ? 0 : selected == 3 ? 2 : 1));
        if (selected == 0 || selected == 3) assert(results[0] == i + 1);
        if (selected == 3) assert(results[1] == i + 2);
    }
    return 0;
}
