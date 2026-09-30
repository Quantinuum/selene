#ifndef BASE_QIS_PROGRAM_CONTEXT_H
#define BASE_QIS_PROGRAM_CONTEXT_H

#include <setjmp.h>
#include <stdint.h>
#include <mimalloc.h>

#ifdef USER_PROGRAM_THREADING
#include <threads.h>
#define context_attrs thread_local
#else
#define context_attrs
#endif

typedef struct RunContext {
    jmp_buf program_end;
    uint64_t error_code;
    mi_heap_t* heap;
} RunContext;

extern context_attrs RunContext program_context;

#endif
