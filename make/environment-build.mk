#
# set up build environment for other makefiles
#
# -----------------------------------------------------------------------------

CONFIG_SITE =
export CONFIG_SITE

LD_LIBRARY_PATH =
export LD_LIBRARY_PATH

SHELL := /bin/bash

# empty variable EMPTY for smoother comparisons
EMPTY =

# -----------------------------------------------------------------------------

# set up default parallelism
PARALLEL_JOBS := $(shell echo $$((1 + `getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1`)))
override MAKE = make $(if $(findstring j,$(filter-out --%,$(MAKEFLAGS))),,-j$(PARALLEL_JOBS))

MAKEFLAGS += --no-print-directory
#MAKEFLAGS += --silent

# -----------------------------------------------------------------------------

BASE_DIR     := $(shell pwd)
MAINTAINER   ?= unknown
WHOAMI       := $(shell id -un)
ARCHIVE       = $(BASE_DIR)/download
BUILD_TMP     = $(BASE_DIR)/build_tmp
ROOTFS        = $(BUILD_TMP)/rootfs
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd51))
  ROOTFS      = $(BUILD_TMP)/rootfs/linuxrootfs1
endif
DEPS_DIR      = $(BASE_DIR)/deps
D             = $(DEPS_DIR)
HOST_DIR      = $(BASE_DIR)/host
TARGET_DIR   ?= $(BASE_DIR)/root
SOURCE_DIR    = $(BASE_DIR)/source
MAKE_DIR      = $(BASE_DIR)/make
LOCAL_DIR     = $(BASE_DIR)/local
STAGING_DIR   = $(BASE_DIR)/staging
IMAGE_DIR     = $(STAGING_DIR)/images
UPDATE_DIR    = $(STAGING_DIR)/updates
HELPERS_DIR   = $(BASE_DIR)/helpers
CROSS_BASE    = $(BASE_DIR)/cross
CROSS_DIR    ?= $(CROSS_BASE)/$(BOXARCH)-linux-$(KERNEL_VER)
STATIC_BASE   = $(BASE_DIR)/static
STATIC_DIR    = $(STATIC_BASE)/$(BOXARCH)-linux-$(KERNEL_VER)
CONFIGS       = $(BASE_DIR)/configs
PATCHES       = $(BASE_DIR)/patches
SKEL-ROOT     = $(BASE_DIR)/skel-root/$(BOXSERIES)
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse))
  SKEL-ROOT   = $(BASE_DIR)/skel-root/vuplus
endif
TARGET_FILES  = $(BASE_DIR)/skel-root/general

BUILD        ?= $(shell /usr/share/libtool/config.guess 2>/dev/null || /usr/share/libtool/config/config.guess 2>/dev/null || /usr/share/misc/config.guess)

# -----------------------------------------------------------------------------

PKG_NAME        = $(basename $(@F))
PKG_UPPER       = $(call UPPERCASE,$(PKG_NAME))
PKG_LOWER       = $(call LOWERCASE,$(PKG_NAME))
PKG_VER         = $($(PKG_UPPER)_VER)
PKG_TMP         = $($(PKG_UPPER)_TMP)
PKG_SOURCE      = $($(PKG_UPPER)_SOURCE)
PKG_SITE        = $($(PKG_UPPER)_SITE)
PKG_BUILD_TMP   = $(BUILD_TMP)/$(PKG_TMP)
PKG_PATCHES_DIR = $(PATCHES)/$(subst host-,,$(PKG_NAME))

# -----------------------------------------------------------------------------

CCACHE        = /usr/bin/ccache
CCACHE_DIR    = $(HOME)/.ccache-ni-buildsystem-$(BOXARCH)-linux-$(KERNEL_VER)
export CCACHE_DIR

# -----------------------------------------------------------------------------

# create debug image
DEBUG ?= no

# -----------------------------------------------------------------------------

