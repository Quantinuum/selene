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
