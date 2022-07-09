################################################################################
#
# zic
#
################################################################################

ZIC_VERSION = 2022a
ZIC_DIR = tzcode$(ZIC_VERSION)
ZIC_SOURCE = tzcode$(ZIC_VERSION).tar.gz
ZIC_SITE = https://data.iana.org/time-zones/releases

# ------------------------------------------------------------------------------

HOST_ZIC = $(HOST_DIR)/sbin/zic

define HOST_ZIC_INSTALL_BINARY
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/zic $(HOST_ZIC)
endef
HOST_ZIC_PRE_FOLLOWUP_HOOKS += HOST_ZIC_INSTALL_BINARY

host-zic: | $(HOST_DIR)
	$(eval $(pkg-check-variables))
	$(call STARTUP)
	$(call DEPENDENCIES)
	$(call DOWNLOAD,$($(PKG)_SOURCE))
	$(MKDIR)/$($(PKG)_DIR)
	$(call EXTRACT,$(PKG_BUILD_DIR))
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$($(PKG)_DIR); \
		$(MAKE) zic
	$(call HOST_FOLLOWUP)
