# makefile to setup and initialize the final buildsystem

BOOTSTRAP  = targetprefix $(D) $(BUILD_TMP) $(CROSS_DIR) $(STAGING_DIR) $(IMAGE_DIR) $(UPDATE_DIR) $(HOSTPREFIX)/bin includes-and-libs modules host-preqs
BOOTSTRAP += $(TARGETLIB)/libc.so.6

ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 ax))
  BOOTSTRAP += static blobs
endif

PLAT_INCS  = $(TARGETLIB)/firmware
PLAT_LIBS  = $(TARGETLIB) $(STATICLIB)

bootstrap: $(BOOTSTRAP)
	@echo -e "$(TERM_YELLOW)Bootstrapped for $(shell echo $(BOXTYPE) | sed 's/.*/\u&/') $(BOXMODEL)$(TERM_NORMAL)"

skeleton: | $(TARGETPREFIX)
	cp --remove-destination -a $(SKEL_ROOT)/* $(TARGETPREFIX)/
	if [ -d $(SKEL_ROOT)-$(BOXFAMILY)/ ]; then \
		cp -a $(SKEL_ROOT)-$(BOXFAMILY)/* $(TARGETPREFIX)/; \
	fi
	if [ -d $(STATIC_DIR)/ ]; then \
		cp -a $(STATIC_DIR)/* $(TARGETPREFIX)/; \
	fi

targetprefix:
	mkdir -p $(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX)/bin
	mkdir -p $(TARGETINCLUDE)
	mkdir -p $(PKG_CONFIG_PATH)
	make skeleton

$(TARGETPREFIX):
	@echo "**********************************************************************"
	@echo "TARGETPREFIX does not exist. You probably need to run 'make bootstrap'"
	@echo "**********************************************************************"
	@echo ""
	@false

$(D) \
$(BUILD_TMP) \
$(CROSS_DIR) \
$(STAGING_DIR) \
$(IMAGE_DIR) \
$(UPDATE_DIR) \
$(HOSTPREFIX):
	mkdir -p $@

$(HOSTPREFIX)/bin: $(HOSTPREFIX)
	mkdir -p $@

$(STATICLIB):
	mkdir -p $@

$(TARGETLIB)/firmware: | $(TARGETPREFIX)
ifeq ($(BOXTYPE), coolstream)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/firmware/* $@/
endif

$(TARGETLIB): | $(TARGETPREFIX)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/libs/* $@

$(TARGETLIB)/modules: | $(TARGETPREFIX)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/drivers/$(KVERSION_FULL) $@/

$(TARGETLIB)/libc.so.6: | $(TARGETPREFIX)
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/lib; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/lib/*so* $(TARGETLIB); \
	else \
		cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(TARGETLIB); \
	fi

$(TARGETPREFIX)/var/update: | $(TARGETPREFIX)
	mkdir -p $@
ifeq ($(BOXTYPE), coolstream)
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/uldr.bin $@/
ifeq ($(BOXMODEL), kronos_v2)
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/u-boot.bin.link $@/u-boot.bin
else
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/u-boot.bin $@/
endif
endif

includes-and-libs: $(PLAT_INCS) $(PLAT_LIBS)

modules: $(TARGETLIB)/modules

blobs: $(TARGETPREFIX)/var/update

# helper target to create ccache links (make sure to have ccache installed in /usr/bin ;)
ccache: find-ccache $(CCACHE) $(HOSTPREFIX)/bin
	@ln -sf $(CCACHE) $(HOSTPREFIX)/bin/cc
	@ln -sf $(CCACHE) $(HOSTPREFIX)/bin/gcc
	@ln -sf $(CCACHE) $(HOSTPREFIX)/bin/g++
	@ln -sf $(CCACHE) $(HOSTPREFIX)/bin/$(TARGET)-gcc
	@ln -sf $(CCACHE) $(HOSTPREFIX)/bin/$(TARGET)-g++

# build all needed host-binaries
host-preqs: pkg-config mkfs.jffs2 mkfs.fat sumtool mkimage zic parted_host mtools resize2fs ccache

pkg-config-preqs:
	@PATH=$(subst $(HOSTPREFIX)/bin:,,$(PATH)); \
		if ! pkg-config --exists glib-2.0; then \
			echo "pkg-config and glib2-devel packages are needed for building cross-pkg-config."; false; \
		fi

pkg-config: $(HOSTPREFIX)/bin/pkg-config
$(HOSTPREFIX)/bin/pkg-config: $(ARCHIVE)/pkg-config-$(PKGCONF_VER).tar.gz | $(HOSTPREFIX)/bin pkg-config-preqs
	$(UNTAR)/pkg-config-$(PKGCONF_VER).tar.gz
	set -e; cd $(BUILD_TMP)/pkg-config-$(PKGCONF_VER); \
		./configure \
			--with-pc_path=$(PKG_CONFIG_PATH); \
		$(MAKE); \
		cp -a pkg-config $(HOSTPREFIX)/bin; \
	ln -sf pkg-config $(HOSTPREFIX)/bin/arm-cx2450x-linux-gnueabi-pkg-config
	ln -sf pkg-config $(HOSTPREFIX)/bin/arm-cortex-linux-uclibcgnueabi-pkg-config
	ln -sf pkg-config $(HOSTPREFIX)/bin/arm-cortex-linux-gnueabihf-pkg-config
	$(REMOVE)/pkg-config-$(PKGCONF_VER)

mkfs.jffs2: $(HOSTPREFIX)/bin/mkfs.jffs2
sumtool: $(HOSTPREFIX)/bin/sumtool
$(HOSTPREFIX)/bin/mkfs.jffs2 \
$(HOSTPREFIX)/bin/sumtool: $(ARCHIVE)/mtd-utils-$(MTD-UTILS_VER).tar.bz2 | $(HOSTPREFIX)/bin
	$(UNTAR)/mtd-utils-$(MTD-UTILS_VER).tar.bz2
	pushd $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER) && \
		./configure \
			ZLIB_CFLAGS=" " \
			ZLIB_LIBS="-lz" \
			UUID_CFLAGS=" " \
			UUID_LIBS="-luuid" \
			--enable-silent-rules \
			--without-ubifs \
			--without-xattr \
			--disable-tests && \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/sumtool $(HOSTPREFIX)/bin/
	install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/mkfs.jffs2 $(HOSTPREFIX)/bin/
	$(REMOVE)/mtd-utils-$(MTD-UTILS_VER)

mkimage: $(HOSTPREFIX)/bin/mkimage
$(HOSTPREFIX)/bin/mkimage: $(ARCHIVE)/u-boot-$(U_BOOT_VER).tar.bz2 | $(HOSTPREFIX)/bin
	$(UNTAR)/u-boot-$(U_BOOT_VER).tar.bz2
	pushd $(BUILD_TMP)/u-boot-$(U_BOOT_VER) && \
		$(MAKE) defconfig && \
		$(MAKE) silentoldconfig && \
		$(MAKE) tools-only
	install -D -m 0755 $(BUILD_TMP)/u-boot-$(U_BOOT_VER)/tools/mkimage $(HOSTPREFIX)/bin/
	$(REMOVE)/u-boot-$(U_BOOT_VER)

zic: $(HOSTPREFIX)/bin/zic
$(HOSTPREFIX)/bin/zic: $(ARCHIVE)/tzdata$(TZDATA_VER).tar.gz $(ARCHIVE)/tzcode$(TZCODE_VER).tar.gz | $(HOSTPREFIX)/bin
	mkdir $(BUILD_TMP)/tzcode && \
	tar -C $(BUILD_TMP)/tzcode -xf $(ARCHIVE)/tzcode$(TZCODE_VER).tar.gz
	tar -C $(BUILD_TMP)/tzcode -xf $(ARCHIVE)/tzdata$(TZDATA_VER).tar.gz
	pushd $(BUILD_TMP)/tzcode && \
		$(MAKE) zic
	install -D -m 0755 $(BUILD_TMP)/tzcode/zic $(HOSTPREFIX)/bin/
	$(REMOVE)/tzcode

parted_host: $(HOSTPREFIX)/bin/parted
$(HOSTPREFIX)/bin/parted: $(ARCHIVE)/parted-$(PARTED_VER).tar.xz | $(HOSTPREFIX)/bin
	$(UNTAR)/parted-$(PARTED_VER).tar.xz
	cd $(BUILD_TMP)/parted-$(PARTED_VER) && \
		$(PATCH)/parted-3.2-devmapper-1.patch && \
		$(PATCH)/parted-3.2-sysmacros.patch && \
		./configure \
			--enable-silent-rules \
			--enable-static \
			--disable-shared \
			--disable-device-mapper \
			--without-readline && \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/parted-$(PARTED_VER)/parted/parted $(HOSTPREFIX)/bin/
	$(REMOVE)/parted-$(PARTED_VER)

mkfs.fat: $(HOSTPREFIX)/bin/mkfs.fat
$(HOSTPREFIX)/bin/mkfs.fat: $(ARCHIVE)/dosfstools-$(DOSFSTOOLS_VER).tar.xz | $(HOSTPREFIX)/bin
	$(UNTAR)/dosfstools-$(DOSFSTOOLS_VER).tar.xz
	set -e; cd $(BUILD_TMP)/dosfstools-$(DOSFSTOOLS_VER); \
		./configure \
			--without-udev \
		; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/dosfstools-$(DOSFSTOOLS_VER)/src/mkfs.fat $(HOSTPREFIX)/bin/
	ln -sf mkfs.fat $(HOSTPREFIX)/bin/mkfs.vfat
	ln -sf mkfs.fat $(HOSTPREFIX)/bin/mkfs.msdos
	ln -sf mkfs.fat $(HOSTPREFIX)/bin/mkdosfs
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VER)

mtools: $(HOSTPREFIX)/bin/mtools
$(HOSTPREFIX)/bin/mtools: $(ARCHIVE)/mtools-$(MTOOLS_VER).tar.gz | $(HOSTPREFIX)/bin
	$(UNTAR)/mtools-$(MTOOLS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/mtools-$(MTOOLS_VER); \
		./configure; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/mtools-$(MTOOLS_VER)/mtools $(HOSTPREFIX)/bin/
	ln -sf mtools $(HOSTPREFIX)/bin/mcopy
	$(REMOVE)/mtools-$(MTOOLS_VER)

resize2fs: $(HOSTPREFIX)/bin/resize2fs
$(HOSTPREFIX)/bin/resize2fs: $(ARCHIVE)/e2fsprogs-$(E2FSPROGS_VER).tar.gz | $(HOSTPREFIX)/bin
	$(UNTAR)/e2fsprogs-$(E2FSPROGS_VER).tar.gz
	cd $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER) && \
		./configure; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER)/resize/resize2fs $(HOSTPREFIX)/bin/
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER)/misc/mke2fs $(HOSTPREFIX)/bin/
	ln -sf mke2fs $(HOSTPREFIX)/bin/mkfs.ext2
	ln -sf mke2fs $(HOSTPREFIX)/bin/mkfs.ext3
	ln -sf mke2fs $(HOSTPREFIX)/bin/mkfs.ext4
	ln -sf mke2fs $(HOSTPREFIX)/bin/mkfs.ext4dev
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER)/e2fsck/e2fsck $(HOSTPREFIX)/bin/
	ln -sf e2fsck $(HOSTPREFIX)/bin/fsck.ext2
	ln -sf e2fsck $(HOSTPREFIX)/bin/fsck.ext3
	ln -sf e2fsck $(HOSTPREFIX)/bin/fsck.ext4
	ln -sf e2fsck $(HOSTPREFIX)/bin/fsck.ext4dev
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VER)

# hack to make sure they are always copied
PHONY += $(TARGETLIB)
PHONY += $(TARGETLIB)/firmware
PHONY += $(TARGETLIB)/modules
PHONY += $(TARGETPREFIX)/var/update
PHONY += ccache includes-and-libs modules targetprefix bootstrap blobs
