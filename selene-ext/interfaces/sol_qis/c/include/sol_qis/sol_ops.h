#ifndef SOL_QIS_SOL_SPECIFIC_INTERFACE_H
#define SOL_QIS_SOL_SPECIFIC_INTERFACE_H

#include <stdint.h>
#include <stdbool.h>

#include <base_qis/macros.h>

typedef uint64_t measurement_mode_t;
const measurement_mode_t MEASUREMENT_MODE_BINARY = 0; // true|false
const measurement_mode_t MEASUREMENT_MODE_LEAKAGE = 1; // true|false|leaked

EXPORT uint64_t ___qalloc(void);
EXPORT void ___qfree(uint64_t q);
EXPORT void ___rxy(uint64_t q, double theta, double phi);
EXPORT void ___rzz(uint64_t q1, uint64_t q2, double theta);
EXPORT void ___rz(uint64_t q, double theta);
EXPORT void ___rp(uint64_t q, double theta, double phi);
EXPORT void ___rz(uint64_t q, double theta);
EXPORT void ___rpp(uint64_t q1, uint64_t q2, double theta, double phi);
EXPORT void ___reset(uint64_t q);
EXPORT bool ___measure(uint64_t q);
EXPORT uint64_t ___lazy_measure(uint64_t q, measurement_mode_t mode);
EXPORT void ___dec_future_refcount(uint64_t r);
EXPORT void ___inc_future_refcount(uint64_t r);
EXPORT bool ___read_future_bool(uint64_t r);
EXPORT void ___barrier(uint64_t* qubits, uint64_t qubits_len);
EXPORT void ___sleep(uint64_t* qubits, uint64_t qubits_len, uint64_t sleep_time);
EXPORT uint64_t ___read_future_uint(uint64_t r);
EXPORT void set_tc(uint64_t time_cursor);
EXPORT uint64_t get_tc(void);
EXPORT void setup(uint64_t time_cursor);
EXPORT uint64_t teardown(void);

#endif
