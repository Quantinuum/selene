#include <sol_qis/sol_ops.h>

#include <selene/selene.h> // selene_ functions
#include <base_qis/selene_lifetime.h> // selene_instance
#include <base_qis/unwrap.h> // unwrap

#include <stdlib.h>

#include "logging.h" // DIAGNOSTIC

static GwSemanticId rz_id;
static GwSemanticId phased_x_id;
static GwSemanticId phased_xx_id;
static bool gate_ids_initialized = false;

static void check_gw(GwStatus status) {
    if (status != GW_STATUS_OK) {
        ERROR("gatewire error: %s\n", gw_status_message(status));
        abort();
    }
}

static void init_gate_ids(void) {
    if (gate_ids_initialized) {
        return;
    }
    rz_id = gw_builtin_rz_semantic_id();
    phased_x_id = gw_builtin_phased_x_semantic_id();
    phased_xx_id = gw_builtin_phased_xx_semantic_id();
    gate_ids_initialized = true;
}

static GwGateValue qubit_value(uint64_t q) {
    GwGateValue value = {
        .abi_size = sizeof(GwGateValue),
        .kind = GW_OPERAND_KIND_QUBIT,
        .data.qubit = (uint32_t)q,
        .bytes_ptr = NULL,
        .bytes_len = 0,
    };
    return value;
}

static GwGateValue angle_value(double angle) {
    GwGateValue value = {
        .abi_size = sizeof(GwGateValue),
        .kind = GW_OPERAND_KIND_F64,
        .data.f64_value = angle,
        .bytes_ptr = NULL,
        .bytes_len = 0,
    };
    return value;
}

static void emit_gate(GwSemanticId semantic_id, GwGateValue const* values, size_t values_len) {
    GwGateInstanceView gate = {
        .abi_size = sizeof(GwGateInstanceView),
        .semantic_id = semantic_id,
        .values_ptr = values,
        .values_len = values_len,
    };
    size_t len = 0;
    check_gw(gw_gate_serialized_len(&gate, &len));
    uint8_t* buffer = malloc(len);
    if (buffer == NULL) {
        ERROR("failed to allocate gate buffer\n");
        abort();
    }
    size_t written = 0;
    check_gw(gw_gate_serialize(&gate, buffer, len, &written));
    unwrap(selene_gate(selene_instance, buffer, written));
    free(buffer);
}

