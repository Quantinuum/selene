#include <array>
#include <condition_variable>
#include <mutex>
#include <thread>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern "C" {
#include <base_qis/debug.h>
#include <base_qis/print.h>
#ifdef SOL_QIS
#include <sol_qis/sol_ops.h>
#define X_GATE(q) ___rp(q, 3.141592653589793, 0.0)
#else
#include <helios_qis/helios_ops.h>
#define X_GATE(q) ___rxy(q, 3.141592653589793, 0.0)
#endif
}

enum { n_workers = 4, n_rounds = 32 };

struct Workers {
    std::mutex mutex;
    std::condition_variable condition;
    unsigned arrived = 0;
    unsigned generation = 0;

    void wait() {
        std::unique_lock<std::mutex> lock(mutex);
        unsigned initial_generation = generation;
        if (++arrived == n_workers) {
            arrived = 0;
            ++generation;
            condition.notify_all();
        } else {
            condition.wait(lock, [&] { return generation != initial_generation; });
        }
    }
};

static void run_worker(Workers &workers, unsigned index) {
    uint64_t qubit = ___qalloc();
    char result_tag[64];
    snprintf(result_tag + 1, sizeof(result_tag) - 1, "USER:INTARR:worker_%u", index);
    result_tag[0] = (char)strlen(result_tag + 1);

    for (unsigned round = 0; round < n_rounds; ++round) {
        ___reset(qubit);
        if ((index + round) % 2 != 0) {
            X_GATE(qubit);
        }
        workers.wait();

        if (round == 0) {
            /* All gates have been submitted, but no worker has measured yet.
             * The state request must ask the runtime to execute that work before
             * lending the simulator to the callback. */
            char state_tag[64];
            snprintf(state_tag + 1, sizeof(state_tag) - 1, "USER:STATE:state_%u", index);
            state_tag[0] = (char)strlen(state_tag + 1);
            cl_array qubits = {.x = 1, .y = 1, .u64s = &qubit};
            print_state_result(state_tag, 0, &qubits);
            workers.wait();
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
}

extern "C" uint64_t qmain(uint64_t time_cursor) {
    setup(time_cursor);
    Workers workers;
    std::array<std::thread, n_workers> threads;
    for (unsigned i = 0; i < n_workers; ++i) {
        threads[i] = std::thread([&workers, i] { run_worker(workers, i); });
    }
    for (auto &thread : threads) {
        thread.join();
    }

    char joined[] = "\017USER:INT:joined";
    print_uint(joined, 0, n_workers);
    return teardown();
}
