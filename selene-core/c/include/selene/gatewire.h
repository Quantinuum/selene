#ifndef SELENE_GATEWIRE_H
#define SELENE_GATEWIRE_H

#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdint.h>

#define GW_METADATA_VALUE_KIND_BOOL 1

#define GW_METADATA_VALUE_KIND_I64 2

#define GW_METADATA_VALUE_KIND_U64 3

#define GW_METADATA_VALUE_KIND_F64 4

#define GW_METADATA_VALUE_KIND_STRING 5

#define GW_METADATA_VALUE_KIND_BYTES 6

#define GW_OPERAND_KIND_QUBIT 1

#define GW_OPERAND_KIND_F64 2

#define GW_OPERAND_KIND_U64 3

#define GW_OPERAND_KIND_I64 4

#define GW_OPERAND_KIND_U8 5

#define GW_OPERAND_KIND_BOOL 6

typedef int32_t GwStatus;

typedef struct {
  uint8_t bytes[16];
} GwSemanticId;

typedef struct {
  uint8_t _private[0];
} GwGateSet;

typedef struct {
  size_t abi_size;
  const char *name_ptr;
  size_t name_len;
  uint32_t kind;
} GwOperandDeclView;

typedef struct {
  size_t abi_size;
  GwSemanticId semantic_id;
  const char *name_ptr;
  size_t name_len;
  const GwOperandDeclView *operands_ptr;
  size_t operands_len;
  uint32_t version;
} GwGateDeclView;

typedef struct {
  size_t abi_size;
  GwSemanticId semantic_id;
  const char *name_ptr;
  size_t name_len;
  size_t operands_len;
  uint32_t version;
} GwGateDeclInfo;

typedef struct {
  size_t abi_size;
  const char *name_ptr;
  size_t name_len;
  uint32_t kind;
} GwOperandDeclInfo;

typedef union {
  uint32_t qubit;
  double f64_value;
  uint64_t u64_value;
  int64_t i64_value;
  uint8_t u8_value;
  uint8_t bool_value;
} GwGateValueData;

typedef struct {
  size_t abi_size;
  uint32_t kind;
  GwGateValueData data;
  const uint8_t *bytes_ptr;
  size_t bytes_len;
} GwGateValue;

typedef union {
  uint8_t bool_value;
  int64_t i64_value;
  uint64_t u64_value;
  double f64_value;
} GwMetadataValueData;

typedef struct {
  size_t abi_size;
  const char *key_ptr;
  size_t key_len;
  uint32_t value_kind;
  GwMetadataValueData data;
  const uint8_t *bytes_ptr;
  size_t bytes_len;
} GwGateMetadata;

typedef struct {
  size_t abi_size;
  GwSemanticId semantic_id;
  const GwGateValue *values_ptr;
  size_t values_len;
  const GwGateMetadata *metadata_ptr;
  size_t metadata_len;
} GwGateInstanceView;

typedef struct {
  uint8_t _private[0];
} GwDecodedGate;

#define GW_STATUS_OK 0

#define GW_STATUS_NULL_POINTER 1

#define GW_STATUS_INVALID_ARGUMENT 2

#define GW_STATUS_DUPLICATE_GATE 3

#define GW_STATUS_NOT_FOUND 4

#define GW_STATUS_BUFFER_TOO_SMALL 5

#define GW_STATUS_DECODE_ERROR 6

#define GW_STATUS_VALIDATION_ERROR 7

#define GW_STATUS_PANIC 255

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

const char *gw_status_message(GwStatus status);

GwStatus gw_semantic_id_from_text(const char *ptr, size_t len, GwSemanticId *out);

uint8_t gw_semantic_id_eq(GwSemanticId a, GwSemanticId b);

GwSemanticId gw_builtin_rz_semantic_id(void);

GwSemanticId gw_builtin_phased_x_semantic_id(void);

GwSemanticId gw_builtin_zz_phase_semantic_id(void);

GwSemanticId gw_builtin_phased_xx_semantic_id(void);

GwStatus gw_gateset_new(GwGateSet **out);

GwStatus gw_builtin_gateset_new(GwGateSet **out);

void gw_gateset_free(GwGateSet *set);

GwStatus gw_gateset_add_decl(GwGateSet *set, const GwGateDeclView *decl);

GwStatus gw_gateset_add_builtin_rz(GwGateSet *set);

GwStatus gw_gateset_add_builtin_phased_x(GwGateSet *set);

GwStatus gw_gateset_add_builtin_zz_phase(GwGateSet *set);

GwStatus gw_gateset_add_builtin_phased_xx(GwGateSet *set);

GwStatus gw_gateset_len(const GwGateSet *set, size_t *out);

GwStatus gw_gateset_contains(const GwGateSet *set, GwSemanticId id, uint8_t *out);

GwStatus gw_gateset_decl_at(const GwGateSet *set, size_t index, GwGateDeclInfo *out);

GwStatus gw_gateset_decl_operand_at(const GwGateSet *set,
                                    size_t decl_index,
                                    size_t operand_index,
                                    GwOperandDeclInfo *out);

GwStatus gw_gateset_serialized_len(const GwGateSet *set, size_t *out);

GwStatus gw_gateset_serialize(const GwGateSet *set,
                              uint8_t *buffer,
                              size_t buffer_len,
                              size_t *written);

GwStatus gw_gateset_deserialize(const uint8_t *data, size_t len, GwGateSet **out);

GwStatus gw_gate_serialized_len(const GwGateInstanceView *view, size_t *out);

GwStatus gw_gate_serialize(const GwGateInstanceView *view,
                           uint8_t *buffer,
                           size_t buffer_len,
                           size_t *written);

GwStatus gw_gate_deserialize(const uint8_t *data, size_t len, GwDecodedGate **out);

void gw_decoded_gate_free(GwDecodedGate *gate);

GwStatus gw_decoded_gate_semantic_id(const GwDecodedGate *gate, GwSemanticId *out);

GwStatus gw_decoded_gate_value_count(const GwDecodedGate *gate, size_t *out);

GwStatus gw_decoded_gate_value_at(const GwDecodedGate *gate, size_t index, GwGateValue *out);

GwStatus gw_decoded_gate_metadata_count(const GwDecodedGate *gate, size_t *out);

GwStatus gw_decoded_gate_metadata_at(const GwDecodedGate *gate, size_t index, GwGateMetadata *out);

GwStatus gw_decoded_gate_metadata_find(const GwDecodedGate *gate,
                                       const char *key_ptr,
                                       size_t key_len,
                                       GwGateMetadata *out);

GwStatus gw_decoded_gate_qubit_operand_count(const GwDecodedGate *gate, size_t *out);

GwStatus gw_decoded_gate_qubit_operand_at(const GwDecodedGate *gate,
                                          size_t qubit_index,
                                          uint32_t *out);

GwStatus gw_gateset_validate_decoded(const GwGateSet *set,
                                     const GwDecodedGate *gate,
                                     uint8_t *out_matches);

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif  /* SELENE_GATEWIRE_H */
