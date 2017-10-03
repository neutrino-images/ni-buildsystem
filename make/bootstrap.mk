# makefile to setup and initialize the final buildsystem

BOOTSTRAP  = targetprefix $(D) $(BUILD_TMP) $(CROSS_DIR) $(STAGING_DIR) $(IMAGE_DIR) $(UPDATE_DIR) $(HOSTPREFIX)/bin includes-and-libs modules host-preqs
BOOTSTRAP += $(TARGETLIB)/libc.so.6

ifeq ($(BOXSERIES), hd2)
  BOOTSTRAP += static blobs
endif

PLAT_INCS  = $(TARGETLIB)/firmware
PLAT_LIBS  = $(TARGETLIB) $(STATICLIB)

bootstrap: $(BOOTSTRAP)
	@echo -e "$(TERM_YELLOW)Bootstrapped for $(shell echo $(BOXMODEL) | sed 's/.*/\u&/')$(TERM_NORMAL)"

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
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/firmware/* $@/

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
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/uldr.bin $@/
ifeq ($(BOXMODEL), kronos_v2)
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/u-boot.bin.link $@/u-boot.bin
else
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/u-boot.bin $@/
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
host-preqs: pkg-config mkfs.jffs2 sumtool mkimage zic ccache

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

# hack to make sure they are always copied
PHONY += $(TARGETLIB)/firmware
PHONY += $(TARGETLIB)
PHONY += $(TARGETLIB)/modules
PHONY += $(TARGETPREFIX)/var/update
PHONY += ccache includes-and-libs modules targetprefix bootstrap blobs
