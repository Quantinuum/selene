#ifndef BASE_QIS_PROGRAM_CONTEXT_H
#define BASE_QIS_PROGRAM_CONTEXT_H

#include <setjmp.h>
#include <stdint.h>
#include <mimalloc.h>

#ifdef USER_PROGRAM_THREADING
#if defined(_MSC_VER)
#define context_attrs __declspec(thread)
#else
#define context_attrs _Thread_local
#endif
#else
#define context_attrs
#endif

typedef struct RunContext {
    jmp_buf program_end;
    uint64_t error_code;
    mi_heap_t* heap;
    mi_heap_t* retired_root_heap;
} RunContext;

extern context_attrs RunContext program_context;

#endif
