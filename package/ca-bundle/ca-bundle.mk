################################################################################
#
# ca-bundle
#
################################################################################

CA_BUNDLE_SOURCE = cacert.pem
CA_BUNDLE_SITE = https://curl.se/ca

$(DL_DIR)/$(CA_BUNDLE_SOURCE):
	$(download) $(CA_BUNDLE_SITE)/$(CA_BUNDLE_SOURCE)

CA_BUNDLE_DIR = /etc/ssl/certs
CA_BUNDLE_CRT = ca-certificates.crt

ca-bundle: $(DL_DIR)/$(CA_BUNDLE_SOURCE) | $(TARGET_DIR)
	$(CD) $(DL_DIR); \
		curl --remote-name --remote-time -z $(PKG_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) || true
	$(INSTALL_DATA) -D $(DL_DIR)/$(PKG_SOURCE) $(TARGET_DIR)/$(CA_BUNDLE_DIR)/$(CA_BUNDLE_CRT)
	$(call TOUCH)
