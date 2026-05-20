/**
 * This file provides the main entrypoint for a QIS-based Selene run,
 * given an entrypoint function to call. It loads the selene configuration,
 * reads the number of shots, and runs them in a loop.
 *
 * The user function is wrapped in a panic handler, such that it will always
 * return with a result indicating whether it exited early (via panic) or not,
 * and if so, with what error code.
 */

#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <selene/selene.h>
#include <base_qis/selene_lifetime.h>
#include <base_qis/program_lifetime.h>
#include <base_qis/unwrap.h>
#include <base_qis/string_utils.h>
#include <helios_qis/interface.h>

#include "logging.h"



int selene_helios_run(int argc, char** argv, uint64_t (*entrypoint)(uint64_t)) {
    DIAGNOSTIC("selene_init() with args:\n");
    for (int i = 0; i < argc; ++i) {
        DIAGNOSTIC("   %d: %s\n", i, argv[i]);
    }
    if(argc < 3 || strcmp(argv[1], "--configuration") != 0){
        ERROR("Usage: %s --configuration <configuration_file>\n", argv[0]);
        return 1;
    }
    char const* configuration_file = argv[2];
    struct selene_void_result_t void_result = selene_load_config(&selene_instance, configuration_file);
    if (void_result.error_code != 0) {
        ERROR("Error initializing selene: error code %" PRIu32 "\n", void_result.error_code);
        return void_result.error_code;
    }
    struct selene_u64_result_t n_shots = selene_shot_count(selene_instance);
    if (n_shots.error_code != 0) {
        ERROR("Error fetching shot count from selene: error code %" PRIu32 "\n", void_result.error_code);
        return n_shots.error_code;
    }
    DIAGNOSTIC("Number of shots: %" PRIu64 "\n", n_shots.value);
    bool do_continue = true;
    for(uint64_t current_shot = 0; do_continue && (current_shot < n_shots.value); ++current_shot){
        DIAGNOSTIC("Starting shot %" PRIu64 "\n", current_shot);
        DIAGNOSTIC("----------------------------\n");
        void_result = selene_on_shot_start(selene_instance, current_shot);
        if (void_result.error_code != 0) {
            fprintf(stderr, "Error starting shot %" PRIu64 ": error code %" PRIu32 "\n", current_shot, void_result.error_code);
            return void_result.error_code;
        }
        user_program_result_t result = user_program_wrapper(entrypoint, 0);
        if (result.exited_early){
            uint64_t error_code = result.result_or_error_code;
            do_continue = (error_code < 1000);
        }
        void_result = selene_on_shot_end(selene_instance);
        if (void_result.error_code != 0) {
            ERROR("Error ending shot %" PRId64 ": error code %" PRIu32 "\n", current_shot, void_result.error_code);
            return void_result.error_code;
        }
    }
    selene_exit(selene_instance);
    return 0;
}

