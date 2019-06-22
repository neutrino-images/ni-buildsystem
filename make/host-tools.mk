#
# makefile to build all needed host-binaries
#
# -----------------------------------------------------------------------------

host-preqs: $(HOST_DIR)/bin \
	host-pkg-config \
	host-pkg-config-link \
	host-mkfs.jffs2 \
	host-sumtool \
	host-mkimage \
	host-zic \
	host-parted \
	host-mkfs.fat \
	host-mtools \
	host-resize2fs \
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

HOST_PKG-CONFIG_VER = 0.29.2

$(ARCHIVE)/pkg-config-$(HOST_PKG-CONFIG_VER).tar.gz:
	$(WGET) https://pkg-config.freedesktop.org/releases/pkg-config-$(HOST_PKG-CONFIG_VER).tar.gz

host-pkg-config: $(HOST_DIR)/bin/pkg-config
$(HOST_DIR)/bin/pkg-config: $(ARCHIVE)/pkg-config-$(HOST_PKG-CONFIG_VER).tar.gz | $(HOST_DIR)/bin pkg-config-preqs
	$(REMOVE)/pkg-config-$(HOST_PKG-CONFIG_VER)
	$(UNTAR)/pkg-config-$(HOST_PKG-CONFIG_VER).tar.gz
	$(CHDIR)/pkg-config-$(HOST_PKG-CONFIG_VER); \
		./configure \
			--with-pc_path=$(PKG_CONFIG_PATH) \
			; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/pkg-config-$(HOST_PKG-CONFIG_VER)/pkg-config $(HOST_DIR)/bin
	$(REMOVE)/pkg-config-$(HOST_PKG-CONFIG_VER)

host-pkg-config-link: $(HOST_DIR)/bin/$(TARGET)-pkg-config
$(HOST_DIR)/bin/$(TARGET)-pkg-config: | $(HOST_DIR)/bin
	ln -sf pkg-config $(HOST_DIR)/bin/$(TARGET)-pkg-config

# -----------------------------------------------------------------------------

HOST_PKGCONF_VER = 1.6.0
HOST_PKGCONF_SOURCE = pkgconf-$(HOST_PKGCONF_VER).tar.gz

$(ARCHIVE)/$(HOST_PKGCONF_SOURCE):
	$(WGET) https://github.com/pkgconf/pkgconf/archive/$(HOST_PKGCONF_SOURCE)

host-pkgconf: $(HOST_DIR)/bin/pkgconf
$(HOST_DIR)/bin/pkgconf: $(ARCHIVE)/$(HOST_PKGCONF_SOURCE) | $(HOST_DIR)/bin pkg-config-preqs
	$(REMOVE)/pkgconf-pkgconf-$(HOST_PKGCONF_VER)
	$(UNTAR)/$(HOST_PKGCONF_SOURCE)
	$(CHDIR)/pkgconf-pkgconf-$(HOST_PKGCONF_VER); \
		./autogen.sh -n; \
		./configure \
			--prefix=$(HOST_DIR) \
			--with-sysroot=$(TARGET_DIR) \
			--with-system-libdir=$(TARGET_LIB_DIR) \
			--with-system-includedir=$(TARGET_INCLUDE_DIR) \
			; \
		$(MAKE); \
		$(MAKE) install
	install -m 0755 $(PATCHES)/pkgconf-pkg-config $(HOST_DIR)/bin/pkg-config
	$(REMOVE)/pkgconf-pkgconf-$(HOST_PKGCONF_VER)

# -----------------------------------------------------------------------------

HOST_MTD-UTILS_VER = $(MTD-UTILS_VER)

#$(ARCHIVE)/mtd-utils-$(HOST_MTD-UTILS_VER).tar.bz2:
#	$(WGET) ftp://ftp.infradead.org/pub/mtd-utils/mtd-utils-$(HOST_MTD-UTILS_VER).tar.bz2

