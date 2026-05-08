cmake_minimum_required(VERSION 3.12)

project(HeliosSeleneInterface LANGUAGES C)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

find_package(Selene REQUIRED)
get_target_property(selene_include_dirs Selene::Selene INTERFACE_INCLUDE_DIRECTORIES)

set(base_name "helios_selene_interface")

function(build_helios_interface log_level suffix)

    set(runtime_target "${base_name}_runtime${suffix}")
    set(launcher_target "${base_name}_launcher${suffix}")

    add_library(${runtime_target} SHARED src/interface.c)
    set_target_properties(${runtime_target} PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        C_STANDARD 11
    )
    target_compile_definitions(${runtime_target} PRIVATE SELENE_LOG_LEVEL=${log_level})
    target_include_directories(${runtime_target} PRIVATE "${selene_include_dirs}")
    target_include_directories(${runtime_target} PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
    )
    target_link_libraries(${runtime_target} PRIVATE Selene::Selene)
    if(MSVC)
        target_compile_options(${runtime_target} PRIVATE /TC /Zl)
    endif()

    add_library(${launcher_target} STATIC src/main.c)
    set_target_properties(${launcher_target} PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        C_STANDARD 11
    )
    target_include_directories(${launcher_target} PRIVATE "${selene_include_dirs}")
    target_include_directories(${launcher_target} PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
    )
    target_link_libraries(${launcher_target} PUBLIC ${runtime_target})
    if(MSVC)
        target_compile_options(${launcher_target} PRIVATE /TC /Zl)
    endif()

    install(TARGETS ${runtime_target} ${launcher_target}
            EXPORT HeliosSeleneInterface
            RUNTIME DESTINATION lib
            LIBRARY DESTINATION lib
            ARCHIVE DESTINATION lib
            INCLUDES DESTINATION include
    )

endfunction()

build_helios_interface(0 "")
build_helios_interface(1 "_debug")
build_helios_interface(2 "_diagnostic")

install(DIRECTORY include/helios_qis
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
install(
    EXPORT HeliosSeleneInterface
    FILE HeliosSeleneInterfaceTargets.cmake
    NAMESPACE HeliosSeleneInterface::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/HeliosSeleneInterface
)
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/HeliosSeleneInterfaceConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/HeliosSeleneInterfaceConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/HeliosSeleneInterface
)
install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/HeliosSeleneInterfaceConfig.cmake"
    DESTINATION
        ${CMAKE_INSTALL_LIBDIR}/cmake/HeliosSeleneInterface
)
