#
# set up build environment for other makefiles
#
# -----------------------------------------------------------------------------

LD_LIBRARY_PATH =
export LD_LIBRARY_PATH

# -----------------------------------------------------------------------------

ifndef MAKE
MAKE := make
endif
ifndef HOSTMAKE
HOSTMAKE = $(MAKE)
endif
HOSTMAKE := $(shell which $(HOSTMAKE) || type -p $(HOSTMAKE) || echo make)

PARALLEL_JOBS := $(shell echo \
	$$((1 + `getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1`)))

MAKE1 := $(HOSTMAKE) -j1
override MAKE = $(HOSTMAKE) \
	$(if $(findstring j,$(filter-out --%,$(MAKEFLAGS))),,-j$(PARALLEL_JOBS))

MAKEFLAGS += --no-print-directory
#MAKEFLAGS += --silent

TARGET_VENDOR = NI-Buildsystem

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
ROOTFS        = $(BUILD_DIR)/rootfs
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd5x))
  ROOTFS      = $(BUILD_DIR)/rootfs/linuxrootfs1
endif
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
CONFIGS       = $(BASE_DIR)/configs
PATCHES       = $(BASE_DIR)/patches
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
TARGET_LDFLAGS += -Wl,-rpath,$(TARGET_libdir) -Wl,-rpath-link,$(TARGET_libdir)
TARGET_LDFLAGS += -Wl,-O1

TARGET_CROSS    = $(TARGET)-

# Define TARGET_xx variables for all common binutils/gcc
TARGET_AR       = $(TARGET_CROSS)ar
TARGET_AS       = $(TARGET_CROSS)as
TARGET_CC       = $(TARGET_CROSS)gcc
TARGET_CPP      = $(TARGET_CROSS)cpp
TARGET_CXX      = $(TARGET_CROSS)g++
TARGET_LD       = $(TARGET_CROSS)ld
TARGET_NM       = $(TARGET_CROSS)nm
TARGET_RANLIB   = $(TARGET_CROSS)ranlib
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

# -----------------------------------------------------------------------------

#HOST_MAKE_ENV = \
#	$($(PKG)_MAKE_ENV)

HOST_MAKE_OPTS = \
	CC="$(HOSTCC)" \
	GCC="$(HOSTCC)" \
	CPP="$(HOSTCPP)" \
	CXX="$(HOSTCXX)" \
	LD="$(HOSTLD)" \
	AR="$(HOSTAR)" \
	AS="$(HOSTAS)" \
	NM="$(HOSTNM)" \
	OBJCOPY="$(HOSTOBJCOPY)" \
	RANLIB="$(HOSTRANLIB)"

#HOST_MAKE_OPTS += \
#	$($(PKG)_MAKE_OPTS)

#TARGET_MAKE_ENV = \
#	$($(PKG)_MAKE_ENV)

TARGET_MAKE_OPTS = \
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
	ARCH=$(TARGET_ARCH)

#TARGET_MAKE_OPTS += \
#	$($(PKG)_MAKE_OPTS)

# -----------------------------------------------------------------------------

HOST_CONFIGURE_ENV = \
	$(HOST_MAKE_OPTS) \
	CFLAGS="$(HOST_CFLAGS)" \
	CPPFLAGS="$(HOST_CPPFLAGS)" \
	CXXFLAGS="$(HOST_CXXFLAGS)" \
	LDFLAGS="$(HOST_LDFLAGS)"

HOST_CONFIGURE_ENV += \
	PKG_CONFIG=/usr/bin/pkg-config \
	PKG_CONFIG_LIBDIR="$(HOST_DIR)/lib/pkgconfig"

HOST_CONFIGURE_ENV += \
	$($(PKG)_CONF_ENV)

HOST_CONFIGURE_OPTS = \
	--prefix=$(HOST_DIR) \
	--sysconfdir=$(HOST_DIR)/etc

HOST_CONFIGURE_OPTS += \
	$($(PKG)_CONF_OPTS)

