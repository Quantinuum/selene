from __future__ import annotations

import ctypes


Errno = ctypes.c_int32
LastErrorFn = ctypes.CFUNCTYPE(
    Errno,
    ctypes.POINTER(ctypes.c_char),
    ctypes.c_size_t,
    ctypes.POINTER(ctypes.c_size_t),
)
PluginGetNameFn = ctypes.CFUNCTYPE(ctypes.c_char_p)


class PluginDescriptorHeaderV1(ctypes.Structure):
    _fields_ = [
        ("struct_size", ctypes.c_uint64),
        ("api_version", ctypes.c_uint64),
        ("last_error_fn", LastErrorFn),
        ("get_name_fn", PluginGetNameFn),
    ]
