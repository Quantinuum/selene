#ifndef HELIOS_QIS_HELIOS_SPECIFIC_INTERFACE_H
#define HELIOS_QIS_HELIOS_SPECIFIC_INTERFACE_H

#include <stdint.h>
#include <stdbool.h>

#include <base_qis/macros.h>


EXPORT uint64_t ___qalloc();
EXPORT void ___qfree(uint64_t q);
EXPORT void ___rxy(uint64_t q, double theta, double phi);
EXPORT void ___rzz(uint64_t q1, uint64_t q2, double theta);
EXPORT void ___rz(uint64_t q, double theta);
EXPORT void ___reset(uint64_t q);
EXPORT bool ___measure(uint64_t q);
EXPORT uint64_t ___lazy_measure(uint64_t q);
EXPORT uint64_t ___lazy_measure_leaked(uint64_t q);
EXPORT void ___dec_future_refcount(uint64_t r);
EXPORT void ___inc_future_refcount(uint64_t r);
EXPORT bool ___read_future_bool(uint64_t r);
EXPORT void ___barrier(uint64_t* qubits, uint64_t qubits_len);
EXPORT void ___sleep(uint64_t* qubits, uint64_t qubits_len, uint64_t sleep_time);
EXPORT uint64_t ___read_future_uint(uint64_t r);
EXPORT void set_tc(uint64_t time_cursor);
EXPORT uint64_t get_tc();
EXPORT void setup(uint64_t time_cursor);
EXPORT uint64_t teardown();

#endif // HELIOS_QIS_HELIOS_SPECIFIC_INTERFACE_H
