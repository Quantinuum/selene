#include <base_qis/random.h>

#include <selene/selene.h> // selene_random_ functions
#include <base_qis/selene_lifetime.h> // selene_instance
#include <base_qis/unwrap.h> // unwrap

#include "logging.h" // DIAGNOSTIC

void random_seed(uint64_t seed) {
    DIAGNOSTIC("random_seed(%" PRIu64 ")\n", seed);
    unwrap(selene_random_seed(selene_instance, seed));
    DIAGNOSTIC("   [done]\n");
}
void random_advance(uint64_t delta) {
    DIAGNOSTIC("random_advance(%" PRIu64 ")\n", delta);
    unwrap(selene_random_advance(selene_instance, delta));
    DIAGNOSTIC("   [done]\n");
}
uint32_t random_int() {
    DIAGNOSTIC("random_int()\n");
    uint32_t result = unwrap(selene_random_u32(selene_instance));
    DIAGNOSTIC("   result: %" PRIu32 "\n", (uint32_t)result);
    return result;
}
uint32_t random_rng(uint32_t bound) {
    DIAGNOSTIC("random_rng(%d)\n", bound);
    uint32_t result = unwrap(selene_random_u32_bounded(selene_instance, bound));
    DIAGNOSTIC("   result: %" PRIu32 "\n", (uint32_t)result);
    return result;
}
double random_float() {
    DIAGNOSTIC("random_float()\n");
    double result = unwrap(selene_random_f64(selene_instance));
    DIAGNOSTIC("   result: %f\n", result);
    return result;
}
