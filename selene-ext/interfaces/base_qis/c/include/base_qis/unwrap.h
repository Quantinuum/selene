#ifndef HELIOS_QIS_UNWRAP_H
#define HELIOS_QIS_UNWRAP_H

#include <stdint.h>
#include <selene/selene.h>
#include <base_qis/macros.h>

#define unwrap(value) _Generic(value \
    , struct selene_u64_result_t: unwrap_u64 \
    , struct selene_u32_result_t: unwrap_u32 \
    , struct selene_f64_result_t: unwrap_f64 \
    , struct selene_void_result_t: unwrap_void \
    , struct selene_bool_result_t: unwrap_bool \
    , struct selene_future_result_t: unwrap_future \
)(value)

EXPORT uint64_t unwrap_u64(struct selene_u64_result_t result);
EXPORT uint32_t unwrap_u32(struct selene_u32_result_t result);
EXPORT double unwrap_f64(struct selene_f64_result_t result);
EXPORT void unwrap_void(struct selene_void_result_t result);
EXPORT bool unwrap_bool(struct selene_bool_result_t result);
EXPORT uint64_t unwrap_future(struct selene_future_result_t result);

#endif
