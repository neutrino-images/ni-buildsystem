#
# set up build environment for other makefiles
#
# -----------------------------------------------------------------------------

CONFIG_SITE =
export CONFIG_SITE

LD_LIBRARY_PATH =
export LD_LIBRARY_PATH

SHELL := /bin/bash

# -----------------------------------------------------------------------------

# assign box environment

# - Coolstream ----------------------------------------------------------------

# BOXTYPE                   coolstream
#                          /          \
# BOXSERIES              hd1          hd2
#                        /           /   \
# BOXFAMILY           nevis      apollo kronos
#                      /        /     | |     \
# BOXMODEL          nevis apollo shiner kronos kronos_v2

# - AX Technologies / Mutant --------------------------------------------------

# BOXTYPE                     armbox
#                             /    \
# BOXSERIES                hd51    bre2ze4k
#                            |      |
# BOXFAMILY                  bcm7251s
#                            |      |
# BOXMODEL                 hd51    bre2ze4k

# -----------------------------------------------------------------------------

# assign by given BOXSERIES
ifneq ($(BOXSERIES),)
  ifeq ($(BOXSERIES), hd1)
    BOXTYPE = coolstream
    BOXFAMILY = nevis
    BOXMODEL = nevis
  else ifeq ($(BOXSERIES), hd2)
    BOXTYPE = coolstream
    BOXFAMILY = apollo
    BOXMODEL = apollo
  else ifeq ($(BOXSERIES), hd51)
    BOXTYPE = armbox
    BOXFAMILY = bcm7251s
    BOXMODEL = hd51
  else ifeq ($(BOXSERIES), bre2ze4k)
    BOXTYPE = armbox
    BOXFAMILY = bcm7251s
    BOXMODEL = bre2ze4k
  else
    $(error $(BOXTYPE) BOXSERIES $(BOXSERIES) not supported)
  endif

# assign by given BOXMODEL
else ifneq ($(BOXMODEL),)
  ifeq ($(BOXMODEL), nevis)
    BOXTYPE = coolstream
    BOXSERIES = hd1
    BOXFAMILY = nevis
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), apollo shiner))
    BOXTYPE = coolstream
    BOXSERIES = hd2
    BOXFAMILY = apollo
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), kronos kronos_v2))
    BOXTYPE = coolstream
    BOXSERIES = hd2
    BOXFAMILY = kronos
  else ifeq ($(BOXMODEL), hd51)
    BOXTYPE = armbox
    BOXSERIES = hd51
    BOXFAMILY = bcm7251s
  else ifeq ($(BOXMODEL), bre2ze4k)
    BOXTYPE = armbox
    BOXSERIES = bre2ze4k
    BOXFAMILY = bcm7251s
  else
    $(error $(BOXTYPE) BOXMODEL $(BOXMODEL) not supported)
  endif

endif

ifeq ($(BOXTYPE), coolstream)
  BOXTYPE_SC = cst
  BOXARCH = arm
else ifeq ($(BOXTYPE), armbox)
  BOXTYPE_SC = arm
  BOXARCH = arm
endif

# -----------------------------------------------------------------------------

ifndef BOXTYPE
  $(error BOXTYPE not set)
endif
ifndef BOXTYPE_SC
  $(error BOXTYPE_SC not set)
endif
ifndef BOXARCH
  $(error BOXARCH not set)
endif
ifndef BOXSERIES
  $(error BOXSERIES not set)
endif
ifndef BOXFAMILY
  $(error BOXFAMILY not set)
endif
ifndef BOXMODEL
  $(error BOXMODEL not set)
endif

# -----------------------------------------------------------------------------

# set up default parallelism
PARALLEL_JOBS := $(shell echo $$((1 + `getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1`)))
override MAKE = make $(if $(findstring j,$(filter-out --%,$(MAKEFLAGS))),,-j$(PARALLEL_JOBS))

MAKEFLAGS += --no-print-directory
#MAKEFLAGS += --silent

# -----------------------------------------------------------------------------