host-mkfs.jffs2: $(HOST_DIR)/bin/mkfs.jffs2
host-sumtool: $(HOST_DIR)/bin/sumtool
$(HOST_DIR)/bin/mkfs.jffs2 \
$(HOST_DIR)/bin/sumtool: $(ARCHIVE)/mtd-utils-$(HOST_MTD-UTILS_VER).tar.bz2 | $(HOST_DIR)/bin
	$(REMOVE)/mtd-utils-$(HOST_MTD-UTILS_VER)
	$(UNTAR)/mtd-utils-$(HOST_MTD-UTILS_VER).tar.bz2
	$(CHDIR)/mtd-utils-$(HOST_MTD-UTILS_VER); \
		./configure \
			ZLIB_CFLAGS=" " \
			ZLIB_LIBS="-lz" \
			UUID_CFLAGS=" " \
			UUID_LIBS="-luuid" \
			--enable-silent-rules \
			--without-ubifs \
			--without-xattr \
			--disable-tests \
			; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(HOST_MTD-UTILS_VER)/mkfs.jffs2 $(HOST_DIR)/bin/
	install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(HOST_MTD-UTILS_VER)/sumtool $(HOST_DIR)/bin/
	$(REMOVE)/mtd-utils-$(HOST_MTD-UTILS_VER)

# -----------------------------------------------------------------------------

HOST_U-BOOT_VER = 2018.09

$(ARCHIVE)/u-boot-$(HOST_U-BOOT_VER).tar.bz2:
	$(WGET) ftp://ftp.denx.de/pub/u-boot/u-boot-$(HOST_U-BOOT_VER).tar.bz2

host-mkimage: $(HOST_DIR)/bin/mkimage
$(HOST_DIR)/bin/mkimage: $(ARCHIVE)/u-boot-$(HOST_U-BOOT_VER).tar.bz2 | $(HOST_DIR)/bin
	$(REMOVE)/u-boot-$(HOST_U-BOOT_VER)
	$(UNTAR)/u-boot-$(HOST_U-BOOT_VER).tar.bz2
	$(CHDIR)/u-boot-$(HOST_U-BOOT_VER); \
		$(MAKE) defconfig; \
		$(MAKE) silentoldconfig; \
		$(MAKE) tools-only
	install -D -m 0755 $(BUILD_TMP)/u-boot-$(HOST_U-BOOT_VER)/tools/mkimage $(HOST_DIR)/bin/
	$(REMOVE)/u-boot-$(HOST_U-BOOT_VER)

# -----------------------------------------------------------------------------

HOST_TZDATA_VER = $(TZDATA_VER)

#$(ARCHIVE)/tzdata$(HOST_TZDATA_VER).tar.gz:
#	$(WGET) ftp://ftp.iana.org/tz/releases/tzdata$(HOST_TZDATA_VER).tar.gz

HOST_TZCODE_VER = 2018e

$(ARCHIVE)/tzcode$(HOST_TZCODE_VER).tar.gz:
	$(WGET) ftp://ftp.iana.org/tz/releases/tzcode$(HOST_TZCODE_VER).tar.gz

host-zic: $(HOST_DIR)/bin/zic
$(HOST_DIR)/bin/zic: $(ARCHIVE)/tzdata$(HOST_TZDATA_VER).tar.gz $(ARCHIVE)/tzcode$(HOST_TZCODE_VER).tar.gz | $(HOST_DIR)/bin
	$(REMOVE)/tzcode
	$(MKDIR)/tzcode
	$(CHDIR)/tzcode; \
		tar -xf $(ARCHIVE)/tzcode$(HOST_TZCODE_VER).tar.gz; \
		tar -xf $(ARCHIVE)/tzdata$(HOST_TZDATA_VER).tar.gz; \
		$(MAKE) zic
	install -D -m 0755 $(BUILD_TMP)/tzcode/zic $(HOST_DIR)/bin/
	$(REMOVE)/tzcode

# -----------------------------------------------------------------------------

HOST_PARTED_VER = $(PARTED_VER)

#$(ARCHIVE)/parted-$(HOST_PARTED_VER).tar.xz:
#	$(WGET) http://ftp.gnu.org/gnu/parted/parted-$(HOST_PARTED_VER).tar.xz

HOST_PARTED_PATCH  = parted-3.2-devmapper-1.patch
HOST_PARTED_PATCH += parted-3.2-sysmacros.patch

