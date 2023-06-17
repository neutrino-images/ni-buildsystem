################################################################################
#
# doscam-webif-skin
#
################################################################################

define DOSCAM_WEBIF_SKIN_INSTALL
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/doscam_ni-dark.css $(TARGET_datadir)/doscam/skin/doscam_ni-dark.css
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/IC_doscam_ni.tpl $(TARGET_datadir)/doscam/tpl/IC_doscam_ni.tpl
endef
DOSCAM_WEBIF_SKIN_INDIVIDUAL_HOOKS += DOSCAM_WEBIF_SKIN_INSTALL

doscam-webif-skin: | $(TARGET_DIR)
	$(call virtual-package)
