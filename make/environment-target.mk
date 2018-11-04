#
# set up target environment for other makefiles
#
# -----------------------------------------------------------------------------

BIN		= $(TARGET_DIR)/bin
ETCINITD	= $(TARGET_DIR)/etc/init.d
LIBPLUGINS	= $(TARGET_DIR)/lib/tuxbox/plugins
SBIN		= $(TARGET_DIR)/sbin
SHAREFLEX	= $(TARGET_DIR)/share/tuxbox/neutrino/flex
SHAREICONS	= $(TARGET_DIR)/share/tuxbox/neutrino/icons
SHAREPLUGINS	= $(TARGET_DIR)/share/tuxbox/neutrino/plugins
SHARETHEMES	= $(TARGET_DIR)/share/tuxbox/neutrino/themes
SHAREWEBRADIO	= $(TARGET_DIR)/share/tuxbox/neutrino/webradio
SHAREWEBTV	= $(TARGET_DIR)/share/tuxbox/neutrino/webtv
VARCONFIG	= $(TARGET_DIR)/var/tuxbox/config
VARINITD	= $(TARGET_DIR)/var/etc/init.d
VARPLUGINS	= $(TARGET_DIR)/var/tuxbox/plugins

$(BIN) \
$(ETCINITD) \
$(LIBPLUGINS) \
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
