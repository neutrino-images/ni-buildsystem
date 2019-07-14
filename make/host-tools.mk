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

HOST_PKG-CONFIG_VER    = 0.29.2
HOST_PKG-CONFIG_TMP    = pkg-config-$(HOST_PKG-CONFIG_VER)
HOST_PKG-CONFIG_SOURCE = pkg-config-$(HOST_PKG-CONFIG_VER).tar.gz
HOST_PKG-CONFIG_URL    = https://pkg-config.freedesktop.org/releases

$(ARCHIVE)/$(HOST_PKG-CONFIG_SOURCE):
	$(DOWNLOAD) $(HOST_PKG-CONFIG_URL)/$(HOST_PKG-CONFIG_SOURCE)

host-pkg-config: $(HOST_DIR)/bin/pkg-config
$(HOST_DIR)/bin/pkg-config: $(ARCHIVE)/$(HOST_PKG-CONFIG_SOURCE) | $(HOST_DIR)/bin pkg-config-preqs
	$(REMOVE)/$(HOST_PKG-CONFIG_TMP)
	$(UNTAR)/$(HOST_PKG-CONFIG_SOURCE)
	$(CHDIR)/$(HOST_PKG-CONFIG_TMP); \
		./configure \
			--with-pc_path=$(PKG_CONFIG_PATH) \
			; \
		$(MAKE); \
		install -D -m 0755 pkg-config $(HOST_DIR)/bin
	$(REMOVE)/$(HOST_PKG-CONFIG_TMP)

host-pkg-config-link: $(HOST_DIR)/bin/$(TARGET)-pkg-config
$(HOST_DIR)/bin/$(TARGET)-pkg-config: | $(HOST_DIR)/bin
	ln -sf pkg-config $@

# -----------------------------------------------------------------------------

HOST_PKGCONF_VER    = 1.6.0
HOST_PKGCONF_TMP    = pkgconf-pkgconf-$(HOST_PKGCONF_VER)
HOST_PKGCONF_SOURCE = pkgconf-$(HOST_PKGCONF_VER).tar.gz
HOST_PKGCONF_URL    = https://github.com/pkgconf/pkgconf/archive

$(ARCHIVE)/$(HOST_PKGCONF_SOURCE):
	$(DOWNLOAD) $(HOST_PKGCONF_URL)/$(HOST_PKGCONF_SOURCE)

host-pkgconf: $(HOST_DIR)/bin/pkgconf
$(HOST_DIR)/bin/pkgconf: $(ARCHIVE)/$(HOST_PKGCONF_SOURCE) | $(HOST_DIR)/bin pkg-config-preqs
	$(REMOVE)/$(HOST_PKGCONF_TMP)
	$(UNTAR)/$(HOST_PKGCONF_SOURCE)
	$(CHDIR)/$(HOST_PKGCONF_TMP); \
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
	$(REMOVE)/$(HOST_PKGCONF_TMP)

# -----------------------------------------------------------------------------

HOST_MTD-UTILS_VER    = $(MTD-UTILS_VER)
HOST_MTD-UTILS_TMP    = mtd-utils-$(HOST_MTD-UTILS_VER)
HOST_MTD-UTILS_SOURCE = mtd-utils-$(HOST_MTD-UTILS_VER).tar.bz2
HOST_MTD-UTILS_URL    = ftp://ftp.infradead.org/pub/mtd-utils

#$(ARCHIVE)/$(HOST_MTD-UTILS_SOURCE):
#	$(DOWNLOAD) $(HOST_MTD-UTILS_URL)/$(HOST_MTD-UTILS_SOURCE)

