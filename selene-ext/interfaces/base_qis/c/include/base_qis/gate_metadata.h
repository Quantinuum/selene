#ifndef BASE_QIS_GATE_METADATA_H
#define BASE_QIS_GATE_METADATA_H

#include <stddef.h>

#include <base_qis/macros.h>
#include <selene/gatewire.h>

#ifndef SELENE_LOG_LEVEL
#define SELENE_LOG_LEVEL 0
#endif

#define QIS_GATE_METADATA_CAPACITY 4

#if defined(_MSC_VER)
#include <intrin.h>
#define QIS_RETURN_ADDRESS() _ReturnAddress()
#else
#define QIS_RETURN_ADDRESS() __builtin_return_address(0)
#endif

EXPORT size_t qis_capture_gate_metadata(
    void* return_address,
    GwGateMetadata* out,
    size_t out_len
);

#if (SELENE_LOG_LEVEL) == 2
#define QIS_EMIT_GATE(semantic_id, values, values_len)                                      \
    do {                                                                                    \
        GwGateMetadata qis_metadata[QIS_GATE_METADATA_CAPACITY];                            \
        size_t qis_metadata_len = qis_capture_gate_metadata(                                \
            QIS_RETURN_ADDRESS(), qis_metadata, QIS_GATE_METADATA_CAPACITY                  \
        );                                                                                  \
        emit_gate((semantic_id), (values), (values_len), qis_metadata, qis_metadata_len);    \
    } while (0)
#else
#define QIS_EMIT_GATE(semantic_id, values, values_len)                                      \
    emit_gate((semantic_id), (values), (values_len), NULL, 0)
#endif

#endif
