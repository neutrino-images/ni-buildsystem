# set up environment for other makefiles

NUM_CPUS=$$(expr `grep -c ^processor /proc/cpuinfo`)

CONFIG_SITE =
export CONFIG_SITE

LD_LIBRARY_PATH =
export LD_LIBRARY_PATH

SHELL := /bin/bash

BASE_DIR    := $(shell pwd)

# assign box environment
BOXTYPE   ?= coolstream
BOXSERIES ?=
BOXFAMILY ?=
BOXMODEL  ?=

ifeq ($(BOXTYPE), coolstream)

# BOXTYPE                   coolstream
#                          /          \
# BOXSERIES              hd1          hd2
#                        /           /   \
# BOXFAMILY           nevis      apollo kronos
#                      /        /     | |     \
# BOXMODEL          nevis apollo shiner kronos kronos_v2

BOXTYPE_SC = cst
BOXARCH = arm

# assign by given BOXSERIES
ifneq ($(BOXSERIES),)
  ifeq ($(BOXSERIES), hd1)
    BOXFAMILY = nevis
    BOXMODEL = nevis
  else ifeq ($(BOXSERIES), hd2)
    BOXFAMILY = apollo
    BOXMODEL = apollo
  else
    $(error $(BOXTYPE) BOXSERIES $(BOXSERIES) not supported)
  endif

# assign by given BOXFAMILY
else ifneq ($(BOXFAMILY),)
  ifeq ($(BOXFAMILY), nevis)
    BOXSERIES = hd1
    BOXMODEL = nevis
  else ifeq ($(BOXFAMILY), apollo)
    BOXSERIES = hd2
    BOXMODEL = apollo
  else ifeq ($(BOXFAMILY), kronos)
    BOXSERIES = hd2
    BOXMODEL = kronos
  else
    $(error $(BOXTYPE) BOXFAMILY $(BOXFAMILY) not supported)
  endif

# assign by given BOXMODEL
else ifneq ($(BOXMODEL),)
  ifeq ($(BOXMODEL), nevis)
    BOXSERIES = hd1
    BOXFAMILY = nevis
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), apollo shiner))
    BOXSERIES = hd2
    BOXFAMILY = apollo
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), kronos kronos_v2))
    BOXSERIES = hd2
    BOXFAMILY = kronos
  else
    $(error $(BOXTYPE) BOXMODEL $(BOXMODEL) not supported)
  endif

endif

else
  $(error BOXTYPE $(BOXTYPE) not supported)
endif

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

MAINTAINER  ?= NI-Team
FLAVOUR     ?= ni-neutrino-hd

TARGET       = arm-cx2450x-linux-gnueabi
ifeq ($(BOXSERIES), hd2)
  TARGET     = arm-cortex-linux-uclibcgnueabi
endif

DRIVERS_DIR  = nevis
KVERSION     = 2.6.34.13
KBRANCH      = ni/2.6.34.x
KTECHSTR     =
ifeq ($(BOXSERIES), hd2)
  KVERSION   = 3.10.93
  KBRANCH    = ni/3.10.x
  ifeq ($(BOXFAMILY), apollo)
    DRIVERS_DIR = apollo-3.x
    KTECHSTR = hd849x
  endif
  ifeq ($(BOXFAMILY), kronos)
    DRIVERS_DIR = kronos-3.x
    KTECHSTR = en75x1
  endif
endif
KSTRING      = NI $(shell echo $(BOXMODEL) | sed 's/.*/\u&/') Kernel

KVERSION_FULL = $(KVERSION)
ifeq ($(BOXMODEL), nevis)
  KVERSION_FULL := $(KVERSION_FULL)-$(BOXMODEL)
endif