host-mkfs.jffs2: $(HOST_DIR)/bin/mkfs.jffs2
host-sumtool: $(HOST_DIR)/bin/sumtool
$(HOST_DIR)/bin/mkfs.jffs2 \
$(HOST_DIR)/bin/sumtool: $(ARCHIVE)/$(HOST_MTD-UTILS_SOURCE) | $(HOST_DIR)/bin
	$(REMOVE)/$(HOST_MTD-UTILS_TMP)
	$(UNTAR)/$(HOST_MTD-UTILS_SOURCE)
	$(CHDIR)/$(HOST_MTD-UTILS_TMP); \
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
	install -D -m 0755 $(BUILD_TMP)/$(HOST_MTD-UTILS_TMP)/mkfs.jffs2 $(HOST_DIR)/bin/
	install -D -m 0755 $(BUILD_TMP)/$(HOST_MTD-UTILS_TMP)/sumtool $(HOST_DIR)/bin/
	$(REMOVE)/$(HOST_MTD-UTILS_TMP)

# -----------------------------------------------------------------------------

HOST_U-BOOT_VER    = 2018.09
HOST_U-BOOT_TMP    = u-boot-$(HOST_U-BOOT_VER)
HOST_U-BOOT_SOURCE = u-boot-$(HOST_U-BOOT_VER).tar.bz2
HOST_U-BOOT_URL    = ftp://ftp.denx.de/pub/u-boot

$(ARCHIVE)/$(HOST_U-BOOT_SOURCE):
	$(DOWNLOAD) $(HOST_U-BOOT_URL)/$(HOST_U-BOOT_SOURCE)

host-mkimage: $(HOST_DIR)/bin/mkimage
$(HOST_DIR)/bin/mkimage: $(ARCHIVE)/$(HOST_U-BOOT_SOURCE) | $(HOST_DIR)/bin
	$(REMOVE)/$(HOST_U-BOOT_TMP)
	$(UNTAR)/$(HOST_U-BOOT_SOURCE)
	$(CHDIR)/$(HOST_U-BOOT_TMP); \
		$(MAKE) defconfig; \
		$(MAKE) silentoldconfig; \
		$(MAKE) tools-only
	install -D -m 0755 $(BUILD_TMP)/$(HOST_U-BOOT_TMP)/tools/mkimage $(HOST_DIR)/bin/
	$(REMOVE)/$(HOST_U-BOOT_TMP)

# -----------------------------------------------------------------------------

HOST_TZDATA_VER    = $(TZDATA_VER)
HOST_TZDATA_TMP    = tzdata$(HOST_TZDATA_VER)
HOST_TZDATA_SOURCE = tzdata$(HOST_TZDATA_VER).tar.gz
HOST_TZDATA_URL    = ftp://ftp.iana.org/tz/releases

#$(ARCHIVE)/$(HOST_TZDATA_SOURCE):
#	$(DOWNLOAD) $(HOST_TZDATA_URL)/$(HOST_TZDATA_SOURCE)

HOST_TZCODE_VER    = 2018e
HOST_TZCODE_TMP    = tzcode$(HOST_TZCODE_VER)
HOST_TZCODE_SOURCE = tzcode$(HOST_TZCODE_VER).tar.gz
HOST_TZCODE_URL    = ftp://ftp.iana.org/tz/releases

$(ARCHIVE)/$(HOST_TZCODE_SOURCE):
	$(DOWNLOAD) $(HOST_TZCODE_URL)/$(HOST_TZCODE_SOURCE)

host-zic: $(HOST_DIR)/bin/zic
$(HOST_DIR)/bin/zic: $(ARCHIVE)/$(HOST_TZDATA_SOURCE) $(ARCHIVE)/$(HOST_TZCODE_SOURCE) | $(HOST_DIR)/bin
	$(REMOVE)/$(HOST_TZCODE_TMP)
	$(MKDIR)/$(HOST_TZCODE_TMP)
	$(CHDIR)/$(HOST_TZCODE_TMP); \
		tar -xf $(ARCHIVE)/$(HOST_TZCODE_SOURCE); \
		tar -xf $(ARCHIVE)/$(HOST_TZDATA_SOURCE); \
		$(MAKE) zic
	install -D -m 0755 $(BUILD_TMP)/$(HOST_TZCODE_TMP)/zic $(HOST_DIR)/bin/
	$(REMOVE)/$(HOST_TZCODE_TMP)

# -----------------------------------------------------------------------------

