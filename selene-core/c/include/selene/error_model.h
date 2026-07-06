#ifndef SELENE_ERROR_MODEL_H
#define SELENE_ERROR_MODEL_H

#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include "selene/core_types.h"
#define SELENE_ERROR_MODEL_CURRENT_API_VERSION 0x00000200ULL

typedef struct SeleneErrorModelAPIVersion {
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
} SeleneErrorModelAPIVersion;

typedef void *SeleneErrorModelInstance;

typedef void *SeleneOperationResultInstance;

typedef struct SeleneOperationResultInterface {
  void (*set_bool_result_fn)(SeleneOperationResultInstance,
                             uint64_t,
                             bool);
  void (*set_u64_result_fn)(SeleneOperationResultInstance,
                            uint64_t,
                            uint64_t);
} SeleneOperationResultInterface;

typedef int32_t SeleneErrno;

typedef SeleneErrno (*LastErrorFn)(char *output,
                                   size_t output_len,
                                   size_t *written);

typedef const char *(*PluginNameFn)(void);

typedef struct PluginDescriptorHeaderV1 {
  uint64_t struct_size;
  uint64_t api_version;
  LastErrorFn last_error_fn;
  PluginNameFn get_name_fn;
} PluginDescriptorHeaderV1;

typedef void *SeleneRuntimeExtractOperationInstance;

/**
 * An instance is provided to `selene_runtime_get_next_operations`, which must
 * pass that back to any function it calls in its provided
 * [RuntimeGetOperationInterface].
 */
typedef void *SeleneRuntimeGetOperationInstance;

typedef struct RuntimeGetOperationInterface {
  void (*measure_fn)(SeleneRuntimeGetOperationInstance,
                     uint64_t,
                     uint64_t);
  void (*measure_leaked_fn)(SeleneRuntimeGetOperationInstance,
                            uint64_t,
                            uint64_t);
  void (*postselect_fn)(SeleneRuntimeGetOperationInstance,
                        uint64_t,
                        bool);
  void (*reset_fn)(SeleneRuntimeGetOperationInstance,
                   uint64_t);
  void (*custom_fn)(SeleneRuntimeGetOperationInstance,
                    size_t,
                    const void*,
                    size_t);
  void (*set_batch_time_fn)(SeleneRuntimeGetOperationInstance,
                            uint64_t,
                            uint64_t);
  void (*gate_fn)(SeleneRuntimeGetOperationInstance,
                  const uint8_t*,
                  size_t);
} RuntimeGetOperationInterface;

typedef struct RuntimeGetOperationHandle {
  SeleneRuntimeGetOperationInstance instance;
  struct RuntimeGetOperationInterface interface;
} RuntimeGetOperationHandle;

typedef struct SeleneRuntimeExtractOperationInterface {
  void (*extract_fn)(const struct RuntimeExtractOperationHandle*,
                     struct RuntimeGetOperationHandle);
} SeleneRuntimeExtractOperationInterface;

typedef struct RuntimeExtractOperationHandle {
  SeleneRuntimeExtractOperationInstance instance;
  struct SeleneRuntimeExtractOperationInterface interface;
} RuntimeExtractOperationHandle;

typedef void *SeleneSimulatorInstance;

typedef struct OperationResultHandle {
  SeleneOperationResultInstance instance;
  struct SeleneOperationResultInterface interface;
} OperationResultHandle;

typedef struct SimulatorOperationInterface {
  SeleneErrno (*exit_fn)(SeleneSimulatorInstance instance);
  LastErrorFn last_error_fn;
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

typedef struct SeleneErrorModelPluginDescriptorV1 {
  struct PluginDescriptorHeaderV1 header;
  SeleneErrno (*init_fn)(SeleneErrorModelInstance *handle,
                         uint64_t n_qubits,
                         uint32_t error_model_argc,
                         const char *const *error_model_argv);
  SeleneErrno (*exit_fn)(SeleneErrorModelInstance handle);
  SeleneErrno (*shot_start_fn)(SeleneErrorModelInstance handle,
                               uint64_t shot_id,
                               uint64_t error_model_seed);
  SeleneErrno (*shot_end_fn)(SeleneErrorModelInstance handle);
  SeleneErrno (*handle_operations_fn)(SeleneErrorModelInstance handle,
                                      struct RuntimeExtractOperationHandle batch,
                                      struct SimulatorHandle simulator,
                                      struct OperationResultHandle result);
  SeleneErrno (*get_metrics_fn)(SeleneErrorModelInstance handle,
                                uint8_t nth_metric,
                                char *out_tag_str,
                                uint8_t *out_datatype,
                                uint64_t *out_data);
  SeleneErrno (*negotiate_gateset_fn)(SeleneErrorModelInstance handle,
                                      const uint8_t *input,
                                      size_t input_len,
                                      uint8_t *output,
                                      size_t output_len,
                                      size_t *written);
} SeleneErrorModelPluginDescriptorV1;

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

#endif  /* SELENE_ERROR_MODEL_H */
