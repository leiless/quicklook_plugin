### *ExampleQL* - Makefile for macOS Quick Look plugin

*ExampleQL* is a Makefile for macOS Quick Look plugin, without Xcode project intervention.

---

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

---

*Created 190121*