WHOAMI       := $(shell id -un)
ARCHIVE      = $(BASE_DIR)/download
BUILD_TMP    = $(BASE_DIR)/build_tmp
D            = $(BASE_DIR)/deps
DEPDIR       = $(D)
HOSTPREFIX   = $(BASE_DIR)/host
TARGETPREFIX ?= $(BASE_DIR)/root
SOURCE_DIR   = $(BASE_DIR)/source
MAKE_DIR     = $(BASE_DIR)/make
STAGING_DIR  = $(BASE_DIR)/staging
LOCAL_DIR    = $(BASE_DIR)/local
IMAGE_DIR    = $(STAGING_DIR)/images
UPDATE_DIR   = $(STAGING_DIR)/updates
STATIC_DIR   = $(BASE_DIR)/static/$(BOXARCH)/$(BOXSERIES)
HELPERS_DIR  = $(BASE_DIR)/helpers
CROSS_BASE   = $(BASE_DIR)/cross/$(BOXARCH)/$(BOXSERIES)
CROSS_DIR   ?= $(CROSS_BASE)
BUILD       ?= $(shell /usr/share/libtool/config.guess 2>/dev/null || /usr/share/libtool/config/config.guess 2>/dev/null || /usr/share/misc/config.guess)
CCACHE       = /usr/bin/ccache

CONFIGS      = $(BASE_DIR)/archive-configs
PATCHES      = $(BASE_DIR)/archive-patches
IMAGEFILES   = $(BASE_DIR)/archive-imagefiles
SOURCES      = $(BASE_DIR)/archive-sources

SKEL_ROOT    = $(BASE_DIR)/skel-root/$(BOXTYPE)/$(BOXSERIES)

# create debug image
DEBUG ?= no

# cortex-strings optimization
CORTEX-STRINGS =
ifeq ($(BOXSERIES), hd2)
  CORTEX-STRINGS = -lcortex-strings
endif

STATICLIB             = $(STATIC_DIR)/lib
TARGETLIB             = $(TARGETPREFIX)/lib
TARGETINCLUDE         = $(TARGETPREFIX)/include

TARGET_CFLAG_O        = -O2
TARGET_CFLAGS_ADD     =
TARGET_LDFLAGS_ADD    =
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), nevis kronos_v2))
  TARGET_CFLAG_O      = -Os
  TARGET_CFLAGS_ADD   = -fdata-sections -ffunction-sections
  TARGET_LDFLAGS_ADD  = -Wl,--gc-sections
endif

TARGET_CFLAGS         = -pipe $(TARGET_CFLAG_O) $(TARGET_CFLAGS_ADD) -g -I$(TARGETINCLUDE)
TARGET_CPPFLAGS       = $(TARGET_CFLAGS)
TARGET_CXXFLAGS       = $(TARGET_CFLAGS)
TARGET_LDFLAGS        = $(CORTEX-STRINGS) -Wl,-O1 $(TARGET_LDFLAGS_ADD) -L$(TARGETLIB)
TARGET_LDFLAGS_RPATH  = $(CORTEX-STRINGS) -Wl,-O1 $(TARGET_LDFLAGS_ADD) -L$(TARGETLIB) -Wl,-rpath-link,$(TARGETLIB)

VPATH = $(D)

