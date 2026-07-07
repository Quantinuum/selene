#define _GNU_SOURCE

#include <base_qis/gate_metadata.h>

#include <stdbool.h>
#include <stdint.h>
#include <string.h>

#if defined(_WIN32)
#include <windows.h>
#define QIS_THREAD_LOCAL __declspec(thread)
#elif defined(__APPLE__) || defined(__unix__)
#include <dlfcn.h>
#define QIS_THREAD_LOCAL _Thread_local
#else
#define QIS_THREAD_LOCAL
#endif

typedef struct {
    const char* path;
    uintptr_t offset;
    bool has_module;
} QisModuleInfo;

static GwGateMetadata u64_metadata(const char* key, uint64_t value) {
    GwGateMetadata metadata = {
        .abi_size = sizeof(GwGateMetadata),
        .key_ptr = key,
        .key_len = strlen(key),
        .value_kind = GW_METADATA_VALUE_KIND_U64,
        .data.u64_value = value,
        .bytes_ptr = NULL,
        .bytes_len = 0,
    };
    return metadata;
}

static GwGateMetadata string_metadata(const char* key, const char* value) {
    GwGateMetadata metadata = {
        .abi_size = sizeof(GwGateMetadata),
        .key_ptr = key,
        .key_len = strlen(key),
        .value_kind = GW_METADATA_VALUE_KIND_STRING,
        .data.u64_value = 0,
        .bytes_ptr = (const uint8_t*)value,
        .bytes_len = strlen(value),
    };
    return metadata;
}

static QisModuleInfo module_info(void* return_address) {
    QisModuleInfo result = {
        .path = NULL,
        .offset = 0,
        .has_module = false,
    };

#if defined(_WIN32)
    HMODULE module = NULL;
    if (GetModuleHandleExA(
            GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
            (LPCSTR)return_address,
            &module
        )) {
        static QIS_THREAD_LOCAL char path[MAX_PATH];
        DWORD len = GetModuleFileNameA(module, path, (DWORD)sizeof(path));
        if (len > 0 && len < sizeof(path)) {
            result.path = path;
            result.offset = (uintptr_t)return_address - (uintptr_t)module;
            result.has_module = true;
        }
    }
#elif defined(__APPLE__) || defined(__unix__)
    Dl_info info;
    if (dladdr(return_address, &info) != 0 && info.dli_fbase != NULL) {
        result.path = info.dli_fname;
        result.offset = (uintptr_t)return_address - (uintptr_t)info.dli_fbase;
        result.has_module = true;
    }
#else
    (void)return_address;
#endif

    return result;
}

size_t qis_capture_gate_metadata(void* return_address, GwGateMetadata* out, size_t out_len) {
    size_t len = 0;
    if (out == NULL || out_len == 0) {
        return 0;
    }

    out[len++] = u64_metadata(
        "qis.call_site.return_address", (uint64_t)(uintptr_t)return_address
    );
    if (len == out_len) {
        return len;
    }

    QisModuleInfo module = module_info(return_address);
    if (module.has_module) {
        out[len++] = u64_metadata("qis.call_site.module_offset", (uint64_t)module.offset);
        if (len == out_len) {
            return len;
        }
        if (module.path != NULL) {
            out[len++] = string_metadata("qis.call_site.module", module.path);
            if (len == out_len) {
                return len;
            }
        }
    }

    out[len++] = string_metadata("qis.symbolization", "return-address-v1");
    return len;
}
