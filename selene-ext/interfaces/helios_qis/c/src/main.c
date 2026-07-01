#include <stdint.h> // uint64_t

#include <helios_qis/interface.h> // selene_helios_run

// compiled user program entrypoint
extern uint64_t qmain(uint64_t);
extern struct selene_void_result_t selene_register_linked_utilities(SeleneInstance* instance);

int main(int argc, char** argv) {
    return selene_helios_run_with_utilities(
        argc,
        argv,
        qmain,
        selene_register_linked_utilities
    );
}
