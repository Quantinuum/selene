#ifndef BASE_QIS_LOGGING_HELPER_H
#define BASE_QIS_LOGGING_HELPER_H

#include <stdio.h>
#include <inttypes.h>

#ifndef SELENE_LOG_LEVEL
#define SELENE_LOG_LEVEL 0
#endif

#define ERROR(...) fprintf(stderr, "[interface] error: " __VA_ARGS__)

#if (SELENE_LOG_LEVEL) == 0
#define INFO(...) printf("[interface] info: " __VA_ARGS__)
#define DEBUG(...)
#define DIAGNOSTIC(...)
#elif (SELENE_LOG_LEVEL) == 1
#define INFO(...) printf("[interface] info: " __VA_ARGS__)
#define DEBUG(...) fprintf(stderr, "[interface] debug: " __VA_ARGS__)
#define DIAGNOSTIC(...)
#elif (SELENE_LOG_LEVEL) == 2
#define INFO(...) printf("[interface] info: " __VA_ARGS__)
#define DEBUG(...) fprintf(stderr, "[interface] debug: " __VA_ARGS__)
#define DIAGNOSTIC(...) fprintf(stderr, "[interface] diagnostic: " __VA_ARGS__)
#else
#error "Invalid SELENE_LOG_LEVEL"
#endif

#endif
