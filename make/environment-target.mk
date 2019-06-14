#
# set up target environment for other makefiles
#
# -----------------------------------------------------------------------------

BIN		= $(TARGET_DIR)/bin
ETCINITD	= $(TARGET_DIR)/etc/init.d
SBIN		= $(TARGET_DIR)/sbin
SHAREFLEX	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/flex
SHAREICONS	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons
SHAREPLUGINS	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins
SHARETHEMES	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/themes
SHAREWEBRADIO	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/webradio
SHAREWEBTV	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/webtv
VARCONFIG	= $(TARGET_DIR)/var/tuxbox/config
VARINITD	= $(TARGET_DIR)/var/etc/init.d
VARPLUGINS	= $(TARGET_DIR)/var/tuxbox/plugins

$(ETCINITD) \
$(SBIN) \
$(SHAREFLEX) \
$(SHAREICONS) \
$(SHAREPLUGINS) \
$(SHARETHEMES) \
$(SHAREWEBRADIO) \
$(SHAREWEBTV) \
$(VARCONFIG) \
$(VARINITD) \
$(VARPLUGINS) : | $(TARGET_DIR)
	mkdir -p $@

# -----------------------------------------------------------------------------

# ca-certificates
CA-BUNDLE	= ca-certificates.crt
CA-BUNDLE_DIR	= /etc/ssl/certs
