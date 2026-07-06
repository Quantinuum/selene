#include <clifford_t_qis.h>

#include <inttypes.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <selene/selene.h>

static SeleneInstance* selene_instance = NULL;

static GwSemanticId h_id;
static GwSemanticId s_id;
static GwSemanticId sdg_id;
static GwSemanticId t_id;
static GwSemanticId tdg_id;
static GwSemanticId x_id;
static GwSemanticId cnot_id;
static bool gate_ids_initialized = false;

static void fail(char const* message) {
    fprintf(stderr, "clifford_t_interface: %s\n", message);
    abort();
}

static void check_gw(GwStatus status) {
    if (status != GW_STATUS_OK) {
        fprintf(stderr, "clifford_t_interface: gatewire error: %s\n", gw_status_message(status));
        abort();
    }
}

static void check_void(struct selene_void_result_t result, char const* context) {
    if (result.error_code != 0) {
        fprintf(stderr, "clifford_t_interface: %s failed with error code %" PRIu32 "\n", context, result.error_code);
        abort();
    }
}

static uint64_t unwrap_u64(struct selene_u64_result_t result, char const* context) {
    if (result.error_code != 0) {
        fprintf(stderr, "clifford_t_interface: %s failed with error code %" PRIu32 "\n", context, result.error_code);
        abort();
    }
    return result.value;
}

static bool unwrap_bool(struct selene_bool_result_t result, char const* context) {
    if (result.error_code != 0) {
        fprintf(stderr, "clifford_t_interface: %s failed with error code %" PRIu32 "\n", context, result.error_code);
        abort();
    }
    return result.value;
}

static struct selene_string_t borrowed_string(char const* text) {
    struct selene_string_t value = {
        .data = text,
        .length = strlen(text),
        .owned = false,
    };
    return value;
}

static GwSemanticId semantic_id(char const* text) {
    GwSemanticId id;
    check_gw(gw_semantic_id_from_text(text, strlen(text), &id));
    return id;
}

static GwOperandDeclView qubit_operand(char const* name) {
    GwOperandDeclView operand = {
        .abi_size = sizeof(GwOperandDeclView),
        .name_ptr = name,
        .name_len = strlen(name),
        .kind = GW_OPERAND_KIND_QUBIT,
    };
    return operand;
}

static void add_gate(GwGateSet* set, GwSemanticId id, char const* display, GwOperandDeclView const* operands, size_t operands_len) {
    GwGateDeclView decl = {
        .abi_size = sizeof(GwGateDeclView),
        .semantic_id = id,
        .name_ptr = display,
        .name_len = strlen(display),
        .operands_ptr = operands,
        .operands_len = operands_len,
        .version = 1,
    };
    check_gw(gw_gateset_add_decl(set, &decl));
}

static void init_gate_ids(void) {
    if (gate_ids_initialized) {
        return;
    }
    h_id = semantic_id("example.clifford_t.H.v1");
    s_id = semantic_id("example.clifford_t.S.v1");
    sdg_id = semantic_id("example.clifford_t.Sdg.v1");
    t_id = semantic_id("example.clifford_t.T.v1");
    tdg_id = semantic_id("example.clifford_t.Tdg.v1");
    x_id = semantic_id("example.clifford_t.X.v1");
    cnot_id = semantic_id("example.clifford_t.CNOT.v1");
    gate_ids_initialized = true;
}

