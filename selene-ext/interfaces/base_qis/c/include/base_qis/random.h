#ifndef BASE_QIS_RANDOM_H
#define BASE_QIS_RANDOM_H

#include <stdint.h>
#include <base_qis/macros.h>

EXPORT void random_seed(uint64_t seed);
EXPORT void random_advance(uint64_t delta);
EXPORT uint32_t random_int(void);
EXPORT uint32_t random_rng(uint32_t bound);
EXPORT double random_float(void);

#endif
