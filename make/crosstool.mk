#
# makefile to build crosstools
#
# -----------------------------------------------------------------------------

crosstool: $(CROSS_DIR)

crosstools:
	for boxseries in hd1 hd2 hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo; do \
		echo "make crosstool-ng for $${boxseries}"; \
		make BOXSERIES=$${boxseries} crosstool || exit; \
	done;

# -----------------------------------------------------------------------------

CROSSTOOL_BACKUP = $(DL_DIR)/crosstool-ng-$(TARGET_ARCH)-linux-$(KERNEL_VER)-backup.tar.gz

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
	for boxseries in hd1 hd2 hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo; do \
		make BOXSERIES=$${boxseries} ccache-clean || exit; \
	done;
	make host-clean
	make static-base-clean
	make cross-base-clean
	make crosstools
	make clean

# -----------------------------------------------------------------------------

# wrapper for manually call
kernel-tarball: $(BUILD_DIR)/linux-$(KERNEL_VER).tar

# create kernel-tarball
$(BUILD_DIR)/linux-$(KERNEL_VER).tar: | $(BUILD_DIR)
	$(MAKE) kernel.do_prepare_$(if $(filter $(KERNEL_SOURCE),git),git,tar)
	tar cf $(@) --exclude-vcs -C $(BUILD_DIR)/$(KERNEL_DIR) .

# -----------------------------------------------------------------------------

CROSSTOOL_NG_VER    = git
CROSSTOOL_NG_DIR    = crosstool-ng.$(CROSSTOOL_NG_VER)
CROSSTOOL_NG_SOURCE = crosstool-ng.$(CROSSTOOL_NG_VER)
CROSSTOOL_NG_SITE   = https://github.com/neutrino-images

CROSSTOOL_NG_PATCH  = crosstool-ng-bash-version.patch

CROSSTOOL_NG_CONFIG = $(PACKAGE_DIR)/crosstool-ng/files/ct-ng-$(BOXTYPE).config
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
  CROSSTOOL_NG_CONFIG = $(PACKAGE_DIR)/crosstool-ng/files/ct-ng-$(BOXTYPE)-$(BOXSERIES).config
endif

# crosstool for hd2 depends on gcc-linaro
GCC_LINARO_VER    = 4.9-2017.01
GCC_LINARO_SOURCE = gcc-linaro-$(GCC_LINARO_VER).tar.xz
GCC_LINARO_SITE   = https://releases.linaro.org/components/toolchain/gcc-linaro/$(GCC_LINARO_VER)

$(DL_DIR)/$(GCC_LINARO_SOURCE):
	$(DOWNLOAD) $(GCC_LINARO_SITE)/$(GCC_LINARO_SOURCE)

UCLIBC_VER = 1.0.24

# -----------------------------------------------------------------------------

# crosstool for arm-hd2 depends on gcc-linaro
$(CROSS_BASE)/arm/hd2: $(DL_DIR)/$(GCC_LINARO_SOURCE)

$(CROSS_DIR): | $(BUILD_DIR)
	make $(BUILD_DIR)/linux-$(KERNEL_VER).tar
	#
	$(REMOVE)/$(CROSSTOOL_NG_DIR)
	$(GET-GIT-SOURCE) $(CROSSTOOL_NG_SITE)/$(CROSSTOOL_NG_SOURCE) $(DL_DIR)/$(CROSSTOOL_NG_SOURCE)
	$(CPDIR)/$(CROSSTOOL_NG_SOURCE)
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
	$(CHDIR)/$(CROSSTOOL_NG_DIR); \
		git checkout 1dbb06f2; \
		$(call apply_patches,$(PACKAGE_DIR)/crosstool-ng/patches/$(CROSSTOOL_NG_PATCH))
  ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd2))
	$(CHDIR)/$(CROSSTOOL_NG_DIR); \
		$(INSTALL_COPY) $(PACKAGE_DIR)/crosstool-ng/patches/gcc/* patches/gcc/linaro-6.3-2017.02
  endif
endif
	$(CHDIR)/$(CROSSTOOL_NG_DIR); \
		unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE; \
		$(INSTALL_DATA) $(CROSSTOOL_NG_CONFIG) .config; \
		$(SED) "s|^CT_PARALLEL_JOBS=.*|CT_PARALLEL_JOBS=$(PARALLEL_JOBS)|" .config; \
		export NI_LOCAL_TARBALLS_DIR=$(DL_DIR); \
		export NI_PREFIX_DIR=$(@); \
		export NI_KERNEL_VERSION=$(KERNEL_VER); \
		export NI_KERNEL_LOCATION=$(BUILD_DIR)/linux-$(KERNEL_VER).tar; \
		export NI_LIBC_UCLIBC_CONFIG_FILE=$(PACKAGE_DIR)/crosstool-ng/files/ct-ng-uClibc-$(UCLIBC_VER).config; \
		export LD_LIBRARY_PATH=; \
		test -f ./configure || ./bootstrap; \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
	test -e $(CROSS_DIR)/$(TARGET)/lib && mv $(CROSS_DIR)/$(TARGET)/lib $(CROSS_DIR)/$(TARGET)/lib.x
endif
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/
	rm -f $(CROSS_DIR)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.*-gdb.py
	$(REMOVE)/$(CROSSTOOL_NG_DIR)

# -----------------------------------------------------------------------------

get-gccversion:
	@echo ""
	@$(TARGET_CC) --version

# -----------------------------------------------------------------------------

PHONY += crosstool
PHONY += crosstools
PHONY += crosstools-renew

PHONY += get-gccversion
