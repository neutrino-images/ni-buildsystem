#
# makefile to build crosstools
#
# -----------------------------------------------------------------------------

crosstool: $(CROSS_BASE)/$(BOXARCH)/$(BOXSERIES)

crosstools:
	for boxseries in hd1 hd2 hd51 bre2ze4k; do \
		make BOXSERIES=$${boxseries} $(CROSS_BASE)/$(BOXARCH)/$${boxseries} || exit; \
	done;

# -----------------------------------------------------------------------------

CROSSTOOL_BACKUP = $(ARCHIVE)/crosstool-$(BOXARCH)-$(BOXSERIES)-backup.tar.gz

$(CROSSTOOL_BACKUP):
	$(call draw_line);
	@echo "CROSSTOOL_BACKUP does not exist. You probably need to run 'make crosstool-backup' first."
	$(call draw_line);
	@false

crosstool-backup:
	$(CD) $(CROSS_DIR); \
		tar -czvf $(CROSSTOOL_BACKUP) *

crosstool-restore: $(CROSSTOOL_BACKUP)
	make cross-clean
	mkdir -p $(CROSS_DIR)
	tar -xzvf $(CROSSTOOL_BACKUP) -C $(CROSS_DIR)

# -----------------------------------------------------------------------------

crosstools-renew:
	for boxseries in hd1 hd2 hd51 bre2ze4k; do \
		make BOXSERIES=$${boxseries} ccache-clean || exit; \
	done;
	make host-clean
	make static-base-clean
	make cross-base-clean
	make crosstools
	make clean

# -----------------------------------------------------------------------------

# wrapper for manually call
kernel-tarball: $(BUILD_TMP)/linux-$(KERNEL_VERSION).tar

# create kernel-tarball
$(BUILD_TMP)/linux-$(KERNEL_VERSION).tar: | $(BUILD_TMP)
	make kernel.do_checkout
	tar cf $(@) --exclude-vcs -C $(SOURCE_DIR)/$(NI-LINUX-KERNEL) .

# -----------------------------------------------------------------------------

# wrappers for manually call
crosstool-arm-hd1: $(CROSS_BASE)/arm/hd1
crosstool-arm-hd2: $(CROSS_BASE)/arm/hd2
crosstool-arm-hd51: $(CROSS_BASE)/arm/hd51
crosstool-arm-bre2ze4k: $(CROSS_BASE)/arm/bre2ze4k

# -----------------------------------------------------------------------------

CROSSTOOL-NG_VER    = git
CROSSTOOL-NG_TMP    = crosstool-ng.$(CROSSTOOL-NG_VER)
CROSSTOOL-NG_SOURCE = crosstool-ng.$(CROSSTOOL-NG_VER)
CROSSTOOL-NG_URL    = https://github.com/crosstool-ng

CROSSTOOL-NG_PATCH  = crosstool-ng-bash-version.patch

# crosstool for hd2 depends on gcc-linaro
GCC-LINARO_VER    = 4.9-2017.01
GCC-LINARO_SOURCE = gcc-linaro-$(GCC-LINARO_VER).tar.xz
GCC-LINARO_URL    = https://releases.linaro.org/components/toolchain/gcc-linaro

$(ARCHIVE)/$(GCC-LINARO_SOURCE):
	$(DOWNLOAD) $(GCC-LINARO_URL)/$(GCC-LINARO_SOURCE)

UCLIBC_VER = 1.0.24

# -----------------------------------------------------------------------------

# crosstool for hd2 depends on gcc-linaro
$(CROSS_BASE)/arm/hd2: $(ARCHIVE)/$(GCC-LINARO_SOURCE)

$(CROSS_BASE)/arm/hd1 \
$(CROSS_BASE)/arm/hd2 \
$(CROSS_BASE)/arm/hd51: | $(BUILD_TMP)
	make $(BUILD_TMP)/linux-$(KERNEL_VERSION).tar
	#
	$(REMOVE)/$(CROSSTOOL-NG_TMP)
	$(GET-GIT-SOURCE) $(CROSSTOOL-NG_URL)/$(CROSSTOOL-NG_SOURCE) $(ARCHIVE)/$(CROSSTOOL-NG_SOURCE)
	$(CPDIR)/$(CROSSTOOL-NG_SOURCE)
	$(CHDIR)/$(CROSSTOOL-NG_TMP); \
		git checkout 1dbb06f2; \
		$(call apply_patches, $(CROSSTOOL-NG_PATCH))
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), hd2 hd51 bre2ze4k))
	$(CHDIR)/$(CROSSTOOL-NG_TMP); \
		cp -a $(PATCHES)/crosstool-ng/gcc/* patches/gcc/linaro-6.3-2017.02
endif
	$(CHDIR)/$(CROSSTOOL-NG_TMP); \
		unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE; \
		$(INSTALL_DATA) $(CONFIGS)/ct-ng-$(BOXTYPE)-$(BOXSERIES).config .config; \
		sed -i "s|^CT_PARALLEL_JOBS=.*|CT_PARALLEL_JOBS=$(PARALLEL_JOBS)|" .config; \
		export NI_LOCAL_TARBALLS_DIR=$(ARCHIVE); \
		export NI_PREFIX_DIR=$(@); \
		export NI_KERNEL_VERSION=$(KERNEL_VERSION); \
		export NI_KERNEL_LOCATION=$(BUILD_TMP)/linux-$(KERNEL_VERSION).tar; \
		export NI_LIBC_UCLIBC_CONFIG_FILE=$(CONFIGS)/ct-ng-uClibc-$(UCLIBC_VER).config; \
		export LD_LIBRARY_PATH=; \
		test -f ./configure || ./bootstrap; \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), hd1 hd2))
	test -e $(CROSS_DIR)/$(TARGET)/lib && mv $(CROSS_DIR)/$(TARGET)/lib $(CROSS_DIR)/$(TARGET)/lib.x
endif
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/
	rm -f $(CROSS_DIR)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.*-gdb.py
	$(REMOVE)/$(CROSSTOOL-NG_TMP)

# -----------------------------------------------------------------------------

# bre2ze4k uses same crosstool as hd51; so let's just create a symlink
$(CROSS_BASE)/arm/bre2ze4k:
	make $(CROSS_BASE)/arm/hd51
	ln -sf hd51 $(@)

# -----------------------------------------------------------------------------

get-gccversion:
	@echo ""
	@$(TARGET_CC) --version

# -----------------------------------------------------------------------------

PHONY += crosstool
PHONY += crosstools
PHONY += crosstools-renew

PHONY += get-gccversion
