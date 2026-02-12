cmake_minimum_required(VERSION 3.13)
project(SeleneStimCInterface LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(FetchContent)

FetchContent_Declare(
    libstim
    GIT_REPOSITORY https://github.com/quantumlib/stim.git
    GIT_TAG f566b83c5da89ab94d7280178e2bd642350180c3
    EXCLUDE_FROM_ALL
)
FetchContent_MakeAvailable(libstim)

add_library(selene_stim_c_interface STATIC
    src/c_interface.cpp
    # Although these are built as part of libstim.a, they appear as undefined
    # symbols in the final archive. As a workaround, we explicitly include
    # them here.
    ${libstim_SOURCE_DIR}/src/stim/mem/bit_ref.cc
    ${libstim_SOURCE_DIR}/src/stim/mem/simd_util.cc
)
target_include_directories(selene_stim_c_interface PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
    ${libstim_SOURCE_DIR}/src
)
target_link_libraries(selene_stim_c_interface PRIVATE libstim)

install(TARGETS selene_stim_c_interface
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        RUNTIME DESTINATION bin
        INCLUDES DESTINATION include
)

install(DIRECTORY include/selene_stim_c_interface
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
