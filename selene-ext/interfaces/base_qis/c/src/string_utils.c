#include <string.h>
#include <base_qis/string_utils.h>

struct selene_string_t parse_cl_string(cl_string str) {
    uint8_t length = str[0];
    char const* contents = str + 1;
    return (struct selene_string_t){contents, length, false};
}

struct selene_string_t parse_c_string(char const* str) {
    if (str == 0) {
        str = "NULL";
    }
    return (struct selene_string_t){str, strlen(str), false};
}
