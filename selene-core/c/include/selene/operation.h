#ifndef SELENE_OPERATION_H
#define SELENE_OPERATION_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

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

struct RuntimeExtractOperationHandle;
struct RuntimeGetOperationHandle;

typedef struct SeleneRuntimeExtractOperationInterface {
  void (*extract_fn)(const struct RuntimeExtractOperationHandle*,
                     struct RuntimeGetOperationHandle);
} SeleneRuntimeExtractOperationInterface;

typedef struct RuntimeExtractOperationHandle {
  SeleneRuntimeExtractOperationInstance instance;
  struct SeleneRuntimeExtractOperationInterface interface;
} RuntimeExtractOperationHandle;

typedef struct RuntimeGetOperationHandle {
  SeleneRuntimeGetOperationInstance instance;
  struct SeleneRuntimeGetOperationInterface interface;
} RuntimeGetOperationHandle;

typedef void *SeleneOperationResultInstance;

typedef struct SeleneOperationResultInterface {
  void (*set_bool_result_fn)(SeleneOperationResultInstance,
                             uint64_t,
                             bool);
  void (*set_u64_result_fn)(SeleneOperationResultInstance,
                            uint64_t,
                            uint64_t);
} SeleneOperationResultInterface;

typedef struct OperationResultHandle {
  SeleneOperationResultInstance instance;
  struct SeleneOperationResultInterface interface;
} OperationResultHandle;

#endif /* SELENE_OPERATION_H */
