#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdint.h>
#include <string.h>
#include <pthread.h>
#include <base_qis/hooks.h>
#include <base_qis/panic.h>
#include <base_qis/program_lifetime.h>
#include <selene/selene.h>

static _Thread_local uint32_t transport_error;
static _Thread_local uint32_t report_error;
static _Thread_local bool returned;

// Controlled Selene responses exercise the C transport itself, including errors.
struct selene_u64_result_t selene_custom_runtime_call(
    struct SeleneInstance* instance, uint64_t tag, const uint8_t* data, uint64_t len) {
    (void)instance;
    assert(tag == 42 && len == 4 && memcmp(data, "test", 4) == 0);
    return (struct selene_u64_result_t){transport_error, 99};
}
struct selene_void_result_t selene_print_panic(
    struct SeleneInstance* instance, struct selene_string_t message, uint32_t code) {
    (void)instance;
    assert(code == 1001 && !message.owned);
    assert(message.length == 4 && memcmp(message.data, "test", 4) == 0);
    return (struct selene_void_result_t){report_error};
}
static uint64_t callback(uint64_t error) {
    transport_error = (uint32_t)error;
    uint64_t value = 123;
    uint32_t status = custom_runtime_call_fallible(42, "test", 4, &value);
    assert(status == error && value == (error == 0 ? 99 : 0));
    report_error = (uint32_t)error;
    assert(panic_str_fallible(1001, "test") == (error == 0 ? 1001 : error));
    // Ownership scopes can finish here before an explicit non-local exit.
    returned = true;
    if (status != 0) early_exit(status);
    return value;
}
static uint64_t legacy_callback(uint64_t code) {
    transport_error = (uint32_t)code;
    uint64_t value = custom_runtime_call(42, "test", 4);
    returned = true;
    return value;
}
static void* worker(void* argument) {
    uint64_t code = (uint64_t)(uintptr_t)argument;
    for (unsigned i = 0; i != 32; ++i) {
        returned = false;
        user_program_result_t result = user_program_wrapper(legacy_callback, code);
        assert(!returned && result.exited_early && result.result_or_error_code == code);
        result = user_program_wrapper(callback, code);
        assert(returned && result.exited_early && result.result_or_error_code == code);
        returned = false;
        result = user_program_wrapper(callback, 0);
        assert(returned && !result.exited_early && result.result_or_error_code == 99);
    }
    return NULL;
}
int main(void) {
    pthread_t left, right;
    assert(pthread_create(&left, NULL, worker, (void*)(uintptr_t)17) == 0);
    assert(pthread_create(&right, NULL, worker, (void*)(uintptr_t)29) == 0);
    assert(pthread_join(left, NULL) == 0 && pthread_join(right, NULL) == 0);
    return 0;
}