uint64_t ___qalloc() {
    DIAGNOSTIC("___qalloc()\n");
    uint64_t addr = unwrap(selene_qalloc(selene_instance));
    DIAGNOSTIC("   address: %" PRIu64 "\n", addr);
    return addr;
}
void ___qfree(uint64_t q) {
    DIAGNOSTIC("___qfree(%" PRIu64 ")\n", q);
    unwrap(selene_qfree(selene_instance, q));
    DIAGNOSTIC("   [done]\n");
}
void ___rp(uint64_t q, double theta, double phi) {
    DIAGNOSTIC("___rp(%" PRIu64 ", %f, %f)\n", q, theta, phi);
    init_gate_ids();
    GwGateValue values[] = {qubit_value(q), angle_value(theta), angle_value(phi)};
    emit_gate(phased_x_id, values, 3);
    DIAGNOSTIC("   [done]\n");
}
void ___rz(uint64_t q, double theta) {
    DIAGNOSTIC("___rz(%" PRIu64 ", %f)\n", q, theta);
    init_gate_ids();
    GwGateValue values[] = {qubit_value(q), angle_value(theta)};
    emit_gate(rz_id, values, 2);
    DIAGNOSTIC("   [done]\n");
}
void ___rpp(uint64_t q1, uint64_t q2, double theta, double phi) {
    DIAGNOSTIC("___rpp(%" PRIu64 ", %" PRIu64 ", %f, %f)\n", q1, q2, theta, phi);
    init_gate_ids();
    GwGateValue values[] = {qubit_value(q1), qubit_value(q2), angle_value(theta), angle_value(phi)};
    emit_gate(phased_xx_id, values, 4);
    DIAGNOSTIC("   [done]\n");
}
void ___reset(uint64_t q) {
    DIAGNOSTIC("___reset(%" PRIu64 ")\n", q);
    unwrap(selene_qubit_reset(selene_instance, q));
    DIAGNOSTIC("   [done]\n");
}
bool ___measure(uint64_t q) {
    DIAGNOSTIC("___measure(%" PRIu64 ")\n", q);
    bool result = unwrap(selene_qubit_measure(selene_instance, q));
    DIAGNOSTIC("   returned %s\n", result ? "true" : "false");
    return result;
}
uint64_t ___lazy_measure(uint64_t q) {
    DIAGNOSTIC("___lazy_measure(%" PRIu64 ")\n", q);
    uint64_t reference = unwrap(selene_qubit_lazy_measure(selene_instance, q));
    DIAGNOSTIC("   reference: %" PRIu64 "\n", reference);
    return reference;
}
uint64_t ___lazy_measure_leaked(uint64_t q) {
    DIAGNOSTIC("___lazy_measure_leaked(%" PRIu64 ")\n", q);
    uint64_t reference = unwrap(selene_qubit_lazy_measure_leaked(selene_instance, q));
    DIAGNOSTIC("   reference: %" PRIu64 "\n", reference);
    return reference;
}
void ___dec_future_refcount(uint64_t r) {
    DIAGNOSTIC("___dec_future_refcount(%" PRIu64 ")\n", r);
    unwrap(selene_refcount_decrement(selene_instance, r));
    DIAGNOSTIC("   [done]\n");
}
void ___inc_future_refcount(uint64_t r) {
    DIAGNOSTIC("___inc_future_refcount(%" PRIu64 ")\n", r);
    unwrap(selene_refcount_increment(selene_instance, r));
    DIAGNOSTIC("   [done]\n");
}
bool ___read_future_bool(uint64_t r) {
    DIAGNOSTIC("___read_future_bool(%" PRIu64 ")\n", r);
    bool result = unwrap(selene_future_read_bool(selene_instance, r));
    DIAGNOSTIC("   returned %s\n", result ? "true" : "false");
    return result;
}
uint64_t ___read_future_uint(uint64_t r) {
    DIAGNOSTIC("___read_future_uint(%" PRIu64 ")\n", r);
    uint64_t result = unwrap(selene_future_read_u64(selene_instance, r));
    DIAGNOSTIC("   returned %" PRIu64 "\n", result);
    return result;
}

void set_tc(uint64_t time_cursor) {
    DIAGNOSTIC("set_tc(%" PRIu64 ")\n", time_cursor);
    unwrap(selene_set_tc(selene_instance, time_cursor));
    DIAGNOSTIC("   [done]\n");
}
uint64_t get_tc() {
    DIAGNOSTIC("get_tc()\n");
    uint64_t result = unwrap(selene_get_tc(selene_instance));
    DIAGNOSTIC("   result: %" PRIu64 "\n", result);
    return result;
}
void setup(uint64_t time_cursor) {
    DIAGNOSTIC("setup(%" PRIu64 ")\n", time_cursor);
    set_tc(time_cursor);
}
uint64_t teardown() {
    DIAGNOSTIC("teardown()\n");
    return get_tc();
}
void ___barrier(uint64_t* qubits, uint64_t qubits_len) {
    DIAGNOSTIC("___barrier(%p, %" PRIu64 ")\n", qubits, qubits_len);
    for (uint64_t i = 0; i < qubits_len; ++i) {
        DIAGNOSTIC("   %" PRIu64 ": %" PRIu64 "\n", i, qubits[i]);
    }
    unwrap(selene_local_barrier(selene_instance, qubits, qubits_len, 0));
    DIAGNOSTIC("   [done]\n");
}
void ___sleep(uint64_t* qubits, uint64_t qubits_len, uint64_t sleep_time) {
    DIAGNOSTIC("___sleep(%p, %" PRIu64 ", %" PRIu64 ")\n", qubits, qubits_len, sleep_time);
    for (uint64_t i = 0; i < qubits_len; ++i) {
        DIAGNOSTIC("   %" PRIu64 ": %" PRIu64 "\n", i, qubits[i]);
    }
    unwrap(selene_local_barrier(selene_instance, qubits, qubits_len, sleep_time));
    DIAGNOSTIC("   [done]\n");
}
