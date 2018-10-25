# makefile to build all needed host-binaries

host-preqs: \
	host_pkg-config \
	host_mkfs.jffs2 \
	host_sumtool \
	host_mkimage \
	host_zic \
	host_parted \
	host_mkfs.fat \
	host_mtools \
	host_resize2fs \
	ccache

# -----------------------------------------------------------------------------

HOST_PKG-CONFIG_VER = 0.29.2

$(ARCHIVE)/pkg-config-$(HOST_PKG-CONFIG_VER).tar.gz:
	$(WGET) https://pkg-config.freedesktop.org/releases/pkg-config-$(HOST_PKG-CONFIG_VER).tar.gz
	
pkg-config-preqs:
	@PATH=$(subst $(HOST_DIR)/bin:,,$(PATH)); \
	if ! pkg-config --exists glib-2.0; then \
		echo "pkg-config and glib2-devel packages are needed for building cross-pkg-config."; false; \
	fi

host_pkg-config: $(HOST_DIR)/bin/pkg-config
$(HOST_DIR)/bin/pkg-config: $(ARCHIVE)/pkg-config-$(HOST_PKG-CONFIG_VER).tar.gz | $(HOST_DIR)/bin pkg-config-preqs
	$(REMOVE)/pkg-config-$(HOST_PKG-CONFIG_VER)
	$(UNTAR)/pkg-config-$(HOST_PKG-CONFIG_VER).tar.gz
	$(CHDIR)/pkg-config-$(HOST_PKG-CONFIG_VER); \
		./configure \
			--with-pc_path=$(PKG_CONFIG_PATH) \
			; \
		$(MAKE); \
		cp -a pkg-config $(HOST_DIR)/bin; \
	ln -sf pkg-config $(HOST_DIR)/bin/arm-cx2450x-linux-gnueabi-pkg-config
	ln -sf pkg-config $(HOST_DIR)/bin/arm-cortex-linux-uclibcgnueabi-pkg-config
	ln -sf pkg-config $(HOST_DIR)/bin/arm-cortex-linux-gnueabihf-pkg-config
	$(REMOVE)/pkg-config-$(HOST_PKG-CONFIG_VER)

# -----------------------------------------------------------------------------

HOST_MTD-UTILS_VER = $(MTD-UTILS_VER)

#$(ARCHIVE)/mtd-utils-$(HOST_MTD-UTILS_VER).tar.bz2:
#	$(WGET) ftp://ftp.infradead.org/pub/mtd-utils/mtd-utils-$(HOST_MTD-UTILS_VER).tar.bz2

host_mkfs.jffs2: $(HOST_DIR)/bin/mkfs.jffs2
host_sumtool: $(HOST_DIR)/bin/sumtool
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

host_mkimage: $(HOST_DIR)/bin/mkimage
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

host_zic: $(HOST_DIR)/bin/zic
$(HOST_DIR)/bin/zic: $(ARCHIVE)/tzdata$(HOST_TZDATA_VER).tar.gz $(ARCHIVE)/tzcode$(HOST_TZCODE_VER).tar.gz | $(HOST_DIR)/bin
	$(REMOVE)/tzcode
	mkdir $(BUILD_TMP)/tzcode
	$(CHDIR)/tzcode; \
		tar -xf $(ARCHIVE)/tzcode$(HOST_TZCODE_VER).tar.gz; \
		tar -xf $(ARCHIVE)/tzdata$(HOST_TZDATA_VER).tar.gz; \
		$(MAKE) zic
	install -D -m 0755 $(BUILD_TMP)/tzcode/zic $(HOST_DIR)/bin/
	#$(REMOVE)/tzcode

# -----------------------------------------------------------------------------

HOST_PARTED_VER = $(PARTED_VER)

#$(ARCHIVE)/parted-$(HOST_PARTED_VER).tar.xz:
#	$(WGET) http://ftp.gnu.org/gnu/parted/parted-$(HOST_PARTED_VER).tar.xz

HOST_PARTED_PATCH  = parted-3.2-devmapper-1.patch
HOST_PARTED_PATCH += parted-3.2-sysmacros.patch

host_parted: $(HOST_DIR)/bin/parted
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

host_mkfs.fat: $(HOST_DIR)/bin/mkfs.fat
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

host_mtools: $(HOST_DIR)/bin/mtools
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

host_resize2fs: $(HOST_DIR)/bin/resize2fs
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

# helper target to create ccache links (make sure to have ccache installed in /usr/bin ;)
ccache: find-ccache $(CCACHE) $(HOST_DIR)/bin
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/cc
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/gcc
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/g++
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/$(TARGET)-gcc
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/$(TARGET)-g++

# -----------------------------------------------------------------------------

PHONY += host-preqs
PHONY += ccache
PHONY += pkg-config-preqs
