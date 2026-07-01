#include "selene_quest_c_interface/interface.h"

#include "quest.h"

#include <complex>
#include <cstdint>
#include <exception>
#include <mutex>
#include <new>
#include <stdexcept>
#include <string>

namespace {

thread_local std::string last_error;

std::mutex env_mutex;
bool env_started = false;

class QuestError : public std::runtime_error {
  public:
    QuestError(const char* func, const char* msg)
        : std::runtime_error(format(func, msg)) {}

  private:
    static std::string format(const char* func, const char* msg) {
        std::string out = func == nullptr ? "unknown QuEST function" : func;
        out += ": ";
        out += msg == nullptr ? "unknown QuEST error" : msg;
        return out;
    }
};

void error_handler(const char* func, const char* msg) {
    throw QuestError(func, msg);
}

void set_error(const char* msg) {
    last_error = msg == nullptr ? "unknown QuEST error" : msg;
}

void set_error(const std::exception& err) {
    last_error = err.what();
}

void set_error_bad_alloc() {
    last_error = "QuEST allocation failed";
}

template <typename F>
bool capture_errors(F&& f) {
    try {
        last_error.clear();
        f();
        return true;
    } catch (const std::bad_alloc&) {
        set_error_bad_alloc();
        return false;
    } catch (const std::exception& err) {
        set_error(err);
        return false;
    } catch (...) {
        set_error("unknown QuEST error");
        return false;
    }
}

qcomp make_qcomp(double real, double imag) {
    return qcomp(static_cast<qreal>(real), static_cast<qreal>(imag));
}

CompMatr1 make_matrix1(const double* real, const double* imag) {
    qcomp elems[2][2] = {
        {make_qcomp(real[0], imag[0]), make_qcomp(real[1], imag[1])},
        {make_qcomp(real[2], imag[2]), make_qcomp(real[3], imag[3])},
    };
    return getCompMatr1(elems);
}

CompMatr2 make_matrix2(const double* real, const double* imag) {
    qcomp elems[4][4] = {
        {
            make_qcomp(real[0], imag[0]),
            make_qcomp(real[1], imag[1]),
            make_qcomp(real[2], imag[2]),
            make_qcomp(real[3], imag[3]),
        },
        {
            make_qcomp(real[4], imag[4]),
            make_qcomp(real[5], imag[5]),
            make_qcomp(real[6], imag[6]),
            make_qcomp(real[7], imag[7]),
        },
        {
            make_qcomp(real[8], imag[8]),
            make_qcomp(real[9], imag[9]),
            make_qcomp(real[10], imag[10]),
            make_qcomp(real[11], imag[11]),
        },
        {
            make_qcomp(real[12], imag[12]),
            make_qcomp(real[13], imag[13]),
            make_qcomp(real[14], imag[14]),
            make_qcomp(real[15], imag[15]),
        },
    };
    return getCompMatr2(elems);
}

DiagMatr2 make_diag_matrix2(const double* real, const double* imag) {
    qcomp elems[4] = {
        make_qcomp(real[0], imag[0]),
        make_qcomp(real[1], imag[1]),
        make_qcomp(real[2], imag[2]),
        make_qcomp(real[3], imag[3]),
    };
    return getDiagMatr2(elems);
}

bool init_environment() {
    std::lock_guard<std::mutex> guard(env_mutex);
    return capture_errors([] {
        if (!env_started) {
            initQuESTEnv();
            env_started = true;
        }
        setInputErrorHandler(error_handler);
    });
}

bool require_sim(const SeleneQuestSimulator* sim, const char* func) {
    if (sim != nullptr) {
        return true;
    }
    std::string message = func;
    message += " received a null simulator pointer";
    set_error(message.c_str());
    return false;
}

} // namespace

struct SeleneQuestSimulator {
    Qureg qureg;
};

