# Program execution boundaries

The compiled Sol and Helios root runs through `user_program_wrapper`. With a
runtime that supplies concurrent cancellation and drain support, this boundary
ends the shot before releasing root captures. The simulator consumer remains
available while the runtime drains managed work and joins native threads.

An external backend creates each worker and calls `selene_run_worker` on that
worker. The callback receives its data and writable result pointers. The entry
installs a live thread-local setjmp frame before checking cancellation. A
cancelled entry skips the callback. Normal return and early exit share an
epilogue that retires the entered-worker count once. Build with
`USER_PROGRAM_THREADING`; do not nest execution boundaries on one thread.

The backend retains the instance, root captures and loaded code until native
creations, delayed entries and descendants are settled. A zero entered-worker
count does not prove that a created worker has entered yet. Backend drain and
native joins establish that no further entry can occur before root cleanup.

`user_program_wrapper` retains its legacy callback ABI. Legacy runtimes use the
original wrapper followed by shot end. Managed roots end the shot inside the
wrapper before root heap cleanup; no deferred heap-release API is needed.

Selene owns shot cancellation and notifies the runtime through a returning
concurrent hook. The hook wakes blocked calls without joining or taking the
lifecycle lock held during completion. Rust dispatch returns before the C-local
longjmp. Foreign frames crossed by that jump must have no live cleanup or
borrowing obligations. Temporary encoded buffers and panic messages may use
ManuallyDrop and intentionally leak on error; normal returns must release them.
