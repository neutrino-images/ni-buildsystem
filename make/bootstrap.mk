# makefile to setup and initialize the final buildsystem

BOOTSTRAP  = targetprefix $(D) $(BUILD_TMP) $(CROSS_DIR) $(STAGING_DIR) $(IMAGE_DIR) $(UPDATE_DIR) $(HOSTPREFIX)/bin includes-and-libs modules host-preqs
BOOTSTRAP += $(TARGETLIB)/libc.so.6

ifeq ($(BOXSERIES), hd2)
  BOOTSTRAP += static blobs
endif

PLAT_INCS  = $(TARGETLIB)/firmware
PLAT_LIBS  = $(TARGETLIB) $(STATICLIB)

bootstrap: $(BOOTSTRAP)
	@echo -e "\033[40;0;33mBootstrapped for $(shell echo $(BOXMODEL) | sed 's/.*/\u&/')\033[0m"

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

# build some static librarys
static: cortex-strings

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
		./configure --with-pc_path=$(PKG_CONFIG_PATH); \
		$(MAKE); \
		cp -a pkg-config $(HOSTPREFIX)/bin; \
	ln -sf pkg-config $(HOSTPREFIX)/bin/arm-cx2450x-linux-gnueabi-pkg-config
	ln -sf pkg-config $(HOSTPREFIX)/bin/arm-cortex-linux-uclibcgnueabi-pkg-config
	$(REMOVE)/pkg-config-$(PKGCONF_VER)

mkfs.jffs2: $(HOSTPREFIX)/bin/mkfs.jffs2
sumtool: $(HOSTPREFIX)/bin/sumtool
$(HOSTPREFIX)/bin/mkfs.jffs2 \
$(HOSTPREFIX)/bin/sumtool: | $(HOSTPREFIX)/bin
	git clone git://git.infradead.org/mtd-utils.git $(BUILD_TMP)/mtd-utils && \
	pushd $(BUILD_TMP)/mtd-utils && \
		./autogen.sh -fi && \
		./configure \
			ZLIB_CFLAGS=" " \
			ZLIB_LIBS="-lz" \
			UUID_CFLAGS=" " \
			UUID_LIBS="-luuid" \
			--enable-silent-rules \
			--without-ubifs \
			--disable-tests && \
		$(MAKE) WITHOUT_XATTR=1
	install -D -m 0755 $(BUILD_TMP)/mtd-utils/sumtool $(HOSTPREFIX)/bin/
	install -D -m 0755 $(BUILD_TMP)/mtd-utils/mkfs.jffs2 $(HOSTPREFIX)/bin/
	$(REMOVE)/mtd-utils

mkimage: $(HOSTPREFIX)/bin/mkimage
$(HOSTPREFIX)/bin/mkimage: $(ARCHIVE)/u-boot-2015.01.tar.bz2 | $(HOSTPREFIX)/bin
	$(UNTAR)/u-boot-2015.01.tar.bz2
	pushd $(BUILD_TMP)/u-boot-2015.01 && \
		$(PATCH)/u-boot-fix-build-error-under-gcc6.patch && \
		$(PATCH)/u-boot-support-gcc5.patch && \
		$(PATCH)/u-boot-rsa-Fix-build-with-OpenSSL-1.1.x.patch && \
		$(MAKE) defconfig && \
		$(MAKE) silentoldconfig && \
		$(MAKE) tools-only
	install -D -m 0755 $(BUILD_TMP)/u-boot-2015.01/tools/mkimage $(HOSTPREFIX)/bin/
	$(REMOVE)/u-boot-2015.01

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
