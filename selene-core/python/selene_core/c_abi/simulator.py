from __future__ import annotations

from typing import Any


class SimulatorCTypes:
    def __init__(self, cffi: Any) -> None:
        self.simulator_instance_ptr = cffi.typeof("SeleneSimulatorInstance *")
        self.char_array = cffi.typeof("char[]")
        self.char_ptr_array = cffi.typeof("char *[]")
        self.size_ptr = cffi.typeof("size_t *")
        self.runtime_extract_operation_handle = cffi.typeof(
            "RuntimeExtractOperationHandle *"
        )
        self.operation_result_handle = cffi.typeof("OperationResultHandle *")
        self.uint8_array = cffi.typeof("uint8_t[]")
        self.uint8_ptr = cffi.typeof("uint8_t *")
        self.uint64_array = cffi.typeof("uint64_t[]")
        self.uint64_ptr = cffi.typeof("uint64_t *")
