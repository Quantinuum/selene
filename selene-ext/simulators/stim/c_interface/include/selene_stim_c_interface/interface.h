#ifndef SELENE_STIM_C_WRAPPER_H
#define SELENE_STIM_C_WRAPPER_H
#include <cstdint>

#ifdef __cplusplus
extern "C" {
#endif

struct TableauSimulatorMin;
TableauSimulatorMin* stim_tableausimulator_min_create(unsigned int n_qubits, uint64_t random_seed);
void stim_tableausimulator_min_destroy(TableauSimulatorMin* sim);
void stim_tableausimulator_min_do_X(TableauSimulatorMin* sim, unsigned int q);
void stim_tableausimulator_min_do_Y(TableauSimulatorMin* sim, unsigned int q);
void stim_tableausimulator_min_do_Z(TableauSimulatorMin* sim, unsigned int q);
void stim_tableausimulator_min_do_SQRT_X(TableauSimulatorMin* sim, unsigned int q);
void stim_tableausimulator_min_do_SQRT_Y(TableauSimulatorMin* sim, unsigned int q);
void stim_tableausimulator_min_do_SQRT_Z(TableauSimulatorMin* sim, unsigned int q);
void stim_tableausimulator_min_do_SQRT_X_DAG(TableauSimulatorMin* sim, unsigned int q);
void stim_tableausimulator_min_do_SQRT_Y_DAG(TableauSimulatorMin* sim, unsigned int q);
void stim_tableausimulator_min_do_SQRT_Z_DAG(TableauSimulatorMin* sim, unsigned int q);
void stim_tableausimulator_min_do_SQRT_XX(TableauSimulatorMin* sim, unsigned int q0, unsigned int q1);
void stim_tableausimulator_min_do_SQRT_YY(TableauSimulatorMin* sim, unsigned int q0, unsigned int q1);
void stim_tableausimulator_min_do_SQRT_ZZ(TableauSimulatorMin* sim, unsigned int q0, unsigned int q1);
void stim_tableausimulator_min_do_SQRT_XX_DAG(TableauSimulatorMin* sim, unsigned int q0, unsigned int q1);
void stim_tableausimulator_min_do_SQRT_YY_DAG(TableauSimulatorMin* sim, unsigned int q0, unsigned int q1);
void stim_tableausimulator_min_do_SQRT_ZZ_DAG(TableauSimulatorMin* sim, unsigned int q0, unsigned int q1);
void stim_tableausimulator_min_do_H_XZ(TableauSimulatorMin* sim, unsigned int q);
void stim_tableausimulator_min_do_ZCX(TableauSimulatorMin* sim, unsigned int q_control, unsigned int q_target);
void stim_tableausimulator_min_do_ZCY(TableauSimulatorMin* sim, unsigned int q_control, unsigned int q_target);
void stim_tableausimulator_min_do_ZCZ(TableauSimulatorMin* sim, unsigned int q_control, unsigned int q_target);
bool stim_tableausimulator_min_do_MZ(TableauSimulatorMin* sim, unsigned int q);
bool stim_tableausimulator_min_do_POSTSELECT_Z(TableauSimulatorMin* sim,unsigned int q, bool target_result);
void stim_tableausimulator_min_get_stabilizers(TableauSimulatorMin* sim, char** write);
void stim_tableausimulator_min_free_stabilizers(char* written);

#ifdef __cplusplus
}
#endif

#endif // SELENE_STIM_C_WRAPPER_H