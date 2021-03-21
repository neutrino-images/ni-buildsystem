#
# makefile to build all needed host-binaries
#
# -----------------------------------------------------------------------------

$(HOST_DIR):
	$(INSTALL) -d $(HOST_DIR)
	$(INSTALL) -d $(HOST_DIR)/bin
	$(INSTALL) -d $(HOST_DEPS_DIR)

# -----------------------------------------------------------------------------

host-tools: $(BUILD_DIR) $(HOST_DIR) \
	host-pkgconf \
	$(PKG_CONFIG) \
	host-mtd-utils \
	host-u-boot \
	host-zic \
	host-parted \
	host-dosfstools \
	host-mtools \
	host-e2fsprogs \
	host-lua \
	host-luarocks \
	host-ccache

# -----------------------------------------------------------------------------

pkg-config-preqs:
	@PATH=$(subst $(HOST_DIR)/bin:$(HOST_DIR)/sbin:,,$(PATH)); \
	if ! pkg-config --exists glib-2.0; then \
		echo "pkg-config and glib2-devel packages are needed for building cross-pkg-config."; false; \
	fi

# -----------------------------------------------------------------------------

HOST_PKG_CONFIG = $(HOST_DIR)/bin/pkg-config

# -----------------------------------------------------------------------------

HOST_PKGCONF_VERSION = 1.7.3
HOST_PKGCONF_DIR = pkgconf-$(HOST_PKGCONF_VERSION)
HOST_PKGCONF_SOURCE = pkgconf-$(HOST_PKGCONF_VERSION).tar.gz
HOST_PKGCONF_SITE = https://distfiles.dereferenced.org/pkgconf

$(DL_DIR)/$(HOST_PKGCONF_SOURCE):
	$(download) $(HOST_PKGCONF_SITE)/$(HOST_PKGCONF_SOURCE)

host-pkgconf: $(DL_DIR)/$(HOST_PKGCONF_SOURCE) | $(HOST_DIR) pkg-config-preqs
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(HOST_CONFIGURE);\
		$(MAKE); \
		$(MAKE) install
	$(INSTALL_EXEC) $(PKG_FILES_DIR)/pkg-config.in $(HOST_PKG_CONFIG)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

PKG_CONFIG_DEPENDENCIES = host-pkgconf

$(PKG_CONFIG): $(PKG_CONFIG_DEPENDENCIES) | $(HOST_DIR)
	ln -sf pkg-config $(@)

# -----------------------------------------------------------------------------

HOST_MTD_UTILS_VERSION = 2.0.2
HOST_MTD_UTILS_DIR = mtd-utils-$(HOST_MTD_UTILS_VERSION)
HOST_MTD_UTILS_SOURCE = mtd-utils-$(HOST_MTD_UTILS_VERSION).tar.bz2
HOST_MTD_UTILS_SITE = ftp://ftp.infradead.org/pub/mtd-utils

$(DL_DIR)/$(HOST_MTD_UTILS_SOURCE):
	$(download) $(HOST_MTD_UTILS_SITE)/$(HOST_MTD_UTILS_SOURCE)

HOST_MTD_UTILS_CONF_ENV = \
	ZLIB_CFLAGS=" " \
	ZLIB_LIBS="-lz" \
	UUID_CFLAGS=" " \
	UUID_LIBS="-luuid"

HOST_MTD_UTILS_CONF_OPTS = \
	--without-ubifs \
	--without-xattr \
	--disable-tests

