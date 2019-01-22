## *ExampleQL* - Makefile for macOS Quick Look plugin

*ExampleQL* is a Makefile for macOS Quick Look plugin, without Xcode project intervention.

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

### Compile and test

```
# Use release target for release build
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

### Debugging

```
# for macOS >= 10.12
$ log stream --style compact --predicate 'process == "QuickLookSatellite" AND  sender == "ExampleQL"'

# for macOS < 10.12  XXX: TODO
```

### Install/uninstall

```
# Install/Uninstall Quick Look plugin for all users
$ sudo make install
$ sudo make uninstall

# Install/Uninstall Quick Look plugin for current user
$ PREFIX=~/Library/QuickLook make install
$ PREFIX=~/Library/QuickLook make uninstall
```

### *References*

[Introduction to Quick Look Programming Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/Quicklook_Programming_Guide/Introduction/Introduction.html)

[Quick Look plugins](https://github.com/sindresorhus/quick-look-plugins)

[QuickLook Plugins List](http://www.quicklookplugins.com)

---

*Created 190121*
