#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include "selene/core_types.h"


#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

/**
 * The API version comprises four unsigned 8-bit integers:
 *     - reserved: 8 bits (must be 0)
 *     - major: 8 bits
 *     - minor: 8 bits
 *     - patch: 8 bits
 *
 * Selene maintains its own API version for the runtime API
 * and is updated upon changes to the API depending on how
 * breaking the changes are. Selene is also responsible for
 * validating the API version of the plugin against its own
 * version.
 *
 * The plans for this validation are a work-in-progress, but
 * currently selene will reject any plugin that has a different
 * major or minor version than the current Selene version, or with
 * a reserved field that is not 0.
 */
uint64_t selene_runtime_get_api_version(void);

const RuntimePluginDescriptorV1 *selene_runtime_get_plugin_descriptor_v1(void);

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus
