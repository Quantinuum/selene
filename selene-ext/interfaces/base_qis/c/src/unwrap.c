#include <base_qis/unwrap.h>

#include <selene/selene.h> // selene_T_result_t structs
#include <base_qis/program_lifetime.h> // early_exit

uint64_t unwrap_u64(struct selene_u64_result_t result){
    if (result.error_code != 0) {
        early_exit(result.error_code);
    }
    return result.value;
}
uint32_t unwrap_u32(struct selene_u32_result_t result){
    if (result.error_code != 0) {
        early_exit(result.error_code);
    }
    return result.value;
}
double unwrap_f64(struct selene_f64_result_t result){
    if (result.error_code != 0) {
        early_exit(result.error_code);
    }
    return result.value;
}
void unwrap_void(struct selene_void_result_t result){
    if (result.error_code != 0) {
        early_exit(result.error_code);
    }
}
bool unwrap_bool(struct selene_bool_result_t result){
    if (result.error_code != 0) {
        early_exit(result.error_code);
    }
    return result.value;
}
uint64_t unwrap_future(struct selene_future_result_t result){
    if (result.error_code != 0) {
        early_exit(result.error_code);
    }
    return result.reference;
}
