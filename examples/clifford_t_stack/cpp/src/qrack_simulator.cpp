#include <selene/gatewire.h>
#include <selene/simulator.h>

#include <algorithm>
#include <cstdint>
#include <cstring>
#include <exception>
#include <memory>
#include <optional>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#include "common/qrack_functions.hpp"
#include "common/qrack_types.hpp"
#include "qstabilizerhybrid.hpp"

namespace selene_example_qrack {

struct GateSetDeleter {
    void operator()(GwGateSet* set) const { gw_gateset_free(set); }
};

struct DecodedGateDeleter {
    void operator()(GwDecodedGate* gate) const { gw_decoded_gate_free(gate); }
};

using GateSetPtr = std::unique_ptr<GwGateSet, GateSetDeleter>;
using DecodedGatePtr = std::unique_ptr<GwDecodedGate, DecodedGateDeleter>;

void check_gw(GwStatus status, const char* context) {
    if (status == GW_STATUS_OK) {
        return;
    }
    const char* message = gw_status_message(status);
    throw std::runtime_error(
        std::string(context) + ": " + (message == nullptr ? "unknown gatewire error" : message));
}

bool id_eq(const std::optional<GwSemanticId>& lhs, GwSemanticId rhs) {
    return lhs.has_value() && gw_semantic_id_eq(*lhs, rhs) != 0;
}

bool id_eq(GwSemanticId lhs, GwSemanticId rhs) { return gw_semantic_id_eq(lhs, rhs) != 0; }

GwSemanticId semantic_id(const char* text) {
    GwSemanticId id{};
    check_gw(gw_semantic_id_from_text(text, std::strlen(text), &id), "build semantic id");
    return id;
}

DecodedGatePtr decode_gate(const uint8_t* data, size_t len) {
    GwDecodedGate* raw = nullptr;
    check_gw(gw_gate_deserialize(data, len, &raw), "decode gate");
    return DecodedGatePtr(raw);
}

GateSetPtr decode_gateset(const uint8_t* data, size_t len) {
    GwGateSet* raw = nullptr;
    check_gw(gw_gateset_deserialize(data, len, &raw), "decode gateset");
    return GateSetPtr(raw);
}

uint64_t qubit_operand(const GwDecodedGate* gate, size_t index) {
    GwGateValue value{};
    value.abi_size = sizeof(GwGateValue);
    check_gw(gw_decoded_gate_value_at(gate, index, &value), "read gate operand");
    if (value.kind != GW_OPERAND_KIND_QUBIT) {
        throw std::runtime_error("gate has unexpected operands");
    }
    return value.data.qubit;
}

struct GateIds {
    std::optional<GwSemanticId> h;
    std::optional<GwSemanticId> s;
    std::optional<GwSemanticId> sdg;
    std::optional<GwSemanticId> t;
    std::optional<GwSemanticId> tdg;
    std::optional<GwSemanticId> x;
    std::optional<GwSemanticId> cnot;
};

GateIds clifford_t_ids() {
    return GateIds{
        semantic_id("example.clifford_t.H.v1"),
        semantic_id("example.clifford_t.S.v1"),
        semantic_id("example.clifford_t.Sdg.v1"),
        semantic_id("example.clifford_t.T.v1"),
        semantic_id("example.clifford_t.Tdg.v1"),
        semantic_id("example.clifford_t.X.v1"),
        semantic_id("example.clifford_t.CNOT.v1"),
    };
}

struct QrackSimulator {
    explicit QrackSimulator(uint64_t qubit_count)
        : n_qubits(qubit_count),
          sim(std::make_shared<Qrack::QStabilizerHybrid>(
              std::vector<Qrack::QInterfaceEngine>{Qrack::QINTERFACE_CPU},
              static_cast<bitLenInt>(qubit_count))) {
        sim->SetTInjection(true);
        sim->SetUseExactNearClifford(true);
        sim->SetNcrp(0.0F);
    }

