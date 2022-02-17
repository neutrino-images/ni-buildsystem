################################################################################
#
# logo-addon
#
################################################################################

logo-addon: $(SOURCE_DIR)/$(NI_LOGO_STUFF) $(SHARE_PLUGINS)
	$(INSTALL_EXEC) $(SOURCE_DIR)/$(NI_LOGO_STUFF)/logo-addon/*.sh $(SHARE_PLUGINS)/
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_LOGO_STUFF)/logo-addon/*.cfg $(SHARE_PLUGINS)/
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_LOGO_STUFF)/logo-addon/*.png $(SHARE_PLUGINS)/
	$(TOUCH)
