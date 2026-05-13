cmake_minimum_required(VERSION 3.12)

project(BaseQISSeleneInterface LANGUAGES C)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

find_package(Selene REQUIRED)
get_target_property(selene_include_dirs Selene::Selene INTERFACE_INCLUDE_DIRECTORIES)

set(base_name "base_qis_selene_interface")

file(GLOB_RECURSE source_files src/*.c)

function(build_base_qis_interface log_level suffix)

    set(runtime_target "${base_name}${suffix}")

    add_library(${runtime_target} SHARED ${source_files})
    set_target_properties(${runtime_target} PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        C_STANDARD 11
    )
    target_compile_definitions(${runtime_target} PRIVATE SELENE_LOG_LEVEL=${log_level} BUILDING_QIS_INTERFACE=1)
    target_include_directories(${runtime_target} PRIVATE "${selene_include_dirs}")
    target_include_directories(${runtime_target} PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
    )
    target_link_libraries(${runtime_target} PRIVATE Selene::Selene)
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

build_base_qis_interface(0 "")
build_base_qis_interface(1 "_debug")
build_base_qis_interface(2 "_diagnostic")

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
