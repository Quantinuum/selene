from __future__ import annotations

from typing import Any


class SeleneCTypes:
    def __init__(self, cffi: Any) -> None:
        self.instance_ptr = cffi.typeof("SeleneInstance *")
        self.instance_ptr_ptr = cffi.typeof("SeleneInstance **")
        self.string = cffi.typeof("selene_string_t")
        self.string_ptr = cffi.typeof("selene_string_t *")
        self.size_ptr = cffi.typeof("size_t *")
        self.uint8_array = cffi.typeof("uint8_t[]")
        self.uint64_array = cffi.typeof("uint64_t[]")
