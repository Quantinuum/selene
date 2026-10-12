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

// Run the compiled root while retaining its heap through managed worker shutdown.
// After shot_end has joined all workers, release the heap on this same root thread.
// Only one compiled root may be active in the runner process at a time.
EXPORT user_program_result_t user_program_root_wrapper(user_program_t program, uint64_t input_arg);
EXPORT void user_program_release_root_heap(void);

EXPORT void early_exit(uint32_t error_code);

#endif
