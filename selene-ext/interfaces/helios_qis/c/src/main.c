#include <stdint.h> // uint64_t

#include <helios_qis/interface.h> // selene_helios_run

// compiled user program entrypoint
extern uint64_t qmain(uint64_t);

int main(int argc, char** argv) {
    return selene_helios_run(argc, argv, qmain);
}
