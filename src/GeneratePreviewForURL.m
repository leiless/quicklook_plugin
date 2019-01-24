#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include "utils.h"

/*
 * Generate a preview for designated file
 */
OSStatus GeneratePreviewForURL(
        void *thisInterface,
        QLPreviewRequestRef preview,
        CFURLRef url,
        CFStringRef contentTypeUTI,
        CFDictionaryRef options)
{
    LOG("%s() called", __func__);
    return noErr;
}

/*
 * Implement only if supported
 */
void CancelPreviewGeneration(
        void *thisInterface,
        QLPreviewRequestRef preview)
{

}