host-mtd-utils: $(DL_DIR)/$(HOST_MTD_UTILS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(HOST_CONFIGURE);\
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_U_BOOT_VERSION = 2018.09
HOST_U_BOOT_DIR = u-boot-$(HOST_U_BOOT_VERSION)
HOST_U_BOOT_SOURCE = u-boot-$(HOST_U_BOOT_VERSION).tar.bz2
HOST_U_BOOT_SITE = ftp://ftp.denx.de/pub/u-boot

$(DL_DIR)/$(HOST_U_BOOT_SOURCE):
	$(download) $(HOST_U_BOOT_SITE)/$(HOST_U_BOOT_SOURCE)

HOST_MKIMAGE = $(HOST_DIR)/bin/mkimage

host-u-boot: $(DL_DIR)/$(HOST_U_BOOT_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(MAKE) defconfig; \
		$(MAKE) silentoldconfig; \
		$(MAKE) tools-only
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/tools/mkimage $(HOST_MKIMAGE)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_ZIC_VERSION = 2020f
HOST_ZIC_DIR = tzcode$(HOST_ZIC_VERSION)
HOST_ZIC_SOURCE = tzcode$(HOST_ZIC_VERSION).tar.gz
HOST_ZIC_SITE = ftp://ftp.iana.org/tz/releases

$(DL_DIR)/$(HOST_ZIC_SOURCE):
	$(download) $(HOST_ZIC_SITE)/$(HOST_ZIC_SOURCE)

HOST_ZIC = $(HOST_DIR)/sbin/zic

host-zic: $(DL_DIR)/$(HOST_ZIC_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(MKDIR)/$(PKG_DIR)
	$(CHDIR)/$(PKG_DIR); \
		tar -xf $(DL_DIR)/$(PKG_SOURCE); \
		$(APPLY_PATCHES); \
		$(MAKE) zic
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/zic $(HOST_ZIC)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_PARTED_VERSION = 3.2
HOST_PARTED_DIR = parted-$(HOST_PARTED_VERSION)
HOST_PARTED_SOURCE = parted-$(HOST_PARTED_VERSION).tar.xz
HOST_PARTED_SITE = $(GNU_MIRROR)/parted

$(DL_DIR)/$(HOST_PARTED_SOURCE):
	$(download) $(HOST_PARTED_SITE)/$(HOST_PARTED_SOURCE)

HOST_PARTED_AUTORECONF = YES

HOST_PARTED_CONF_OPTS = \
	--enable-static \
	--disable-shared \
	--disable-device-mapper \
	--without-readline

host-parted: $(DL_DIR)/$(HOST_PARTED_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(HOST_CONFIGURE);\
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_DOSFSTOOLS_VERSION = 4.1
HOST_DOSFSTOOLS_DIR = dosfstools-$(HOST_DOSFSTOOLS_VERSION)
HOST_DOSFSTOOLS_SOURCE = dosfstools-$(HOST_DOSFSTOOLS_VERSION).tar.xz
HOST_DOSFSTOOLS_SITE = https://github.com/dosfstools/dosfstools/releases/download/v$(HOST_DOSFSTOOLS_VERSION)

$(DL_DIR)/$(HOST_DOSFSTOOLS_SOURCE):
	$(download) $(HOST_DOSFSTOOLS_SITE)/$(HOST_DOSFSTOOLS_SOURCE)

HOST_DOSFSTOOLS_CONF_OPTS = \
	--without-udev

host-dosfstools: $(DL_DIR)/$(HOST_DOSFSTOOLS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(HOST_CONFIGURE);\
		$(MAKE); \
		$(MAKE) install
	ln -sf mkfs.fat $(HOST_DIR)/sbin/mkfs.vfat
	ln -sf mkfs.fat $(HOST_DIR)/sbin/mkfs.msdos
	ln -sf mkfs.fat $(HOST_DIR)/sbin/mkdosfs
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_MTOOLS_VERSION = 4.0.19
HOST_MTOOLS_DIR = mtools-$(HOST_MTOOLS_VERSION)
HOST_MTOOLS_SOURCE = mtools-$(HOST_MTOOLS_VERSION).tar.gz
HOST_MTOOLS_SITE = $(GNU_MIRROR)/mtools

$(DL_DIR)/$(HOST_MTOOLS_SOURCE):
	$(download) $(HOST_MTOOLS_SITE)/$(HOST_MTOOLS_SOURCE)

host-mtools: $(DL_DIR)/$(HOST_MTOOLS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(HOST_CONFIGURE);\
		$(MAKE1); \
		$(MAKE) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_E2FSPROGS_VERSION = $(E2FSPROGS_VERSION)
HOST_E2FSPROGS_DIR = e2fsprogs-$(HOST_E2FSPROGS_VERSION)
HOST_E2FSPROGS_SOURCE = e2fsprogs-$(HOST_E2FSPROGS_VERSION).tar.gz
HOST_E2FSPROGS_SITE = https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(HOST_E2FSPROGS_VERSION)

#$(DL_DIR)/$(HOST_E2FSPROGS_SOURCE):
#	$(download) $(HOST_E2FSPROGS_SITE)/$(HOST_E2FSPROGS_SOURCE)

HOST_E2FSPROGS_CONF_OPTS = \
	--enable-symlink-install \
	--with-crond-dir=no

host-e2fsprogs: $(DL_DIR)/$(HOST_E2FSPROGS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(HOST_CONFIGURE);\
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_MESON_VERSION = 0.56.0
HOST_MESON_DIR = meson-$(HOST_MESON_VERSION)
HOST_MESON_SOURCE = meson-$(HOST_MESON_VERSION).tar.gz
HOST_MESON_SITE = https://github.com/mesonbuild/meson/releases/download/$(HOST_MESON_VERSION)

$(DL_DIR)/$(HOST_MESON_SOURCE):
	$(download) $(HOST_MESON_SITE)/$(HOST_MESON_SOURCE)

HOST_MESON_DEPENDENCIES = host-ninja host-python3 host-python3-setuptools

HOST_MESON = $(HOST_DIR)/bin/meson

host-meson: $(HOST_MESON_DEPENDENCIES) $(DL_DIR)/$(HOST_MESON_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_MESON_DIR)
	$(UNTAR)/$(HOST_MESON_SOURCE)
	$(CHDIR)/$(HOST_MESON_DIR); \
		$(APPLY_PATCHES); \
		$(HOST_PYTHON_BUILD); \
		$(HOST_PYTHON_INSTALL)
	$(REMOVE)/$(HOST_MESON_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_NINJA_VERSION = 1.10.0
HOST_NINJA_DIR = ninja-$(HOST_NINJA_VERSION)
HOST_NINJA_SOURCE = ninja-$(HOST_NINJA_VERSION).tar.gz
HOST_NINJA_SITE = $(call github,ninja-build,ninja,v$(HOST_NINJA_VERSION))

$(DL_DIR)/$(HOST_NINJA_SOURCE):
	$(download) $(HOST_NINJA_SITE)/$(HOST_NINJA_SOURCE)

HOST_NINJA = $(HOST_DIR)/bin/ninja

host-ninja: $(DL_DIR)/$(HOST_NINJA_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(HOST_CMAKE); \
		$(MAKE)
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/ninja $(HOST_NINJA)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_EXPAT_VERSION = $(EXPAT_VERSION)
HOST_EXPAT_DIR = expat-$(EXPAT_VERSION)
HOST_EXPAT_SOURCE = expat-$(EXPAT_VERSION).tar.bz2
HOST_EXPAT_SITE = https://sourceforge.net/projects/expat/files/expat/$(EXPAT_VERSION)

#$(DL_DIR)/$(HOST_EXPAT_SOURCE):
#	$(download) $(HOST_EXPAT_SITE)/$(EXPAT_SOURCE)

HOST_EXPAT_CONF_OPTS = \
	--without-docbook

host-expat: $(DL_DIR)/$(HOST_EXPAT_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_EXPAT_DIR)
	$(UNTAR)/$(HOST_EXPAT_SOURCE)
	$(CHDIR)/$(HOST_EXPAT_DIR); \
		$(HOST_CONFIGURE);\
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/$(HOST_EXPAT_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_PYTHON3_VERSION = 3.9.0
HOST_PYTHON3_DIR = Python-$(HOST_PYTHON3_VERSION)
HOST_PYTHON3_SOURCE = Python-$(HOST_PYTHON3_VERSION).tar.xz
HOST_PYTHON3_SITE = https://www.python.org/ftp/python/$(HOST_PYTHON3_VERSION)

HOST_PYTHON3_BASE_DIR = lib/python$(basename $(HOST_PYTHON3_VERSION))
HOST_PYTHON3_INCLUDE_DIR = include/python$(basename $(HOST_PYTHON3_VERSION))

$(DL_DIR)/$(HOST_PYTHON3_SOURCE):
	$(download) $(HOST_PYTHON3_SITE)/$(HOST_PYTHON3_SOURCE)

HOST_PYTHON3_DEPENDENCIES = host-expat host-libffi

HOST_PYTHON3_CONF_ENV = \
	OPT="$(HOST_CFLAGS)"

HOST_PYTHON3_CONF_OPTS = \
	--without-ensurepip \
	--without-cxx-main \
	--disable-sqlite3 \
	--disable-tk \
	--with-expat=system \
	--disable-curses \
	--disable-codecs-cjk \
	--disable-nis \
	--enable-unicodedata \
	--disable-test-modules \
	--disable-idle3 \
	--disable-ossaudiodev

host-python3: $(HOST_PYTHON3_DEPENDENCIES) $(DL_DIR)/$(HOST_PYTHON3_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		#$(APPLY_PATCHES); \
		autoconf; \
		$(HOST_CONFIGURE);\
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_PYTHON3_SETUPTOOLS_VERSION = 44.0.0
HOST_PYTHON3_SETUPTOOLS_DIR = setuptools-$(HOST_PYTHON3_SETUPTOOLS_VERSION)
HOST_PYTHON3_SETUPTOOLS_SOURCE = setuptools-$(HOST_PYTHON3_SETUPTOOLS_VERSION).zip
HOST_PYTHON3_SETUPTOOLS_SITE = https://files.pythonhosted.org/packages/b0/f3/44da7482ac6da3f36f68e253cb04de37365b3dba9036a3c70773b778b485

$(DL_DIR)/$(HOST_PYTHON3_SETUPTOOLS_SOURCE):
	$(download) $(HOST_PYTHON3_SETUPTOOLS_SITE)/$(HOST_PYTHON3_SETUPTOOLS_SOURCE)

HOST_PYTHON3_SETUPTOOLS_DEPENDENCIES = host-python3

host-python3-setuptools: $(HOST_PYTHON3_SETUPTOOLS_DEPENDENCIES) $(DL_DIR)/$(HOST_PYTHON3_SETUPTOOLS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNZIP)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(HOST_PYTHON_BUILD); \
		$(HOST_PYTHON_INSTALL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_LIBFFI_VERSION = $(LIBFFI_VERSION)
HOST_LIBFFI_DIR = libffi-$(HOST_LIBFFI_VERSION)
HOST_LIBFFI_SOURCE = libffi-$(HOST_LIBFFI_VERSION).tar.gz
HOST_LIBFFI_SITE = https://github.com/libffi/libffi/releases/download/v$(HOST_LIBFFI_VERSION)

#$(DL_DIR)/$(HOST_LIBFFI_SOURCE):
#	$(download) $(HOST_LIBFFI_SITE)/$(HOST_LIBFFI_SOURCE)

host-libffi: $(DL_DIR)/$(HOST_LIBFFI_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(HOST_CONFIGURE);\
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_LUA_VERSION = $(LUA_VERSION)
HOST_LUA_DIR = lua-$(HOST_LUA_VERSION)
HOST_LUA_SOURCE = lua-$(HOST_LUA_VERSION).tar.gz
HOST_LUA_SITE = http://www.lua.org/ftp

#$(DL_DIR)/$(HOST_LUA_SOURCE):
#	$(download) $(HOST_LUA_SITE)/$(HOST_LUA_SOURCE)

HOST_LUA_PATCH  = lua-01-fix-LUA_ROOT.patch
HOST_LUA_PATCH += lua-01-remove-readline.patch

HOST_LUA = $(HOST_DIR)/bin/lua

host-lua: $(DL_DIR)/$(HOST_LUA_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(call apply_patches,$(addprefix $(PKG_PATCHES_DIR)/,$(PKG_PATCH))); \
		$(MAKE) linux; \
		$(MAKE) install INSTALL_TOP=$(HOST_DIR) INSTALL_MAN=$(HOST_DIR)/share/man/man1
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_LUAROCKS_VERSION = 3.1.3
HOST_LUAROCKS_DIR = luarocks-$(HOST_LUAROCKS_VERSION)
HOST_LUAROCKS_SOURCE = luarocks-$(HOST_LUAROCKS_VERSION).tar.gz
HOST_LUAROCKS_SITE = https://luarocks.github.io/luarocks/releases

$(DL_DIR)/$(HOST_LUAROCKS_SOURCE):
	$(download) $(HOST_LUAROCKS_SITE)/$(HOST_LUAROCKS_SOURCE)

HOST_LUAROCKS_DEPENDENCIES = host-lua

HOST_LUAROCKS_CONFIG = $(HOST_DIR)/etc/luarocks/config-$(LUA_ABIVERSION).lua

HOST_LUAROCKS_MAKE_ENV = \
	LUA_PATH="$(HOST_DIR)/share/lua/$(LUA_ABIVERSION)/?.lua" \
	TARGET_CC="$(TARGET_CC)" \
	TARGET_LD="$(TARGET_LD)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS) -fPIC" \
	TARGET_LDFLAGS="-L$(TARGET_libdir)" \
	TARGET_DIR="$(TARGET_DIR)" \
	TARGET_includedir="$(TARGET_includedir)" \
	TARGET_libdir="$(TARGET_libdir)"

HOST_LUAROCKS_CONF_OPTS = \
	--with-lua=$(HOST_DIR) \
	--rocks-tree=$(TARGET_DIR)

HOST_LUAROCKS = $(HOST_DIR)/bin/luarocks

host-luarocks: $(HOST_LUAROCKS_DEPENDENCIES) $(DL_DIR)/$(HOST_LUAROCKS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(HOST_CONFIGURE);\
		$(MAKE); \
		$(MAKE) install
	cat $(PKG_FILES_DIR)/luarocks-config.lua >> $(HOST_LUAROCKS_CONFIG)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

# helper target to create ccache links

ifndef CCACHE
CCACHE := ccache
endif
CCACHE := $(shell which $(CCACHE) || type -p $(CCACHE) || echo ccache)

CCACHE_DIR = $(HOME)/.ccache-$(call LOWERCASE,$(TARGET_VENDOR))-$(TARGET_ARCH)-$(TARGET_OS)-$(KERNEL_VERSION)
export CCACHE_DIR

host-ccache: find-ccache $(CCACHE) | $(HOST_DIR)
	ln -sf $(CCACHE) $(HOST_DIR)/bin/cc
	ln -sf $(CCACHE) $(HOST_DIR)/bin/gcc
	ln -sf $(CCACHE) $(HOST_DIR)/bin/g++
	ln -sf $(CCACHE) $(HOST_DIR)/bin/$(TARGET_CC)
	ln -sf $(CCACHE) $(HOST_DIR)/bin/$(TARGET_CXX)

# -----------------------------------------------------------------------------

PHONY += host-tools
PHONY += pkg-config-preqs
PHONY += host-ccache
