#ifndef HELIOS_QIS_INTERFACE_H
#define HELIOS_QIS_INTERFACE_H

#include <base_qis/program_lifetime.h>
#include <base_qis/macros.h>


EXPORT int selene_helios_run(int argc, char** argv, user_program_t entrypoint);

#endif
