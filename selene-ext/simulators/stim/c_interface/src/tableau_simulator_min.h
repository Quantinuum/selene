// This implementation is heavily derived from Stim's TableauSimulator implementation,
// which can be found at https://github.com/quantumlib/Stim/blob/a6d5c7fa8bc67f4e4002e38275b8c92fc5485019/src/stim/simulators/tableau_simulator.inl
// We choose to avoid using that interface directly as it is more general than we require,
// and makes use of e.g. containers that are not necessary for our specific requirements (e.g.
// we only postselect one qubit at a time, so we can avoid vector usage).
//
// Instead, we provide a thin wrapper around the functionality we need.
// The original implementation is copyright 2021 Google LLC under the Apache 2.0 license.

#ifndef SELENE_STIM_TABLEAU_SIMULATOR_MIN_H
#define SELENE_STIM_TABLEAU_SIMULATOR_MIN_H

#include "stim.h"

struct TableauSimulatorMin{
    stim::Tableau<64> inverse_state;
    std::mt19937_64 rng;
    TableauSimulatorMin(size_t n_qubits, uint64_t random_seed)
    :
        inverse_state{stim::Tableau<64>::identity(n_qubits)},
        rng{random_seed}
    {
    }

    void do_X(unsigned int q) {
        inverse_state.prepend_X(q);
    }

    void do_Y(unsigned int q) {
        inverse_state.prepend_Y(q);
    }

    void do_Z(unsigned int q) {
        inverse_state.prepend_Z(q);
    }

    void do_SQRT_X(unsigned int q) {
        inverse_state.prepend_SQRT_X_DAG(q);
    }

    void do_SQRT_Y(unsigned int q) {
        inverse_state.prepend_SQRT_Y_DAG(q);
    }

    void do_SQRT_Z(unsigned int q) {
        inverse_state.prepend_SQRT_Z_DAG(q);
    }
    
    void do_SQRT_X_DAG(unsigned int q) {
        inverse_state.prepend_SQRT_X(q);
    }

    void do_SQRT_Y_DAG(unsigned int q) {
        inverse_state.prepend_SQRT_Y(q);
    }

    void do_SQRT_Z_DAG(unsigned int q) {
        inverse_state.prepend_SQRT_Z(q);
    }

    void do_SQRT_XX(unsigned int q0, unsigned int q1) {
        inverse_state.prepend_SQRT_XX_DAG(q0,q1);
    }

    void do_SQRT_YY(unsigned int q0, unsigned int q1) {
        inverse_state.prepend_SQRT_YY_DAG(q0,q1);
    }

    void do_SQRT_ZZ(unsigned int q0, unsigned int q1) {
        inverse_state.prepend_SQRT_ZZ_DAG(q0,q1);
    }

    void do_SQRT_XX_DAG(unsigned int q0, unsigned int q1) {
        inverse_state.prepend_SQRT_XX(q0,q1);
    }

    void do_SQRT_YY_DAG(unsigned int q0, unsigned int q1) {
        inverse_state.prepend_SQRT_YY(q0,q1);
    }

    void do_SQRT_ZZ_DAG(unsigned int q0, unsigned int q1) {
        inverse_state.prepend_SQRT_ZZ(q0,q1);
    }

    void do_H_XZ(unsigned int q) {
        inverse_state.prepend_H_XZ(q);
    }

    void do_ZCX(unsigned int q_control, unsigned int q_target){
        inverse_state.prepend_ZCX(q_control, q_target);
    }

    void do_ZCY(unsigned int q_control, unsigned int q_target){
        inverse_state.prepend_ZCY(q_control, q_target);
    }

    void do_ZCZ(unsigned int q_control, unsigned int q_target){
        inverse_state.prepend_ZCZ(q_control, q_target);
    }

    bool do_MZ(unsigned int q) {
        bool result = collapse_qubit_z(q);
        return result;
    }
    
    bool is_deterministic_z(size_t target) const {
        bool result = !inverse_state.zs[target].xs.not_zero();
        return result;
    }
    bool do_POSTSELECT_Z(unsigned int q, bool target_result) {
        bool result = collapse_qubit_z(q, target_result ? -1 : +1);
        if (result == target_result) {
            return true;
        }
        // Can't postselect - write an error and return false.
        fprintf(
            stderr,
            "Error: Postselection impossible.\n"
            "Qubit %u was asked to postselect to state |%d>, "
            "but was in the perpendicular state |%d>.",
            q,
            target_result ? 1 : 0,
            target_result ? 0 : 1
        );
        return false;
    }

    std::string get_stabilizers() {
        std::stringstream ss;
        for(auto const& pauli_string : inverse_state.inverse().stabilizers(true)){
            ss << pauli_string << '\n';
        }
        return ss.str();
    }

    bool collapse_qubit_z(unsigned int target, int8_t sign_bias=0) {
        while(!is_deterministic_z(target)) {
            // We run at most one iteration of this loop. It is structured
            // like this to allow us to break out of the TableauTransposedRaii.
            auto const n = inverse_state.num_qubits;
            stim::TableauTransposedRaii<64> transposed(inverse_state);
            // Search for any stabilizer generator that anti-commutes with the measurement observable.
            size_t pivot = 0;
            while (pivot < n && !transposed.tableau.zs.xt[pivot][target]) {
                pivot++;
            }
            if (pivot == n) {
                // No anti-commuting stabilizer generator - already collapsed.
                break;
            }
            // Perform partial Gaussian elimination over the stabilizer generators that anti-commute with the measurement.
            // Do this by introducing no-effect-because-control-is-zero CNOTs at the beginning of time.
            for (size_t k = pivot + 1; k < n; k++) {
                if (transposed.tableau.zs.xt[k][target]) {
                    transposed.append_ZCX(pivot, k);
                }
            }

            // Swap the now-isolated anti-commuting stabilizer generator for one that commutes with the measurement.
            if (transposed.tableau.zs.zt[pivot][target]) {
                transposed.append_H_YZ(pivot);
            } else {
                transposed.append_H_XZ(pivot);
            }

            // Assign a measurement result.
            bool result_if_measured = sign_bias == 0 ? (rng() & 1) : sign_bias < 0;
            if (inverse_state.zs.signs[target] != result_if_measured) {
                transposed.append_X(pivot);
            }
            break;
        }
        return inverse_state.zs.signs[target];
    }
};

#endif // SELENE_STIM_TABLEAU_SIMULATOR_MIN_H