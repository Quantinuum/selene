#include <stdint.h>

#include <helios_qis/interface.h>

// defined by hybrid user program compiler
extern uint64_t qmain(uint64_t);

int main(int argc, char** argv) {
    return selene_helios_run(argc, argv, qmain);
}
