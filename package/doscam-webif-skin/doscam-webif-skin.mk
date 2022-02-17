################################################################################
#
# doscam-webif-skin
#
################################################################################

doscam-webif-skin:
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/doscam_ni-dark.css $(TARGET_datadir)/doscam/skin/doscam_ni-dark.css
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/IC_doscam_ni.tpl $(TARGET_datadir)/doscam/tpl/IC_doscam_ni.tpl
	$(TOUCH)
