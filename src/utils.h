#ifndef UTILS_H
#define UTILS_H

#import <Foundation/Foundation.h>

#ifndef PLUGIN_NAME_S
#define PLUGIN_NAME_S "XXX"
#endif

#define LOG(fmt, ...)       NSLog(@PLUGIN_NAME_S ": " fmt "\n", ##__VA_ARGS__)
#define LOG_ERR(fmt, ...)   LOG("[ERR] " fmt, ##__VA_ARGS__)
#ifdef DEBUG
#define LOG_DBG(fmt, ...)   LOG("[DBG] " fmt, ##__VA_ARGS__)
#else
#define LOG_DBG(fmt, ...)   (void) (0, ##__VA_ARGS__)
#endif

#endif	/* UTILS_H */

