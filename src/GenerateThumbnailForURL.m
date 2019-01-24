#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include "utils.h"

/*
 * Generate a thumbnail for designated file as fast as possible
 */
OSStatus GenerateThumbnailForURL(
        void *thisInterface,
        QLThumbnailRequestRef thumbnail,
        CFURLRef url,
        CFStringRef contentTypeUTI,
        CFDictionaryRef options,
        CGSize maxSize)
{
    LOG(@"%s() called", __func__);
    return noErr;
}


/*
 * Implement only if supported
 */
void CancelThumbnailGeneration(
        void *thisInterface,
        QLThumbnailRequestRef thumbnail)
{

}

