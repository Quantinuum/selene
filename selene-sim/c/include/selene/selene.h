#ifndef SELENE_SIM_H
#define SELENE_SIM_H

#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>


typedef struct SeleneInstance SeleneInstance;

typedef struct selene_u64_result_t {
  uint32_t error_code;
  uint64_t value;
} selene_u64_result_t;

typedef struct selene_void_result_t {
  uint32_t error_code;
} selene_void_result_t;

typedef struct selene_string_t {
  const char *data;
  uint64_t length;
  bool owned;
} selene_string_t;

typedef struct selene_bool_result_t {
  uint32_t error_code;
  bool value;
} selene_bool_result_t;

typedef struct selene_future_result_t {
  uint32_t error_code;
  uint64_t reference;
} selene_future_result_t;

typedef struct selene_f64_result_t {
  uint32_t error_code;
  double value;
} selene_f64_result_t;

typedef struct selene_u32_result_t {
  uint32_t error_code;
  uint32_t value;
} selene_u32_result_t;

/**
 * Some runtimes have additional capabilities outside of the core API. These can be triggered
 * by a frontend by passing in opaque data blobs with an identification tag. The runtime determines
 * how it handles each tag, forming a narrow contract with the frontend about how to trigger custom
 * behaviour.
 *
 * An example of custom runtime behaviour might include configuring settings on-the-fly, or issuing
 * custom instructions pertaining to that runtime (e.g. synchronization points).
 */
struct selene_u64_result_t selene_custom_runtime_call(struct SeleneInstance *instance,
                                                      uint64_t tag,
                                                      const uint8_t *data,
                                                      uint64_t data_length);

struct selene_void_result_t selene_dump_state(struct SeleneInstance *instance,
                                              struct selene_string_t message,
                                              const uint64_t *qubits,
                                              uint64_t qubits_length);

struct selene_void_result_t selene_exit(struct SeleneInstance *instance);

/**
 * Returns the number of bytes read. This is only for use with the "internal" output stream configuration, which stores outputs
 * in an internal buffer rather than writing them directly to stdout/stderr/file/tcp, and attempted use of this function with any
 * other mode will produce an error.
 *
 * This is intended primarily for interactive use cases, where the frontend requires on-demand, unbuffered access to the output
 * stream data.
 */
struct selene_u64_result_t selene_fetch_output(struct SeleneInstance *instance,
                                               uint8_t *out_ptr,
                                               uint64_t out_max_len);

/**
 * Reads a bool future
 */
struct selene_bool_result_t selene_future_read_bool(struct SeleneInstance *instance, uint64_t r);

/**
 * Reads a u64 future
 */
struct selene_u64_result_t selene_future_read_u64(struct SeleneInstance *instance, uint64_t r);

struct selene_u64_result_t selene_get_current_shot(struct SeleneInstance *instance);

struct selene_u64_result_t selene_get_tc(struct SeleneInstance *instance);

struct selene_void_result_t selene_global_barrier(struct SeleneInstance *instance,
                                                  uint64_t sleep_time);

struct selene_void_result_t selene_load_config(struct SeleneInstance **instance,
                                               const char *config_file);

struct selene_void_result_t selene_local_barrier(struct SeleneInstance *instance,
                                                 const uint64_t *qubit_ids,
                                                 uint64_t qubit_ids_length,
                                                 uint64_t sleep_time);

/**
 * Utilities can use `selene_log_custom_call` to log their activity through
 * Selene traces.
 *
 * For example, consider a custom utility that allows the user program
 * to invoke a call to some function `foo(x: u64) -> u64`, by defining
 * it as a symbol that gets linked in when the utility is provided to
 * `selene_sim.build()`.
 *
 * If `foo` invokes an opaque call to the runtime to trigger runtime-specific
 * functionality, then a selene run with tracing enabled will log it as a normal
 * Custom call. However, if `foo` has entirely classical behaviour (e.g. it
 * calculates a SHA256 sum, or makes a HTTP request, or plays a sound, etc.)
 * then it may not interact through libselene at all, and will not get logged.
 * By calling `selene_log_utility_call` by the FFI-exposed function, the utility
 * plugin has the opportunity to log the foo call as a Custom operation, in any
 * format it chooses.
 *
 * It is recommended that a utility's python frontend provides a way to decode
 * the logged data back in a human-readable format, so that a user scanning the
 * trace can easily understand what utility functions are being called and the
 * arguments to them.
 */
struct selene_void_result_t selene_log_utility_call(struct SeleneInstance *instance,
                                                    uint64_t tag,
                                                    const uint8_t *data,
                                                    uint64_t data_length);

struct selene_void_result_t selene_on_shot_end(struct SeleneInstance *instance);

struct selene_void_result_t selene_on_shot_start(struct SeleneInstance *instance,
                                                 uint64_t shot_index);

struct selene_void_result_t selene_print_bool(struct SeleneInstance *instance,
                                              struct selene_string_t tag,
                                              bool value);

struct selene_void_result_t selene_print_bool_array(struct SeleneInstance *instance,
                                                    struct selene_string_t tag,
                                                    const bool *ptr,
                                                    uint64_t length);

