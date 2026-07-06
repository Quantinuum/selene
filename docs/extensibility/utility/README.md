# Utility Plugins

Utilities are link-time extensions for compiled Selene programs. They are useful
when the user program needs ordinary classical helper symbols, such as an
argument reader, a calibration data accessor, or a logging helper.

Utilities are different from runtime, error-model, and simulator plugins:

- They are linked into the final executable by `selene_sim.build(...)`.
- They are not selected from the runtime plugin configuration.
- They do not have a descriptor.
- They may optionally register shot lifecycle callbacks after Selene has loaded
  its configuration.

## Python Shape

A utility package exposes a Python class derived from `selene_core.Utility`:

```python
from pathlib import Path
from selene_core import Utility

class MyUtility(Utility):
    @property
    def library_file(self) -> Path:
        return Path(__file__).parent / "_dist/lib/libmy_utility.so"

    @property
    def library_search_dirs(self) -> list[Path]:
        return [self.library_file.parent]

    @property
    def registration_symbol(self) -> str | None:
        return "my_utility_register"
```

Pass utilities to the build step:

```python
from selene_sim.build import build

instance = build(program, utilities=[MyUtility()])
```

Selene generates a small C object in an artifact subdirectory that calls each
registration symbol once after `selene_load_config(...)` succeeds.

## Registration Function

A registration symbol has this C signature:

```c
struct selene_void_result_t my_utility_register(SeleneInstance *instance);
```

It can call `selene_register_utility_event_callbacks(...)` directly, or, when
the utility links against the Base QIS helper library, call the wrapper
`register_utility_event_callbacks(...)` from `base_qis/hooks.h`.

The callback struct supports:

- `on_shot_start(context, shot_id)`;
- `on_shot_end(context, shot_id)`.

Both callbacks return `struct selene_void_result_t`. A nonzero error code aborts
the current run with a utility callback error.

## Link-Time Boundaries

On macOS and Windows, unresolved symbols in a utility shared library generally
fail at link time. If a utility calls Base QIS helper symbols such as
`panic_str`, `log_utility_call`, or `register_utility_event_callbacks`, link it
against the Base QIS library and provide the correct library search directory in
the Python `Utility` class.

If a utility emits quantum gates, it should not invent private gate entrypoints.
Use the same gateset registration and `selene_gate(...)` path as a QIS
interface.
