################################################################################
#
# neutrino initial settings
#
################################################################################

neutrino-initial-settings: matze-192
	$(REMOVE)/initial
	$(MKDIR)/initial
	$(CHDIR)/initial; \
		tar -xf $(STAGING_DIR)/updates/matze-192.bin; \
		cp temp_inst/inst/var/tuxbox/config/zapit/* $(SOURCE_DIR)/$(NI_NEUTRINO)/data/initial/
	P192=$$(grep -m 1 "position=\"192\"" $(SOURCE_DIR)/$(NI_NEUTRINO)/data/config/satellites.xml); \
	P192=$$(echo $$P192); \
	$(SED) "/position=\"192\"/c\	$$P192" $(SOURCE_DIR)/$(NI_NEUTRINO)/data/initial/services.xml
	@$(call MESSAGE,"Commit your changes in $(SOURCE_DIR)/$(NI_NEUTRINO)/data/initial")