struct selene_void_result_t selene_print_exit(struct SeleneInstance *instance,
                                              struct selene_string_t message,
                                              uint32_t error_code);

struct selene_void_result_t selene_print_f64(struct SeleneInstance *instance,
                                             struct selene_string_t tag,
                                             double value);

struct selene_void_result_t selene_print_f64_array(struct SeleneInstance *instance,
                                                   struct selene_string_t tag,
                                                   const double *ptr,
                                                   uint64_t length);

struct selene_void_result_t selene_print_i64(struct SeleneInstance *instance,
                                             struct selene_string_t tag,
                                             int64_t value);

struct selene_void_result_t selene_print_i64_array(struct SeleneInstance *instance,
                                                   struct selene_string_t tag,
                                                   const int64_t *ptr,
                                                   uint64_t length);

struct selene_void_result_t selene_print_panic(struct SeleneInstance *instance,
                                               struct selene_string_t message,
                                               uint32_t error_code);

struct selene_void_result_t selene_print_u64(struct SeleneInstance *instance,
                                             struct selene_string_t tag,
                                             uint64_t value);

struct selene_void_result_t selene_print_u64_array(struct SeleneInstance *instance,
                                                   struct selene_string_t tag,
                                                   const uint64_t *ptr,
                                                   uint64_t length);

struct selene_u64_result_t selene_qalloc(struct SeleneInstance *instance);

struct selene_void_result_t selene_qfree(struct SeleneInstance *instance, uint64_t q);

/**
 * Performs a lazy measurement
 */
struct selene_future_result_t selene_qubit_lazy_measure(struct SeleneInstance *instance,
                                                        uint64_t q);

/**
 * Performs a lazy measurement with leakage detection
 */
struct selene_future_result_t selene_qubit_lazy_measure_leaked(struct SeleneInstance *instance,
                                                               uint64_t q);

struct selene_bool_result_t selene_qubit_measure(struct SeleneInstance *instance, uint64_t q);

struct selene_void_result_t selene_qubit_reset(struct SeleneInstance *instance, uint64_t q);

/**
 * Advance the PRNG with a user-provided delta. As this
 * is cyclic, i64s with negative values have well defined
 * rewinding behaviour.
 *
 * Requires the PRNG to be seeded with random_seed,
 * otherwise an error will be returned.
 */
struct selene_void_result_t selene_random_advance(struct SeleneInstance *instance, uint64_t delta);

/**
 * Produces a random 32-bit float.
 *
 * Requires the PRNG to be seeded with random_seed,
 * otherwise an error will be returned.
 */
struct selene_f64_result_t selene_random_f64(struct SeleneInstance *instance);

/**
 * Seeds the PRNG with a user-provided seed.
 *
 * If PRNG already has state, it will be overwritten
 * by this call.
 */
struct selene_void_result_t selene_random_seed(struct SeleneInstance *instance, uint64_t seed);

/**
 * Produces a random 32-bit unsigned integer.
 *
 * Requires the PRNG to be seeded with random_seed,
 * otherwise an error will be returned.
 */
struct selene_u32_result_t selene_random_u32(struct SeleneInstance *instance);

/**
 * Produces a bounded random 32-bit unsigned integer.
 *
 * Requires the PRNG to be seeded with random_seed,
 * otherwise an error will be returned.
 */
struct selene_u32_result_t selene_random_u32_bounded(struct SeleneInstance *instance,
                                                     uint32_t bound);

/**
 * Decrements a refcount
 */
struct selene_void_result_t selene_refcount_decrement(struct SeleneInstance *instance, uint64_t r);

/**
 * Increments a refcount
 */
struct selene_void_result_t selene_refcount_increment(struct SeleneInstance *instance, uint64_t r);

struct selene_void_result_t selene_rxy(struct SeleneInstance *instance,
                                       uint64_t qubit_id,
                                       double theta,
                                       double phi);

struct selene_void_result_t selene_rz(struct SeleneInstance *instance,
                                      uint64_t qubit_id,
                                      double theta);

struct selene_void_result_t selene_rzz(struct SeleneInstance *instance,
                                       uint64_t qubit_id,
                                       uint64_t qubit_id2,
                                       double theta);

struct selene_void_result_t selene_set_tc(struct SeleneInstance *instance, uint64_t tc);

struct selene_u64_result_t selene_shot_count(struct SeleneInstance *instance);

/**
 * Simulates a delay by notifying the runtime of a period of inactivity. This may be used by utility plugins to
 * emulate a classical process taking some period of time, allowing the runtime to acknowledge the time spent
 * when providing timing information for subsequent batches, which in turn allows time-based noise modelling to
 * account for additional idling.
 */
struct selene_void_result_t selene_simulate_delay(struct SeleneInstance *instance,
                                                  uint64_t delay);

/**
 * Read the output stream buffer from the point of the last read, up to a maximum length, copying it into the provided pointer.
 *
 * Writes metadata to the result stream, such as event hooks (metrics, instruction logs, etc).
 * This happens upon shot end automatically, but can be triggered manually mid-shot if desired
 * by calling this function (e.g. in interactive mode)
 */
struct selene_void_result_t selene_write_metadata(struct SeleneInstance *instance);

#endif  /* SELENE_SIM_H */
