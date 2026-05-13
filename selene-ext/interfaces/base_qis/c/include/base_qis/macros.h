#ifndef EXPORT

// when building, we mark the functions as exported on windows,
// and as used on other platforms.
#ifdef BUILDING_QIS_INTERFACE
#  ifdef _WIN32
#    define EXPORT __declspec(dllexport)
#  else
#    define EXPORT __attribute__((used, visibility("default")))
#  endif
// When consuming, we mark the functions as imported on
// windows. No special marking is needed on other platforms.
#else
#  ifdef _WIN32
#    define EXPORT __declspec(dllimport)
#  else
#    define EXPORT
#  endif
#endif

#endif
