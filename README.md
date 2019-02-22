## *ExampleQL* - Makefile for macOS Quick Look plugin

*ExampleQL* is a Makefile for a barebone Quick Look plugin, without Xcode project intervention.

Theoretically, this plugin can be run in macOS >= 10.5, yet only tested in macOS [10.10, 10.14]
If you tested it under macOS 10.10, please let me know.

<br>

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

You may alternatively specify following variables(default value will be used if not specified)

```
# Plugin bundle identifier
PLUGIN_BID

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
# Use `release' target for release build; default is `debug'
$ make

$ mkdir -p ~/Library/QuickLook
$ cp -r ExampleQL.qlgenerator ~/Library/QuickLook

# Reset Quick Look Server
$ qlmanage -r cache
$ qlmanage -r

# Check loaded Quick Look plugins
$ qlmanage -m plugins | grep ExampleQL
```

In side `Finder`, open a directory with supported-UTI files, so your  Quick Look plugin can be invoked to generate thumbnail/preview.

Alternatively, you can use [qlmanage(1)](x-man-page://1/qlmanage) command line utility to generate thumbnail/preview manually.

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

# Install/uninstall Quick Look plugin for current user
$ PREFIX=~/Library/QuickLook make install
$ PREFIX=~/Library/QuickLook make uninstall
```

### Caveats

* This Quick Look plugin was written in Objective-C & C.

* `main.c` contains the generic CFPlug-in code necessary for a Quick Look generator to use, don't touch it.

* Mojave(10.14) is the last macOS release to support 32-bit apps, Apple LLVM 10.0.0 and above don't support `i386` architecture, thus you should eliminate `-arch i386` in `ARCHFLAGS` for 10.14 and above.

* Apple LLVM 10.0.0 and above drop library linkage with `gcc_s.10.5`(need confirmation), you should specify `MACOSX_VERSION_MIN=10.6` before make(or declare it in `Makefile.inc`)

<br>

### *References*

[Introduction to Quick Look Programming Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/Quicklook_Programming_Guide/Introduction/Introduction.html)

[sindresorhus/quick-look-plugins](https://github.com/sindresorhus/quick-look-plugins)

[phracker/MacOSX-SDKs](https://github.com/phracker/MacOSX-SDKs)

[QuickLook Plugins List](http://www.quicklookplugins.com)

---

*Created 190121+0800*