TARGET_CONFIGURE_ENV = \
	$(TARGET_MAKE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"

TARGET_CONFIGURE_ENV += \
	PKG_CONFIG=$(PKG_CONFIG) \
	PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" \
	PKG_CONFIG_SYSROOT_DIR=$(PKG_CONFIG_SYSROOT_DIR)

TARGET_CONFIGURE_ENV += \
	$($(PKG)_CONF_ENV)

TARGET_CONFIGURE_OPTS = \
	--build=$(GNU_HOST_NAME) \
	--host=$(TARGET) \
	--target=$(TARGET) \
	\
	--program-prefix="" \
	--program-suffix="" \
	\
	--prefix=$(prefix) \
	--exec_prefix=$(exec_prefix) \
	--sysconfdir=$(sysconfdir) \
	--localstatedir=$(localstatedir) \
	\
	--mandir=$(REMOVE_mandir) \
	--infodir=$(REMOVE_infodir)

TARGET_CONFIGURE_OPTS += \
	$($(PKG)_CONF_OPTS)

HOST_CONFIGURE = \
	if [ "$($(PKG)_AUTORECONF)" == "YES" ]; then \
		$(call MESSAGE,"Autoreconfiguring"); \
		$($(PKG)_AUTORECONF_ENV) autoreconf -fi $($(PKG)_AUTORECONF_OPTS); \
	fi; \
	test -f ./configure || ./autogen.sh && \
	CONFIG_SITE=/dev/null \
	$(HOST_CONFIGURE_ENV) ./configure $(HOST_CONFIGURE_OPTS)

TARGET_CONFIGURE = \
	if [ "$($(PKG)_AUTORECONF)" == "YES" ]; then \
		$(call MESSAGE,"Autoreconfiguring"); \
		$($(PKG)_AUTORECONF_ENV) autoreconf -fi $($(PKG)_AUTORECONF_OPTS); \
	fi; \
	test -f ./configure || ./autogen.sh && \
	CONFIG_SITE=/dev/null \
	$(TARGET_CONFIGURE_ENV) ./configure $(TARGET_CONFIGURE_OPTS)

CONFIGURE = $(TARGET_CONFIGURE)

# -----------------------------------------------------------------------------

HOST_CMAKE_ENV = \
	$($(PKG)_CONF_ENV)

HOST_CMAKE_OPTS += \
	--no-warn-unused-cli

HOST_CMAKE_OPTS += \
	-DENABLE_STATIC=OFF \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_DOC=OFF \
	-DBUILD_DOCS=OFF \
	-DBUILD_EXAMPLE=OFF \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_TEST=OFF \
	-DBUILD_TESTS=OFF \
	-DBUILD_TESTING=OFF \
	-DCMAKE_COLOR_MAKEFILE=OFF \
	-DCMAKE_INSTALL_PREFIX="$(HOST_DIR)" \
	-DCMAKE_PREFIX_PATH="$(HOST_DIR)"

HOST_CMAKE_OPTS += \
	$($(PKG)_CONF_OPTS)

TARGET_CMAKE_ENV = \
	$($(PKG)_CONF_ENV)

TARGET_CMAKE_OPTS = \
	--no-warn-unused-cli

TARGET_CMAKE_OPTS += \
	-DENABLE_STATIC=OFF \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_DOC=OFF \
	-DBUILD_DOCS=OFF \
	-DBUILD_EXAMPLE=OFF \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_TEST=OFF \
	-DBUILD_TESTS=OFF \
	-DBUILD_TESTING=OFF \
	-DCMAKE_COLOR_MAKEFILE=OFF \
	-DCMAKE_BUILD_TYPE="None" \
	-DCMAKE_SYSTEM_NAME="Linux" \
	-DCMAKE_SYSTEM_PROCESSOR="$(TARGET_ARCH)" \
	-DCMAKE_INSTALL_PREFIX="$(prefix)" \
	-DCMAKE_INSTALL_DOCDIR="$(REMOVE_docdir)" \
	-DCMAKE_INSTALL_MANDIR="$(REMOVE_mandir)" \
	-DCMAKE_PREFIX_PATH="$(TARGET_DIR)" \
	-DCMAKE_INCLUDE_PATH="$(TARGET_includedir)" \
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

TARGET_CMAKE_OPTS += \
	$($(PKG)_CONF_OPTS)

HOST_CMAKE = \
	rm -f CMakeCache.txt; \
	$(HOST_CMAKE_ENV) cmake $(HOST_CMAKE_OPTS)

TARGET_CMAKE = \
	rm -f CMakeCache.txt; \
	$(TARGET_CMAKE_ENV) cmake $(TARGET_CMAKE_OPTS)

CMAKE = $(TARGET_CMAKE)

# -----------------------------------------------------------------------------

define meson-cross-config # (dest dir)
	mkdir -p $(1)
	( \
		echo "# Note: Buildsystems's and Meson's terminologies differ about the meaning"; \
		echo "# of 'build', 'host' and 'target':"; \
		echo "# - Buildsystems's 'host' is Meson's 'build'"; \
		echo "# - Buildsystems's 'target' is Meson's 'host'"; \
		echo ""; \
		echo "[binaries]"; \
		echo "c = '$(TARGET_CC)'"; \
		echo "cpp = '$(TARGET_CXX)'"; \
		echo "ar = '$(TARGET_AR)'"; \
		echo "strip = '$(TARGET_STRIP)'"; \
		echo "pkgconfig = '$(PKG_CONFIG)'"; \
		echo ""; \
		echo "[built-in options]"; \
		echo "c_args = '$(TARGET_CFLAGS)'"; \
		echo "c_link_args = '$(TARGET_LDFLAGS)'"; \
		echo "cpp_args = '$(TARGET_CXXFLAGS)'"; \
		echo "cpp_link_args = '$(TARGET_LDFLAGS)'"; \
		echo ""; \
		echo "[properties]"; \
		echo "needs_exe_wrapper = true"; \
		echo "sys_root = '$(TARGET_DIR)'"; \
		echo "pkg_config_libdir = '$(PKG_CONFIG_LIBDIR)'"; \
		echo ""; \
		echo "[host_machine]"; \
		echo "system = 'linux'"; \
		echo "cpu_family = '$(TARGET_ARCH)'"; \
		echo "cpu = '$(TARGET_CPU)'"; \
		echo "endian = '$(TARGET_ENDIAN)'" \
	) > $(1)/meson-cross.config
endef

MESON_CONFIGURE = \
	$(call meson-cross-config,$(PKG_BUILD_DIR)/build); \
	unset CC CXX CPP LD AR NM STRIP; \
	PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" \
	$(HOST_MESON) \
		--buildtype=release \
		--cross-file $(PKG_BUILD_DIR)/build/meson-cross.config \
		-Dstrip=false \
		$(PKG_BUILD_DIR) $(PKG_BUILD_DIR)/build

NINJA = \
	$(HOST_NINJA) -C $(PKG_BUILD_DIR)/build

NINJA_INSTALL = DESTDIR=$(TARGET_DIR) \
	$(HOST_NINJA) -C $(PKG_BUILD_DIR)/build install

# -----------------------------------------------------------------------------

include package/Makefile

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