    uint64_t n_qubits = 0;
    std::shared_ptr<Qrack::QStabilizerHybrid> sim;
    GateIds ids;
    std::optional<bitCapInt> measured_register_sample;
    uint64_t gates_seen = 0;
    uint64_t measurements = 0;
    uint64_t engine_fallbacks = 0;
};

void ensure_qubit(const QrackSimulator& simulator, uint64_t qubit) {
    if (qubit >= simulator.n_qubits) {
        throw std::out_of_range("qubit index is out of bounds");
    }
}

void ensure_no_engine_fallback(QrackSimulator& simulator) {
    if (!simulator.sim->isClifford()) {
        ++simulator.engine_fallbacks;
        throw std::runtime_error("Qrack left stabilizer-hybrid mode and switched to a full engine");
    }
}

bool sample_bit(const bitCapInt& sample, uint64_t qubit) {
    return bi_compare_0(sample & Qrack::pow2(static_cast<bitLenInt>(qubit))) != 0;
}

void invalidate_measured_register_sample(QrackSimulator& simulator) {
    simulator.measured_register_sample.reset();
}

void expect_arity(size_t operands, size_t expected) {
    if (operands != expected) {
        throw std::runtime_error("gate declaration has unexpected arity");
    }
}

void remember_gate(GateIds& negotiated, const GateIds& supported, GwSemanticId id, size_t operands) {
    if (id_eq(*supported.h, id)) {
        expect_arity(operands, 1);
        negotiated.h = id;
    } else if (id_eq(*supported.s, id)) {
        expect_arity(operands, 1);
        negotiated.s = id;
    } else if (id_eq(*supported.sdg, id)) {
        expect_arity(operands, 1);
        negotiated.sdg = id;
    } else if (id_eq(*supported.t, id)) {
        expect_arity(operands, 1);
        negotiated.t = id;
    } else if (id_eq(*supported.tdg, id)) {
        expect_arity(operands, 1);
        negotiated.tdg = id;
    } else if (id_eq(*supported.x, id)) {
        expect_arity(operands, 1);
        negotiated.x = id;
    } else if (id_eq(*supported.cnot, id)) {
        expect_arity(operands, 2);
        negotiated.cnot = id;
    } else {
        throw std::runtime_error("Qrack Clifford+T simulator received an unsupported gate");
    }
}

GateIds parse_gateset(const uint8_t* data, size_t len) {
    auto set = decode_gateset(data, len);
    GateIds ids;
    const GateIds supported = clifford_t_ids();
    size_t gate_count = 0;
    check_gw(gw_gateset_len(set.get(), &gate_count), "read gateset length");
    for (size_t gate = 0; gate < gate_count; ++gate) {
        GwGateDeclInfo decl{};
        decl.abi_size = sizeof(GwGateDeclInfo);
        check_gw(gw_gateset_decl_at(set.get(), gate, &decl), "read gate declaration");
        for (size_t operand = 0; operand < decl.operands_len; ++operand) {
            GwOperandDeclInfo operand_decl{};
            operand_decl.abi_size = sizeof(GwOperandDeclInfo);
            check_gw(
                gw_gateset_decl_operand_at(set.get(), gate, operand, &operand_decl), "read operand declaration");
            if (operand_decl.kind != GW_OPERAND_KIND_QUBIT) {
                throw std::runtime_error("Clifford+T gates must use only qubit operands");
            }
        }
        remember_gate(ids, supported, decl.semantic_id, decl.operands_len);
    }
    return ids;
}

thread_local std::string last_error_message;

int fail(const char* context, const std::exception& error) {
    last_error_message =
        std::string("selene_example_clifford_t_qrack: ") + context + ": " + error.what();
    return -1;
}

template <typename Fn> int wrap_errno(const char* context, Fn fn) {
    try {
        fn();
        last_error_message.clear();
        return 0;
    } catch (const std::exception& error) {
        return fail(context, error);
    }
}

QrackSimulator& instance(SeleneSimulatorInstance handle) {
    if (handle == nullptr) {
        throw std::runtime_error("simulator instance is null");
    }
    return *static_cast<QrackSimulator*>(handle);
}

}  // namespace selene_example_qrack

