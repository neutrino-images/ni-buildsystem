#
# set up build environment for other makefiles
#
# -----------------------------------------------------------------------------

LD_LIBRARY_PATH =
export LD_LIBRARY_PATH

# -----------------------------------------------------------------------------

TARGET_VENDOR = NI-Buildsystem
TARGET_BOX = "$(shell echo $(BOXTYPE) | sed 's/.*/\u&/') $(BOXNAME) ($(BOXMODEL))"

TARGET_OS = linux

# -----------------------------------------------------------------------------

ifeq ($(BOXSERIES),hd1)
  DRIVERS_BIN_DIR        = $(BOXTYPE)/$(BOXFAMILY)
  CORTEX_STRINGS_LDFLAG  =
  TARGET                 = arm-cx2450x-linux-gnueabi
  TARGET_OPTIMIZATION    = -Os
  TARGET_DEBUGGING       = -g
  TARGET_ARCH            = arm
  TARGET_CPU             = armv6
  TARGET_ABI             = -march=$(TARGET_CPU) -mfloat-abi=soft -mlittle-endian
  TARGET_ENDIAN          = little
  TARGET_EXTRA_CFLAGS    = -fdata-sections -ffunction-sections
  TARGET_EXTRA_LDFLAGS   = -Wl,--gc-sections
  CXX11_ABI              =

else ifeq ($(BOXSERIES),hd2)
  DRIVERS_BIN_DIR        = $(BOXTYPE)/$(BOXFAMILY)
  CORTEX_STRINGS_LDFLAG  = -lcortex-strings
  TARGET                 = arm-cortex-linux-uclibcgnueabi
  TARGET_OPTIMIZATION    = -O2
  TARGET_DEBUGGING       = -g
  TARGET_ARCH            = arm
  TARGET_CPU             = armv7-a
  TARGET_ABI             = -march=$(TARGET_CPU) -mtune=cortex-a9 -mfpu=vfpv3-d16 -mfloat-abi=hard -mlittle-endian
  TARGET_ENDIAN          = little
  TARGET_EXTRA_CFLAGS    =
  TARGET_EXTRA_LDFLAGS   =
  ifeq ($(BOXMODEL),kronos_v2)
    TARGET_OPTIMIZATION  = -Os
    TARGET_EXTRA_CFLAGS  = -fdata-sections -ffunction-sections
    TARGET_EXTRA_LDFLAGS = -Wl,--gc-sections
  endif
  CXX11_ABI              = -D_GLIBCXX_USE_CXX11_ABI=0

else ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
  DRIVERS_BIN_DIR        = $(BOXTYPE)/$(BOXMODEL)
  CORTEX_STRINGS_LDFLAG  = -lcortex-strings
  TARGET                 = arm-cortex-linux-gnueabihf
  TARGET_OPTIMIZATION    = -O2
  TARGET_DEBUGGING       = -g
  TARGET_ARCH            = arm
  TARGET_CPU             = armv7ve
  TARGET_ABI             = -march=$(TARGET_CPU) -mtune=cortex-a15 -mfpu=neon-vfpv4 -mfloat-abi=hard
  TARGET_ENDIAN          = little
  TARGET_EXTRA_CFLAGS    =
  TARGET_EXTRA_LDFLAGS   =
  CXX11_ABI              =

else ifeq ($(BOXSERIES),$(filter $(BOXSERIES),vuduo))
  DRIVERS_BIN_DIR        = $(BOXTYPE)/$(BOXMODEL)
  CORTEX_STRINGS_LDFLAG  =
  TARGET                 = mipsel-unknown-linux-gnu
  TARGET_OPTIMIZATION    = -O2
  TARGET_DEBUGGING       = -g
  TARGET_ARCH            = mips
  TARGET_CPU             = mips32
  TARGET_ABI             = -march=$(TARGET_CPU) -mtune=mips32
  TARGET_ENDIAN          = little
  TARGET_EXTRA_CFLAGS    =
  TARGET_EXTRA_LDFLAGS   =
  CXX11_ABI              =

endif

# -----------------------------------------------------------------------------

BASE_DIR     := $(CURDIR)
DL_DIR        = $(BASE_DIR)/download
BUILD_DIR     = $(BASE_DIR)/build_tmp
DEPS_DIR      = $(BASE_DIR)/deps
D             = $(DEPS_DIR)
SOURCE_DIR   ?= $(BASE_DIR)/source
MAKE_DIR      = $(BASE_DIR)/make
LOCAL_DIR     = $(BASE_DIR)/local
STAGING_DIR   = $(BASE_DIR)/staging
IMAGE_DIR     = $(STAGING_DIR)/images
UPDATE_DIR    = $(STAGING_DIR)/updates
CROSS_BASE    = $(BASE_DIR)/cross
CROSS_DIR    ?= $(CROSS_BASE)/$(TARGET_ARCH)-$(TARGET_OS)-$(KERNEL_VERSION)
STATIC_BASE   = $(BASE_DIR)/static
STATIC_DIR    = $(STATIC_BASE)/$(TARGET_ARCH)-$(TARGET_OS)-$(KERNEL_VERSION)
SKEL_ROOT     = $(BASE_DIR)/skel-root/$(BOXSERIES)
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
  SKEL_ROOT   = $(BASE_DIR)/skel-root/vuplus
