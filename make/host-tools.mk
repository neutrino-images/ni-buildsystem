#
# makefile to build all needed host-binaries
#
# -----------------------------------------------------------------------------

$(HOST_DIR):
	mkdir -p $(HOST_DIR)
	mkdir -p $(HOST_DIR)/bin
	mkdir -p $(HOST_DEPS_DIR)

# -----------------------------------------------------------------------------

host-preqs: $(HOST_DIR) \
	host-pkg-config \
	$(PKG_CONFIG) \
	host-mtd-utils \
	host-mkimage \
	host-zic \
	host-parted \
	host-dosfstools \
	host-mtools \
	host-e2fsprocs \
	host-lua \
	host-luarocks \
	host-ccache

# -----------------------------------------------------------------------------

pkg-config-preqs:
	@PATH=$(subst $(HOST_DIR)/bin:,,$(PATH)); \
	if ! pkg-config --exists glib-2.0; then \
		echo "pkg-config and glib2-devel packages are needed for building cross-pkg-config."; false; \
	fi

# -----------------------------------------------------------------------------

HOST_PKG-CONFIG_VER    = 0.29.2
HOST_PKG-CONFIG_TMP    = pkg-config-$(HOST_PKG-CONFIG_VER)
HOST_PKG-CONFIG_SOURCE = pkg-config-$(HOST_PKG-CONFIG_VER).tar.gz
HOST_PKG-CONFIG_SITE   = https://pkg-config.freedesktop.org/releases

$(ARCHIVE)/$(HOST_PKG-CONFIG_SOURCE):
	$(DOWNLOAD) $(HOST_PKG-CONFIG_SITE)/$(HOST_PKG-CONFIG_SOURCE)

HOST_PKG-CONFIG = $(HOST_DIR)/bin/pkg-config

host-pkg-config: $(HOST_PKG-CONFIG)
$(HOST_PKG-CONFIG): $(ARCHIVE)/$(HOST_PKG-CONFIG_SOURCE) | $(HOST_DIR) pkg-config-preqs
	$(REMOVE)/$(HOST_PKG-CONFIG_TMP)
	$(UNTAR)/$(HOST_PKG-CONFIG_SOURCE)
	$(CHDIR)/$(HOST_PKG-CONFIG_TMP); \
		./configure \
			--with-pc_path=$(PKG_CONFIG_PATH) \
			; \
		$(MAKE); \
		$(INSTALL_EXEC) -D pkg-config $(HOST_PKG-CONFIG)
	$(REMOVE)/$(HOST_PKG-CONFIG_TMP)

# -----------------------------------------------------------------------------

HOST_PKGCONF_VER    = 1.6.3
HOST_PKGCONF_TMP    = pkgconf-$(HOST_PKGCONF_VER)
HOST_PKGCONF_SOURCE = pkgconf-$(HOST_PKGCONF_VER).tar.gz
HOST_PKGCONF_SITE   = https://distfiles.dereferenced.org/pkgconf

$(ARCHIVE)/$(HOST_PKGCONF_SOURCE):
	$(DOWNLOAD) $(HOST_PKGCONF_SITE)/$(HOST_PKGCONF_SOURCE)

HOST_PKGCONF_PATCH  = 0001-Only-prefix-with-the-sysroot-a-subset-of-variables.patch
HOST_PKGCONF_PATCH += 0002-Revert-main-assume-modversion-insted-of-version-if-o.patch

