#ifndef SELENE_SIMULATOR_H
#define SELENE_SIMULATOR_H

#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include "selene/gatewire.h"
#include "selene/operation.h"
#include "selene/plugin.h"
#define SELENE_SIMULATOR_CURRENT_API_VERSION 0x00000200ULL

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

typedef struct SimulatorOperationInterface {
  SeleneErrno (*exit_fn)(SeleneSimulatorInstance instance);
  SeleneErrno (*last_error_fn)(char *output,
                               size_t output_len,
                               size_t *written);
  SeleneErrno (*shot_start_fn)(SeleneSimulatorInstance instance,
                               uint64_t shot_id,
                               uint64_t seed);
  SeleneErrno (*shot_end_fn)(SeleneSimulatorInstance instance);
  SeleneErrno (*handle_operations_fn)(SeleneSimulatorInstance instance,
                                      struct RuntimeExtractOperationHandle batch,
                                      struct OperationResultHandle result);
  SeleneErrno (*measure_fn)(SeleneSimulatorInstance instance,
                            uint64_t qubit);
  SeleneErrno (*reset_fn)(SeleneSimulatorInstance instance,
                          uint64_t qubit);
  SeleneErrno (*get_metric_fn)(SeleneSimulatorInstance instance,
                               uint8_t nth_metric,
                               char *tag_ptr,
                               uint8_t *datatype_ptr,
                               uint64_t *data_ptr);
  SeleneErrno (*dump_state_fn)(SeleneSimulatorInstance instance,
                               const char *file,
                               const uint64_t *qubits,
                               uint64_t n_qubits);
  SeleneErrno (*gate_fn)(SeleneSimulatorInstance instance,
                         const uint8_t *data,
                         size_t len);
  SeleneErrno (*negotiate_gateset_fn)(SeleneSimulatorInstance instance,
                                      const uint8_t *input,
                                      size_t input_len,
                                      uint8_t *output,
                                      size_t output_len,
                                      size_t *written);
} SimulatorOperationInterface;

typedef struct SimulatorHandle {
  SeleneSimulatorInstance instance;
  struct SimulatorOperationInterface interface;
} SimulatorHandle;

typedef struct SeleneSimulatorPluginDescriptorV1 {
  SelenePluginDescriptorV1 header;
  SeleneErrno (*init_fn)(SeleneSimulatorInstance *handle,
                         uint64_t n_qubits,
                         uint32_t argc,
                         const char *const *argv);
  SeleneErrno (*exit_fn)(SeleneSimulatorInstance handle);
  SeleneErrno (*shot_start_fn)(SeleneSimulatorInstance handle,
                               uint64_t shot_id,
                               uint64_t seed);
  SeleneErrno (*shot_end_fn)(SeleneSimulatorInstance handle);
  SeleneErrno (*handle_operations_fn)(SeleneSimulatorInstance handle,
                                      struct RuntimeExtractOperationHandle batch,
                                      struct OperationResultHandle result);
  SeleneErrno (*get_metrics_fn)(SeleneSimulatorInstance handle,
                                uint8_t nth_metric,
                                char *tag_out,
                                uint8_t *datatype_out,
                                uint64_t *value_out);
  SeleneErrno (*dump_state_fn)(SeleneSimulatorInstance handle,
                               const char *file,
                               const uint64_t *qubits,
                               uint64_t n_qubits);
  SeleneErrno (*negotiate_gateset_fn)(SeleneSimulatorInstance handle,
                                      const uint8_t *input,
                                      size_t input_len,
                                      uint8_t *output,
                                      size_t output_len,
                                      size_t *written);
} SeleneSimulatorPluginDescriptorV1;

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

extern SeleneSimulatorPluginDescriptorV1 selene_simulator_plugin_descriptor_v1;

GwStatus gw_decoded_gate_qubit_operand_count(const GwDecodedGate *gate,
                                             size_t *out);

GwStatus gw_decoded_gate_qubit_operand_at(const GwDecodedGate *gate,
                                          size_t qubit_index,
                                          uint32_t *out);

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif /* SELENE_SIMULATOR_H */
