#include <clifford_t_qis.h>

void ct_program(void) {
    uint64_t q0 = ct_qalloc();
    uint64_t q1 = ct_qalloc();

    ct_h(q0);
    ct_t(q0);
    ct_cnot(q0, q1);

    bool m0 = ct_measure(q0);
    bool m1 = ct_measure(q1);

    ct_record_bool("q0", m0);
    ct_record_bool("q1", m1);

    ct_qfree(q0);
    ct_qfree(q1);
}
