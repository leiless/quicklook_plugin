#ifndef UTILS_H
#define UTILS_H

#import <Foundation/Foundation.h>

#ifndef PLUGIN_NAME_S
#define PLUGIN_NAME_S "XXX"
#endif

#define LOG(fmt, ...) NSLog(@PLUGIN_NAME_S ": " fmt "\n", ##__VA_ARGS__)

#endif	/* UTILS_H */

