################################################################################
#
# crosstool-ng
#
################################################################################

CROSSTOOL_NG_VERSION = 9433647
CROSSTOOL_NG_DIR = crosstool-ng.git
CROSSTOOL_NG_SOURCE = crosstool-ng.git
CROSSTOOL_NG_SITE = https://github.com/crosstool-ng
CROSSTOOL_NG_SITE_METHOD = git

CROSSTOOL_NG_DEPENDENCIES = kernel-tarball kernel-headers

CROSSTOOL_NG_CONFIG = $(PKG_FILES_DIR)/crosstool-ng-$(BOXTYPE).config
CROSSTOOL_NG_BUILD_CONFIG = $(PKG_BUILD_DIR)/.config

CROSSTOOL_NG_UNSET = \
	CONFIG_SITE \
	CPATH \
	CPLUS_INCLUDE_PATH \
	C_INCLUDE_PATH \
	INCLUDE \
	LD_LIBRARY_PATH \
	LIBRARY_PATH \
	PKG_CONFIG_PATH

CROSSTOOL_NG_EXPORT = \
	BS_LOCAL_TARBALLS_DIR=$(DL_DIR) \
	BS_PREFIX_DIR=$(CROSS_DIR) \
	BS_LINUX_CUSTOM_LOCATION=$(BUILD_DIR)/$(KERNEL_DIR)

# begin coolstream
ifeq ($(BOXTYPE),coolstream)

CROSSTOOL_NG_VERSION = 1dbb06f

CROSSTOOL_NG_CONFIG = $(PKG_FILES_DIR)/crosstool-ng-$(BOXTYPE)-$(BOXSERIES).config

CROSSTOOL_NG_EXPORT += \
	LD_LIBRARY_PATH= \
	BS_KERNEL_VERSION=$(KERNEL_VERSION) \
	BS_KERNEL_LOCATION=$(KERNEL_TARBALL) \
	BS_KERNEL_HEADERS=$(KERNEL_HEADERS_DIR) \

ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1))

# crosstool-ng for cst hd1 uses external gcc-linaro 4.9
GCC_LINARO_VERSION = 4.9-2017.01
GCC_LINARO_SOURCE = gcc-linaro-$(GCC_LINARO_VERSION).tar.xz
GCC_LINARO_SITE = https://releases.linaro.org/components/toolchain/gcc-linaro/$(GCC_LINARO_VERSION)

define CROSSTOOL_NG_DOWNLOAD_LINARO_4_9
	$(GET_ARCHIVE) $(DL_DIR) $(GCC_LINARO_SITE)/$(GCC_LINARO_SOURCE)
endef
CROSSTOOL_NG_POST_DOWNLOAD_HOOKS += CROSSTOOL_NG_DOWNLOAD_LINARO_4_9

endif

ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd2))

# crosstool-ng for cst hd2 uses uclibc-ng 1.0.24
UCLIBC_NG_VERSION = 1.0.24

CROSSTOOL_NG_EXPORT += \
	BS_LIBC_UCLIBC_CONFIG_FILE=$(PKG_FILES_DIR)/uclibc-ng-$(UCLIBC_NG_VERSION).config

# crosstool-ng for cst hd1 uses gcc-linaro 6.3
GCC_LINARO_VERSION = 6.3-2017.02

define CROSSTOOL_NG_INSTALL_PATCHES
	$(INSTALL_COPY) $(PKG_PATCHES_DIR)/$(CROSSTOOL_NG_SITE_METHOD)-$(CROSSTOOL_NG_VERSION)-gcc/* \
		$(PKG_BUILD_DIR)/patches/gcc/linaro-$(GCC_LINARO_VERSION)
endef
CROSSTOOL_NG_POST_PATCH_HOOKS += CROSSTOOL_NG_INSTALL_PATCHES

endif

define CROSSTOOL_NG_CLEANUP_COOLSTREAM
	test -e $(CROSS_DIR)/$(GNU_TARGET_NAME)/lib && \
		mv $(CROSS_DIR)/$(GNU_TARGET_NAME)/lib $(CROSS_DIR)/$(GNU_TARGET_NAME)/lib.x
endef
CROSSTOOL_NG_CLEANUP_HOOKS += CROSSTOOL_NG_CLEANUP_COOLSTREAM

endif
# end coolstream

define CROSSTOOL_NG_CLEANUP_COMMON
	test -e $(CROSS_DIR)/$(GNU_TARGET_NAME)/lib || \
		ln -sf sys-root/lib $(CROSS_DIR)/$(GNU_TARGET_NAME)/
	rm -f $(CROSS_DIR)/$(GNU_TARGET_NAME)/sys-root/lib/libstdc++.so.6.0.*-gdb.py
endef
CROSSTOOL_NG_CLEANUP_HOOKS += CROSSTOOL_NG_CLEANUP_COMMON

define CROSSTOOL_NG_INSTALL_CONFIG
	$(INSTALL_DATA) $(CROSSTOOL_NG_CONFIG) $(CROSSTOOL_NG_BUILD_CONFIG)
	$(SED) "s|^CT_PARALLEL_JOBS=.*|CT_PARALLEL_JOBS=$(PARALLEL_JOBS)|" $(CROSSTOOL_NG_BUILD_CONFIG)
endef
CROSSTOOL_NG_POST_PATCH_HOOKS += CROSSTOOL_NG_INSTALL_CONFIG

define CROSSTOOL_NG_DISTRIBUTE_CONFIG
	$(INSTALL_DATA) $(CROSSTOOL_NG_BUILD_CONFIG) $(CROSSTOOL_NG_CONFIG)
	$(SED) "s|^CT_PARALLEL_JOBS=.*|CT_PARALLEL_JOBS=0|" $(CROSSTOOL_NG_CONFIG)
	@$(call MESSAGE,"Commit your changes in $(CROSSTOOL_NG_CONFIG)")
endef

# -----------------------------------------------------------------------------

crosstool-ng.do_prepare: | $(DEPS_DIR) $(BUILD_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		unset $($(PKG)_UNSET); \
		export $($(PKG)_EXPORT); \
		test -f ./configure || ./bootstrap; \
		./configure --enable-local; \
		MAKELEVEL=0 make
	$(call TOUCH)

crosstool-ng.do_compile: crosstool-ng.do_prepare
	$(CHDIR)/$($(PKG)_DIR); \
		unset $($(PKG)_UNSET); \
		export $($(PKG)_EXPORT); \
		./ct-ng oldconfig; \
		./ct-ng build
	$(call TOUCH)

# -----------------------------------------------------------------------------

# upgradeconfig doesn't work for coolstream; crosstool-ng 1dbb06f is too old

crosstool-ng.menuconfig \
crosstool-ng.upgradeconfig: crosstool-ng.do_prepare
	$(CHDIR)/$($(PKG)_DIR); \
		unset $($(PKG)_UNSET); \
		export $($(PKG)_EXPORT); \
		./ct-ng $(subst crosstool-ng.,,$(@))
	$(CROSSTOOL_NG_DISTRIBUTE_CONFIG)

# -----------------------------------------------------------------------------

ifeq ($(wildcard $(CROSS_DIR)/build.log.bz2),)

crosstool-ng: crosstool-ng.do_compile
	$(foreach hook,$($(PKG)_CLEANUP_HOOKS),$(call $(hook))$(sep))

else

crosstool-ng:

endif
