#ifndef SOL_QIS_INTERFACE_H
#define SOL_QIS_INTERFACE_H

#include <base_qis/program_lifetime.h>
#include <base_qis/macros.h>


EXPORT int selene_sol_run(int argc, char** argv, user_program_t entrypoint);

#endif
