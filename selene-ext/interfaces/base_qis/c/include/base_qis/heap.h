#ifndef HELIOS_QIS_HEAP_H
#define HELIOS_QIS_HEAP_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <inttypes.h>

#include <base_qis/macros.h>

EXPORT void* heap_alloc(size_t size);
EXPORT void heap_free(void* ptr);

#endif
