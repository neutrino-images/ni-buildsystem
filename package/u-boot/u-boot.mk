################################################################################
#
# u-boot
#
################################################################################

HOST_U_BOOT_VERSION = 2018.09
HOST_U_BOOT_DIR = u-boot-$(HOST_U_BOOT_VERSION)
HOST_U_BOOT_SOURCE = u-boot-$(HOST_U_BOOT_VERSION).tar.bz2
HOST_U_BOOT_SITE = ftp://ftp.denx.de/pub/u-boot

$(DL_DIR)/$(HOST_U_BOOT_SOURCE):
	$(download) $(HOST_U_BOOT_SITE)/$(HOST_U_BOOT_SOURCE)

HOST_MKIMAGE = $(HOST_DIR)/bin/mkimage

host-u-boot: $(DL_DIR)/$(HOST_U_BOOT_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(MAKE) defconfig; \
		$(MAKE) silentoldconfig; \
		$(MAKE) tools-only
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/tools/mkimage $(HOST_MKIMAGE)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
