include(FetchContent)

# Each interface bundles mimalloc for the user's heap. We don't want to
# replace malloc/free in Selene or require another shared library at runtime.
set(MI_OVERRIDE OFF CACHE BOOL "" FORCE)
set(MI_BUILD_SHARED OFF CACHE BOOL "" FORCE)
set(MI_BUILD_STATIC ON CACHE BOOL "" FORCE)
set(MI_BUILD_OBJECT OFF CACHE BOOL "" FORCE)
set(MI_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(MI_NO_OPT_ARCH ON CACHE BOOL "" FORCE)
# The interfaces can also be loaded after the process has started.
set(MI_LOCAL_DYNAMIC_TLS ON CACHE BOOL "" FORCE)
FetchContent_Declare(mimalloc
    GIT_REPOSITORY https://github.com/microsoft/mimalloc.git
    GIT_TAG 00d07c4c15a04a4cb68d3aeeecbd8d6ae80bb0b7 # v2.2.4
)
FetchContent_MakeAvailable(mimalloc)
set_property(DIRECTORY "${mimalloc_SOURCE_DIR}" PROPERTY EXCLUDE_FROM_ALL TRUE)
set_target_properties(mimalloc-static PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    C_VISIBILITY_PRESET hidden
    CXX_VISIBILITY_PRESET hidden
)
install(FILES "${mimalloc_SOURCE_DIR}/LICENSE"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/licenses/mimalloc"
)