TERM_RED	= \033[40;0;31m
TERM_RED_BOLD	= \033[40;1;31m
TERM_GREEN	= \033[40;0;32m
TERM_GREEN_BOLD	= \033[40;1;32m
TERM_YELLOW	= \033[40;0;33m
TERM_YELLOW_BOLD= \033[40;1;33m
TERM_NORMAL	= \033[0m

N_HD_SOURCE ?= $(SOURCE_DIR)/$(FLAVOUR)

PATH := $(HOSTPREFIX)/bin:$(CROSS_DIR)/bin:$(HELPERS_DIR):$(PATH)

PKG_CONFIG = $(HOSTPREFIX)/bin/$(TARGET)-pkg-config
PKG_CONFIG_LIBDIR = $(TARGETLIB)
PKG_CONFIG_PATH = $(PKG_CONFIG_LIBDIR)/pkgconfig

# helper-"functions":
REWRITE_LIBTOOL = sed -i "s,^libdir=.*,libdir='$(TARGETLIB)'," $(TARGETLIB)
REWRITE_LIBTOOL_STATIC = sed -i "s,^libdir=.*,libdir='$(TARGETLIB)'," $(STATICLIB)
REWRITE_PKGCONF = sed -i "s,^prefix=.*,prefix='$(TARGETPREFIX)',"

# unpack tarballs, clean up
UNTAR = tar -C $(BUILD_TMP) -xf $(ARCHIVE)
REMOVE = rm -rf $(BUILD_TMP)/.remove $(TARGETPREFIX)/.remove $(BUILD_TMP)
PATCH = patch -p1 -i $(PATCHES)

# wget tarballs into archive directory
WGET = wget -t3 -T60 -c -P $(ARCHIVE)

CONFIGURE_OPTS = \
	--build=$(BUILD) --host=$(TARGET)

BUILDENV = \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

BUILDENV_NON_CORTEX = \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="-Wl,-O1 -L$(TARGETLIB)" \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

BUILDENV_RPATH = \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS_RPATH)" \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

CONFIGURE = \
	test -f ./configure || ./autogen.sh && \
	$(BUILDENV) \
	./configure $(CONFIGURE_OPTS)

CONFIGURE_NON_CORTEX = \
	test -f ./configure || ./autogen.sh && \
	$(BUILDENV_NON_CORTEX) \
	./configure $(CONFIGURE_OPTS)

CONFIGURE_RPATH = \
	test -f ./configure || ./autogen.sh && \
	$(BUILDENV_RPATH) \
	./configure $(CONFIGURE_OPTS)

GITHUB			= https://github.com
BITBUCKET		= https://bitbucket.org
BITBUCKET_SSH		= git@bitbucket.org

NI_GIT			= $(BITBUCKET_SSH):neutrino-images
NI_NEUTRINO		= ni-neutrino-hd
NI_NEUTRINO_BRANCH	?= ni/tuxbox

BUILD-GENERIC-PC	= build-generic-pc
NI_BUILD-GENERIC-PC	= ni-build-generic-pc

NI_LIBSTB-HAL		= ni-libstb-hal
NI_STREAMRIPPER		= ni-streamripper

NI_LINUX-KERNEL		= ni-linux-kernel
NI_DRIVERS-BIN		= ni-drivers-bin

# ffmpeg/master is currently not mature enough for daily use
# if you want to help testing you can enable it here
NI_FFMPEG		= ni-ffmpeg
#NI_FFMPEG_BRANCH	= ni/ffmpeg/2.8
NI_FFMPEG_BRANCH	= ni/ffmpeg/master

NI_OPENTHREADS		= ni-openthreads

TUXBOX_GIT		= $(GITHUB)/tuxbox-neutrino
TUXBOX_NEUTRINO		= gui-neutrino
TUXBOX_NEUTRINO_BRANCH	?= master

TUXBOX_LIBSTB-HAL	= library-stb-hal

TUXBOX_BOOTLOADER	= bootloader-uboot-cst
TUXBOX_PLUGINS		= plugins

TUXBOX_REMOTE_REPO	= tuxbox

# plugins with remote repo
NI_TUXWETTER		= ni-neutrino-plugin-tuxwetter
TUXBOX_TUXWETTER	= plugin-tuxwetter

# various
NI_LOGO_STUFF		= ni-logo-stuff
NI_SMARTHOMEINFO	= ni-neutrino-plugin-smarthomeinfo

# execute local scripts
define local-script
	@if [ -x $(LOCAL_DIR)/scripts/$(1) ]; then \
		$(LOCAL_DIR)/scripts/$(1) $(2) $(TARGETPREFIX) $(BUILD_TMP); \
	fi
endef
