#ifndef SELENE_QUEST_C_INTERFACE_H
#define SELENE_QUEST_C_INTERFACE_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct SeleneQuestSimulator SeleneQuestSimulator;

const char* selene_quest_last_error(void);
void selene_quest_clear_error(void);

bool selene_quest_create(uint32_t num_qubits, SeleneQuestSimulator** out);
void selene_quest_destroy(SeleneQuestSimulator* sim);

bool selene_quest_init_zero_state(SeleneQuestSimulator* sim);
bool selene_quest_apply_rotate_z(SeleneQuestSimulator* sim, uint32_t q, double theta);
bool selene_quest_apply_pauli_x(SeleneQuestSimulator* sim, uint32_t q);
bool selene_quest_apply_matrix1(
    SeleneQuestSimulator* sim,
    uint32_t q,
    const double* real,
    const double* imag
);
bool selene_quest_apply_matrix2(
    SeleneQuestSimulator* sim,
    uint32_t q0,
    uint32_t q1,
    const double* real,
    const double* imag
);
bool selene_quest_apply_diag_matrix2(
    SeleneQuestSimulator* sim,
    uint32_t q0,
    uint32_t q1,
    const double* real,
    const double* imag
);
bool selene_quest_prob_of_outcome(
    SeleneQuestSimulator* sim,
    uint32_t q,
    bool outcome,
    double* out
);
bool selene_quest_collapse_to_outcome(
    SeleneQuestSimulator* sim,
    uint32_t q,
    bool outcome,
    double* probability
);
bool selene_quest_get_amp(
    const SeleneQuestSimulator* sim,
    uint64_t index,
    double* real,
    double* imag
);

#ifdef __cplusplus
}
#endif

#endif
