/**
 * This file defines a shim for running Selene with a compiled
 * program for the Helios Quantum Instruction Set.
 *
 * The user's program is expected to have a `qmain` function.
 * This is invoked on each shot, and the calls it makes are
 * routed to the selene library.
 */

#include <stdint.h>
#include <stdio.h>

#include <selene/selene.h>
#include <base_qis/panic.h>
#include <base_qis/program_lifetime.h>
#include <base_qis/selene_lifetime.h>
#include <base_qis/unwrap.h>
#include <base_qis/string_utils.h>

#include "logging.h"


void panic(int32_t error_code, cl_string message) {
    DIAGNOSTIC("panic(%d, %.*s)\n", error_code, message[0], message+1);
    unwrap(selene_print_panic(selene_instance, parse_cl_string(message), error_code));
    DIAGNOSTIC("   Jumping\n");
    early_exit(error_code);
}
void panic_str(int32_t error_code, char const* message) {
    DIAGNOSTIC("panic_str(%d, %s)\n", error_code, message);
    unwrap(selene_print_panic(selene_instance, parse_c_string(message), error_code));
    DIAGNOSTIC("   Jumping\n");
    early_exit(error_code);
}