ifeq ($(BOXSERIES), hd1)
  DRIVERS-BIN_DIR        = $(BOXTYPE)/$(BOXFAMILY)
  CORTEX-STRINGS_LDFLAG  =
  TARGET                 = arm-cx2450x-linux-gnueabi
  TARGET_OPTIMIZATION    = -Os
  TARGET_DEBUGGING       = -g
  TARGET_ARCH            = armv6
  TARGET_ABI             = -march=$(TARGET_ARCH) -mfloat-abi=soft -mlittle-endian
  TARGET_EXTRA_CFLAGS    = -fdata-sections -ffunction-sections
  TARGET_EXTRA_LDFLAGS   = -Wl,--gc-sections
  CXX11_ABI              =

else ifeq ($(BOXSERIES), hd2)
  DRIVERS-BIN_DIR        = $(BOXTYPE)/$(BOXFAMILY)
  CORTEX-STRINGS_LDFLAG  = -lcortex-strings
  TARGET                 = arm-cortex-linux-uclibcgnueabi
  TARGET_OPTIMIZATION    = -O2
  TARGET_DEBUGGING       = -g
  TARGET_ARCH            = armv7-a
  TARGET_ABI             = -march=$(TARGET_ARCH) -mtune=cortex-a9 -mfpu=vfpv3-d16 -mfloat-abi=hard -mlittle-endian
  TARGET_EXTRA_CFLAGS    =
  TARGET_EXTRA_LDFLAGS   =
  ifeq ($(BOXMODEL), kronos_v2)
    TARGET_OPTIMIZATION  = -Os
    TARGET_EXTRA_CFLAGS  = -fdata-sections -ffunction-sections
    TARGET_EXTRA_LDFLAGS = -Wl,--gc-sections
  endif
  CXX11_ABI              = -D_GLIBCXX_USE_CXX11_ABI=0

else ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse))
  DRIVERS-BIN_DIR        = $(BOXTYPE)/$(BOXMODEL)
  CORTEX-STRINGS_LDFLAG  = -lcortex-strings
  TARGET                 = arm-cortex-linux-gnueabihf
  TARGET_OPTIMIZATION    = -O2
  TARGET_DEBUGGING       = -g
  TARGET_ARCH            = armv7ve
  TARGET_ABI             = -march=$(TARGET_ARCH) -mtune=cortex-a15 -mfpu=neon-vfpv4 -mfloat-abi=hard
  TARGET_EXTRA_CFLAGS    =
  TARGET_EXTRA_LDFLAGS   =
  CXX11_ABI              =

else ifeq ($(BOXSERIES), $(filter $(BOXSERIES), vuduo))
  DRIVERS-BIN_DIR        = $(BOXTYPE)/$(BOXMODEL)
  CORTEX-STRINGS_LDFLAG  =
  TARGET                 = mipsel-unknown-linux-gnu
  TARGET_OPTIMIZATION    = -O2
  TARGET_DEBUGGING       = -g
  TARGET_ARCH            = mips32
  TARGET_ABI             = -march=$(TARGET_ARCH) -mtune=mips32
  TARGET_EXTRA_CFLAGS    =
  TARGET_EXTRA_LDFLAGS   =
  CXX11_ABI              =

endif

STATIC_LIB_DIR = $(STATIC_DIR)/lib

TARGET_BIN_DIR     = $(TARGET_DIR)/bin
TARGET_INCLUDE_DIR = $(TARGET_DIR)/include
TARGET_LIB_DIR     = $(TARGET_DIR)/lib
TARGET_MODULES_DIR = $(TARGET_LIB_DIR)/modules/$(KERNEL_VER)
TARGET_SBIN_DIR    = $(TARGET_DIR)/sbin
TARGET_SHARE_DIR   = $(TARGET_DIR)/share

TARGET_CFLAGS   = -pipe $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_ABI) $(TARGET_EXTRA_CFLAGS) $(CXX11_ABI) -I$(TARGET_INCLUDE_DIR)
TARGET_CPPFLAGS = $(TARGET_CFLAGS)
TARGET_CXXFLAGS = $(TARGET_CFLAGS)
TARGET_LDFLAGS  = $(CORTEX-STRINGS_LDFLAG) -Wl,-O1 -Wl,-rpath,$(TARGET_LIB_DIR) -Wl,-rpath-link,$(TARGET_LIB_DIR) -L$(TARGET_LIB_DIR) $(TARGET_EXTRA_LDFLAGS)