static void register_clifford_t_gateset(void) {
    init_gate_ids();

    GwGateSet* set = NULL;
    check_gw(gw_gateset_new(&set));

    GwOperandDeclView q0[] = {qubit_operand("q0")};
    GwOperandDeclView cnot[] = {qubit_operand("control"), qubit_operand("target")};
    add_gate(set, h_id, "H", q0, 1);
    add_gate(set, s_id, "S", q0, 1);
    add_gate(set, sdg_id, "Sdg", q0, 1);
    add_gate(set, t_id, "T", q0, 1);
    add_gate(set, tdg_id, "Tdg", q0, 1);
    add_gate(set, x_id, "X", q0, 1);
    add_gate(set, cnot_id, "CNOT", cnot, 2);

    size_t input_len = 0;
    check_gw(gw_gateset_serialized_len(set, &input_len));
    uint8_t* input = malloc(input_len);
    if (input == NULL) {
        gw_gateset_free(set);
        fail("failed to allocate gateset buffer");
    }
    size_t written = 0;
    check_gw(gw_gateset_serialize(set, input, input_len, &written));
    gw_gateset_free(set);

    size_t output_len = 0;
    check_void(selene_register_gateset(selene_instance, input, written, NULL, 0, &output_len), "selene_register_gateset(size)");
    uint8_t* output = malloc(output_len);
    if (output == NULL && output_len != 0) {
        free(input);
        fail("failed to allocate accepted gateset buffer");
    }
    check_void(selene_register_gateset(selene_instance, input, written, output, output_len, &output_len), "selene_register_gateset(write)");
    free(input);
    free(output);
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

static void emit_gate(GwSemanticId id, GwGateValue const* values, size_t values_len) {
    GwGateInstanceView gate = {
        .abi_size = sizeof(GwGateInstanceView),
        .semantic_id = id,
        .values_ptr = values,
        .values_len = values_len,
    };
    size_t buffer_len = 0;
    check_gw(gw_gate_serialized_len(&gate, &buffer_len));
    uint8_t* buffer = malloc(buffer_len);
    if (buffer == NULL) {
        fail("failed to allocate gate buffer");
    }
    size_t written = 0;
    check_gw(gw_gate_serialize(&gate, buffer, buffer_len, &written));
    check_void(selene_gate(selene_instance, buffer, written), "selene_gate");
    free(buffer);
}

static void emit_single_qubit_gate(GwSemanticId id, uint64_t q) {
    init_gate_ids();
    GwGateValue values[] = {qubit_value(q)};
    emit_gate(id, values, 1);
}

uint64_t ct_qalloc(void) {
    return unwrap_u64(selene_qalloc(selene_instance), "selene_qalloc");
}

void ct_qfree(uint64_t q) {
    check_void(selene_qfree(selene_instance, q), "selene_qfree");
}

void ct_reset(uint64_t q) {
    check_void(selene_qubit_reset(selene_instance, q), "selene_qubit_reset");
}

void ct_h(uint64_t q) {
    emit_single_qubit_gate(h_id, q);
}

void ct_s(uint64_t q) {
    emit_single_qubit_gate(s_id, q);
}

void ct_sdg(uint64_t q) {
    emit_single_qubit_gate(sdg_id, q);
}

void ct_t(uint64_t q) {
    emit_single_qubit_gate(t_id, q);
}

void ct_tdg(uint64_t q) {
    emit_single_qubit_gate(tdg_id, q);
}

void ct_x(uint64_t q) {
    emit_single_qubit_gate(x_id, q);
}

void ct_cnot(uint64_t control, uint64_t target) {
    init_gate_ids();
    GwGateValue values[] = {qubit_value(control), qubit_value(target)};
    emit_gate(cnot_id, values, 2);
}

bool ct_measure(uint64_t q) {
    return unwrap_bool(selene_qubit_measure(selene_instance, q), "selene_qubit_measure");
}

void ct_record_bool(char const* tag, bool value) {
    char buffer[256];
    int written = snprintf(buffer, sizeof(buffer), "USER:BOOL:%s", tag);
    if (written < 0 || (size_t)written >= sizeof(buffer)) {
        fail("result tag is too long");
    }
    check_void(selene_print_bool(selene_instance, borrowed_string(buffer), value), "selene_print_bool");
}

int main(int argc, char** argv) {
    if (argc < 3 || strcmp(argv[1], "--configuration") != 0) {
        fprintf(stderr, "Usage: %s --configuration <configuration_file>\n", argv[0]);
        return 1;
    }

    check_void(selene_load_config(&selene_instance, argv[2]), "selene_load_config");
    register_clifford_t_gateset();

    uint64_t n_shots = unwrap_u64(selene_shot_count(selene_instance), "selene_shot_count");
    for (uint64_t shot = 0; shot < n_shots; ++shot) {
        check_void(selene_on_shot_start(selene_instance, shot), "selene_on_shot_start");
        ct_program();
        check_void(selene_on_shot_end(selene_instance), "selene_on_shot_end");
    }
    check_void(selene_exit(selene_instance), "selene_exit");
    return 0;
}
