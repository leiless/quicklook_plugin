## *ExampleQL* - Makefile for macOS Quick Look plugin

*ExampleQL* is a Makefile for a barebone Quick Look plugin, without Xcode project intervention.

Theoretically, this plugin can be run in macOS >= 10.5, yet only tested in macOS [10.10, 10.14]
If you tested it under macOS 10.10, please let me know

### Mandatory variables

You must define at least following Makefile variables in ```Makefile.inc```

```
PLUGIN_NAME

PLUGIN_VERSION

PLUGIN_BUILD

# Reversed domain  Example: com.example
BUNDLE_DOMAIN	

# Supported UTI types to generate preview/thumbnail
PLUGIN_SUPPORTED_UTI
```

### Optional variables

You may alternatively specify following variables

```
# Supported architectures
ARCHFLAGS

# Quick Look installation prefix
PREFIX

# macOS SDK root path
SDKROOT

# Minimal supported macOS version(should >= 10.5)
MACOSX_VERSION_MIN

# Copyright string embedded in Info.plist
COPYRIGHT

# Code signature identity
SIGNCERT
```

For a full list of optional variables, please check `Makefile`

### Compile & load

```
# Use release target for release build; default is debug
$ make

$ mkdir -p ~/Library/QuickLook
$ cp -r ExampleQL.qlgenerator ~/Library/QuickLook

# Reset Quick Look Server
$ qlmanage -r cache
$ qlmanage -r

# Check loaded Quick Look plugins
$ qlmanage -m plugins | grep ExampleQL
```

In side `Finder`, open a directory with supported-UTI files, so your  Quick Look plugin can be invoked to generate thumbnail/preview

Alternatively, you can use [qlmanage(1)](x-man-page://1/qlmanage) command line utility to generate thumbnail/preview manually

### Debugging & test

```
# for macOS >= 10.12
$ log stream --style compact --predicate 'process == "QuickLookSatellite" AND  sender == "ExampleQL"'

# for macOS < 10.12
$ syslog -w 0 -k Sender QuickLookSatellite -k Message S ExampleQL
```

Please check [Debugging and Testing a Generator](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/Quicklook_Programming_Guide/Articles/QLDebugTest.html) for a comprehensive debugging tips.

### Install/uninstall

```
# Install/Uninstall Quick Look plugin for all users
$ sudo make install
$ sudo make uninstall

# Install/Uninstall Quick Look plugin for current user
$ PREFIX=~/Library/QuickLook make install
$ PREFIX=~/Library/QuickLook make uninstall
```

### Caveats

This Quick Look plugin was written in Objective-C, previously its template code was written in C.

Since Objective-C loosely compatible with C, in most cases, you should have no hesitation migrate from C to Objective-C.

Mojave(10.14) is the last macOS release to support 32-bit apps. Apple LLVM 10.0.0 and above don't support `i386` architecture, thus you should eliminate `-arch i386` in `ARCHFLAGS`.

Also, Apple LLVM 10.0.0 and above drop library linkage with `gcc_s.10.5`(need confirmation), you should specify `MACOSX_VERSION_MIN=10.6` before make(or declare it in `Makefile.inc`)

### *References*

[Introduction to Quick Look Programming Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/Quicklook_Programming_Guide/Introduction/Introduction.html)

[Quick Look plugins](https://github.com/sindresorhus/quick-look-plugins)

[QuickLook Plugins List](http://www.quicklookplugins.com)

---

*Created 190121*
