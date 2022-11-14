################################################################################
#
# neutrino-dirs
#
################################################################################

SHARE_FLEX	= $(TARGET_datadir)/tuxbox/neutrino/flex
SHARE_ICONS	= $(TARGET_datadir)/tuxbox/neutrino/icons
SHARE_LOGOS	= $(TARGET_datadir)/tuxbox/neutrino/icons/logo
SHARE_PLUGINS	= $(TARGET_datadir)/tuxbox/neutrino/plugins
SHARE_THEMES	= $(TARGET_datadir)/tuxbox/neutrino/themes
SHARE_WEBRADIO	= $(TARGET_datadir)/tuxbox/neutrino/webradio
SHARE_WEBTV	= $(TARGET_datadir)/tuxbox/neutrino/webtv
VAR_CONFIG	= $(TARGET_localstatedir)/tuxbox/config
VAR_PLUGINS	= $(TARGET_localstatedir)/tuxbox/plugins

$(SHARE_FLEX) \
$(SHARE_ICONS) \
$(SHARE_LOGOS) \
$(SHARE_PLUGINS) \
$(SHARE_THEMES) \
$(SHARE_WEBRADIO) \
$(SHARE_WEBTV) \
$(VAR_CONFIG) \
$(VAR_PLUGINS) : | $(TARGET_DIR)
	$(INSTALL) -d $(@)