using namespace selene_example_qrack;

extern "C" const char* qrack_get_name() { return "Qrack Clifford+T stabilizer-hybrid simulator"; }

extern "C" SeleneErrno qrack_last_error(char* output, size_t output_len, size_t* written) {
    if (written == nullptr) {
        return -1;
    }
    *written = last_error_message.size();
    if (output == nullptr) {
        return 0;
    }
    if (output_len < last_error_message.size()) {
        return -1;
    }
    std::memcpy(output, last_error_message.data(), last_error_message.size());
    return 0;
}

extern "C" SeleneErrno qrack_init(
    SeleneSimulatorInstance* handle, uint64_t n_qubits, uint32_t, const char* const*) {
    return wrap_errno("init", [&]() {
        if (handle == nullptr) {
            throw std::runtime_error("output handle is null");
        }
        *handle = new QrackSimulator(n_qubits);
    });
}

extern "C" SeleneErrno qrack_exit(SeleneSimulatorInstance handle) {
    return wrap_errno("exit", [&]() { delete &instance(handle); });
}

extern "C" SeleneErrno qrack_shot_start(SeleneSimulatorInstance handle, uint64_t, uint64_t seed) {
    return wrap_errno("shot_start", [&]() {
        auto& simulator = instance(handle);
        simulator.sim = std::make_shared<Qrack::QStabilizerHybrid>(
            std::vector<Qrack::QInterfaceEngine>{Qrack::QINTERFACE_CPU},
            static_cast<bitLenInt>(simulator.n_qubits));
        simulator.sim->SetTInjection(true);
        simulator.sim->SetUseExactNearClifford(true);
        simulator.sim->SetNcrp(0.0F);
        simulator.sim->SetRandomSeed(static_cast<uint32_t>(seed));
        simulator.measured_register_sample.reset();
        simulator.gates_seen = 0;
        simulator.measurements = 0;
        simulator.engine_fallbacks = 0;
    });
}

extern "C" SeleneErrno qrack_shot_end(SeleneSimulatorInstance handle) {
    return wrap_errno("shot_end", [&]() { ensure_no_engine_fallback(instance(handle)); });
}

void apply_gate(QrackSimulator& simulator, const uint8_t* data, size_t len) {
    invalidate_measured_register_sample(simulator);
    auto gate = decode_gate(data, len);
    GwSemanticId gate_id{};
    check_gw(gw_decoded_gate_semantic_id(gate.get(), &gate_id), "read gate semantic id");

    if (id_eq(simulator.ids.h, gate_id)) {
        const auto q = qubit_operand(gate.get(), 0);
        ensure_qubit(simulator, q);
        simulator.sim->H(static_cast<bitLenInt>(q));
    } else if (id_eq(simulator.ids.s, gate_id)) {
        const auto q = qubit_operand(gate.get(), 0);
        ensure_qubit(simulator, q);
        simulator.sim->S(static_cast<bitLenInt>(q));
    } else if (id_eq(simulator.ids.sdg, gate_id)) {
        const auto q = qubit_operand(gate.get(), 0);
        ensure_qubit(simulator, q);
        simulator.sim->IS(static_cast<bitLenInt>(q));
    } else if (id_eq(simulator.ids.t, gate_id)) {
        const auto q = qubit_operand(gate.get(), 0);
        ensure_qubit(simulator, q);
        simulator.sim->T(static_cast<bitLenInt>(q));
    } else if (id_eq(simulator.ids.tdg, gate_id)) {
        const auto q = qubit_operand(gate.get(), 0);
        ensure_qubit(simulator, q);
        simulator.sim->IT(static_cast<bitLenInt>(q));
    } else if (id_eq(simulator.ids.x, gate_id)) {
        const auto q = qubit_operand(gate.get(), 0);
        ensure_qubit(simulator, q);
        simulator.sim->X(static_cast<bitLenInt>(q));
    } else if (id_eq(simulator.ids.cnot, gate_id)) {
        const auto control = qubit_operand(gate.get(), 0);
        const auto target = qubit_operand(gate.get(), 1);
        ensure_qubit(simulator, control);
        ensure_qubit(simulator, target);
        simulator.sim->CNOT(static_cast<bitLenInt>(control), static_cast<bitLenInt>(target));
    } else {
        throw std::runtime_error("gate is not in the negotiated Clifford+T gateset");
    }

    ++simulator.gates_seen;
    ensure_no_engine_fallback(simulator);
}