host-parted: $(HOST_DIR)/bin/parted
$(HOST_DIR)/bin/parted: $(ARCHIVE)/parted-$(HOST_PARTED_VER).tar.xz | $(HOST_DIR)/bin
	$(REMOVE)/parted-$(HOST_PARTED_VER)
	$(UNTAR)/parted-$(HOST_PARTED_VER).tar.xz
	$(CHDIR)/parted-$(HOST_PARTED_VER); \
		$(call apply_patches, $(HOST_PARTED_PATCH)); \
		./configure \
			--enable-silent-rules \
			--enable-static \
			--disable-shared \
			--disable-device-mapper \
			--without-readline \
			; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/parted-$(HOST_PARTED_VER)/parted/parted $(HOST_DIR)/bin/
	$(REMOVE)/parted-$(HOST_PARTED_VER)

# -----------------------------------------------------------------------------

HOST_DOSFSTOOLS_VER = $(DOSFSTOOLS_VER)

#$(ARCHIVE)/dosfstools-$(HOST_DOSFSTOOLS_VER).tar.xz:
#	$(WGET) https://github.com/dosfstools/dosfstools/releases/download/v$(HOST_DOSFSTOOLS_VER)/dosfstools-$(HOST_DOSFSTOOLS_VER).tar.xz

host-mkfs.fat: $(HOST_DIR)/bin/mkfs.fat
$(HOST_DIR)/bin/mkfs.fat: $(ARCHIVE)/dosfstools-$(HOST_DOSFSTOOLS_VER).tar.xz | $(HOST_DIR)/bin
	$(REMOVE)/dosfstools-$(HOST_DOSFSTOOLS_VER)
	$(UNTAR)/dosfstools-$(HOST_DOSFSTOOLS_VER).tar.xz
	$(CHDIR)/dosfstools-$(HOST_DOSFSTOOLS_VER); \
		./configure \
			--without-udev \
			; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/dosfstools-$(HOST_DOSFSTOOLS_VER)/src/mkfs.fat $(HOST_DIR)/bin/
	ln -sf mkfs.fat $(HOST_DIR)/bin/mkfs.vfat
	ln -sf mkfs.fat $(HOST_DIR)/bin/mkfs.msdos
	ln -sf mkfs.fat $(HOST_DIR)/bin/mkdosfs
	$(REMOVE)/dosfstools-$(HOST_DOSFSTOOLS_VER)

# -----------------------------------------------------------------------------

HOST_MTOOLS_VER = 4.0.19

$(ARCHIVE)/mtools-$(HOST_MTOOLS_VER).tar.gz:
	$(WGET) ftp://ftp.gnu.org/gnu/mtools/mtools-$(HOST_MTOOLS_VER).tar.gz

host-mtools: $(HOST_DIR)/bin/mtools
$(HOST_DIR)/bin/mtools: $(ARCHIVE)/mtools-$(HOST_MTOOLS_VER).tar.gz | $(HOST_DIR)/bin
	$(REMOVE)/mtools-$(HOST_MTOOLS_VER)
	$(UNTAR)/mtools-$(HOST_MTOOLS_VER).tar.gz
	$(CHDIR)/mtools-$(HOST_MTOOLS_VER); \
		./configure; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/mtools-$(HOST_MTOOLS_VER)/mtools $(HOST_DIR)/bin/
	ln -sf mtools $(HOST_DIR)/bin/mcopy
	$(REMOVE)/mtools-$(HOST_MTOOLS_VER)

# -----------------------------------------------------------------------------

HOST_E2FSPROGS_VER = $(E2FSPROGS_VER)

#$(ARCHIVE)/e2fsprogs-$(HOST_E2FSPROGS_VER).tar.gz:
#	$(WGET) http://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v$(HOST_E2FSPROGS_VER)/e2fsprogs-$(HOST_E2FSPROGS_VER).tar.gz

