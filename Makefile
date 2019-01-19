#
# Created 190116 lynnl
# Makefile of Quick Look plugin
#

include Makefile.inc

#
# Check mandatory vars
#
ifndef PLUGIN_NAME
$(error PLUGIN_NAME not defined)
endif

ifndef PLUGIN_VERSION
$(error PLUGIN_VERSION not defined)
endif

ifndef PLUGIN_BUILD
# [assume] zero indicates no build number
PLUGIN_BUILD:=	0
endif

ifndef BUNDLE_DOMAIN
$(error BUNDLE_DOMAIN not defined)
endif


# defaults
PLUGIN_BID?=		$(BUNDLE_DOMAIN).quicklook.$(PLUGIN_NAME)
PLUGIN_BUNDLE?=		$(PLUGIN_NAME).qlgenerator
PLUGIN_MACHO?=		$(PLUGIN_NAME).out
ARCH?=			x86_64
#ARCH?=			i386
PREFIX?=		/Library/QuickLook

#
# Set default macOS SDK
# You may use
#  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
# to switch to Xcode from Command Line Tools if cannot find any SDK
#
SDKROOT?=	$(shell xcrun --sdk macosx --show-sdk-path)

SDKFLAGS=	-isysroot $(SDKROOT)
CC=		$(shell xcrun -find -sdk $(SDKROOT) cc)
#CXX=		$(shell xcrun -find -sdk $(SDKROOT) c++)
CODESIGN=	$(shell xcrun -find -sdk $(SDKROOT) codesign)

#
# Standard defines and includes for kernel extensions
#
# The __ql_makefile__ macro used to compatible with XCode
# Since XCode use intermediate objects  which causes symbol duplicated
#
CPPFLAGS+=	-D__ql_makefile__ \
		$(SDKFLAGS)

#
# Convenience defines
# PLUGIN_BID macro will be used in KMOD_EXPLICIT_DECL
#
CPPFLAGS+=	-DPLUGIN_NAME_S=\"$(PLUGIN_NAME)\"		\
		-DPLUGIN_VERSION_S=\"$(PLUGIN_VERSION)\"	\
		-DPLUGIN_BUILD_S=\"$(PLUGIN_BUILD)\"		\
		-DPLUGIN_BID_S=\"$(PLUGIN_BID)\"		\
		-DPLUGIN_BID=$(PLUGIN_BID)			\
		-D__TS__=\"$(shell date +'%Y/%m/%d\ %H:%M:%S%z')\"

#
# C compiler flags
#
ifdef MACOSX_VERSION_MIN
CFLAGS+=	-mmacosx-version-min=$(MACOSX_VERSION_MIN)
else
CFLAGS+=	-mmacosx-version-min=10.5
endif
CFLAGS+=	-x c \
		-arch $(ARCH) \
		-std=c99 \
		-fmodules \
		-fno-common

# warnings
CFLAGS+=	-Wall -Os
#CFLAGS+=	-Wextra
#CFLAGS+=	-Werror

# linker flags
ifdef MACOSX_VERSION_MIN
LDFLAGS+=	-mmacosx-version-min=$(MACOSX_VERSION_MIN)
else
LDFLAGS+=	-mmacosx-version-min=10.5
endif
LDFLAGS+=	-arch $(ARCH)
LDFLAGS+=	-Xlinker -object_path_lto \
		-Xlinker -export_dynamic -bundle

# source, header, object and make files
SRCS:=		$(wildcard src/*.c)
HDRS:=		$(wildcard src/*.h)
OBJS:=		$(SRCS:.c=.o)
MKFS:=		$(wildcard Makefile)


# targets

all: debug

%.o: %.c $(HDRS)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

$(OBJS): $(MKFS)

$(PLUGIN_MACHO): $(OBJS)
	$(CC) $(SDKFLAGS) $(LDFLAGS) -o $@ $^
	otool -h $@
	otool -l $@ | grep uuid

Info.plist~: Info.plist.in
	sed \
		-e 's/__PLUGIN_NAME__/$(PLUGIN_NAME)/g' \
		-e 's/__PLUGIN_VERSION__/$(PLUGIN_VERSION)/g' \
		-e 's/__PLUGIN_BUILD__/$(PLUGIN_BUILD)/g' \
		-e 's/__PLUGIN_BID__/$(PLUGIN_BID)/g' \
		-e 's/__OS_BUILD__/$(shell /usr/bin/sw_vers -buildVersion)/g' \
		-e 's/__CLANG_VERSION__/$(shell $(CC) -v 2>&1 | grep version)/g' \
		-e 's/__DEV_LANG__/$(shell echo $(LANG) | cut -d'.' -f1)/g' \
		-e 's/__UUID__/$(shell uuidgen)/g' \
	$^ > $@

$(PLUGIN_BUNDLE): $(PLUGIN_MACHO) Info.plist~
	mkdir -p $@/Contents/MacOS
	mv $< $@/Contents/MacOS/$(PLUGIN_NAME)

	#mv $@/Contents/Info.plist~ $@/Contents/Info.plist
	mv Info.plist~ $@/Contents/Info.plist

ifdef COPYRIGHT
	/usr/libexec/PlistBuddy -c 'Add :NSHumanReadableCopyright string "$(COPYRIGHT)"' $@/Contents/Info.plist
endif

ifdef SIGNCERT
	$(CODESIGN) --force --timestamp=none --sign $(SIGNCERT) $@
	/usr/libexec/PlistBuddy -c 'Add :CFBundleSignature string ????' $@/Contents/Info.plist
endif

	touch $@
	dsymutil -arch $(ARCH) -o $(PLUGIN_BUNDLE).dSYM $@/Contents/MacOS/$(PLUGIN_NAME)

release: $(PLUGIN_BUNDLE)

# see: https://www.gnu.org/software/make/manual/html_node/Target_002dspecific.html
# Those two flags must present at the same time  o.w. debug symbol cannot be generated
debug: CPPFLAGS += -g -DDEBUG
debug: release

install: $(PLUGIN_BUNDLE) uninstall
	test -d "$(PREFIX)"
	sudo cp -r $< "$(PREFIX)/$<"
	sudo chown -R root:wheel "$(PREFIX)/$<"

uninstall:
	test -d "$(PREFIX)"
	test -e "$(PREFIX)/$(PLUGIN_BUNDLE)" && \
	sudo rm -rf "$(PREFIX)/$(PLUGIN_BUNDLE)" || true

clean:
	rm -rf $(PLUGIN_BUNDLE) $(PLUGIN_BUNDLE).dSYM Info.plist~ $(OBJS) $(PLUGIN_MACHO)

.PHONY: all debug release intall uninstall clean