extern "C" {

const char* selene_quest_last_error(void) {
    return last_error.c_str();
}

void selene_quest_clear_error(void) {
    last_error.clear();
}

bool selene_quest_create(uint32_t num_qubits, SeleneQuestSimulator** out) {
    if (out == nullptr) {
        set_error("selene_quest_create received a null output pointer");
        return false;
    }
    *out = nullptr;

    if (!init_environment()) {
        return false;
    }

    bool ok = capture_errors([&] {
        auto* sim = new SeleneQuestSimulator{createQureg(static_cast<int>(num_qubits))};
        *out = sim;
    });

    if (!ok) {
        delete *out;
        *out = nullptr;
    }
    return ok;
}

void selene_quest_destroy(SeleneQuestSimulator* sim) {
    if (sim == nullptr) {
        return;
    }
    capture_errors([&] {
        destroyQureg(sim->qureg);
        delete sim;
    });
}

bool selene_quest_init_zero_state(SeleneQuestSimulator* sim) {
    if (!require_sim(sim, __func__)) {
        return false;
    }
    return capture_errors([&] { initZeroState(sim->qureg); });
}

bool selene_quest_apply_rotate_z(SeleneQuestSimulator* sim, uint32_t q, double theta) {
    if (!require_sim(sim, __func__)) {
        return false;
    }
    return capture_errors([&] { applyRotateZ(sim->qureg, static_cast<int>(q), theta); });
}

bool selene_quest_apply_pauli_x(SeleneQuestSimulator* sim, uint32_t q) {
    if (!require_sim(sim, __func__)) {
        return false;
    }
    return capture_errors([&] { applyPauliX(sim->qureg, static_cast<int>(q)); });
}

bool selene_quest_apply_matrix1(
    SeleneQuestSimulator* sim,
    uint32_t q,
    const double* real,
    const double* imag
) {
    if (!require_sim(sim, __func__)) {
        return false;
    }
    if (real == nullptr || imag == nullptr) {
        set_error("selene_quest_apply_matrix1 received a null matrix pointer");
        return false;
    }
    return capture_errors([&] {
        applyCompMatr1(sim->qureg, static_cast<int>(q), make_matrix1(real, imag));
    });
}

bool selene_quest_apply_matrix2(
    SeleneQuestSimulator* sim,
    uint32_t q0,
    uint32_t q1,
    const double* real,
    const double* imag
) {
    if (!require_sim(sim, __func__)) {
        return false;
    }
    if (real == nullptr || imag == nullptr) {
        set_error("selene_quest_apply_matrix2 received a null matrix pointer");
        return false;
    }
    return capture_errors([&] {
        applyCompMatr2(
            sim->qureg,
            static_cast<int>(q0),
            static_cast<int>(q1),
            make_matrix2(real, imag)
        );
    });
}

bool selene_quest_apply_diag_matrix2(
    SeleneQuestSimulator* sim,
    uint32_t q0,
    uint32_t q1,
    const double* real,
    const double* imag
) {
    if (!require_sim(sim, __func__)) {
        return false;
    }
    if (real == nullptr || imag == nullptr) {
        set_error("selene_quest_apply_diag_matrix2 received a null matrix pointer");
        return false;
    }
    return capture_errors([&] {
        applyDiagMatr2(
            sim->qureg,
            static_cast<int>(q0),
            static_cast<int>(q1),
            make_diag_matrix2(real, imag)
        );
    });
}

bool selene_quest_prob_of_outcome(
    SeleneQuestSimulator* sim,
    uint32_t q,
    bool outcome,
    double* out
) {
    if (!require_sim(sim, __func__)) {
        return false;
    }
    if (out == nullptr) {
        set_error("selene_quest_prob_of_outcome received a null output pointer");
        return false;
    }
    return capture_errors([&] {
        *out = calcProbOfQubitOutcome(sim->qureg, static_cast<int>(q), outcome ? 1 : 0);
    });
}

bool selene_quest_collapse_to_outcome(
    SeleneQuestSimulator* sim,
    uint32_t q,
    bool outcome,
    double* probability
) {
    if (!require_sim(sim, __func__)) {
        return false;
    }
    return capture_errors([&] {
        qreal prob = applyForcedQubitMeasurement(sim->qureg, static_cast<int>(q), outcome ? 1 : 0);
        if (probability != nullptr) {
            *probability = prob;
        }
    });
}

bool selene_quest_get_amp(
    const SeleneQuestSimulator* sim,
    uint64_t index,
    double* real,
    double* imag
) {
    if (!require_sim(sim, __func__)) {
        return false;
    }
    if (real == nullptr || imag == nullptr) {
        set_error("selene_quest_get_amp received a null output pointer");
        return false;
    }
    return capture_errors([&] {
        qcomp amp = getQuregAmp(sim->qureg, static_cast<qindex>(index));
        *real = std::real(amp);
        *imag = std::imag(amp);
    });
}

} // extern "C"
