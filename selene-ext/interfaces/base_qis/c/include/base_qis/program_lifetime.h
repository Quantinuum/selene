#ifndef BASE_QIS_PROGRAM_LIFETIME_H
#define BASE_QIS_PROGRAM_LIFETIME_H

#include <stdint.h>
#include <stdbool.h>
#include <base_qis/macros.h>

typedef uint64_t (*user_program_t)(uint64_t);

typedef struct user_program_result_t {
    bool exited_early;
    uint64_t result_or_error_code;
} user_program_result_t;

EXPORT user_program_result_t user_program_wrapper(
    user_program_t user_program,
    uint64_t input_arg
);

// Execute a managed callback on the calling worker thread.
// The concurrent-v2 backend keeps the shot and root captures live until its
// drain and native joins finish. Selene installs this worker's TLS exit frame
// before checking cancellation. Cancellation skips the callback.
// On normal return, the status is {false, 0}. On early exit, it is
// {true, error_code}, including early_exit(0). The result value is written
// through result by the callback; it is not carried in this status structure.
// The callback and data must remain valid through this call. The result pointer
// must address writable, suitably aligned storage, also for zero-sized results.
// This entry requires USER_PROGRAM_THREADING and the concurrent-v2 managed
// cancellation/drain contract. The caller must not nest it on an active frame.
typedef void (*selene_worker_program_t)(void *data, void *result);

EXPORT user_program_result_t selene_run_worker(
    selene_worker_program_t callback,
    void *data,
    void *result
);

EXPORT void early_exit(uint32_t error_code);

#endif
