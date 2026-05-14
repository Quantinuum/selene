#ifndef SELENE_HELIOS_QIS_PROGRAM_LIFETIME_H
#define SELENE_HELIOS_QIS_PROGRAM_LIFETIME_H

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

EXPORT void early_exit(uint32_t error_code);

#endif //SELENE_HELIOS_QIS_PROGRAM_LIFETIME_H
