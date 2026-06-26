#include <clifford_t_qis.h>

void ct_program(void) {
    uint64_t qubit = ct_qalloc();
    ct_h(qubit);
    ct_t(qubit);
    ct_h(qubit);
    bool measurement = ct_measure(qubit);
    ct_record_bool("measurement", measurement);
    ct_qfree(qubit);
}