host-pkgconf: $(ARCHIVE)/$(HOST_PKGCONF_SOURCE) | $(HOST_DIR) pkg-config-preqs
	$(REMOVE)/$(HOST_PKGCONF_TMP)
	$(UNTAR)/$(HOST_PKGCONF_SOURCE)
	$(CHDIR)/$(HOST_PKGCONF_TMP); \
		$(call apply_patches, $(addprefix $(@F)/,$(HOST_PKGCONF_PATCH))); \
		./configure \
			--prefix=$(HOST_DIR) \
			--with-sysroot=$(TARGET_DIR) \
			--with-system-libdir=$(TARGET_LIB_DIR) \
			--with-system-includedir=$(TARGET_INCLUDE_DIR) \
			; \
		$(MAKE); \
		$(MAKE) install
	$(INSTALL_EXEC) $(PATCHES)/$(@F)/pkgconf-pkg-config $(HOST_PKG-CONFIG)
	$(REMOVE)/$(HOST_PKGCONF_TMP)

# -----------------------------------------------------------------------------

$(PKG_CONFIG): $(HOST_PKG-CONFIG)
	ln -sf pkg-config $(@)

# -----------------------------------------------------------------------------

HOST_MTD-UTILS_VER    = $(MTD-UTILS_VER)
HOST_MTD-UTILS_TMP    = mtd-utils-$(HOST_MTD-UTILS_VER)
HOST_MTD-UTILS_SOURCE = mtd-utils-$(HOST_MTD-UTILS_VER).tar.bz2
HOST_MTD-UTILS_SITE   = ftp://ftp.infradead.org/pub/mtd-utils

#$(ARCHIVE)/$(HOST_MTD-UTILS_SOURCE):
#	$(DOWNLOAD) $(HOST_MTD-UTILS_SITE)/$(HOST_MTD-UTILS_SOURCE)