endif
TARGET_FILES  = $(BASE_DIR)/skel-root/general
PACKAGE_DIR   = $(BASE_DIR)/package
SUPPORT_DIR   = $(BASE_DIR)/support

MAINTAINER   ?= unknown

# -----------------------------------------------------------------------------

include make/environment-host.mk
include make/environment-target.mk

STATIC_libdir = $(STATIC_DIR)/$(prefix)/lib

# -----------------------------------------------------------------------------

HOST_CPPFLAGS   = -I$(HOST_DIR)/include
HOST_CFLAGS    ?= -O2
HOST_CFLAGS    += $(HOST_CPPFLAGS)
HOST_CXXFLAGS  += $(HOST_CFLAGS)
HOST_LDFLAGS   += -L$(HOST_DIR)/lib -Wl,-rpath,$(HOST_DIR)/lib

TARGET_CFLAGS   = -pipe $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_ABI) $(TARGET_EXTRA_CFLAGS) $(CXX11_ABI) -I$(TARGET_includedir)
TARGET_CPPFLAGS = $(TARGET_CFLAGS)
TARGET_CXXFLAGS = $(TARGET_CFLAGS)
TARGET_LDFLAGS  = $(CORTEX_STRINGS_LDFLAG) $(TARGET_EXTRA_LDFLAGS)
TARGET_LDFLAGS += -L$(TARGET_base_libdir) -L$(TARGET_libdir)
TARGET_LDFLAGS += -Wl,-rpath,$(TARGET_base_libdir),-rpath,$(TARGET_libdir)
TARGET_LDFLAGS += -Wl,-rpath-link,$(TARGET_base_libdir),-rpath-link,$(TARGET_libdir)
TARGET_LDFLAGS += -Wl,-O1

TARGET_CROSS    = $(TARGET)-

# gcc-4.7 and later ships with wrappers that will automatically pass
# arguments to the binutils tools. Those are paths to necessary linker
# plugins.
TARGET_GCC_WRAPPERS_PREFIX = gcc-

# Define TARGET_xx variables for all common binutils/gcc
TARGET_AR       = $(TARGET_CROSS)$(TARGET_GCC_WRAPPERS_PREFIX)ar
TARGET_AS       = $(TARGET_CROSS)as
TARGET_CC       = $(TARGET_CROSS)gcc
TARGET_CPP      = $(TARGET_CROSS)cpp
TARGET_CXX      = $(TARGET_CROSS)g++
TARGET_LD       = $(TARGET_CROSS)ld
TARGET_NM       = $(TARGET_CROSS)$(TARGET_GCC_WRAPPERS_PREFIX)nm
TARGET_RANLIB   = $(TARGET_CROSS)$(TARGET_GCC_WRAPPERS_PREFIX)ranlib
TARGET_READELF  = $(TARGET_CROSS)readelf
TARGET_OBJCOPY  = $(TARGET_CROSS)objcopy
TARGET_OBJDUMP  = $(TARGET_CROSS)objdump
TARGET_STRIP    = $(TARGET_CROSS)strip

GNU_HOST_NAME  := $(shell support/gnuconfig/config.guess)

# -----------------------------------------------------------------------------

# search path(s) for all prerequisites
VPATH = $(DEPS_DIR) $(HOST_DEPS_DIR)

PATH := $(HOST_DIR)/bin:$(HOST_DIR)/sbin:$(CROSS_DIR)/bin:$(PATH)

# -----------------------------------------------------------------------------

PKG_CONFIG = $(HOST_DIR)/bin/$(TARGET)-pkg-config
PKG_CONFIG_LIBDIR = $(TARGET_base_libdir):$(TARGET_libdir)
PKG_CONFIG_PATH = $(TARGET_base_libdir)/pkgconfig:$(TARGET_libdir)/pkgconfig
PKG_CONFIG_SYSROOT_DIR=$(TARGET_DIR)

# -----------------------------------------------------------------------------

include package/pkg-utils.mk
include package/pkg-configuration.mk

# -----------------------------------------------------------------------------

GITHUB			= https://github.com
GITHUB_SSH		= git@github.com
BITBUCKET		= https://bitbucket.org
BITBUCKET_SSH		= git@bitbucket.org

GNU_MIRROR		= http://ftp.gnu.org/pub/gnu
KERNEL_MIRROR		= https://cdn.kernel.org/pub

NI_PUBLIC		= $(GITHUB)/neutrino-images
NI_PRIVATE		= $(BITBUCKET_SSH):neutrino-images

NI_NEUTRINO		= ni-neutrino
NI_NEUTRINO_PLUGINS	= ni-neutrino-plugins

BUILD_GENERIC_PC	= build-generic-pc
NI_BUILD_GENERIC_PC	= ni-build-generic-pc
NI_DRIVERS_BIN		= ni-drivers-bin
NI_FFMPEG		= ni-ffmpeg
NI_LIBSTB_HAL		= ni-libstb-hal
NI_LINUX_KERNEL		= ni-linux-kernel
NI_LOGO_STUFF		= ni-logo-stuff
NI_OFGWRITE		= ni-ofgwrite
NI_OPENTHREADS		= ni-openthreads
NI_RTMPDUMP		= ni-rtmpdump
NI_STREAMRIPPER		= ni-streamripper
