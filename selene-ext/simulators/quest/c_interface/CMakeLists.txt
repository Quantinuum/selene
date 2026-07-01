cmake_minimum_required(VERSION 3.21)
project(SeleneQuestCInterface LANGUAGES C CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(FetchContent)

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(ENABLE_TESTING OFF CACHE BOOL "" FORCE)
set(ENABLE_MULTITHREADING OFF CACHE BOOL "" FORCE)
set(ENABLE_DISTRIBUTION OFF CACHE BOOL "" FORCE)
set(ENABLE_CUDA OFF CACHE BOOL "" FORCE)
set(ENABLE_CUQUANTUM OFF CACHE BOOL "" FORCE)
set(ENABLE_HIP OFF CACHE BOOL "" FORCE)
set(ENABLE_DEPRECATED_API OFF CACHE BOOL "" FORCE)
set(FLOAT_PRECISION 2 CACHE STRING "" FORCE)

FetchContent_Declare(
    quest
    GIT_REPOSITORY https://github.com/QuEST-Kit/QuEST.git
    GIT_TAG 9d7618d7263e3bfba433b88cf1eac0647f08fa0a
    EXCLUDE_FROM_ALL
)
FetchContent_MakeAvailable(quest)

add_library(selene_quest_c_interface STATIC
    src/c_interface.cpp
)

target_include_directories(selene_quest_c_interface PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_link_libraries(selene_quest_c_interface PRIVATE QuEST::QuEST)

install(TARGETS selene_quest_c_interface
        EXPORT SeleneQuestCInterfaceTargets
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        RUNTIME DESTINATION bin
        INCLUDES DESTINATION include
)

install(DIRECTORY include/selene_quest_c_interface
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT SeleneQuestCInterfaceTargets
        FILE SeleneQuestCInterfaceTargets.cmake
        NAMESPACE SeleneQuest::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/SeleneQuestCInterface
)

configure_package_config_file(
    cmake/SeleneQuestCInterfaceConfig.cmake.in
    "${CMAKE_CURRENT_BINARY_DIR}/SeleneQuestCInterfaceConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/SeleneQuestCInterface
)

install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/SeleneQuestCInterfaceConfig.cmake"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/SeleneQuestCInterface
)
