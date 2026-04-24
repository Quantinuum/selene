#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include "selene/core_types.h"


typedef struct ErrorModelAPIVersion {
  /**
   * Reserved for future use, must be 0.
   */
  uint8_t reserved;
  /**
   * Major version of the API.
   */
  uint8_t major;
  /**
   * Minor version of the API.
   */
  uint8_t minor;
  /**
   * Patch version of the API.
   */
  uint8_t patch;
} ErrorModelAPIVersion;

typedef struct SeleneSimulatorAPIVersion {
  /**
   * Reserved for future use, must be 0.
   */
  uint8_t reserved;
  /**
   * Major version of the API.
   */
  uint8_t major;
  /**
   * Minor version of the API.
   */
  uint8_t minor;
  /**
   * Patch version of the API.
   */
  uint8_t patch;
} SeleneSimulatorAPIVersion;

typedef void *SeleneSimulatorInstance;

typedef int32_t SeleneErrno;

typedef struct SeleneSimulatorPluginDescriptorV1 {
  uint64_t struct_size;
  uint64_t api_version;
  const char *(*get_name_fn)(void);
  SeleneErrno (*init_fn)(SeleneSimulatorInstance *handle,
                         uint64_t n_qubits,
                         uint32_t argc,
                         const char *const *argv);
  SeleneErrno (*exit_fn)(SeleneSimulatorInstance handle);
  SeleneErrno (*shot_start_fn)(SeleneSimulatorInstance handle,
                               uint64_t shot_id,
                               uint64_t seed);
  SeleneErrno (*shot_end_fn)(SeleneSimulatorInstance handle);
  SeleneErrno (*rxy_fn)(SeleneSimulatorInstance handle,
                        uint64_t qubit,
                        double theta,
                        double phi);
  SeleneErrno (*rz_fn)(SeleneSimulatorInstance handle,
                       uint64_t qubit0,
                       double theta);
  SeleneErrno (*rzz_fn)(SeleneSimulatorInstance handle,
                        uint64_t qubit0,
                        uint64_t qubit1,
                        double theta);
  SeleneErrno (*tk2_fn)(SeleneSimulatorInstance handle,
                        uint64_t qubit0,
                        uint64_t qubit1,
                        double alpha,
                        double beta,
                        double gamma);
  SeleneErrno (*rpp_fn)(SeleneSimulatorInstance handle,
                        uint64_t qubit0,
                        uint64_t qubit1,
                        double theta,
                        double phi);
  SeleneErrno (*measure_fn)(SeleneSimulatorInstance handle,
                            uint64_t qubit);
  SeleneErrno (*postselect_fn)(SeleneSimulatorInstance handle,
                               uint64_t qubit,
                               bool target_value);
  SeleneErrno (*reset_fn)(SeleneSimulatorInstance handle,
                          uint64_t qubit);
  SeleneErrno (*get_metrics_fn)(SeleneSimulatorInstance handle,
                                uint8_t nth_metric,
                                char *tag_out,
                                uint8_t *datatype_out,
                                uint64_t *value_out);
  SeleneErrno (*dump_state_fn)(SeleneSimulatorInstance handle,
                               const char *file,
                               const uint64_t *qubits,
                               uint64_t n_qubits);
} SeleneSimulatorPluginDescriptorV1;
