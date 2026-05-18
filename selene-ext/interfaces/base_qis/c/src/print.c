/**
 * This file defines a shim for running Selene with a compiled
 * program for the Helios Quantum Instruction Set.
 *
 * The user's program is expected to have a `qmain` function.
 * This is invoked on each shot, and the calls it makes are
 * routed to the selene library.
 */
#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <selene/selene.h>
#include <base_qis/program_lifetime.h>
#include <base_qis/selene_lifetime.h>
#include <base_qis/print.h>
#include <base_qis/unwrap.h>
#include <base_qis/string_utils.h>
#include "logging.h"

void print_bool(cl_string tag, uint64_t _unused, char value) {
    DIAGNOSTIC("print_bool(\"%.*s\", %02X)\n", tag[0], tag+1, value);
    // Rust bools are specifically 0x00 for false and 0x01 for true,
    // but in HUGR compilation to LLVM, an i1 is passed here. This means
    // that what we receive is not a rust-compatible bool, but 8 bits where
    // only the least significant bit matters. If we accept it as a bool here,
    // the compiler is very good at eliding conversion to 0x00 and 0x01 on the
    // assumption that the value is already a well-formed bool. As such, we accept
    // a char for print_bool and then convert it to a char of the form 0x00 or 0x01.
    char safe_value = (value & 1) == 1 ? 0x01 : 0x00;
    DIAGNOSTIC("   converted to %02X\n", safe_value);
    unwrap(selene_print_bool(selene_instance, parse_cl_string(tag), safe_value));
    DIAGNOSTIC("   [done]\n");
}
void print_int(cl_string tag, uint64_t _unused, int64_t value) {
    DIAGNOSTIC("print_int(\"%.*s\", %" PRId64 ")\n", tag[0], tag+1, value);
    unwrap(selene_print_i64(selene_instance, parse_cl_string(tag), value));
    DIAGNOSTIC("   [done]\n");
}
void print_uint(cl_string tag, uint64_t _unused, uint64_t value) {
    DIAGNOSTIC("print_uint(\"%.*s\", %" PRIu64 ")\n", tag[0], tag+1, value);
    unwrap(selene_print_u64(selene_instance, parse_cl_string(tag), value));
    DIAGNOSTIC("   [done]\n");
}
void print_float(cl_string tag, uint64_t _unused, double value) {
    DIAGNOSTIC("print_float(\"%.*s\", %f)\n", tag[0], tag+1, value);
    unwrap(selene_print_f64(selene_instance, parse_cl_string(tag), value));
    DIAGNOSTIC("   [done]\n");
}
void print_bool_arr(cl_string tag, uint64_t _unused, struct cl_array* arr) {
    uint8_t* array = arr->bytes;
    uint64_t length = arr->x;
    // TODO: check whether the array needs to be copied/modified to convert data into
    // 0x00 and 0x01 based on the last bit of each byte
    DIAGNOSTIC("print_bool_array(\"%.*s\", ptr, %" PRIu64 ")\n", tag[0], tag+1, length);
    for (uint64_t i = 0; i < length; ++i) {
        DIAGNOSTIC("   %" PRIu64 ": %s (%02x)\n", i, array[i] ? "true" : "false", (unsigned char)array[i]);
    }
    unwrap(selene_print_bool_array(selene_instance, parse_cl_string(tag), (bool*)array, length));
    DIAGNOSTIC("   [done]\n");
}
void print_int_arr(cl_string tag, uint64_t _unused, struct cl_array* arr) {
    int64_t* array = arr->i64s;
    uint64_t length = arr->x;
    DIAGNOSTIC("print_int_array(%s, ptr, %" PRId64 ")\n", tag, length);
    for (uint64_t i = 0; i < length; ++i) {
        DIAGNOSTIC("   %" PRIu64 ": %" PRId64 "\n", i, array[i]);
    }
    unwrap(selene_print_i64_array(selene_instance, parse_cl_string(tag), array, length));
    DIAGNOSTIC("   [done]\n");
}
void print_uint_arr(cl_string tag, uint64_t _unused, struct cl_array* arr) {
    uint64_t* array = arr->u64s;
    uint64_t length = arr->x;
    DIAGNOSTIC("print_uint_array(%s, ptr, %" PRIu64 ")\n", tag, length);
    for (uint64_t i = 0; i < length; ++i) {
        DIAGNOSTIC("   %" PRIu64 ": %" PRIu64 "\n", i, array[i]);
    }
    unwrap(selene_print_u64_array(selene_instance, parse_cl_string(tag), array, length));
    DIAGNOSTIC("   [done]\n");
}
void print_float_arr(cl_string tag, uint64_t _unused, struct cl_array* arr) {
    double* array = arr->f64s;
    uint64_t length = arr->x;
    DIAGNOSTIC("print_float_array(%s, ptr, %" PRIu64 ")\n", tag, length);
    for (uint64_t i = 0; i < length; ++i) {
        DIAGNOSTIC("   %" PRIu64 ": %f\n", i, array[i]);
    }
    unwrap(selene_print_f64_array(selene_instance, parse_cl_string(tag), array, length));
    DIAGNOSTIC("   [done]\n");
}
