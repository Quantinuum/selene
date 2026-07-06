# Writing Gates in C

C plugins use the gatewire C ABI from `selene/gatewire.h`. The ABI is explicit:
you create gatesets through opaque `GwGateSet` handles, serialize gate instances
into byte buffers, and decode incoming gate bytes through `GwDecodedGate`.

## Create a Gateset

Use the builtin helpers when possible:

```c
#include <selene/gatewire.h>

GwGateSet *set = NULL;
GwStatus status = gw_gateset_new(&set);
if (status != GW_STATUS_OK) {
    return 1;
}

gw_gateset_add_builtin_rz(set);
gw_gateset_add_builtin_phased_x(set);
gw_gateset_add_builtin_zz_phase(set);
```

Free the gateset when you are done:

```c
gw_gateset_free(set);
```

## Serialize a Gateset

Plugin negotiation callbacks use serialized gateset bytes. The pattern is:

```c
static int write_gateset(GwGateSet *set,
                         uint8_t *output,
                         size_t output_len,
                         size_t *written) {
    size_t required = 0;
    GwStatus status = gw_gateset_serialized_len(set, &required);
    if (status != GW_STATUS_OK) {
        return 1;
    }

    if (output == NULL || output_len == 0) {
        *written = required;
        return 0;
    }

    status = gw_gateset_serialize(set, output, output_len, written);
    return status == GW_STATUS_OK ? 0 : 1;
}
```

The same two-call shape is used by runtime, error model, and simulator gateset
negotiation.

## Decode an Incoming Gate

Runtime callbacks and operation-batch collectors receive gate bytes. Decode them
before inspecting operands:

```c
static int handle_gate(const uint8_t *data, size_t len) {
    GwDecodedGate *gate = NULL;
    GwStatus status = gw_gate_deserialize(data, len, &gate);
    if (status != GW_STATUS_OK) {
        return 1;
    }

    GwSemanticId id;
    status = gw_decoded_gate_semantic_id(gate, &id);
    if (status != GW_STATUS_OK) {
        gw_decoded_gate_free(gate);
        return 1;
    }

    if (gw_semantic_id_eq(id, gw_builtin_rz_semantic_id())) {
        GwGateValue q0;
        GwGateValue theta;
        gw_decoded_gate_value_at(gate, 0, &q0);
        gw_decoded_gate_value_at(gate, 1, &theta);
        /* q0.data.qubit, theta.data.f64_value */
    }

    gw_decoded_gate_free(gate);
    return 0;
}
```

Always check both the semantic ID and the expected operand kinds. The order of
operands is part of the declaration.

## Inspect Qubit Operands Generically

Some plugins care about gate arity rather than the gate's identity. A
depolarizing error model, for example, may want to apply a one-qubit channel
after every one-qubit gate and a two-qubit channel after every two-qubit gate.

Use the qubit operand helpers after decoding the gate:

```c
size_t qubits = 0;
if (gw_decoded_gate_qubit_operand_count(gate, &qubits) != GW_STATUS_OK) {
    gw_decoded_gate_free(gate);
    return 1;
}

if (qubits == 1) {
    uint32_t q0 = 0;
    if (gw_decoded_gate_qubit_operand_at(gate, 0, &q0) != GW_STATUS_OK) {
        gw_decoded_gate_free(gate);
        return 1;
    }
    /* apply a one-qubit policy to q0 */
} else if (qubits == 2) {
    uint32_t q0 = 0;
    uint32_t q1 = 0;
    gw_decoded_gate_qubit_operand_at(gate, 0, &q0);
    gw_decoded_gate_qubit_operand_at(gate, 1, &q1);
    /* apply a two-qubit policy to q0 and q1 */
}
```

This keeps the plugin independent of display names and works equally well for
builtin and custom gates.

## Define a Custom Gate

Create a semantic ID and a declaration view:

```c
static GwStatus add_virtual_z(GwGateSet *set) {
    static const char id_text[] = "com.example.calibration.VirtualZ.v1";
    static const char name[] = "VirtualZ";
    static const char q0_name[] = "q0";
    static const char theta_name[] = "theta";

    GwSemanticId id;
    GwStatus status = gw_semantic_id_from_text(
        id_text,
        sizeof(id_text) - 1,
        &id
    );
    if (status != GW_STATUS_OK) {
        return status;
    }

    GwOperandDeclView operands[2] = {
        {
            .abi_size = sizeof(GwOperandDeclView),
            .name_ptr = q0_name,
            .name_len = sizeof(q0_name) - 1,
            .kind = GW_OPERAND_KIND_QUBIT,
        },
        {
            .abi_size = sizeof(GwOperandDeclView),
            .name_ptr = theta_name,
            .name_len = sizeof(theta_name) - 1,
            .kind = GW_OPERAND_KIND_F64,
        },
    };

    GwGateDeclView decl = {
        .abi_size = sizeof(GwGateDeclView),
        .semantic_id = id,
        .name_ptr = name,
        .name_len = sizeof(name) - 1,
        .operands_ptr = operands,
        .operands_len = 2,
        .version = 1,
    };

    return gw_gateset_add_decl(set, &decl);
}
```

The strings and operand arrays only need to live for the duration of
`gw_gateset_add_decl`; the gateset stores its own copy.

## Serialize a Gate Instance

Use a `GwGateInstanceView` with operand values:

```c
GwGateValue values[2] = {
    {
        .abi_size = sizeof(GwGateValue),
        .kind = GW_OPERAND_KIND_QUBIT,
        .data.qubit = 0,
    },
    {
        .abi_size = sizeof(GwGateValue),
        .kind = GW_OPERAND_KIND_F64,
        .data.f64_value = 3.141592653589793,
    },
};

GwGateInstanceView view = {
    .abi_size = sizeof(GwGateInstanceView),
    .semantic_id = gw_builtin_rz_semantic_id(),
    .values_ptr = values,
    .values_len = 2,
};

size_t required = 0;
gw_gate_serialized_len(&view, &required);
```

After you know the size, allocate a buffer and call `gw_gate_serialize`.
