#ifndef HELIOS_QIS_INTERFACE_H
#define HELIOS_QIS_INTERFACE_H

#include <base_qis/program_lifetime.h>
#include <base_qis/macros.h>
#include <selene/selene.h>

typedef struct selene_void_result_t (*selene_utility_registrar_t)(SeleneInstance* instance);

EXPORT int selene_helios_run(int argc, char** argv, user_program_t entrypoint);
EXPORT int selene_helios_run_with_utilities(
    int argc,
    char** argv,
    user_program_t entrypoint,
    selene_utility_registrar_t register_utilities
);

#endif
