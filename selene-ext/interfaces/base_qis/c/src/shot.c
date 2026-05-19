#include <base_qis/shot.h>

#include <selene/selene.h> // selene_get_current_shot
#include <base_qis/selene_lifetime.h> // selene_instance
#include <base_qis/unwrap.h> // unwrap

#include "logging.h" // DIAGNOSTIC

uint64_t get_current_shot() {
    DIAGNOSTIC("get_current_shot()\n");
    uint64_t result = unwrap(selene_get_current_shot(selene_instance));
    DIAGNOSTIC("   result: %" PRIu64 "\n", result);
    return result;
}
