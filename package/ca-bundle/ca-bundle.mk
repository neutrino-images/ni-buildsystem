################################################################################
#
# ca-bundle
#
################################################################################

CA_BUNDLE_VERSION =
CA_BUNDLE_DIR =
CA_BUNDLE_SOURCE = cacert.pem
CA_BUNDLE_SITE = https://curl.se/ca
CA_BUNDLE_SITE_METHOD = curl

CA_BUNDLE_CERTS_DIR = $(sysconfdir)/ssl/certs
CA_BUNDLE_CERT = ca-certificates.crt

define CA_BUNDLE_INSTALL
	$(INSTALL_DATA) -D $(DL_DIR)/$($(PKG)_SOURCE) $(TARGET_DIR)/$(CA_BUNDLE_CERTS_DIR)/$(CA_BUNDLE_CERT)
endef
CA_BUNDLE_INDIVIDUAL_HOOKS += CA_BUNDLE_INSTALL

ca-bundle: | $(TARGET_DIR)
	$(call individual-package,$(PKG_NO_EXTRACT) $(PKG_NO_PATCHES))
