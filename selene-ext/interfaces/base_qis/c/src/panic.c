#include <base_qis/panic.h>

#include <selene/selene.h>
#include <base_qis/program_lifetime.h> // early_exit
#include <base_qis/selene_lifetime.h>  // selene_instance
#include <base_qis/unwrap.h>           // unwrap
#include <base_qis/string_utils.h>     // parse_cl_string, parse_c_string

#include "logging.h" // DIAGNOSTIC


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

uint32_t panic_str_fallible(uint32_t error_code, char const* message) {
    struct selene_void_result_t result =
        selene_print_panic(selene_instance, parse_c_string(message), error_code);
    return result.error_code == 0 ? error_code : result.error_code;
}
