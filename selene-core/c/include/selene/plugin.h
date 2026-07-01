#ifndef SELENE_PLUGIN_H
#define SELENE_PLUGIN_H

#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

typedef int32_t SeleneErrno;

typedef struct SelenePluginDescriptorV1 {
  uint64_t struct_size;
  uint64_t api_version;
  SeleneErrno (*last_error_fn)(char *output,
                               size_t output_len,
                               size_t *written);
  const char *(*get_name_fn)(void);
} SelenePluginDescriptorV1;

#endif /* SELENE_PLUGIN_H */
