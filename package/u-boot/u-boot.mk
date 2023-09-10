################################################################################
#
# u-boot
#
################################################################################

U_BOOT_VERSION = 2021.04
U_BOOT_DIR = u-boot-$(U_BOOT_VERSION)
U_BOOT_SOURCE = u-boot-$(U_BOOT_VERSION).tar.bz2
U_BOOT_SITE = ftp://ftp.denx.de/pub/u-boot

# ------------------------------------------------------------------------------

HOST_MKIMAGE_BINARY = $(HOST_DIR)/bin/mkimage

define HOST_U_BOOT_MAKE_DEFCONFIG
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_MAKE) defconfig
endef
HOST_U_BOOT_PRE_BUILD_HOOKS += HOST_U_BOOT_MAKE_DEFCONFIG

HOST_U_BOOT_MAKE_ARGS = \
	tools-only

define HOST_U_BOOT_INSTALL_CMDS
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/tools/mkimage $(HOST_MKIMAGE_BINARY)
endef

host-u-boot: | $(HOST_DIR)
	$(call host-generic-package)
