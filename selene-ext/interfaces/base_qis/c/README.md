# Program boundaries and fallible transport

`user_program_root_wrapper` installs the root program boundary. Each native worker
calls `user_program_wrapper` on its own thread. Builds use `USER_PROGRAM_THREADING`
so the exit frame and heap are thread-local. The wrapper returns the program result
or the error supplied to `early_exit`; callers must keep frames bypassed by an exit
free of resources that require cleanup. Root capture storage remains live until the
runtime has joined workers and calls `user_program_release_root_heap`.

`custom_runtime_call_fallible` sends borrowed data synchronously and returns an error
code without calling `early_exit`. Its writable output pointer receives the runtime
value on success and zero on error. Foreign code can release encoded buffers and
other owned values after the function returns, then propagate a nonzero code through
`early_exit` from a frame that has no remaining cleanup obligations.

`panic_str_fallible` reports a borrowed message without exiting or retaining it. It
returns the requested panic code on successful reporting, or the reporting error
when reporting fails. Release message storage before calling `early_exit` with that
code. The existing `custom_runtime_call`, `panic`, and `panic_str` functions retain
their immediate-exit behavior; neither fallible helper installs a nested boundary.
