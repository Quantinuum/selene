cmake_minimum_required(VERSION 3.12)

project(BaseQISSeleneInterface LANGUAGES C)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

find_package(Selene REQUIRED)
get_target_property(selene_include_dirs Selene::Selene INTERFACE_INCLUDE_DIRECTORIES)

# we provide three shared libraries with the same interface, but
# with different logging levels.

# For something to depend on the interface rather than an implementation
# (e.g. specific log level), we define an INTERFACE library that links to
# the Selene library and provides the include directories.
add_library(base_qis_selene_interface INTERFACE)
target_include_directories(base_qis_selene_interface INTERFACE
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_link_libraries(base_qis_selene_interface INTERFACE Selene::Selene)
install(TARGETS base_qis_selene_interface
        EXPORT BaseQISSeleneInterface
        RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

file(GLOB_RECURSE source_files src/*.c)
function(build_base_qis_interface log_level suffix)

    set(runtime_target "base_qis_selene_interface_logging_${suffix}")

    add_library(${runtime_target} SHARED ${source_files})
    set_target_properties(${runtime_target} PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        C_STANDARD 11
    )
    target_compile_definitions(${runtime_target} PRIVATE
        SELENE_LOG_LEVEL=${log_level}
        BUILDING_QIS_INTERFACE=1
    )
    target_link_libraries(${runtime_target} PUBLIC
        base_qis_selene_interface
    )
    if(MSVC)
        target_compile_options(${runtime_target} PRIVATE /TC /Zl)
    endif()

    install(TARGETS ${runtime_target}
            EXPORT BaseQISSeleneInterface
            RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

endfunction()

build_base_qis_interface(0 "off")
build_base_qis_interface(1 "debug")
build_base_qis_interface(2 "diagnostic")

install(DIRECTORY include/base_qis
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
install(
    EXPORT BaseQISSeleneInterface
    FILE BaseQISSeleneInterfaceTargets.cmake
    NAMESPACE BaseQISSeleneInterface::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/BaseQISSeleneInterface
)
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/BaseQISSeleneInterfaceConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/BaseQISSeleneInterfaceConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/BaseQISSeleneInterface
)
install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/BaseQISSeleneInterfaceConfig.cmake"
    DESTINATION
        ${CMAKE_INSTALL_LIBDIR}/cmake/BaseQISSeleneInterface
)
