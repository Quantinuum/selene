#include <assert.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <base_qis/debug.h>
#include <base_qis/print.h>
#ifdef SOL_QIS
#include <sol_qis/sol_ops.h>
#define X_GATE(q) ___rp(q, 3.141592653589793, 0.0)
#else
#include <helios_qis/helios_ops.h>
#define X_GATE(q) ___rxy(q, 3.141592653589793, 0.0)
#endif

enum { n_workers = 4, n_rounds = 32 };

typedef struct Workers {
    pthread_mutex_t mutex;
    pthread_cond_t condition;
    unsigned arrived;
    unsigned generation;
} Workers;

typedef struct Worker {
    Workers *workers;
    unsigned index;
} Worker;

static void check_thread_result(int status) {
    assert(status == 0);
}

static void wait_for_workers(Workers *workers) {
    check_thread_result(pthread_mutex_lock(&workers->mutex));
    unsigned generation = workers->generation;
    if (++workers->arrived == n_workers) {
        workers->arrived = 0;
        ++workers->generation;
        check_thread_result(pthread_cond_broadcast(&workers->condition));
    } else {
        while (workers->generation == generation) {
            check_thread_result(pthread_cond_wait(&workers->condition, &workers->mutex));
        }
    }
    check_thread_result(pthread_mutex_unlock(&workers->mutex));
}

static void *run_worker(void *context) {
    Worker *worker = context;
    uint64_t qubit = ___qalloc();
    char result_tag[64];
    snprintf(result_tag + 1, sizeof(result_tag) - 1, "USER:INTARR:worker_%u", worker->index);
    result_tag[0] = (char)strlen(result_tag + 1);

    for (unsigned round = 0; round < n_rounds; ++round) {
        ___reset(qubit);
        if ((worker->index + round) % 2 != 0) {
            X_GATE(qubit);
        }
        wait_for_workers(worker->workers);

        if (round == 0) {
            /* All gates have been submitted, but no worker has measured yet.
             * The state request must ask the runtime to execute that work before
             * lending the simulator to the callback. */
            char state_tag[64];
            snprintf(state_tag + 1, sizeof(state_tag) - 1, "USER:STATE:state_%u", worker->index);
            state_tag[0] = (char)strlen(state_tag + 1);
            cl_array qubits = {.x = 1, .y = 1, .u64s = &qubit};
            print_state_result(state_tag, 0, &qubits);
            wait_for_workers(worker->workers);
        }

        uint64_t future = ___lazy_measure(qubit);
        ___inc_future_refcount(future);
        ___dec_future_refcount(future);
        bool measured = ___read_future_bool(future);
        ___dec_future_refcount(future);

        /* Each worker uses its own measurement to return its qubit to zero.
         * Mixing up futures between workers can therefore spoil either the
         * first measurement or this second one. */
        if (measured) {
            X_GATE(qubit);
        }
        uint64_t values[] = {round, measured, ___measure(qubit)};
        cl_array result = {.x = 3, .y = 1, .u64s = values};
        print_uint_arr(result_tag, 0, &result);

        /* The QIS call has returned, so this buffer belongs to us again even
         * if the runtime hasn't written its queued output yet. */
        for (unsigned i = 0; i < 3; ++i) {
            values[i] = UINT64_MAX;
        }
    }
    ___qfree(qubit);
    return NULL;
}

uint64_t qmain(uint64_t time_cursor) {
    setup(time_cursor);
    Workers workers = {.arrived = 0, .generation = 0};
    check_thread_result(pthread_mutex_init(&workers.mutex, NULL));
    check_thread_result(pthread_cond_init(&workers.condition, NULL));
    pthread_t threads[n_workers];
    Worker contexts[n_workers];
    for (unsigned i = 0; i < n_workers; ++i) {
        contexts[i] = (Worker){.workers = &workers, .index = i};
        check_thread_result(pthread_create(&threads[i], NULL, run_worker, &contexts[i]));
    }
    for (unsigned i = 0; i < n_workers; ++i) {
        check_thread_result(pthread_join(threads[i], NULL));
    }
    check_thread_result(pthread_cond_destroy(&workers.condition));
    check_thread_result(pthread_mutex_destroy(&workers.mutex));

    char joined[] = "\017USER:INT:joined";
    print_uint(joined, 0, n_workers);
    return teardown();
}