host-mtd-utils: $(ARCHIVE)/$(HOST_MTD-UTILS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_MTD-UTILS_TMP)
	$(UNTAR)/$(HOST_MTD-UTILS_SOURCE)
	$(CHDIR)/$(HOST_MTD-UTILS_TMP); \
		./configure \
			ZLIB_CFLAGS=" " \
			ZLIB_LIBS="-lz" \
			UUID_CFLAGS=" " \
			UUID_LIBS="-luuid" \
			--prefix= \
			--enable-silent-rules \
			--without-ubifs \
			--without-xattr \
			--disable-tests \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(HOST_DIR)
	$(REMOVE)/$(HOST_MTD-UTILS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_U-BOOT_VER    = 2018.09
HOST_U-BOOT_TMP    = u-boot-$(HOST_U-BOOT_VER)
HOST_U-BOOT_SOURCE = u-boot-$(HOST_U-BOOT_VER).tar.bz2
HOST_U-BOOT_SITE   = ftp://ftp.denx.de/pub/u-boot

$(ARCHIVE)/$(HOST_U-BOOT_SOURCE):
	$(DOWNLOAD) $(HOST_U-BOOT_SITE)/$(HOST_U-BOOT_SOURCE)

host-mkimage: $(HOST_DIR)/bin/mkimage
$(HOST_DIR)/bin/mkimage: $(ARCHIVE)/$(HOST_U-BOOT_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_U-BOOT_TMP)
	$(UNTAR)/$(HOST_U-BOOT_SOURCE)
	$(CHDIR)/$(HOST_U-BOOT_TMP); \
		$(MAKE) defconfig; \
		$(MAKE) silentoldconfig; \
		$(MAKE) tools-only
	$(INSTALL_EXEC) -D $(BUILD_TMP)/$(HOST_U-BOOT_TMP)/tools/mkimage $(HOST_DIR)/bin/
	$(REMOVE)/$(HOST_U-BOOT_TMP)

# -----------------------------------------------------------------------------

HOST_TZCODE_VER    = 2019b
HOST_TZCODE_TMP    = tzcode$(HOST_TZCODE_VER)
HOST_TZCODE_SOURCE = tzcode$(HOST_TZCODE_VER).tar.gz
HOST_TZCODE_SITE   = ftp://ftp.iana.org/tz/releases

$(ARCHIVE)/$(HOST_TZCODE_SOURCE):
	$(DOWNLOAD) $(HOST_TZCODE_SITE)/$(HOST_TZCODE_SOURCE)

HOST_TZDATA_VER    = $(TZDATA_VER)
HOST_TZDATA_TMP    = tzdata$(HOST_TZDATA_VER)
HOST_TZDATA_SOURCE = tzdata$(HOST_TZDATA_VER).tar.gz
HOST_TZDATA_SITE   = ftp://ftp.iana.org/tz/releases

#$(ARCHIVE)/$(HOST_TZDATA_SOURCE):
#	$(DOWNLOAD) $(HOST_TZDATA_SITE)/$(HOST_TZDATA_SOURCE)

HOST_ZIC = $(HOST_DIR)/sbin/zic

host-zic: $(ARCHIVE)/$(HOST_TZDATA_SOURCE) $(ARCHIVE)/$(HOST_TZCODE_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_TZCODE_TMP)
	$(MKDIR)/$(HOST_TZCODE_TMP)
	$(CHDIR)/$(HOST_TZCODE_TMP); \
		tar -xf $(ARCHIVE)/$(HOST_TZCODE_SOURCE); \
		tar -xf $(ARCHIVE)/$(HOST_TZDATA_SOURCE); \
		$(MAKE) zic
	$(INSTALL_EXEC) -D $(BUILD_TMP)/$(HOST_TZCODE_TMP)/zic $(HOST_ZIC)
	$(REMOVE)/$(HOST_TZCODE_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_PARTED_VER    = $(PARTED_VER)
HOST_PARTED_TMP    = parted-$(HOST_PARTED_VER)
HOST_PARTED_SOURCE = parted-$(HOST_PARTED_VER).tar.xz
HOST_PARTED_SITE   = https://ftp.gnu.org/gnu/parted

#$(ARCHIVE)/$(HOST_PARTED_SOURCE):
#	$(DOWNLOAD) $(HOST_PARTED_SITE)/$(HOST_PARTED_SOURCE)

HOST_PARTED_PATCH  = parted-device-mapper.patch
HOST_PARTED_PATCH += parted-sysmacros.patch

host-parted: $(ARCHIVE)/$(HOST_PARTED_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_PARTED_TMP)
	$(UNTAR)/$(HOST_PARTED_SOURCE)
	$(CHDIR)/$(HOST_PARTED_TMP); \
		$(call apply_patches, $(HOST_PARTED_PATCH)); \
		./configure \
			--prefix= \
			--enable-silent-rules \
			--enable-static \
			--disable-shared \
			--disable-device-mapper \
			--without-readline \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(HOST_DIR)
	$(REMOVE)/$(HOST_PARTED_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_DOSFSTOOLS_VER    = $(DOSFSTOOLS_VER)
HOST_DOSFSTOOLS_TMP    = dosfstools-$(HOST_DOSFSTOOLS_VER)
HOST_DOSFSTOOLS_SOURCE = dosfstools-$(HOST_DOSFSTOOLS_VER).tar.xz
HOST_DOSFSTOOLS_SITE   = https://github.com/dosfstools/dosfstools/releases/download/v$(HOST_DOSFSTOOLS_VER)

#$(ARCHIVE)/$(HOST_DOSFSTOOLS_SOURCE):
#	$(DOWNLOAD) $(HOST_DOSFSTOOLS_SITE)/$(HOST_DOSFSTOOLS_SOURCE)

host-dosfstools: $(ARCHIVE)/$(HOST_DOSFSTOOLS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_DOSFSTOOLS_TMP)
	$(UNTAR)/$(HOST_DOSFSTOOLS_SOURCE)
	$(CHDIR)/$(HOST_DOSFSTOOLS_TMP); \
		./configure \
			--prefix= \
			--without-udev \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(HOST_DIR)
	ln -sf mkfs.fat $(HOST_DIR)/sbin/mkfs.vfat
	ln -sf mkfs.fat $(HOST_DIR)/sbin/mkfs.msdos
	ln -sf mkfs.fat $(HOST_DIR)/sbin/mkdosfs
	$(REMOVE)/$(HOST_DOSFSTOOLS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_MTOOLS_VER    = 4.0.19
HOST_MTOOLS_TMP    = mtools-$(HOST_MTOOLS_VER)
HOST_MTOOLS_SOURCE = mtools-$(HOST_MTOOLS_VER).tar.gz
HOST_MTOOLS_SITE   = ftp://ftp.gnu.org/gnu/mtools

$(ARCHIVE)/$(HOST_MTOOLS_SOURCE):
	$(DOWNLOAD) $(HOST_MTOOLS_SITE)/$(HOST_MTOOLS_SOURCE)

host-mtools: $(ARCHIVE)/$(HOST_MTOOLS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_MTOOLS_TMP)
	$(UNTAR)/$(HOST_MTOOLS_SOURCE)
	$(CHDIR)/$(HOST_MTOOLS_TMP); \
		./configure \
			--prefix= \
			; \
		$(MAKE1); \
		$(MAKE1) install DESTDIR=$(HOST_DIR)
	$(REMOVE)/$(HOST_MTOOLS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_E2FSPROGS_VER    = $(E2FSPROGS_VER)
HOST_E2FSPROGS_TMP    = e2fsprogs-$(HOST_E2FSPROGS_VER)
HOST_E2FSPROGS_SOURCE = e2fsprogs-$(HOST_E2FSPROGS_VER).tar.gz
HOST_E2FSPROGS_SITE   = https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(HOST_E2FSPROGS_VER)

#$(ARCHIVE)/$(HOST_E2FSPROGS_SOURCE):
#	$(DOWNLOAD) $(HOST_E2FSPROGS_SITE)/$(HOST_E2FSPROGS_SOURCE)

host-e2fsprocs: $(ARCHIVE)/$(HOST_E2FSPROGS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_E2FSPROGS_TMP)
	$(UNTAR)/$(HOST_E2FSPROGS_SOURCE)
	$(CHDIR)/$(HOST_E2FSPROGS_TMP); \
		./configure \
			--prefix= \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(HOST_DIR)
	$(REMOVE)/$(HOST_E2FSPROGS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_NINJA_VER    = 1.10.0
HOST_NINJA_TMP    = ninja-$(HOST_NINJA_VER)
HOST_NINJA_SOURCE = ninja-$(HOST_NINJA_VER).tar.gz
HOST_NINJA_SITE   = $(call github,ninja-build,ninja,v$(HOST_NINJA_VER))

HOST_NINJA_PATCH  = ninja/0001-set-minimum-cmake-version-to-3.10.patch
HOST_NINJA_PATCH += ninja/0002-remove-fdiagnostics-color-from-make-command.patch
HOST_NINJA_PATCH += ninja/0003-CMake-fix-object-library-usage.patch

$(ARCHIVE)/$(HOST_NINJA_SOURCE):
	$(DOWNLOAD) $(HOST_NINJA_SITE)/$(HOST_NINJA_SOURCE)

host-ninja: $(ARCHIVE)/$(HOST_NINJA_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_NINJA_TMP)
	$(UNTAR)/$(HOST_NINJA_SOURCE)
	$(CHDIR)/$(HOST_NINJA_TMP); \
		$(call apply_patches, $(HOST_NINJA_PATCH)); \
		cmake . \
			-DCMAKE_INSTALL_PREFIX="" \
			; \
		$(MAKE)
	$(INSTALL_EXEC) -D $(BUILD_TMP)/$(HOST_NINJA_TMP)/ninja $(HOST_DIR)/bin/ninja
	$(REMOVE)/$(HOST_NINJA_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_LUA_VER    = $(LUA_VER)
HOST_LUA_TMP    = lua-$(HOST_LUA_VER)
HOST_LUA_SOURCE = lua-$(HOST_LUA_VER).tar.gz
HOST_LUA_SITE   = http://www.lua.org/ftp

#$(ARCHIVE)/$(HOST_LUA_SOURCE):
#	$(DOWNLOAD) $(HOST_LUA_SITE)/$(HOST_LUA_SOURCE)

HOST_LUA_PATCH  = lua-01-fix-LUA_ROOT.patch
HOST_LUA_PATCH += lua-01-remove-readline.patch

HOST_LUA = $(HOST_DIR)/bin/lua

host-lua: $(ARCHIVE)/$(HOST_LUA_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_LUA_TMP)
	$(UNTAR)/$(HOST_LUA_SOURCE)
	$(CHDIR)/$(HOST_LUA_TMP); \
		$(call apply_patches, $(HOST_LUA_PATCH)); \
		$(MAKE) linux; \
		$(MAKE) install INSTALL_TOP=$(HOST_DIR)
	$(REMOVE)/$(HOST_LUA_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_LUAROCKS_VER    = 3.1.3
HOST_LUAROCKS_TMP    = luarocks-$(HOST_LUAROCKS_VER)
HOST_LUAROCKS_SOURCE = luarocks-$(HOST_LUAROCKS_VER).tar.gz
HOST_LUAROCKS_SITE   = https://luarocks.github.io/luarocks/releases

$(ARCHIVE)/$(HOST_LUAROCKS_SOURCE):
	$(DOWNLOAD) $(HOST_LUAROCKS_SITE)/$(HOST_LUAROCKS_SOURCE)

HOST_LUAROCKS_PATCH  = luarocks-0001-allow-libluajit-detection.patch

HOST_LUAROCKS_CONFIG_FILE = $(HOST_DIR)/etc/luarocks/config-$(LUA_ABIVER).lua

HOST_LUAROCKS_MAKE_ENV = \
	LUA_PATH="$(HOST_DIR)/share/lua/$(LUA_ABIVER)/?.lua" \
	TARGET_CC="$(TARGET_CC)" \
	TARGET_LD="$(TARGET_LD)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS) -fPIC" \
	TARGET_LDFLAGS="-L$(TARGET_LIB_DIR)" \
	TARGET_DIR="$(TARGET_DIR)" \
	TARGET_INCLUDE_DIR="$(TARGET_INCLUDE_DIR)" \
	TARGET_LIB_DIR="$(TARGET_LIB_DIR)"

HOST_LUAROCKS = $(HOST_DIR)/bin/luarocks

host-luarocks: $(HOST_LUAROCKS)
$(HOST_LUAROCKS): $(HOST_LUA) $(ARCHIVE)/$(HOST_LUAROCKS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_LUAROCKS_TMP)
	$(UNTAR)/$(HOST_LUAROCKS_SOURCE)
	$(CHDIR)/$(HOST_LUAROCKS_TMP); \
		$(call apply_patches, $(HOST_LUAROCKS_PATCH)); \
		./configure $(SILENT_OPT) \
			--prefix=$(HOST_DIR) \
			--sysconfdir=$(HOST_DIR)/etc \
			--with-lua=$(HOST_DIR) \
			--rocks-tree=$(TARGET_DIR) \
		; \
		rm -f $(HOST_LUAROCKS_CONFIG_FILE); \
		$(MAKE); \
		$(MAKE) install
	cat $(CONFIGS)/luarocks-config.lua >> $(HOST_LUAROCKS_CONFIG_FILE)
	$(REMOVE)/$(HOST_LUAROCKS_TMP)

# -----------------------------------------------------------------------------

# helper target to create ccache links
host-ccache: find-ccache $(CCACHE) | $(HOST_DIR)
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/cc
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/gcc
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/g++
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/$(TARGET_CC)
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/$(TARGET_CXX)

# -----------------------------------------------------------------------------

PHONY += host-preqs
PHONY += pkg-config-preqs
PHONY += host-ccache
