################################################################################
#
# crosstool-ng
#
################################################################################

CROSSTOOL_NG_VERSION = git
CROSSTOOL_NG_DIR = crosstool-ng.$(CROSSTOOL_NG_VERSION)
CROSSTOOL_NG_SOURCE = crosstool-ng.$(CROSSTOOL_NG_VERSION)
CROSSTOOL_NG_SITE = https://github.com/neutrino-images

CROSSTOOL_NG_DEPS = kernel-tarball

CROSSTOOL_NG_CONFIG = $(PACKAGE_DIR)/crosstool-ng/files/ct-ng-$(BOXTYPE).config
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
  CROSSTOOL_NG_CONFIG = $(PACKAGE_DIR)/crosstool-ng/files/ct-ng-$(BOXTYPE)-$(BOXSERIES).config
endif

# crosstool-ng for hd2 depends on gcc-linaro and uses uclibc
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd2))

CROSSTOOL_NG_PATCH = 0001-bash-version.patch

GCC_LINARO_VERSION = 4.9-2017.01
GCC_LINARO_SOURCE = gcc-linaro-$(GCC_LINARO_VERSION).tar.xz
GCC_LINARO_SITE = https://releases.linaro.org/components/toolchain/gcc-linaro/$(GCC_LINARO_VERSION)

$(DL_DIR)/$(GCC_LINARO_SOURCE):
	$(download) $(GCC_LINARO_SITE)/$(GCC_LINARO_SOURCE)

CROSSTOOL_NG_DEPS += $(DL_DIR)/$(GCC_LINARO_SOURCE)

UCLIBC_VERSION = 1.0.24

CROSSTOOL_NG_DEPS += kernel-headers

endif

ifeq ($(wildcard $(CROSS_DIR)/build.log.bz2),)

crosstool-ng: $(CROSSTOOL_NG_DEPS) | $(BUILD_DIR)
	$(REMOVE)/$($(PKG)_DIR)
	$(GET_GIT_SOURCE) $($(PKG)_SITE)/$($(PKG)_SOURCE) $(DL_DIR)/$($(PKG)_SOURCE)
	$(CPDIR)/$($(PKG)_SOURCE)
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
	$(CHDIR)/$($(PKG)_DIR); \
		git checkout 1dbb06f2
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
  ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd2))
	$(INSTALL_COPY) $(PKG_PATCHES_DIR)/gcc/* $(PKG_BUILD_DIR)/patches/gcc/linaro-6.3-2017.02
  endif
endif
	$(CHDIR)/$($(PKG)_DIR); \
		unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE; \
		$(INSTALL_DATA) $(CROSSTOOL_NG_CONFIG) .config; \
		$(SED) "s|^CT_PARALLEL_JOBS=.*|CT_PARALLEL_JOBS=$(PARALLEL_JOBS)|" .config; \
		export BS_LOCAL_TARBALLS_DIR=$(DL_DIR); \
		export BS_PREFIX_DIR=$(CROSS_DIR); \
		export BS_KERNEL_VERSION=$(KERNEL_VERSION); \
		export BS_KERNEL_LOCATION=$(KERNEL_TARBALL); \
		export BS_KERNEL_HEADERS=$(KERNEL_HEADERS_DIR); \
		export BS_LIBC_UCLIBC_CONFIG_FILE=$(PACKAGE_DIR)/crosstool-ng/files/ct-ng-uClibc-$(UCLIBC_VERSION).config; \
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
	$(REMOVE)/$($(PKG)_DIR)

else

crosstool-ng:

endif
