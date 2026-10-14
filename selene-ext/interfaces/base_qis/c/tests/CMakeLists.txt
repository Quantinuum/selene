foreach(suffix off debug diagnostic)
    add_executable(test_heap_${suffix} test_heap.c)
    target_link_libraries(test_heap_${suffix} PRIVATE
        base_qis_selene_interface_logging_${suffix}
    )
    foreach(exit_mode normal early panic)
        add_test(NAME heap_${suffix}_${exit_mode}
            COMMAND test_heap_${suffix} ${exit_mode}
        )
    endforeach()
endforeach()

if(UNIX)
    find_package(Threads REQUIRED)
    foreach(suffix off debug diagnostic)
        add_executable(test_local_exit_${suffix} test_local_exit.c)
        target_link_libraries(test_local_exit_${suffix} PRIVATE
            base_qis_selene_interface_logging_${suffix} Threads::Threads
        )
        set_target_properties(test_local_exit_${suffix} PROPERTIES ENABLE_EXPORTS ON)
        add_test(NAME local_exit_${suffix} COMMAND test_local_exit_${suffix})
        set_tests_properties(local_exit_${suffix} PROPERTIES TIMEOUT 20)
        add_executable(test_run_worker_${suffix} test_run_worker.c)
        target_link_libraries(test_run_worker_${suffix} PRIVATE
            base_qis_selene_interface_logging_${suffix} Threads::Threads)
        set_target_properties(test_run_worker_${suffix} PROPERTIES ENABLE_EXPORTS ON)
        add_test(NAME run_worker_${suffix} COMMAND test_run_worker_${suffix})
        set_tests_properties(run_worker_${suffix} PROPERTIES TIMEOUT 20)
        add_executable(test_worker_heap_${suffix} test_worker_heap.c)
        target_link_libraries(test_worker_heap_${suffix} PRIVATE
            base_qis_selene_interface_logging_${suffix} Threads::Threads
        )
        set_target_properties(test_worker_heap_${suffix} PROPERTIES ENABLE_EXPORTS ON)
        add_test(NAME worker_heap_${suffix} COMMAND test_worker_heap_${suffix})
        set_tests_properties(worker_heap_${suffix} PROPERTIES TIMEOUT 20)
    endforeach()
endif()
