################################################################################
#
# channellogos
#
################################################################################

channellogos: $(SOURCE_DIR)/$(NI_LOGO_STUFF) $(SHARE_ICONS)
	rm -rf $(SHARE_LOGOS)
	$(INSTALL) -d $(SHARE_LOGOS)
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_LOGO_STUFF)/logos/* $(SHARE_LOGOS)
	$(INSTALL) -d $(SHARE_LOGOS)/events
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_LOGO_STUFF)/logos-events/* $(SHARE_LOGOS)/events
	$(CD) $(SOURCE_DIR)/$(NI_LOGO_STUFF)/logo-links; \
		./logo-linker.sh logo-links.db $(SHARE_LOGOS)
	$(TOUCH)