HOST_PARTED_VER    = $(PARTED_VER)
HOST_PARTED_TMP    = parted-$(HOST_PARTED_VER)
HOST_PARTED_SOURCE = parted-$(HOST_PARTED_VER).tar.xz
HOST_PARTED_URL    = https://ftp.gnu.org/gnu/parted

#$(ARCHIVE)/$(HOST_PARTED_SOURCE):
#	$(DOWNLOAD) $(HOST_PARTED_URL)/$(HOST_PARTED_SOURCE)

HOST_PARTED_PATCH  = parted-devmapper-1.patch
HOST_PARTED_PATCH += parted-sysmacros.patch

host-parted: $(HOST_DIR)/bin/parted
$(HOST_DIR)/bin/parted: $(ARCHIVE)/$(HOST_PARTED_SOURCE) | $(HOST_DIR)/bin
	$(REMOVE)/$(HOST_PARTED_TMP)
	$(UNTAR)/$(HOST_PARTED_SOURCE)
	$(CHDIR)/$(HOST_PARTED_TMP); \
		$(call apply_patches, $(HOST_PARTED_PATCH)); \
		./configure \
			--enable-silent-rules \
			--enable-static \
			--disable-shared \
			--disable-device-mapper \
			--without-readline \
			; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/$(HOST_PARTED_TMP)/parted/parted $(HOST_DIR)/bin/
	$(REMOVE)/$(HOST_PARTED_TMP)

# -----------------------------------------------------------------------------

HOST_DOSFSTOOLS_VER = $(DOSFSTOOLS_VER)
HOST_DOSFSTOOLS_TMP    = dosfstools-$(HOST_DOSFSTOOLS_VER)
HOST_DOSFSTOOLS_SOURCE = dosfstools-$(HOST_DOSFSTOOLS_VER).tar.xz
HOST_DOSFSTOOLS_URL    = https://github.com/dosfstools/dosfstools/releases/download/v$(HOST_DOSFSTOOLS_VER)

#$(ARCHIVE)/$(HOST_DOSFSTOOLS_SOURCE):
#	$(DOWNLOAD) $(HOST_DOSFSTOOLS_URL)/$(HOST_DOSFSTOOLS_SOURCE)

host-mkfs.fat: $(HOST_DIR)/bin/mkfs.fat
$(HOST_DIR)/bin/mkfs.fat: $(ARCHIVE)/$(HOST_DOSFSTOOLS_SOURCE) | $(HOST_DIR)/bin
	$(REMOVE)/$(HOST_DOSFSTOOLS_TMP)
	$(UNTAR)/$(HOST_DOSFSTOOLS_SOURCE)
	$(CHDIR)/$(HOST_DOSFSTOOLS_TMP); \
		./configure \
			--without-udev \
			; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/$(HOST_DOSFSTOOLS_TMP)/src/mkfs.fat $(HOST_DIR)/bin/
	ln -sf mkfs.fat $(HOST_DIR)/bin/mkfs.vfat
	ln -sf mkfs.fat $(HOST_DIR)/bin/mkfs.msdos
	ln -sf mkfs.fat $(HOST_DIR)/bin/mkdosfs
	$(REMOVE)/$(HOST_DOSFSTOOLS_TMP)

# -----------------------------------------------------------------------------

HOST_MTOOLS_VER    = 4.0.19
HOST_MTOOLS_TMP    = mtools-$(HOST_MTOOLS_VER)
HOST_MTOOLS_SOURCE = mtools-$(HOST_MTOOLS_VER).tar.gz
HOST_MTOOLS_URL    = ftp://ftp.gnu.org/gnu/mtools

$(ARCHIVE)/$(HOST_MTOOLS_SOURCE):
	$(DOWNLOAD) $(HOST_MTOOLS_URL)/$(HOST_MTOOLS_SOURCE)

host-mtools: $(HOST_DIR)/bin/mtools
$(HOST_DIR)/bin/mtools: $(ARCHIVE)/$(HOST_MTOOLS_SOURCE) | $(HOST_DIR)/bin
	$(REMOVE)/$(HOST_MTOOLS_TMP)
	$(UNTAR)/$(HOST_MTOOLS_SOURCE)
	$(CHDIR)/$(HOST_MTOOLS_TMP); \
		./configure; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/$(HOST_MTOOLS_TMP)/mtools $(HOST_DIR)/bin/
	ln -sf mtools $(HOST_DIR)/bin/mcopy
	$(REMOVE)/$(HOST_MTOOLS_TMP)