BASE_DIR     := $(shell pwd)
MAINTAINER   ?= NI-Team
WHOAMI       := $(shell id -un)
ARCHIVE       = $(BASE_DIR)/download
BUILD_TMP     = $(BASE_DIR)/build_tmp
ROOTFS        = $(BUILD_TMP)/rootfs
ifeq ($(BOXTYPE), armbox)
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
STATIC_BASE   = $(BASE_DIR)/static
STATIC_DIR    = $(STATIC_BASE)/$(BOXARCH)/$(BOXSERIES)
HELPERS_DIR   = $(BASE_DIR)/helpers
CROSS_BASE    = $(BASE_DIR)/cross
CROSS_DIR    ?= $(CROSS_BASE)/$(BOXARCH)/$(BOXSERIES)
CONFIGS       = $(BASE_DIR)/archive-configs
PATCHES       = $(BASE_DIR)/archive-patches
IMAGEFILES    = $(BASE_DIR)/archive-imagefiles
SKEL_ROOT     = $(BASE_DIR)/skel-root/$(BOXTYPE)/$(BOXSERIES)

BUILD        ?= $(shell /usr/share/libtool/config.guess 2>/dev/null || /usr/share/libtool/config/config.guess 2>/dev/null || /usr/share/misc/config.guess)
CCACHE        = /usr/bin/ccache
CCACHE_DIR    = $(HOME)/.ccache-ni-buildsystem-$(BOXARCH)-$(BOXSERIES)
export CCACHE_DIR

# create debug image
DEBUG ?= no

# -----------------------------------------------------------------------------

ifeq ($(BOXSERIES), hd1)
  KERNEL_VERSION_MAJOR   = 2.6.34
  KERNEL_VERSION         = 2.6.34.13

  DRIVERS_DIR            = nevis
  CORTEX-STRINGS         =
  TARGET                 = arm-cx2450x-linux-gnueabi
  TARGET_OPTIMIZATION    = -Os
  TARGET_DEBUGGING       = -g
  TARGET_ABI             = -march=armv6 -mfloat-abi=soft -mlittle-endian
  TARGET_EXTRA_CFLAGS    = -fdata-sections -ffunction-sections
  TARGET_EXTRA_LDFLAGS   = -Wl,--gc-sections
  CXX11_ABI              =

else ifeq ($(BOXSERIES), hd2)
  KERNEL_VERSION_MAJOR   = 3.10
  KERNEL_VERSION         = 3.10.93

  ifeq ($(BOXFAMILY), apollo)
    DRIVERS_DIR          = apollo
  endif
  ifeq ($(BOXFAMILY), kronos)
    DRIVERS_DIR          = kronos
  endif
  CORTEX-STRINGS         = -lcortex-strings
  TARGET                 = arm-cortex-linux-uclibcgnueabi
  TARGET_OPTIMIZATION    = -O2
  TARGET_DEBUGGING       = -g
  TARGET_ABI             = -march=armv7-a -mtune=cortex-a9 -mfpu=vfpv3-d16 -mfloat-abi=hard -mlittle-endian
  TARGET_EXTRA_CFLAGS    =
  TARGET_EXTRA_LDFLAGS   =
  ifeq ($(BOXMODEL), kronos_v2)
    TARGET_OPTIMIZATION  = -Os
    TARGET_EXTRA_CFLAGS  = -fdata-sections -ffunction-sections
    TARGET_EXTRA_LDFLAGS = -Wl,--gc-sections
  endif
  CXX11_ABI              = -D_GLIBCXX_USE_CXX11_ABI=0

else ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 bre2ze4k))
  KERNEL_VERSION_MAJOR   = 4.10
  KERNEL_VERSION         = 4.10.12

  DRIVERS_DIR            = $(BOXSERIES)
  CORTEX-STRINGS         = -lcortex-strings
  TARGET                 = arm-cortex-linux-gnueabihf
  TARGET_OPTIMIZATION    = -O2
  TARGET_DEBUGGING       = -g
  TARGET_ABI             = -march=armv7ve -mtune=cortex-a15 -mfpu=neon-vfpv4 -mfloat-abi=hard
  TARGET_EXTRA_CFLAGS    =
  TARGET_EXTRA_LDFLAGS   =
  CXX11_ABI              =

endif

