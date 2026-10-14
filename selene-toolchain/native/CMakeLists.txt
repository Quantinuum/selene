cmake_minimum_required(VERSION 3.21)
project(SeleneLLVMTools LANGUAGES C CXX)

if(WIN32 AND NOT MINGW)
    message(FATAL_ERROR "The Windows inspector requires a MinGW toolchain")
endif()

find_package(LLVM REQUIRED CONFIG)

add_executable(selene-llvm inspect.cpp)
target_compile_features(selene-llvm PRIVATE cxx_std_17)
target_include_directories(selene-llvm SYSTEM PRIVATE ${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})

if(NOT LLVM_ENABLE_RTTI)
    target_compile_options(selene-llvm PRIVATE -fno-rtti)
endif()

llvm_map_components_to_libnames(llvm_libraries Core IRReader Support)
target_link_libraries(selene-llvm PRIVATE ${llvm_libraries})
install(TARGETS selene-llvm RUNTIME DESTINATION bin)
