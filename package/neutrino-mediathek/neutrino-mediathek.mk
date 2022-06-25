################################################################################
#
# neutrino-mediathek
#
################################################################################

NEUTRINO_MEDIATHEK_VERSION = git
NEUTRINO_MEDIATHEK_DIR = mediathek.$(NEUTRINO_MEDIATHEK_VERSION)
NEUTRINO_MEDIATHEK_SOURCE = mediathek.$(NEUTRINO_MEDIATHEK_VERSION)
NEUTRINO_MEDIATHEK_SITE = https://github.com/neutrino-mediathek

neutrino-mediathek: $(SHARE_PLUGINS) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(INSTALL_COPY) plugins/* $(SHARE_PLUGINS)/; \
		$(INSTALL_COPY) share/* $(TARGET_datadir)
	$(REMOVE)/$(PKG_DIR)
	# temporarily use beta-version from our board
	rm -rf $(SHARE_PLUGINS)/neutrino-mediathek*
	$(INSTALL_COPY) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/plugins/mediathek/* $(SHARE_PLUGINS)/
	$(call TOUCH)
