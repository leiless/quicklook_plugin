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
BUNDLE_ID?=	$(BUNDLE_DOMAIN).quicklook.$(PLUGIN_NAME)
KEXTBUNDLE?=	$(PLUGIN_NAME).qlgenerator
KEXTMACHO?=	$(PLUGIN_NAME).out
ARCH?=		x86_64
#ARCH?=		i386
PREFIX?=	/Library/QuickLook

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
# BUNDLE_ID macro will be used in KMOD_EXPLICIT_DECL
#
CPPFLAGS+=	-DPLUGIN_NAME_S=\"$(PLUGIN_NAME)\"		\
		-DPLUGIN_VERSION_S=\"$(PLUGIN_VERSION)\"	\
		-DPLUGIN_BUILD_S=\"$(PLUGIN_BUILD)\"		\
		-DBUNDLE_ID_S=\"$(BUNDLE_ID)\"		\
		-DBUNDLE_ID=$(BUNDLE_ID)			\
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
		-nostdinc \
		-fno-builtin \
		-fno-common \

# warnings
CFLAGS+=	-Wall -Wextra -Werror -Os

# linker flags
ifdef MACOSX_VERSION_MIN
LDFLAGS+=	-mmacosx-version-min=$(MACOSX_VERSION_MIN)
else
LDFLAGS+=	-mmacosx-version-min=10.4
endif
LDFLAGS+=	-arch $(ARCH)
LDFLAGS+=	-nostdlib \
		-Xlinker -object_path_lto \
		-Xlinker -export_dynamic

# kextlibs flags
KLFLAGS+=	-xml -c -unsupported -undef-symbols

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

$(KEXTMACHO): $(OBJS)
	$(CC) $(SDKFLAGS) $(LDFLAGS) -o $@ $^
	otool -h $@
	otool -l $@ | grep uuid

Info.plist~: Info.plist.in
	sed \
		-e 's/__PLUGIN_NAME__/$(PLUGIN_NAME)/g' \
		-e 's/__KEXTMACHO__/$(PLUGIN_NAME)/g' \
		-e 's/__PLUGIN_VERSION__/$(PLUGIN_VERSION)/g' \
		-e 's/__PLUGIN_BUILD__/$(PLUGIN_BUILD)/g' \
		-e 's/__BUNDLE_ID__/$(BUNDLE_ID)/g' \
		-e 's/__OSBUILD__/$(shell /usr/bin/sw_vers -buildVersion)/g' \
		-e 's/__CLANGVER__/$(shell $(CC) -v 2>&1 | grep version)/g' \
	$^ > $@

$(KEXTBUNDLE): $(KEXTMACHO) Info.plist~
	mkdir -p $@/Contents/MacOS
	mv $< $@/Contents/MacOS/$(PLUGIN_NAME)

	# Clear placeholders(o.w. kextlibs cannot parse)
	sed 's/__KEXTLIBS__//g' Info.plist~ > $@/Contents/Info.plist
	awk '/__KEXTLIBS__/{system("kextlibs $(KLFLAGS) $@");next};1' Info.plist~ > $@/Contents/Info.plist~
	mv $@/Contents/Info.plist~ $@/Contents/Info.plist

ifdef COPYRIGHT
	/usr/libexec/PlistBuddy -c 'Add :NSHumanReadableCopyright string "$(COPYRIGHT)"' $@/Contents/Info.plist
endif

ifdef SIGNCERT
	$(CODESIGN) --force --timestamp=none --sign $(SIGNCERT) $@
	/usr/libexec/PlistBuddy -c 'Add :CFBundleSignature string ????' $@/Contents/Info.plist
endif

	# Empty-dependency kext cannot be load  so we add one manually
	/usr/libexec/PlistBuddy -c 'Print OSBundleLibraries' $@/Contents/Info.plist &> /dev/null || \
		/usr/libexec/PlistBuddy -c 'Add :OSBundleLibraries:com.apple.kpi.bsd string "8.0b1"' $@/Contents/Info.plist

	touch $@

	dsymutil -arch $(ARCH) -o $(PLUGIN_NAME).kext.dSYM $@/Contents/MacOS/$(PLUGIN_NAME)

release: $(KEXTBUNDLE)

# see: https://www.gnu.org/software/make/manual/html_node/Target_002dspecific.html
# Those two flags must present at the same time  o.w. debug symbol cannot be generated
debug: CPPFLAGS += -g -DDEBUG
debug: release

load: $(KEXTBUNDLE)
	sudo chown -R root:wheel $<
	sudo sync
	sudo kextutil $<
	# restore original owner:group
	sudo chown -R '$(USER):$(shell id -gn)' $<
	sudo dmesg | grep $(PLUGIN_NAME) | tail -1

stat:
	kextstat | grep $(PLUGIN_NAME)

unload:
	sudo kextunload $(KEXTBUNDLE)
	sudo dmesg | grep $(PLUGIN_NAME) | tail -2

install: $(KEXTBUNDLE) uninstall
	test -d "$(PREFIX)"
	sudo cp -r $< "$(PREFIX)/$<"
	sudo chown -R root:wheel "$(PREFIX)/$<"

uninstall:
	test -d "$(PREFIX)"
	test -e "$(PREFIX)/$(KEXTBUNDLE)" && \
	sudo rm -rf "$(PREFIX)/$(KEXTBUNDLE)" || true

clean:
	rm -rf $(KEXTBUNDLE) $(KEXTBUNDLE).dSYM Info.plist~ $(OBJS) $(KEXTMACHO)

.PHONY: all debug release load stat unload intall uninstall clean

