#include <setjmp.h>
#include <base_qis/program_lifetime.h>

#ifdef USER_PROGRAM_THREADING
#define context_attrs thread_local
#else
#define context_attrs
#endif

typedef struct RunContext{
    jmp_buf program_end;
    uint64_t error_code;
} RunContext;

context_attrs RunContext program_context = {0};

struct user_program_result_t user_program_wrapper(
    user_program_t user_program,
    uint64_t arg
){
    uint32_t error_code = setjmp(program_context.program_end);
    user_program_result_t result = {0};
    if(error_code == 0){
        uint64_t program_return = user_program(arg);
        result.exited_early = false;
        result.result_or_error_code = program_return;
    }else{
        result.exited_early = true;
        result.result_or_error_code = program_context.error_code;
    }
    return result;
}

void early_exit(uint32_t error_code){
    program_context.error_code = error_code;
    longjmp(program_context.program_end, 1);
}