# -----------------------------------------------------------------------------

HOST_E2FSPROGS_VER    = $(E2FSPROGS_VER)
HOST_E2FSPROGS_TMP    = e2fsprogs-$(HOST_E2FSPROGS_VER)
HOST_E2FSPROGS_SOURCE = e2fsprogs-$(HOST_E2FSPROGS_VER).tar.gz
HOST_E2FSPROGS_URL    = https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(HOST_E2FSPROGS_VER)

#$(ARCHIVE)/$(HOST_E2FSPROGS_SOURCE):
#	$(DOWNLOAD) $(HOST_E2FSPROGS_URL)/$(HOST_E2FSPROGS_SOURCE)

host-resize2fs: $(HOST_DIR)/bin/resize2fs
$(HOST_DIR)/bin/resize2fs: $(ARCHIVE)/$(HOST_E2FSPROGS_SOURCE) | $(HOST_DIR)/bin
	$(REMOVE)/$(HOST_E2FSPROGS_TMP)
	$(UNTAR)/$(HOST_E2FSPROGS_SOURCE)
	$(CHDIR)/$(HOST_E2FSPROGS_TMP); \
		./configure; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/$(HOST_E2FSPROGS_TMP)/resize/resize2fs $(HOST_DIR)/bin/
	install -D -m 0755 $(BUILD_TMP)/$(HOST_E2FSPROGS_TMP)/misc/mke2fs $(HOST_DIR)/bin/
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext2
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext3
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext4
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext4dev
	install -D -m 0755 $(BUILD_TMP)/$(HOST_E2FSPROGS_TMP)/e2fsck/e2fsck $(HOST_DIR)/bin/
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext2
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext3
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext4
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext4dev
	$(REMOVE)/$(HOST_E2FSPROGS_TMP)

# -----------------------------------------------------------------------------

HOST_LUA = $(HOST_DIR)/bin/lua

HOST_LUA_VER    = $(LUA_VER)
HOST_LUA_TMP    = lua-$(HOST_LUA_VER)
HOST_LUA_SOURCE = lua-$(HOST_LUA_VER).tar.gz
HOST_LUA_URL    = http://www.lua.org/ftp

#$(ARCHIVE)/$(HOST_LUA_SOURCE):
#	$(DOWNLOAD) $(HOST_LUA_URL)/$(HOST_LUA_SOURCE)

HOST_LUA_PATCH  = lua-01-fix-LUA_ROOT.patch
HOST_LUA_PATCH += lua-01-remove-readline.patch

host-lua: $(HOST_LUA)
$(HOST_LUA): $(ARCHIVE)/$(HOST_LUA_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_LUA_TMP)
	$(UNTAR)/$(HOST_LUA_SOURCE)
	$(CHDIR)/$(HOST_LUA_TMP); \
		$(call apply_patches, $(HOST_LUA_PATCH)); \
		$(MAKE) linux; \
		$(MAKE) install INSTALL_TOP=$(HOST_DIR)
	$(REMOVE)/$(HOST_LUA_TMP)

# -----------------------------------------------------------------------------

HOST_LUAROCKS = $(HOST_DIR)/bin/luarocks

HOST_LUAROCKS_VER    = 3.1.3
HOST_LUAROCKS_TMP    = luarocks-$(HOST_LUAROCKS_VER)
HOST_LUAROCKS_SOURCE = luarocks-$(HOST_LUAROCKS_VER).tar.gz
HOST_LUAROCKS_URL    = https://luarocks.github.io/luarocks/releases

$(ARCHIVE)/$(HOST_LUAROCKS_SOURCE):
	$(DOWNLOAD) $(HOST_LUAROCKS_URL)/$(HOST_LUAROCKS_SOURCE)

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
