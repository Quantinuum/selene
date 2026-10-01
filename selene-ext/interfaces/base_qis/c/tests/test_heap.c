#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdint.h>
#include <string.h>

#ifdef __linux__
#include <sys/resource.h>
#endif

#include <base_qis/heap.h>
#include <base_qis/program_lifetime.h>

static uint32_t exit_code;
static bool exit_early;

static uint64_t allocate(uint64_t arg) {
    size_t size = 8 * 1024 * 1024;
    unsigned char* left_allocated = heap_alloc(size);
    assert(left_allocated != NULL);
    left_allocated[0] = 42;
    left_allocated[size - 1] = 17;

    // Freeing another allocation shouldn't affect the one we're keeping.
    // We also allow free(NULL), just as we did with the libc allocator.
    void* freed = heap_alloc(128);
    assert(freed != NULL);
    heap_free(freed);
    heap_free(NULL);
    heap_free(heap_alloc(0));
    assert(left_allocated[0] == 42);
    assert(left_allocated[size - 1] == 17);

    if (exit_early) {
        early_exit(exit_code);
        assert(false);
    }
    return arg;
}

static uint64_t no_allocations(uint64_t arg) {
    return arg;
}

int main(int argc, char** argv) {
    assert(argc == 2);
    exit_early = strcmp(argv[1], "normal") != 0;
    exit_code = strcmp(argv[1], "panic") == 0 ? 1001 : 0;

#ifdef __linux__
    // Across these shots we leave 1 GiB allocated, but only 8 MiB is needed
    // at a time. With a 512 MiB address-space limit, we'll run out if the
    // wrapper forgets to free a shot's allocations. This also catches using
    // mi_heap_delete, which lets outstanding allocations outlive the heap.
    struct rlimit limit;
    assert(getrlimit(RLIMIT_AS, &limit) == 0);
    rlim_t budget = (rlim_t)512 * 1024 * 1024;
    if (limit.rlim_cur == RLIM_INFINITY || limit.rlim_cur > budget) {
        limit.rlim_cur = budget;
    }
    assert(setrlimit(RLIMIT_AS, &limit) == 0);
#endif

    for (uint64_t shot = 0; shot < 128; ++shot) {
        uint64_t expected = UINT64_MAX - shot;
        user_program_result_t result = user_program_wrapper(allocate, expected);
        assert(result.exited_early == exit_early);
        assert(result.result_or_error_code == (exit_early ? exit_code : expected));

        // A shot that exits early must also leave us able to run an ordinary
        // shot afterwards, including one that doesn't allocate anything.
        result = user_program_wrapper(no_allocations, expected);
        assert(!result.exited_early);
        assert(result.result_or_error_code == expected);
    }
    return 0;
}
