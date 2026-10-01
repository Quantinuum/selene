#include <base_qis/program_lifetime.h>

#include "program_context.h"

context_attrs RunContext program_context = {0};

struct user_program_result_t user_program_wrapper(
    user_program_t user_program,
    uint64_t arg
){
    program_context.heap = mi_heap_new();
    int jump_code = setjmp(program_context.program_end);
    user_program_result_t result = {0};
    if(jump_code == 0){
        uint64_t program_return = user_program(arg);
        result.exited_early = false;
        result.result_or_error_code = program_return;
    }else{
        result.exited_early = true;
        result.result_or_error_code = program_context.error_code;
    }
    // Free anything the user program left allocated on their heap
    if (program_context.heap != NULL) {
        mi_heap_destroy(program_context.heap);
        program_context.heap = NULL;
    }
    return result;
}

void early_exit(uint32_t error_code){
    program_context.error_code = error_code;
    longjmp(program_context.program_end, 1);
}
