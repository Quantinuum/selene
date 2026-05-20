cmake_minimum_required(VERSION 3.12)

project(HeliosSeleneInterface LANGUAGES C)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

find_package(Selene REQUIRED)
find_package(BaseQISSeleneInterface REQUIRED)
get_target_property(selene_include_dirs Selene::Selene INTERFACE_INCLUDE_DIRECTORIES)


add_library(helios_qis_selene_interface INTERFACE)
target_include_directories(helios_qis_selene_interface INTERFACE
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
install(TARGETS helios_qis_selene_interface
        EXPORT HeliosSeleneInterface
        RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

add_library(helios_qis_selene_runner STATIC src/main.c)
set_target_properties(helios_qis_selene_runner PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    C_STANDARD 11
)
target_include_directories(helios_qis_selene_runner PRIVATE "${selene_include_dirs}")
target_include_directories(helios_qis_selene_runner PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_link_libraries(helios_qis_selene_runner PUBLIC BaseQISSeleneInterface::base_qis_selene_interface)
target_link_libraries(helios_qis_selene_runner PUBLIC helios_qis_selene_interface)
if(MSVC)
    target_compile_options(helios_qis_selene_runner PRIVATE /TC /Zl)
endif()

install(TARGETS helios_qis_selene_runner
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

function(build_helios_interface log_level suffix)
    set(interface_target "helios_qis_selene_interface_logging_${suffix}")

    add_library(${interface_target} SHARED src/interface.c src/helios_ops.c)
    set_target_properties(${interface_target} PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        C_STANDARD 11
    )
    target_compile_definitions(${interface_target} PRIVATE
        SELENE_LOG_LEVEL=${log_level}
        BUILDING_QIS_INTERFACE=1
    )
    target_link_libraries(${interface_target} PRIVATE helios_qis_selene_interface)
    target_include_directories(${interface_target} PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
    )
    target_link_libraries(${interface_target} PRIVATE Selene::Selene)
    target_link_libraries(${interface_target} PUBLIC BaseQISSeleneInterface::base_qis_selene_interface_logging_${suffix})
    if(MSVC)
        target_compile_options(${interface_target} PRIVATE /TC /Zl)
    endif()


    install(TARGETS ${interface_target}
            EXPORT HeliosSeleneInterface
            RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

endfunction()

build_helios_interface(0 "off")
build_helios_interface(1 "debug")
build_helios_interface(2 "diagnostic")

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
