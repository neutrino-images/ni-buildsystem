# makefile to setup and initialize the final buildsystem

BOOTSTRAP  = targetprefix $(D) $(BUILD_TMP) $(CROSS_DIR) $(STAGING_DIR) $(IMAGE_DIR) $(UPDATE_DIR) $(HOST_DIR)/bin includes-and-libs modules host-preqs
BOOTSTRAP += $(TARGETLIB)/libc.so.6

ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 hd51))
  BOOTSTRAP += static blobs
endif

PLAT_INCS  = $(TARGETLIB)/firmware
PLAT_LIBS  = $(TARGETLIB) $(STATICLIB)

bootstrap: $(BOOTSTRAP)
	@echo -e "$(TERM_YELLOW)Bootstrapped for $(shell echo $(BOXTYPE) | sed 's/.*/\u&/') $(BOXMODEL)$(TERM_NORMAL)"

skeleton: | $(TARGET_DIR)
	cp --remove-destination -a $(SKEL_ROOT)/* $(TARGET_DIR)/
	if [ -d $(SKEL_ROOT)-$(BOXFAMILY)/ ]; then \
		cp -a $(SKEL_ROOT)-$(BOXFAMILY)/* $(TARGET_DIR)/; \
	fi
	if [ -d $(STATIC_DIR)/ ]; then \
		cp -a $(STATIC_DIR)/* $(TARGET_DIR)/; \
	fi

targetprefix:
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/bin
	mkdir -p $(TARGETINCLUDE)
	mkdir -p $(PKG_CONFIG_PATH)
	make skeleton

$(TARGET_DIR):
	@echo "**********************************************************************"
	@echo "TARGET_DIR does not exist. You probably need to run 'make bootstrap'"
	@echo "**********************************************************************"
	@echo ""
	@false

$(D) \
$(BUILD_TMP) \
$(CROSS_DIR) \
$(STAGING_DIR) \
$(IMAGE_DIR) \
$(UPDATE_DIR) \
$(HOST_DIR):
	mkdir -p $@

$(HOST_DIR)/bin: $(HOST_DIR)
	mkdir -p $@

$(STATICLIB):
	mkdir -p $@

$(TARGETLIB)/firmware: | $(TARGET_DIR)
ifeq ($(BOXTYPE), coolstream)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/firmware/* $@/
endif

$(TARGETLIB): | $(TARGET_DIR)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/libs/* $@
ifeq ($(BOXTYPE), coolstream)
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/libcoolstream/$(shell echo -n $(NI_FFMPEG_BRANCH) | sed 's,/,-,g')/* $@
endif

$(TARGETLIB)/modules: | $(TARGET_DIR)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/drivers/$(KERNEL_VERSION_FULL) $@/

$(TARGETLIB)/libc.so.6: | $(TARGET_DIR)
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/lib; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/lib/*so* $(TARGETLIB); \
	else \
		cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(TARGETLIB); \
	fi

$(TARGET_DIR)/var/update: | $(TARGET_DIR)
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

blobs: $(TARGET_DIR)/var/update

# helper target to create ccache links (make sure to have ccache installed in /usr/bin ;)
ccache: find-ccache $(CCACHE) $(HOST_DIR)/bin
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/cc
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/gcc
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/g++
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/$(TARGET)-gcc
	@ln -sf $(CCACHE) $(HOST_DIR)/bin/$(TARGET)-g++

# build all needed host-binaries
host-preqs: pkg-config mkfs.jffs2 mkfs.fat sumtool mkimage zic parted_host mtools resize2fs ccache

pkg-config-preqs:
	@PATH=$(subst $(HOST_DIR)/bin:,,$(PATH)); \
		if ! pkg-config --exists glib-2.0; then \
			echo "pkg-config and glib2-devel packages are needed for building cross-pkg-config."; false; \
		fi

pkg-config: $(HOST_DIR)/bin/pkg-config
$(HOST_DIR)/bin/pkg-config: $(ARCHIVE)/pkg-config-$(PKGCONF_VER).tar.gz | $(HOST_DIR)/bin pkg-config-preqs
	$(UNTAR)/pkg-config-$(PKGCONF_VER).tar.gz
	set -e; cd $(BUILD_TMP)/pkg-config-$(PKGCONF_VER); \
		./configure \
			--with-pc_path=$(PKG_CONFIG_PATH); \
		$(MAKE); \
		cp -a pkg-config $(HOST_DIR)/bin; \
	ln -sf pkg-config $(HOST_DIR)/bin/arm-cx2450x-linux-gnueabi-pkg-config
	ln -sf pkg-config $(HOST_DIR)/bin/arm-cortex-linux-uclibcgnueabi-pkg-config
	ln -sf pkg-config $(HOST_DIR)/bin/arm-cortex-linux-gnueabihf-pkg-config
	$(REMOVE)/pkg-config-$(PKGCONF_VER)

mkfs.jffs2: $(HOST_DIR)/bin/mkfs.jffs2
sumtool: $(HOST_DIR)/bin/sumtool
$(HOST_DIR)/bin/mkfs.jffs2 \
$(HOST_DIR)/bin/sumtool: $(ARCHIVE)/mtd-utils-$(MTD-UTILS_VER).tar.bz2 | $(HOST_DIR)/bin
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
	install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/sumtool $(HOST_DIR)/bin/
	install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/mkfs.jffs2 $(HOST_DIR)/bin/
	$(REMOVE)/mtd-utils-$(MTD-UTILS_VER)

mkimage: $(HOST_DIR)/bin/mkimage
$(HOST_DIR)/bin/mkimage: $(ARCHIVE)/u-boot-$(U_BOOT_VER).tar.bz2 | $(HOST_DIR)/bin
	$(UNTAR)/u-boot-$(U_BOOT_VER).tar.bz2
	pushd $(BUILD_TMP)/u-boot-$(U_BOOT_VER) && \
		$(MAKE) defconfig && \
		$(MAKE) silentoldconfig && \
		$(MAKE) tools-only
	install -D -m 0755 $(BUILD_TMP)/u-boot-$(U_BOOT_VER)/tools/mkimage $(HOST_DIR)/bin/
	$(REMOVE)/u-boot-$(U_BOOT_VER)

zic: $(HOST_DIR)/bin/zic
$(HOST_DIR)/bin/zic: $(ARCHIVE)/tzdata$(TZDATA_VER).tar.gz $(ARCHIVE)/tzcode$(TZCODE_VER).tar.gz | $(HOST_DIR)/bin
	mkdir $(BUILD_TMP)/tzcode && \
	tar -C $(BUILD_TMP)/tzcode -xf $(ARCHIVE)/tzcode$(TZCODE_VER).tar.gz
	tar -C $(BUILD_TMP)/tzcode -xf $(ARCHIVE)/tzdata$(TZDATA_VER).tar.gz
	pushd $(BUILD_TMP)/tzcode && \
		$(MAKE) zic
	install -D -m 0755 $(BUILD_TMP)/tzcode/zic $(HOST_DIR)/bin/
	$(REMOVE)/tzcode

parted_host: $(HOST_DIR)/bin/parted
$(HOST_DIR)/bin/parted: $(ARCHIVE)/parted-$(PARTED_VER).tar.xz | $(HOST_DIR)/bin
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
	install -D -m 0755 $(BUILD_TMP)/parted-$(PARTED_VER)/parted/parted $(HOST_DIR)/bin/
	$(REMOVE)/parted-$(PARTED_VER)

mkfs.fat: $(HOST_DIR)/bin/mkfs.fat
$(HOST_DIR)/bin/mkfs.fat: $(ARCHIVE)/dosfstools-$(DOSFSTOOLS_VER).tar.xz | $(HOST_DIR)/bin
	$(UNTAR)/dosfstools-$(DOSFSTOOLS_VER).tar.xz
	set -e; cd $(BUILD_TMP)/dosfstools-$(DOSFSTOOLS_VER); \
		./configure \
			--without-udev \
		; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/dosfstools-$(DOSFSTOOLS_VER)/src/mkfs.fat $(HOST_DIR)/bin/
	ln -sf mkfs.fat $(HOST_DIR)/bin/mkfs.vfat
	ln -sf mkfs.fat $(HOST_DIR)/bin/mkfs.msdos
	ln -sf mkfs.fat $(HOST_DIR)/bin/mkdosfs
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VER)

mtools: $(HOST_DIR)/bin/mtools
$(HOST_DIR)/bin/mtools: $(ARCHIVE)/mtools-$(MTOOLS_VER).tar.gz | $(HOST_DIR)/bin
	$(UNTAR)/mtools-$(MTOOLS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/mtools-$(MTOOLS_VER); \
		./configure; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/mtools-$(MTOOLS_VER)/mtools $(HOST_DIR)/bin/
	ln -sf mtools $(HOST_DIR)/bin/mcopy
	$(REMOVE)/mtools-$(MTOOLS_VER)

resize2fs: $(HOST_DIR)/bin/resize2fs
$(HOST_DIR)/bin/resize2fs: $(ARCHIVE)/e2fsprogs-$(E2FSPROGS_VER).tar.gz | $(HOST_DIR)/bin
	$(UNTAR)/e2fsprogs-$(E2FSPROGS_VER).tar.gz
	cd $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER) && \
		./configure; \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER)/resize/resize2fs $(HOST_DIR)/bin/
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER)/misc/mke2fs $(HOST_DIR)/bin/
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext2
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext3
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext4
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext4dev
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER)/e2fsck/e2fsck $(HOST_DIR)/bin/
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext2
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext3
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext4
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext4dev
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VER)

# hack to make sure they are always copied
PHONY += $(TARGETLIB)
PHONY += $(TARGETLIB)/firmware
PHONY += $(TARGETLIB)/modules
PHONY += $(TARGET_DIR)/var/update
PHONY += ccache includes-and-libs modules targetprefix bootstrap blobs
