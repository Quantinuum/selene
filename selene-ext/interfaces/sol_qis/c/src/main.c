#include <stdint.h> // uint64_t

#include <sol_qis/interface.h> // selene_sol_run

// compiled user program entrypoint
extern uint64_t qmain(uint64_t);

int main(int argc, char** argv) {
    return selene_sol_run(argc, argv, qmain);
}
