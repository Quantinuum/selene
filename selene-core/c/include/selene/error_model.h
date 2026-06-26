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

/**
 * An instance is provided to `selene_runtime_get_next_operations`, which must
 * pass that back to any function it calls in its provided
 * [ErrorModelSetResultInterface].
 */
typedef void *SeleneErrorModelSetResultInstance;

/**
 * A plugin's implementation of `selene_runtime_get_next_operations` is provided
 * a pointer to a `ErrorModelSetResultInterface` as well as a
 * [ErrorModelSetResultInstance]. It should call the functions
 * within to populate a batch. All such calls must pass the instance as the
 * first parameter.
 */
typedef struct SeleneErrorModelSetResultInterface {
  void (*set_bool_result_fn)(SeleneErrorModelSetResultInstance,
                             uint64_t,
                             bool);
  void (*set_u64_result_fn)(SeleneErrorModelSetResultInstance,
                            uint64_t,
                            uint64_t);
} SeleneErrorModelSetResultInterface;

typedef int32_t SeleneErrno;

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
  void (*extract_fn)(struct RuntimeExtractOperationHandle,
                     struct RuntimeGetOperationHandle);
} SeleneRuntimeExtractOperationInterface;

typedef struct RuntimeExtractOperationHandle {
  SeleneRuntimeExtractOperationInstance instance;
  struct SeleneRuntimeExtractOperationInterface interface;
} RuntimeExtractOperationHandle;

typedef void *SeleneSimulatorInstance;

typedef struct SimulatorOperationInterface {
  SeleneErrno (*exit_fn)(SeleneSimulatorInstance instance);
  SeleneErrno (*shot_start_fn)(SeleneSimulatorInstance instance,
                               uint64_t shot_id,
                               uint64_t seed);
  SeleneErrno (*shot_end_fn)(SeleneSimulatorInstance instance);
  SeleneErrno (*measure_fn)(SeleneSimulatorInstance instance,
                            uint64_t qubit);
  SeleneErrno (*postselect_fn)(SeleneSimulatorInstance instance,
                               uint64_t qubit,
                               bool target_value);
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

typedef struct ErrorModelSetResultHandle {
  SeleneErrorModelSetResultInstance instance;
  struct SeleneErrorModelSetResultInterface interface;
} ErrorModelSetResultHandle;

typedef struct SeleneErrorModelPluginDescriptorV1 {
  uint64_t struct_size;
  uint64_t api_version;
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
                                      struct ErrorModelSetResultHandle result);
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
