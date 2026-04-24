#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>


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
 * pass that back to any function it calls in it's provided
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
 * pass that back to any function it calls in it's provided
 * [RuntimeGetOperationInterface].
 */
typedef void *SeleneRuntimeGetOperationInstance;

/**
 * A plugin's implementation of `selene_runtime_get_next_operations` is provided
 * a pointer to a `RuntimeGetOperationInterface` as well as a
 * [RuntimeGetOperationInstance]. It should call the functions
 * within to populate a batch. All such calls must pass the instance as the
 * first parameter.
 */
typedef struct SeleneRuntimeGetOperationInterface {
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
  void (*rzz_fn)(SeleneRuntimeGetOperationInstance,
                 uint64_t,
                 uint64_t,
                 double);
  void (*rxy_fn)(SeleneRuntimeGetOperationInstance,
                 uint64_t,
                 double,
                 double);
  void (*rz_fn)(SeleneRuntimeGetOperationInstance,
                uint64_t,
                double);
  void (*rpp_fn)(SeleneRuntimeGetOperationInstance,
                 uint64_t,
                 uint64_t,
                 double,
                 double);
  void (*tk2_fn)(SeleneRuntimeGetOperationInstance,
                 uint64_t,
                 uint64_t,
                 double,
                 double,
                 double);
} SeleneRuntimeGetOperationInterface;

typedef struct SeleneRuntimeExtractOperationInterface {
  void (*extract_fn)(SeleneRuntimeExtractOperationInstance,
                     SeleneRuntimeGetOperationInstance,
                     struct SeleneRuntimeGetOperationInterface);
} SeleneRuntimeExtractOperationInterface;

typedef void *SeleneSimulatorInstance;

typedef struct SimulatorOperationInterface {
  SeleneErrno (*exit_fn)(SeleneSimulatorInstance instance);
  SeleneErrno (*shot_start_fn)(SeleneSimulatorInstance instance,
                               uint64_t shot_id,
                               uint64_t seed);
  SeleneErrno (*shot_end_fn)(SeleneSimulatorInstance instance);
  SeleneErrno (*rxy_fn)(SeleneSimulatorInstance instance,
                        uint64_t qubit,
                        double theta,
                        double phi);
  SeleneErrno (*rz_fn)(SeleneSimulatorInstance instance,
                       uint64_t qubit,
                       double theta);
  SeleneErrno (*rzz_fn)(SeleneSimulatorInstance instance,
                        uint64_t qubit1,
                        uint64_t qubit2,
                        double theta);
  SeleneErrno (*tk2_fn)(SeleneSimulatorInstance instance,
                        uint64_t qubit1,
                        uint64_t qubit2,
                        double alpha,
                        double beta,
                        double gamma);
  SeleneErrno (*rpp_fn)(SeleneSimulatorInstance instance,
                        uint64_t qubit1,
                        uint64_t qubit2,
                        double theta,
                        double phi);
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
} SimulatorOperationInterface;

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
                                      SeleneRuntimeExtractOperationInstance batch_instance,
                                      const struct SeleneRuntimeExtractOperationInterface *batch_interface,
                                      SeleneSimulatorInstance simulator_instance,
                                      const struct SimulatorOperationInterface *simulator_interface,
                                      SeleneErrorModelSetResultInstance result_instance,
                                      const struct SeleneErrorModelSetResultInterface *result_interface);
  SeleneErrno (*get_metrics_fn)(SeleneErrorModelInstance handle,
                                uint8_t nth_metric,
                                char *out_tag_str,
                                uint8_t *out_datatype,
                                uint64_t *out_data);
} SeleneErrorModelPluginDescriptorV1;

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

typedef void *RuntimeInstance;

typedef struct SeleneRuntimePluginDescriptorV1 {
  uint64_t struct_size;
  uint64_t api_version;
  SeleneErrno (*init_fn)(RuntimeInstance *handle,
                         uint64_t n_qubits,
                         uint64_t start,
                         uint32_t argc,
                         const char *const *argv);
  SeleneErrno (*exit_fn)(RuntimeInstance handle);
  SeleneErrno (*get_next_operations_fn)(RuntimeInstance handle,
                                        SeleneRuntimeGetOperationInstance instance,
                                        const struct SeleneRuntimeGetOperationInterface *interface);
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
  SeleneErrno (*rxy_gate_fn)(RuntimeInstance handle,
                             uint64_t qubit,
                             double theta,
                             double phi);
  SeleneErrno (*rzz_gate_fn)(RuntimeInstance handle,
                             uint64_t qubit0,
                             uint64_t qubit1,
                             double theta);
  SeleneErrno (*rz_gate_fn)(RuntimeInstance handle,
                            uint64_t qubit,
                            double theta);
  SeleneErrno (*tk2_gate_fn)(RuntimeInstance handle,
                             uint64_t qubit0,
                             uint64_t qubit1,
                             double alpha,
                             double beta,
                             double gamma);
  SeleneErrno (*rpp_gate_fn)(RuntimeInstance handle,
                             uint64_t qubit0,
                             uint64_t qubit1,
                             double theta,
                             double phi);
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
} SeleneRuntimePluginDescriptorV1;
