cmake_minimum_required(VERSION 3.20)

project(selene_example_clifford_t_qrack LANGUAGES CXX)

include(ExternalProject)
include(GNUInstallDirs)

find_package(Threads REQUIRED)

set(QRACK_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/qrack-install)
set(QRACK_LIBRARY
  ${QRACK_INSTALL_DIR}/${CMAKE_INSTALL_LIBDIR}/qrack/${CMAKE_STATIC_LIBRARY_PREFIX}qrack${CMAKE_STATIC_LIBRARY_SUFFIX}
)

ExternalProject_Add(qrack_external
  GIT_REPOSITORY https://github.com/vm6502q/qrack.git
  GIT_TAG vm6502q.v10.10.0
  CMAKE_ARGS
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX=${QRACK_INSTALL_DIR}
    -DENABLE_EXAMPLES=OFF
    -DENABLE_TESTS=OFF
    -DENABLE_OPENCL=OFF
    -DENABLE_CUDA=OFF
    -DENABLE_QBDT=OFF
  BUILD_BYPRODUCTS ${QRACK_LIBRARY}
)

file(MAKE_DIRECTORY
  ${QRACK_INSTALL_DIR}/include/qrack
  ${QRACK_INSTALL_DIR}/include/qrack/common
)

add_library(qrack::qrack STATIC IMPORTED GLOBAL)
set_target_properties(qrack::qrack PROPERTIES
  IMPORTED_LOCATION ${QRACK_LIBRARY}
  INTERFACE_INCLUDE_DIRECTORIES "${QRACK_INSTALL_DIR}/include/qrack;${QRACK_INSTALL_DIR}/include/qrack/common"
)
add_dependencies(qrack::qrack qrack_external)

add_library(selene_example_clifford_t_qrack SHARED src/qrack_simulator.cpp)
target_compile_features(selene_example_clifford_t_qrack PRIVATE cxx_std_17)
target_include_directories(selene_example_clifford_t_qrack PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/../../../selene-core/c/include
)
target_link_libraries(selene_example_clifford_t_qrack PRIVATE qrack::qrack Threads::Threads)

set_target_properties(selene_example_clifford_t_qrack PROPERTIES
  CXX_EXTENSIONS OFF
  POSITION_INDEPENDENT_CODE ON
)
