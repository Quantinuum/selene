#include <base_qis/debug.h>

#include <selene/selene.h>            // selene_dump_state
#include <base_qis/selene_lifetime.h> // selene_instance
#include <base_qis/unwrap.h>          // unwrap
#include <base_qis/string_utils.h>    // parse_cl_string

#include "logging.h" // DIAGNOSTIC

void print_state_result(cl_string tag, uint64_t _unused, struct cl_array* qubits) {
    uint64_t* qubits_ptr = qubits->u64s;
    uint64_t qubits_length = qubits->x;
    DIAGNOSTIC("print_state(\"%.*s\", %" PRIu64 ")\n", tag[0], tag+1, qubits_length);
    DIAGNOSTIC("Qubits:\n");
    for (uint64_t i = 0; i < qubits_length; ++i) {
        DIAGNOSTIC("   %" PRIu64 ": %" PRIu64 "\n", i, qubits_ptr[i]);
    }
    unwrap(selene_dump_state(selene_instance, parse_cl_string(tag), qubits_ptr, qubits_length));
    DIAGNOSTIC("   [done]\n");
}

