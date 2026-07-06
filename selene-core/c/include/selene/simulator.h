#ifndef SELENE_SIMULATOR_H
#define SELENE_SIMULATOR_H

#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include "selene/core_types.h"
#define SELENE_SIMULATOR_CURRENT_API_VERSION 0x00000101ULL

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

typedef void *RuntimeExtractOperationInstance;

/**
 * An instance is provided to `selene_runtime_get_next_operations`, which must
 * pass that back to any function it calls in its provided
 * [RuntimeGetOperationInterface].
 */
typedef void *RuntimeGetOperationInstance;

typedef struct RuntimeGetOperationInterface {
  void (*measure_fn)(RuntimeGetOperationInstance,
                     uint64_t,
                     uint64_t);
  void (*measure_leaked_fn)(RuntimeGetOperationInstance,
                            uint64_t,
                            uint64_t);
  void (*postselect_fn)(RuntimeGetOperationInstance,
                        uint64_t,
                        bool);
  void (*reset_fn)(RuntimeGetOperationInstance,
                   uint64_t);
  void (*custom_fn)(RuntimeGetOperationInstance,
                    size_t,
                    const void*,
                    size_t);
  void (*set_batch_time_fn)(RuntimeGetOperationInstance,
                            uint64_t,
                            uint64_t);
  void (*gate_fn)(RuntimeGetOperationInstance,
                  const uint8_t*,
                  size_t);
} RuntimeGetOperationInterface;

typedef struct RuntimeGetOperationHandle {
  RuntimeGetOperationInstance instance;
  struct RuntimeGetOperationInterface interface;
} RuntimeGetOperationHandle;

typedef struct RuntimeExtractOperationInterface {
  void (*extract_fn)(const struct RuntimeExtractOperationHandle*,
                     struct RuntimeGetOperationHandle);
} RuntimeExtractOperationInterface;

typedef struct RuntimeExtractOperationHandle {
  RuntimeExtractOperationInstance instance;
  struct RuntimeExtractOperationInterface interface;
} RuntimeExtractOperationHandle;

typedef void *OperationResultInstance;

typedef struct OperationResultInterface {
  void (*set_bool_result_fn)(OperationResultInstance,
                             uint64_t,
                             bool);
  void (*set_u64_result_fn)(OperationResultInstance,
                            uint64_t,
                            uint64_t);
} OperationResultInterface;

typedef struct OperationResultHandle {
  OperationResultInstance instance;
  struct OperationResultInterface interface;
} OperationResultHandle;

typedef struct SeleneSimulatorPluginDescriptorV1 {
  struct PluginDescriptorHeaderV1 header;
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

GwStatus gw_decoded_gate_qubit_operand_count(const GwDecodedGate *gate,
                                             size_t *out);

GwStatus gw_decoded_gate_qubit_operand_at(const GwDecodedGate *gate,
                                          size_t qubit_index,
                                          uint32_t *out);

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif  /* SELENE_SIMULATOR_H */
