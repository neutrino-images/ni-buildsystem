################################################################################
#
# zic
#
################################################################################

HOST_ZIC_VERSION = 2020f
HOST_ZIC_DIR = tzcode$(HOST_ZIC_VERSION)
HOST_ZIC_SOURCE = tzcode$(HOST_ZIC_VERSION).tar.gz
HOST_ZIC_SITE = ftp://ftp.iana.org/tz/releases

$(DL_DIR)/$(HOST_ZIC_SOURCE):
	$(download) $(HOST_ZIC_SITE)/$(HOST_ZIC_SOURCE)

HOST_ZIC = $(HOST_DIR)/sbin/zic

host-zic: $(DL_DIR)/$(HOST_ZIC_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(MKDIR)/$(PKG_DIR)
	$(CHDIR)/$(PKG_DIR); \
		tar -xf $(DL_DIR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(MAKE) zic
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/zic $(HOST_ZIC)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
