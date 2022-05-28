################################################################################
#
# zic
#
################################################################################

HOST_ZIC_VERSION = 2022a
HOST_ZIC_DIR = tzcode$(HOST_ZIC_VERSION)
HOST_ZIC_SOURCE = tzcode$(HOST_ZIC_VERSION).tar.gz
HOST_ZIC_SITE = https://data.iana.org/time-zones/releases

HOST_ZIC = $(HOST_DIR)/sbin/zic

define HOST_ZIC_INSTALL_BINARY
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/zic $(HOST_ZIC)
endef
HOST_ZIC_PRE_FOLLOWUP_HOOKS += HOST_ZIC_INSTALL_BINARY

host-zic: | $(HOST_DIR)
	$(call STARTUP)
	$(call DEPENDENCIES)
	$(call DOWNLOAD,$($(PKG)_SOURCE))
	$(MKDIR)/$($(PKG)_DIR)
	$(call EXTRACT,$(PKG_BUILD_DIR))
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$($(PKG)_DIR); \
		$(MAKE) zic
	$(call HOST_FOLLOWUP)
