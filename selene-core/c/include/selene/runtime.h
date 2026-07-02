#ifndef SELENE_RUNTIME_H
#define SELENE_RUNTIME_H

#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include "selene/core_types.h"
#define SELENE_RUNTIME_CURRENT_API_VERSION 0x00000300ULL

typedef struct SeleneRuntimeAPIVersion {
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
} SeleneRuntimeAPIVersion;

/**
 * An instance is provided to `selene_runtime_get_next_operations`, which must
 * pass that back to any function it calls in its provided
 * [RuntimeGetOperationInterface].
 */
typedef void *SeleneRuntimeGetOperationInstance;

typedef struct SeleneRuntimeGetOperationInterface {
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
} SeleneRuntimeGetOperationInterface;

typedef void *SeleneRuntimeExtractOperationInstance;

typedef struct RuntimeExtractOperationHandle {
  SeleneRuntimeExtractOperationInstance instance;
  struct SeleneRuntimeExtractOperationInterface interface;
} RuntimeExtractOperationHandle;

typedef struct RuntimeGetOperationHandle {
  SeleneRuntimeGetOperationInstance instance;
  struct SeleneRuntimeGetOperationInterface interface;
} RuntimeGetOperationHandle;

typedef struct SeleneRuntimeExtractOperationInterface {
  void (*extract_fn)(const struct RuntimeExtractOperationHandle*,
                     struct RuntimeGetOperationHandle);
} SeleneRuntimeExtractOperationInterface;

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

typedef void *RuntimeInstance;

typedef struct SeleneRuntimePluginDescriptorV1 {
  struct PluginDescriptorHeaderV1 header;
  SeleneErrno (*init_fn)(RuntimeInstance *handle,
                         uint64_t n_qubits,
                         uint64_t start,
                         uint32_t argc,
                         const char *const *argv);
  SeleneErrno (*exit_fn)(RuntimeInstance handle);
  SeleneErrno (*get_next_operations_fn)(RuntimeInstance handle,
                                        struct RuntimeGetOperationHandle ops);
  SeleneErrno (*shot_start_fn)(RuntimeInstance handle,
                               uint64_t shot_id,
                               uint64_t seed);
  SeleneErrno (*shot_end_fn)(RuntimeInstance handle);
  int32_t (*get_metrics_fn)(RuntimeInstance handle,
                            uint8_t nth_metric,
                            char *tag_out,
                            uint8_t *datatype_out,
                            uint64_t *value_out);
  SeleneErrno (*qalloc_fn)(RuntimeInstance handle,
                           uint64_t *qaddress_out);
  SeleneErrno (*qfree_fn)(RuntimeInstance handle,
                          uint64_t qaddress);
  SeleneErrno (*local_barrier_fn)(RuntimeInstance handle,
                                  const uint64_t *qubits,
                                  uint64_t qubits_len,
                                  uint64_t sleep_ns);
  SeleneErrno (*global_barrier_fn)(RuntimeInstance handle,
                                   uint64_t sleep_ns);
  SeleneErrno (*measure_fn)(RuntimeInstance handle,
                            uint64_t qubit,
                            uint64_t *result_id);
  SeleneErrno (*measure_leaked_fn)(RuntimeInstance handle,
                                   uint64_t qubit,
                                   uint64_t *result_id);
  SeleneErrno (*reset_fn)(RuntimeInstance handle,
                          uint64_t qubit);
  SeleneErrno (*force_result_fn)(RuntimeInstance handle,
                                 uint64_t result_id);
  SeleneErrno (*get_bool_result_fn)(RuntimeInstance handle,
                                    uint64_t id,
                                    int8_t *result);
  SeleneErrno (*get_u64_result_fn)(RuntimeInstance handle,
                                   uint64_t id,
                                   uint64_t *result);
  SeleneErrno (*set_bool_result_fn)(RuntimeInstance handle,
                                    uint64_t result_id,
                                    bool result);
  SeleneErrno (*set_u64_result_fn)(RuntimeInstance handle,
                                   uint64_t result_id,
                                   uint64_t result);
  SeleneErrno (*increment_future_refcount_fn)(RuntimeInstance handle,
                                              uint64_t result_id);
  SeleneErrno (*decrement_future_refcount_fn)(RuntimeInstance handle,
                                              uint64_t result_id);
  SeleneErrno (*custom_call_fn)(RuntimeInstance handle,
                                uint64_t tag,
                                const void *data,
                                size_t data_len,
                                uint64_t *result);
  SeleneErrno (*simulate_delay_fn)(RuntimeInstance handle,
                                   uint64_t delay_ns);
  SeleneErrno (*gate_fn)(RuntimeInstance handle,
                         const uint8_t *data,
                         size_t len);
  SeleneErrno (*negotiate_gateset_fn)(RuntimeInstance handle,
                                      const uint8_t *input,
                                      size_t input_len,
                                      uint8_t *output,
                                      size_t output_len,
                                      size_t *written);
} SeleneRuntimePluginDescriptorV1;

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

#endif  /* SELENE_RUNTIME_H */
