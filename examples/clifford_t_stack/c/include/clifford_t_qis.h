#ifndef CLIFFORD_T_QIS_H
#define CLIFFORD_T_QIS_H

#include <stdbool.h>
#include <stdint.h>

uint64_t ct_qalloc(void);
void ct_qfree(uint64_t q);
void ct_reset(uint64_t q);

void ct_h(uint64_t q);
void ct_s(uint64_t q);
void ct_sdg(uint64_t q);
void ct_t(uint64_t q);
void ct_tdg(uint64_t q);
void ct_x(uint64_t q);
void ct_cnot(uint64_t control, uint64_t target);

bool ct_measure(uint64_t q);
void ct_record_bool(char const* tag, bool value);

void ct_program(void);

#endif
