#ifndef SELENE_CORE_TYPES_H
#define SELENE_CORE_TYPES_H

#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>


typedef struct Operation Operation;

typedef int32_t SeleneErrno;

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

GwStatus gw_decoded_gate_qubit_operand_count(const GwDecodedGate *gate,
                                             size_t *out);

GwStatus gw_decoded_gate_qubit_operand_at(const GwDecodedGate *gate,
                                          size_t qubit_index,
                                          uint32_t *out);

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif  /* SELENE_CORE_TYPES_H */