host-resize2fs: $(HOST_DIR)/bin/resize2fs
$(HOST_DIR)/bin/resize2fs: $(ARCHIVE)/e2fsprogs-$(HOST_E2FSPROGS_VER).tar.gz | $(HOST_DIR)/bin
	$(REMOVE)/e2fsprogs-$(HOST_E2FSPROGS_VER)
	$(UNTAR)/e2fsprogs-$(HOST_E2FSPROGS_VER).tar.gz
	$(CHDIR)/e2fsprogs-$(HOST_E2FSPROGS_VER) && \
		./configure; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(HOST_E2FSPROGS_VER)/resize/resize2fs $(HOST_DIR)/bin/
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(HOST_E2FSPROGS_VER)/misc/mke2fs $(HOST_DIR)/bin/
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext2
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext3
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext4
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext4dev
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(HOST_E2FSPROGS_VER)/e2fsck/e2fsck $(HOST_DIR)/bin/
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext2
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext3
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext4
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext4dev
	$(REMOVE)/e2fsprogs-$(HOST_E2FSPROGS_VER)

# -----------------------------------------------------------------------------

HOST_LUA = $(HOST_DIR)/bin/lua
HOST_LUA_VER = $(LUA_VER)

#$(ARCHIVE)/lua-$(HOST_LUA_VER).tar.gz:
#	$(WGET) http://www.lua.org/ftp/lua-$(HOST_LUA_VER).tar.gz

HOST_LUA_PATCH  = lua-01-fix-LUA_ROOT.patch
HOST_LUA_PATCH += lua-01-remove-readline.patch

host-lua: $(HOST_LUA)
$(HOST_LUA): $(ARCHIVE)/lua-$(HOST_LUA_VER).tar.gz | $(HOST_DIR)
	$(REMOVE)/lua-$(HOST_LUA_VER)
	$(UNTAR)/lua-$(HOST_LUA_VER).tar.gz
	$(CHDIR)/lua-$(HOST_LUA_VER); \
		$(call apply_patches, $(HOST_LUA_PATCH)); \
		$(MAKE) linux; \
		$(MAKE) install INSTALL_TOP=$(HOST_DIR)
	$(REMOVE)/lua-$(HOST_LUA_VER)

# -----------------------------------------------------------------------------

HOST_LUAROCKS = $(HOST_DIR)/bin/luarocks
HOST_LUAROCKS_VER = 3.1.3
HOST_LUAROCKS_SOURCE = luarocks-$(HOST_LUAROCKS_VER).tar.gz

$(ARCHIVE)/$(HOST_LUAROCKS_SOURCE):
	$(WGET) https://luarocks.github.io/luarocks/releases/$(HOST_LUAROCKS_SOURCE)

HOST_LUAROCKS_PATCH  = luarocks-0001-allow-libluajit-detection.patch

HOST_LUAROCKS_CONFIG_FILE = $(HOST_DIR)/etc/luarocks/config-$(LUA_ABIVER).lua

HOST_LUAROCKS_BUILDENV = \
	LUA_PATH="$(HOST_DIR)/share/lua/$(LUA_ABIVER)/?.lua" \
	TARGET_CC="$(TARGET)-gcc" \
	TARGET_LD="$(TARGET)-ld" \
	TARGET_CFLAGS="$(TARGET_CFLAGS) -fPIC" \
	TARGET_LDFLAGS="-L$(TARGET_LIB_DIR)" \
	TARGET_DIR="$(TARGET_DIR)" \
	TARGET_INCLUDE_DIR="$(TARGET_INCLUDE_DIR)" \
	TARGET_LIB_DIR="$(TARGET_LIB_DIR)"

host-luarocks: $(HOST_LUAROCKS)
$(HOST_LUAROCKS): $(HOST_LUA) $(ARCHIVE)/$(HOST_LUAROCKS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/luarocks-$(HOST_LUAROCKS_VER)
	$(UNTAR)/$(HOST_LUAROCKS_SOURCE)
	$(CHDIR)/luarocks-$(HOST_LUAROCKS_VER); \
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
	$(REMOVE)/luarocks-$(HOST_LUAROCKS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

# helper target to create ccache links
host-ccache: find-ccache $(CCACHE) $(HOST_DIR)/bin
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/cc
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/gcc
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/g++
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/$(TARGET)-gcc
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/$(TARGET)-g++

# -----------------------------------------------------------------------------

PHONY += host-preqs
PHONY += pkg-config-preqs
PHONY += host-ccache