bool apply_measure(QrackSimulator& simulator, uint64_t qubit) {
    ensure_qubit(simulator, qubit);

    if (!simulator.measured_register_sample.has_value()) {
        const bitCapInt sample = simulator.sim->MAll();
        simulator.measured_register_sample = sample;
    }
    const bool result = sample_bit(*simulator.measured_register_sample, qubit);

    ++simulator.measurements;
    ensure_no_engine_fallback(simulator);
    return result;
}

void apply_reset(QrackSimulator& simulator, uint64_t qubit) {
    invalidate_measured_register_sample(simulator);
    ensure_qubit(simulator, qubit);
    simulator.sim->SetBit(static_cast<bitLenInt>(qubit), false);
    ensure_no_engine_fallback(simulator);
}

struct OperationSink {
    QrackSimulator* simulator;
    OperationResultHandle result;
};

void sink_gate(SeleneRuntimeGetOperationInstance instance, const uint8_t* data, size_t len) {
    auto* sink = static_cast<OperationSink*>(instance);
    apply_gate(*sink->simulator, data, len);
}

void sink_measure(SeleneRuntimeGetOperationInstance instance, uint64_t qubit, uint64_t result_id) {
    auto* sink = static_cast<OperationSink*>(instance);
    const bool result = apply_measure(*sink->simulator, qubit);
    sink->result.interface.set_bool_result_fn(sink->result.instance, result_id, result);
}

void sink_measure_leaked(SeleneRuntimeGetOperationInstance instance, uint64_t qubit, uint64_t result_id) {
    auto* sink = static_cast<OperationSink*>(instance);
    const bool result = apply_measure(*sink->simulator, qubit);
    sink->result.interface.set_u64_result_fn(sink->result.instance, result_id, result ? 1 : 0);
}

void sink_postselect(SeleneRuntimeGetOperationInstance instance, uint64_t qubit, bool target_value) {
    auto* sink = static_cast<OperationSink*>(instance);
    invalidate_measured_register_sample(*sink->simulator);
    ensure_qubit(*sink->simulator, qubit);
    (void)sink->simulator->sim->ForceM(static_cast<bitLenInt>(qubit), target_value, true, true);
    ensure_no_engine_fallback(*sink->simulator);
}

void sink_reset(SeleneRuntimeGetOperationInstance instance, uint64_t qubit) {
    auto* sink = static_cast<OperationSink*>(instance);
    apply_reset(*sink->simulator, qubit);
}

void sink_custom(SeleneRuntimeGetOperationInstance, size_t, const void*, size_t) {
    throw std::runtime_error("custom operations are not supported by the Qrack simulator");
}

void sink_set_batch_time(SeleneRuntimeGetOperationInstance, uint64_t, uint64_t) {}

