#ifndef SELENE_ERROR_MODEL_H
#define SELENE_ERROR_MODEL_H

#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include "selene/gatewire.h"
#include "selene/operation.h"
#include "selene/plugin.h"
#include "selene/runtime.h"
#include "selene/simulator.h"
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

typedef struct SeleneErrorModelPluginDescriptorV1 {
  SelenePluginDescriptorV1 header;
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

#endif /* SELENE_ERROR_MODEL_H */