TARGET_CROSS    = $(TARGET)-

# Define TARGET_xx variables for all common binutils/gcc
TARGET_AR       = $(TARGET_CROSS)ar
TARGET_AS       = $(TARGET_CROSS)as
TARGET_CC       = $(TARGET_CROSS)gcc
TARGET_CPP      = $(TARGET_CROSS)cpp
TARGET_CXX      = $(TARGET_CROSS)g++
TARGET_LD       = $(TARGET_CROSS)ld
TARGET_NM       = $(TARGET_CROSS)nm
TARGET_OBJCOPY  = $(TARGET_CROSS)objcopy
TARGET_OBJDUMP  = $(TARGET_CROSS)objdump
TARGET_RANLIB   = $(TARGET_CROSS)ranlib
TARGET_READELF  = $(TARGET_CROSS)readelf
TARGET_STRIP    = $(TARGET_CROSS)strip

# -----------------------------------------------------------------------------

TERM_RED	= \033[40;0;31m
TERM_RED_BOLD	= \033[40;1;31m
TERM_GREEN	= \033[40;0;32m
TERM_GREEN_BOLD	= \033[40;1;32m
TERM_YELLOW	= \033[40;0;33m
TERM_YELLOW_BOLD= \033[40;1;33m
TERM_NORMAL	= \033[0m

# -----------------------------------------------------------------------------

# search path(s) for all prerequisites
VPATH = $(D)

PATH := $(HOST_DIR)/bin:$(CROSS_DIR)/bin:$(PATH)

# -----------------------------------------------------------------------------

PKG_CONFIG = $(HOST_DIR)/bin/$(TARGET)-pkg-config
PKG_CONFIG_LIBDIR = $(TARGET_LIB_DIR)
PKG_CONFIG_PATH = $(PKG_CONFIG_LIBDIR)/pkgconfig

# -----------------------------------------------------------------------------

# download archives into archives directory
DOWNLOAD = wget --no-check-certificate -t3 -T60 -c -P $(ARCHIVE)

# unpack archives into build directory
UNTAR = tar -C $(BUILD_TMP) -xf $(ARCHIVE)
UNZIP = unzip -d $(BUILD_TMP) -o $(ARCHIVE)

# clean up
REMOVE = rm -rf $(BUILD_TMP)

# apply patches
PATCH = patch -p1 -i $(PATCHES)

# build helper variables
CD    = set -e; cd
CHDIR = $(CD) $(BUILD_TMP)
MKDIR = mkdir -p $(BUILD_TMP)
CPDIR = cp -a -t $(BUILD_TMP) $(ARCHIVE)
TOUCH = @touch $(D)/$(@)

INSTALL      = install
INSTALL_DATA = $(INSTALL) -m 0644
INSTALL_EXEC = $(INSTALL) -m 0755
INSTALL_COPY = cp -a

define INSTALL_EXIST # (source, dest)
	if [ -d $(dir $(1)) ]; then \
		$(INSTALL) -d $(2); \
		$(INSTALL_COPY) $(1) $(2); \
	fi
endef

GET-GIT-ARCHIVE = $(HELPERS_DIR)/get-git-archive.sh
GET-GIT-SOURCE  = $(HELPERS_DIR)/get-git-source.sh
GET-SVN-SOURCE  = $(HELPERS_DIR)/get-svn-source.sh
UPDATE-RC.D     = $(HELPERS_DIR)/update-rc.d -r $(TARGET_DIR)

# -----------------------------------------------------------------------------

MAKE_OPTS = \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	CC="$(TARGET_CC)" \
	GCC="$(TARGET_CC)" \
	CPP="$(TARGET_CPP)" \
	CXX="$(TARGET_CXX)" \
	LD="$(TARGET_LD)" \
	AR="$(TARGET_AR)" \
	AS="$(TARGET_AS)" \
	NM="$(TARGET_NM)" \
	OBJCOPY="$(TARGET_OBJCOPY)" \
	OBJDUMP="$(TARGET_OBJDUMP)" \
	RANLIB="$(TARGET_RANLIB)" \
	READELF="$(TARGET_READELF)" \
	STRIP="$(TARGET_STRIP)" \
	ARCH=$(BOXARCH)

BUILD_ENV = \
	$(MAKE_OPTS) \
	\
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \

BUILD_ENV += \
	PKG_CONFIG=$(PKG_CONFIG) \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

CONFIGURE_OPTS = \
	--build=$(BUILD) \
	--host=$(TARGET)

CONFIGURE = \
	test -f ./configure || ./autogen.sh && \
	$(BUILD_ENV) \
	./configure $(CONFIGURE_OPTS)

# -----------------------------------------------------------------------------

CMAKE_OPTS = \
	-DBUILD_SHARED_LIBS=ON \
	-DENABLE_STATIC=OFF \
	-DCMAKE_BUILD_TYPE="None" \
	-DCMAKE_SYSTEM_NAME="Linux" \
	-DCMAKE_SYSTEM_PROCESSOR="$(BOXARCH)" \
	-DCMAKE_INSTALL_PREFIX="" \
	-DCMAKE_INSTALL_DOCDIR="$(remove-docdir)" \
	-DCMAKE_INSTALL_MANDIR="$(remove-mandir)" \
	-DCMAKE_PREFIX_PATH="$(TARGET_DIR)" \
	-DCMAKE_INCLUDE_PATH="$(TARGET_INCLUDE_DIR)" \
	-DCMAKE_C_COMPILER="$(TARGET_CC)" \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) -DNDEBUG" \
	-DCMAKE_CPP_COMPILER="$(TARGET_CPP)" \
	-DCMAKE_CPP_FLAGS="$(TARGET_CFLAGS) -DNDEBUG" \
	-DCMAKE_CXX_COMPILER="$(TARGET_CXX)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CFLAGS) -DNDEBUG" \
	-DCMAKE_LINKER="$(TARGET_LD)" \
	-DCMAKE_AR="$(TARGET_AR)" \
	-DCMAKE_AS="$(TARGET_AS)" \
	-DCMAKE_NM="$(TARGET_NM)" \
	-DCMAKE_OBJCOPY="$(TARGET_OBJCOPY)" \
	-DCMAKE_OBJDUMP="$(TARGET_OBJDUMP)" \
	-DCMAKE_RANLIB="$(TARGET_RANLIB)" \
	-DCMAKE_READELF="$(TARGET_READELF)" \
	-DCMAKE_STRIP="$(TARGET_STRIP)"

CMAKE = \
	rm -f CMakeCache.txt; \
	cmake --no-warn-unused-cli $(CMAKE_OPTS)

# -----------------------------------------------------------------------------

GITHUB			= https://github.com
GITHUB_SSH		= git@github.com
BITBUCKET		= https://bitbucket.org
BITBUCKET_SSH		= git@bitbucket.org

NI-PUBLIC		= $(GITHUB)/neutrino-images
NI-PRIVATE		= $(BITBUCKET_SSH):neutrino-images

NI-NEUTRINO		= ni-neutrino
NI-NEUTRINO_BRANCH	?= master
NI-NEUTRINO-PLUGINS	= ni-neutrino-plugins

BUILD-GENERIC-PC	= build-generic-pc
NI-BUILD-GENERIC-PC	= ni-build-generic-pc
NI-DRIVERS-BIN		= ni-drivers-bin
NI-LIBSTB-HAL		= ni-libstb-hal
NI-LINUX-KERNEL		= ni-linux-kernel
NI-LOGO-STUFF		= ni-logo-stuff
NI-OFGWRITE		= ni-ofgwrite
NI-OPENTHREADS		= ni-openthreads
NI-RTMPDUMP		= ni-rtmpdump
NI-STREAMRIPPER		= ni-streamripper

# Note: NI-FFMPEG-variables are only used for Coolstream-builds
#
# ffmpeg/master is currently not mature enough for daily use
# if you want to help testing you can enable it here
NI-FFMPEG		= ni-ffmpeg
NI-FFMPEG_BRANCH	?= ni/ffmpeg/2.8
#NI-FFMPEG_BRANCH	?= ni/ffmpeg/master
#NI-FFMPEG_BRANCH	?= ffmpeg/master
