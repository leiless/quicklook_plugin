#ifndef UTILS_H
#define UTILS_H

#include <stdio.h>

#ifndef PLUGIN_NAME_S
#define PLUGIN_NAME_S "XXX"
#endif

#define LOG(fmt, ...) printf(PLUGIN_NAME_S ": " fmt "\n", ##__VA_ARGS__)

#endif	/* UTILS_H */

