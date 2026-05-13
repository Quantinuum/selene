#ifndef SELENE_STRING_UTILS_H
#define SELENE_STRING_UTILS_H

#include <selene/selene.h>
#include <base_qis/cl_types.h>

struct selene_string_t parse_cl_string(cl_string str);
struct selene_string_t parse_c_string(char const* str);

#endif
