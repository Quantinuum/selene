from __future__ import annotations

from typing import Any


class RuntimeCTypes:
    def __init__(self, cffi: Any) -> None:
        self.runtime_instance_ptr = cffi.typeof("RuntimeInstance *")
        self.runtime_get_operation_handle = cffi.typeof("RuntimeGetOperationHandle")
        self.runtime_get_operation_handle_ptr = cffi.typeof(
            "RuntimeGetOperationHandle *"
        )
        self.runtime_get_operation_interface = cffi.typeof(
            "SeleneRuntimeGetOperationInterface"
        )
        self.runtime_get_operation_interface_ptr = cffi.typeof(
            "SeleneRuntimeGetOperationInterface *"
        )
        self.char_array = cffi.typeof("char[]")
        self.char_ptr_array = cffi.typeof("char *[]")
        self.size_ptr = cffi.typeof("size_t *")
        self.uint8_array = cffi.typeof("uint8_t[]")
        self.uint8_ptr = cffi.typeof("uint8_t *")
        self.uint64_array = cffi.typeof("uint64_t[]")
        self.uint64_ptr = cffi.typeof("uint64_t *")
        self.int8_ptr = cffi.typeof("int8_t *")
