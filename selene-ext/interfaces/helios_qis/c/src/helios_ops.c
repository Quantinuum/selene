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

#include <selene/selene.h>
#include <base_qis/selene_lifetime.h>
#include <base_qis/program_lifetime.h>
#include <base_qis/unwrap.h>
#include <helios_qis/helios_ops.h>

#include "logging.h"


uint64_t ___qalloc() {
    DIAGNOSTIC("___qalloc()\n");
    uint64_t addr = unwrap(selene_qalloc(selene_instance));
    DIAGNOSTIC("   address: %" PRIu64 "\n", addr);
    return addr;
}
void ___qfree(uint64_t q) {
    DIAGNOSTIC("___qfree(%" PRIu64 ")\n", q);
    unwrap(selene_qfree(selene_instance, q));
    DIAGNOSTIC("   [done]\n");
}
void ___rxy(uint64_t q, double theta, double phi) {
    DIAGNOSTIC("___rxy(%" PRIu64 ", %f, %f)\n", q, theta, phi);
    unwrap(selene_rxy(selene_instance, q, theta, phi));
    DIAGNOSTIC("   [done]\n");
}
void ___rzz(uint64_t q1, uint64_t q2, double theta) {
    DIAGNOSTIC("___rzz(%" PRIu64 ", %" PRIu64 ", %f)\n", q1, q2, theta);
    unwrap(selene_rzz(selene_instance, q1, q2, theta));
    DIAGNOSTIC("   [done]\n");
}
void ___rz(uint64_t q, double theta) {
    DIAGNOSTIC("___rz(%" PRIu64 ", %f)\n", q, theta);
    unwrap(selene_rz(selene_instance, q, theta));
    DIAGNOSTIC("   [done]\n");
}
void ___reset(uint64_t q) {
    DIAGNOSTIC("___reset(%" PRIu64 ")\n", q);
    unwrap(selene_qubit_reset(selene_instance, q));
    DIAGNOSTIC("   [done]\n");
}
bool ___measure(uint64_t q) {
    DIAGNOSTIC("___measure(%" PRIu64 ")\n", q);
    bool result = unwrap(selene_qubit_measure(selene_instance, q));
    DIAGNOSTIC("   returned %s\n", result ? "true" : "false");
    return result;
}
uint64_t ___lazy_measure(uint64_t q) {
    DIAGNOSTIC("___lazy_measure(%" PRIu64 ")\n", q);
    uint64_t reference = unwrap(selene_qubit_lazy_measure(selene_instance, q));
    DIAGNOSTIC("   reference: %" PRIu64 "\n", reference);
    return reference;
}
uint64_t ___lazy_measure_leaked(uint64_t q) {
    DIAGNOSTIC("___lazy_measure_leaked(%" PRIu64 ")\n", q);
    uint64_t reference = unwrap(selene_qubit_lazy_measure_leaked(selene_instance, q));
    DIAGNOSTIC("   reference: %" PRIu64 "\n", reference);
    return reference;
}
void ___dec_future_refcount(uint64_t r) {
    DIAGNOSTIC("___dec_future_refcount(%" PRIu64 ")\n", r);
    unwrap(selene_refcount_decrement(selene_instance, r));
    DIAGNOSTIC("   [done]\n");
}
void ___inc_future_refcount(uint64_t r) {
    DIAGNOSTIC("___inc_future_refcount(%" PRIu64 ")\n", r);
    unwrap(selene_refcount_increment(selene_instance, r));
    DIAGNOSTIC("   [done]\n");
}
bool ___read_future_bool(uint64_t r) {
    DIAGNOSTIC("___read_future_bool(%" PRIu64 ")\n", r);
    bool result = unwrap(selene_future_read_bool(selene_instance, r));
    DIAGNOSTIC("   returned %s\n", result ? "true" : "false");
    return result;
}
uint64_t ___read_future_uint(uint64_t r) {
    DIAGNOSTIC("___read_future_uint(%" PRIu64 ")\n", r);
    uint64_t result = unwrap(selene_future_read_u64(selene_instance, r));
    DIAGNOSTIC("   returned %" PRIu64 "\n", result);
    return result;
}

void set_tc(uint64_t time_cursor) {
    DIAGNOSTIC("set_tc(%" PRIu64 ")\n", time_cursor);
    unwrap(selene_set_tc(selene_instance, time_cursor));
    DIAGNOSTIC("   [done]\n");
}
uint64_t get_tc() {
    DIAGNOSTIC("get_tc()\n");
    uint64_t result = unwrap(selene_get_tc(selene_instance));
    DIAGNOSTIC("   result: %" PRIu64 "\n", result);
    return result;
}
void setup(uint64_t time_cursor) {
    DIAGNOSTIC("setup(%" PRIu64 ")\n", time_cursor);
    set_tc(time_cursor);
}
uint64_t teardown() {
    DIAGNOSTIC("teardown()\n");
    return get_tc();
}
void ___barrier(uint64_t* qubits, uint64_t qubits_len) {
    DIAGNOSTIC("___barrier(%p, %" PRIu64 ")\n", qubits, qubits_len);
    for (uint64_t i = 0; i < qubits_len; ++i) {
        DIAGNOSTIC("   %" PRIu64 ": %" PRIu64 "\n", i, qubits[i]);
    }
    unwrap(selene_local_barrier(selene_instance, qubits, qubits_len, 0));
    DIAGNOSTIC("   [done]\n");
}
void ___sleep(uint64_t* qubits, uint64_t qubits_len, uint64_t sleep_time) {
    DIAGNOSTIC("___sleep(%p, %" PRIu64 ", %" PRIu64 ")\n", qubits, qubits_len, sleep_time);
    for (uint64_t i = 0; i < qubits_len; ++i) {
        DIAGNOSTIC("   %" PRIu64 ": %" PRIu64 "\n", i, qubits[i]);
    }
    unwrap(selene_local_barrier(selene_instance, qubits, qubits_len, sleep_time));
    DIAGNOSTIC("   [done]\n");
}
