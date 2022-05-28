################################################################################
#
# u-boot
#
################################################################################

HOST_U_BOOT_VERSION = 2022.01
HOST_U_BOOT_DIR = u-boot-$(HOST_U_BOOT_VERSION)
HOST_U_BOOT_SOURCE = u-boot-$(HOST_U_BOOT_VERSION).tar.bz2
HOST_U_BOOT_SITE = ftp://ftp.denx.de/pub/u-boot

HOST_MKIMAGE = $(HOST_DIR)/bin/mkimage

define HOST_U_BOOT_INSTALL_BINARY
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/tools/mkimage $(HOST_MKIMAGE)
endef
HOST_U_BOOT_PRE_FOLLOWUP_HOOKS += HOST_U_BOOT_INSTALL_BINARY

host-u-boot: | $(HOST_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(MAKE) defconfig; \
		$(MAKE) tools-only
	$(call HOST_FOLLOWUP)