STATIC_LIB_DIR = $(STATIC_DIR)/lib
TARGET_BIN_DIR = $(TARGET_DIR)/bin
TARGET_LIB_DIR = $(TARGET_DIR)/lib
TARGET_MODULES_DIR = $(TARGET_LIB_DIR)/modules/$(KERNEL_VERSION)
TARGET_INCLUDE_DIR = $(TARGET_DIR)/include
TARGET_SHARE_DIR = $(TARGET_DIR)/share

TARGET_CFLAGS   = -pipe $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_ABI) $(TARGET_EXTRA_CFLAGS) $(CXX11_ABI) -I$(TARGET_INCLUDE_DIR)
TARGET_CPPFLAGS = $(TARGET_CFLAGS)
TARGET_CXXFLAGS = $(TARGET_CFLAGS)
TARGET_LDFLAGS  = $(CORTEX-STRINGS) -Wl,-O1 -Wl,-rpath,$(TARGET_LIB_DIR) -Wl,-rpath-link,$(TARGET_LIB_DIR) -L$(TARGET_LIB_DIR) $(TARGET_EXTRA_LDFLAGS)

VPATH = $(D)

TERM_RED	= \033[40;0;31m
TERM_RED_BOLD	= \033[40;1;31m
TERM_GREEN	= \033[40;0;32m
TERM_GREEN_BOLD	= \033[40;1;32m
TERM_YELLOW	= \033[40;0;33m
TERM_YELLOW_BOLD= \033[40;1;33m
TERM_NORMAL	= \033[0m

USE_LIBSTB-HAL = no
ifneq ($(BOXTYPE), coolstream)
  USE_LIBSTB-HAL = yes
endif

PATH := $(HOST_DIR)/bin:$(CROSS_DIR)/bin:$(HELPERS_DIR):$(PATH)

PKG_CONFIG = $(HOST_DIR)/bin/$(TARGET)-pkg-config
PKG_CONFIG_LIBDIR = $(TARGET_LIB_DIR)
PKG_CONFIG_PATH = $(PKG_CONFIG_LIBDIR)/pkgconfig

# helper-"functions":
REWRITE_LIBTOOL_RULES  = sed -i \
				-e "s,^libdir=.*,libdir='$(TARGET_LIB_DIR)'," \
				-e "s,\(^dependency_libs='\| \|-L\|^dependency_libs='\)/lib,\ $(TARGET_LIB_DIR),g"

REWRITE_LIBTOOL        = $(REWRITE_LIBTOOL_RULES) $(TARGET_LIB_DIR)
REWRITE_LIBTOOL_STATIC = $(REWRITE_LIBTOOL_RULES) $(STATIC_LIB_DIR)

REWRITE_CONFIG_RULES   = sed -i \
				-e "s,^prefix=.*,prefix='$(TARGET_DIR)'," \
				-e "s,^exec_prefix=.*,exec_prefix='$(TARGET_DIR)'," \
				-e "s,^libdir=.*,libdir='$(TARGET_LIB_DIR)'," \
				-e "s,^includedir=.*,includedir='$(TARGET_INCLUDE_DIR)',"

REWRITE_CONFIG         = $(REWRITE_CONFIG_RULES)
REWRITE_PKGCONF        = $(REWRITE_CONFIG_RULES) $(PKG_CONFIG_PATH)

# unpack tarballs, clean up
UNTAR = tar -C $(BUILD_TMP) -xf $(ARCHIVE)
UNZIP = unzip -d $(BUILD_TMP) -o $(ARCHIVE)
REMOVE = rm -rf $(TARGET_DIR)/.remove $(BUILD_TMP)
PATCH = patch -p1 -i $(PATCHES)

# wget tarballs into archive directory
WGET = wget -t3 -T60 -c -P $(ARCHIVE)

CD    = set -e; cd
CHDIR = $(CD) $(BUILD_TMP)
MKDIR = mkdir -p $(BUILD_TMP)
CPDIR = cp -a -t $(BUILD_TMP) $(ARCHIVE)
TOUCH = @touch $@
STRIP = $(TARGET)-strip

# empty variable EMPTY for smoother comparisons
EMPTY =

BUILDENV = \
	CC=$(TARGET)-gcc \
	CXX=$(TARGET)-g++ \
	LD=$(TARGET)-ld \
	NM=$(TARGET)-nm \
	AR=$(TARGET)-ar \
	AS=$(TARGET)-as \
	LDD=$(TARGET)-ldd \
	RANLIB=$(TARGET)-ranlib \
	STRIP=$(TARGET)-strip \
	OBJCOPY=$(TARGET)-objcopy \
	OBJDUMP=$(TARGET)-objdump \
	READELF=$(TARGET)-readelf \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG=$(PKG_CONFIG) \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

CONFIGURE_OPTS = \
	--build=$(BUILD) \
	--host=$(TARGET)

CONFIGURE = \
	test -f ./configure || ./autogen.sh && \
	$(BUILDENV) \
	./configure $(CONFIGURE_OPTS)

CMAKE_OPTS = \
	-DBUILD_SHARED_LIBS=ON \
	-DENABLE_STATIC=OFF \
	-DCMAKE_BUILD_TYPE="None" \
	-DCMAKE_SYSTEM_NAME="Linux" \
	-DCMAKE_SYSTEM_PROCESSOR="$(BOXARCH)" \
	-DCMAKE_INSTALL_PREFIX="" \
	-DCMAKE_INSTALL_DOCDIR="/.remove" \
	-DCMAKE_INSTALL_MANDIR="/.remove" \
	-DCMAKE_PREFIX_PATH="$(TARGET_DIR)" \
	-DCMAKE_INCLUDE_PATH="$(TARGET_INCLUDE_DIR)" \
	-DCMAKE_C_COMPILER="$(TARGET)-gcc" \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) -DNDEBUG" \
	-DCMAKE_CXX_COMPILER="$(TARGET)-g++" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CFLAGS) -DNDEBUG" \
	-DCMAKE_LINKER="$(TARGET)-ld" \
	-DCMAKE_AR="$(TARGET)-ar" \
	-DCMAKE_NM="$(TARGET)-nm" \
	-DCMAKE_OBJDUMP="$(TARGET)-objdump" \
	-DCMAKE_RANLIB="$(TARGET)-ranlib" \
	-DCMAKE_STRIP="$(TARGET)-strip"

CMAKE = \
	rm -f CMakeCache.txt; \
	cmake --no-warn-unused-cli $(CMAKE_OPTS)

GITHUB			= https://github.com
BITBUCKET		= https://bitbucket.org
BITBUCKET_SSH		= git@bitbucket.org

NI_GIT			= $(BITBUCKET_SSH):neutrino-images
NI_NEUTRINO		= ni-neutrino-hd
NI_NEUTRINO_BRANCH	?= ni/mp/tuxbox
NI_NEUTRINO-PLUGINS	= ni-neutrino-plugins

BUILD-GENERIC-PC	= build-generic-pc
NI_BUILD-GENERIC-PC	= ni-build-generic-pc
NI_DRIVERS-BIN		= ni-drivers-bin
NI_LIBSTB-HAL		= ni-libstb-hal
NI_LINUX-KERNEL		= ni-linux-kernel
NI_LOGO-STUFF		= ni-logo-stuff
NI_OFGWRITE		= ni-ofgwrite
NI_OPENTHREADS		= ni-openthreads
NI_RTMPDUMP		= ni-rtmpdump
NI_STREAMRIPPER		= ni-streamripper

# Note: NI_FFMPEG-variables are only used for Coolstream-builds
#
# ffmpeg/master is currently not mature enough for daily use
# if you want to help testing you can enable it here
NI_FFMPEG		= ni-ffmpeg
NI_FFMPEG_BRANCH	?= ni/ffmpeg/2.8
#NI_FFMPEG_BRANCH	?= ni/ffmpeg/master
#NI_FFMPEG_BRANCH	?= ffmpeg/master

TUXBOX_GIT		= $(GITHUB)/tuxbox-neutrino
TUXBOX_NEUTRINO		= gui-neutrino
TUXBOX_NEUTRINO_BRANCH	?= master
TUXBOX_LIBSTB-HAL	= library-stb-hal
TUXBOX_REMOTE_REPO	= tuxbox

TANGO_REMOTE_REPO	= tango