extern "C" SeleneErrno qrack_handle_operations(
    SeleneSimulatorInstance handle, RuntimeExtractOperationHandle batch, OperationResultHandle result) {
    return wrap_errno("handle_operations", [&]() {
        OperationSink sink{&instance(handle), result};
        RuntimeGetOperationHandle output{
            &sink,
            {
                sink_measure,
                sink_measure_leaked,
                sink_postselect,
                sink_reset,
                sink_custom,
                sink_set_batch_time,
                sink_gate,
            },
        };
        batch.interface.extract_fn(&batch, output);
    });
}

extern "C" SeleneErrno qrack_postselect(
    SeleneSimulatorInstance handle, uint64_t qubit, bool target_value) {
    return wrap_errno("postselect", [&]() {
        auto& simulator = instance(handle);
        invalidate_measured_register_sample(simulator);
        ensure_qubit(simulator, qubit);
        (void)simulator.sim->ForceM(static_cast<bitLenInt>(qubit), target_value, true, true);
        ensure_no_engine_fallback(simulator);
    });
}

extern "C" SeleneErrno qrack_reset(SeleneSimulatorInstance handle, uint64_t qubit) {
    return wrap_errno("reset", [&]() { apply_reset(instance(handle), qubit); });
}

void write_metric(const char* tag, uint8_t datatype, uint64_t value, char* tag_out, uint8_t* datatype_out,
    uint64_t* value_out) {
    std::strcpy(tag_out, tag);
    *datatype_out = datatype;
    *value_out = value;
}

extern "C" SeleneErrno qrack_get_metrics(
    SeleneSimulatorInstance handle, uint8_t nth_metric, char* tag_out, uint8_t* datatype_out, uint64_t* value_out) {
    try {
        auto& simulator = instance(handle);
        switch (nth_metric) {
        case 0:
            write_metric("gates_seen", 2, simulator.gates_seen, tag_out, datatype_out, value_out);
            last_error_message.clear();
            return 0;
        case 1:
            write_metric("measurements", 2, simulator.measurements, tag_out, datatype_out, value_out);
            last_error_message.clear();
            return 0;
        case 2:
            write_metric("engine_fallbacks", 2, simulator.engine_fallbacks, tag_out, datatype_out, value_out);
            last_error_message.clear();
            return 0;
        default:
            return 1;
        }
    } catch (const std::exception& error) {
        return fail("get_metrics", error);
    }
}

extern "C" SeleneErrno qrack_dump_state(SeleneSimulatorInstance, const char*, const uint64_t*, uint64_t) {
    return wrap_errno("dump_state", []() { throw std::runtime_error("dump_state is not implemented"); });
}

extern "C" SeleneErrno qrack_negotiate_gateset(SeleneSimulatorInstance handle, const uint8_t* input,
    size_t input_len, uint8_t* output, size_t output_len, size_t* written) {
    return wrap_errno("negotiate_gateset", [&]() {
        if (written == nullptr) {
            throw std::runtime_error("written pointer is null");
        }
        auto& simulator = instance(handle);
        GateIds ids = parse_gateset(input, input_len);
        *written = input_len;
        if (output == nullptr) {
            simulator.ids = std::move(ids);
            return;
        }
        if (output_len < input_len) {
            throw std::runtime_error("output buffer is too small");
        }
        std::memcpy(output, input, input_len);
        simulator.ids = std::move(ids);
    });
}

extern "C" SeleneSimulatorPluginDescriptorV1 selene_simulator_plugin_descriptor_v1 = {
    sizeof(SeleneSimulatorPluginDescriptorV1),
    SELENE_SIMULATOR_CURRENT_API_VERSION,
    qrack_last_error,
    qrack_get_name,
    qrack_init,
    qrack_exit,
    qrack_shot_start,
    qrack_shot_end,
    qrack_handle_operations,
    qrack_get_metrics,
    qrack_dump_state,
    qrack_negotiate_gateset,
};

extern "C" const SeleneSimulatorPluginDescriptorV1* selene_simulator_get_plugin_descriptor_v1() {
    return &selene_simulator_plugin_descriptor_v1;
}
