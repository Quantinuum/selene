#include "selene_stim_c_interface/interface.h"
#include "tableau_simulator_min.h"

extern "C" {

TableauSimulatorMin* stim_tableausimulator_min_create(
    unsigned int n_qubits,
    uint64_t random_seed
){
    return new TableauSimulatorMin(n_qubits, random_seed);
}
void stim_tableausimulator_min_destroy(TableauSimulatorMin* sim){
    delete sim;
}

void stim_tableausimulator_min_do_X(TableauSimulatorMin* sim, unsigned int q) {
    sim->do_X(q);
}

void stim_tableausimulator_min_do_Y(TableauSimulatorMin* sim, unsigned int q) {
    sim->do_Y(q);
}

void stim_tableausimulator_min_do_Z(TableauSimulatorMin* sim, unsigned int q) {
    sim->do_Z(q);
}

void stim_tableausimulator_min_do_SQRT_X(TableauSimulatorMin* sim, unsigned int q) {
    sim->do_SQRT_X(q);
}

void stim_tableausimulator_min_do_SQRT_Y(TableauSimulatorMin* sim, unsigned int q) {
    sim->do_SQRT_Y(q);
}

void stim_tableausimulator_min_do_SQRT_Z(TableauSimulatorMin* sim, unsigned int q) {
    sim->do_SQRT_Z(q);
}

void stim_tableausimulator_min_do_SQRT_X_DAG(TableauSimulatorMin* sim, unsigned int q) {
    sim->do_SQRT_X_DAG(q);
}

void stim_tableausimulator_min_do_SQRT_Y_DAG(TableauSimulatorMin* sim, unsigned int q) {
    sim->do_SQRT_Y_DAG(q);
}

void stim_tableausimulator_min_do_SQRT_Z_DAG(TableauSimulatorMin* sim, unsigned int q) {
    sim->do_SQRT_Z_DAG(q);
}

void stim_tableausimulator_min_do_SQRT_XX(TableauSimulatorMin* sim, unsigned int q0, unsigned int q1) {
    sim->do_SQRT_XX(q0, q1);
}

void stim_tableausimulator_min_do_SQRT_YY(TableauSimulatorMin* sim, unsigned int q0, unsigned int q1) {
    sim->do_SQRT_YY(q0, q1);
}

void stim_tableausimulator_min_do_SQRT_ZZ(TableauSimulatorMin* sim, unsigned int q0, unsigned int q1) {
    sim->do_SQRT_ZZ(q0, q1);
}

void stim_tableausimulator_min_do_SQRT_XX_DAG(TableauSimulatorMin* sim, unsigned int q0, unsigned int q1) {
    sim->do_SQRT_XX_DAG(q0, q1);
}

void stim_tableausimulator_min_do_SQRT_YY_DAG(TableauSimulatorMin* sim, unsigned int q0, unsigned int q1) {
    sim->do_SQRT_YY_DAG(q0, q1);
}

void stim_tableausimulator_min_do_SQRT_ZZ_DAG(TableauSimulatorMin* sim, unsigned int q0, unsigned int q1) {
    sim->do_SQRT_ZZ_DAG(q0, q1);
}

void stim_tableausimulator_min_do_H_XZ(TableauSimulatorMin* sim, unsigned int q) {
    sim->do_H_XZ(q);
}

void stim_tableausimulator_min_do_ZCX(TableauSimulatorMin* sim, unsigned int q_control, unsigned int q_target){
    sim->do_ZCX(q_control, q_target);
}

void stim_tableausimulator_min_do_ZCY(TableauSimulatorMin* sim, unsigned int q_control, unsigned int q_target){
    sim->do_ZCY(q_control, q_target);
}

void stim_tableausimulator_min_do_ZCZ(TableauSimulatorMin* sim, unsigned int q_control, unsigned int q_target){
    sim->do_ZCZ(q_control, q_target);
}

bool stim_tableausimulator_min_do_MZ(TableauSimulatorMin* sim, unsigned int q) {
    return sim->do_MZ(q);
}

bool stim_tableausimulator_min_do_POSTSELECT_Z(TableauSimulatorMin* sim, unsigned int q, bool target_result) {
    return sim->do_POSTSELECT_Z(q, target_result);
}

void stim_tableausimulator_min_get_stabilizers(TableauSimulatorMin* sim, char** write) {
    std::string str = sim->get_stabilizers();
    char* cstr = new char[str.size() + 1];
    std::copy(str.begin(), str.end(), cstr);
    cstr[str.size()] = '\0';
    *write = cstr;
}

void stim_tableausimulator_min_free_stabilizers(char* written) {
    delete[] written;
}

} // extern "C"