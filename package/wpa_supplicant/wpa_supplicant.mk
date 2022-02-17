################################################################################
#
# wpa_supplicant
#
################################################################################

WPA_SUPPLICANT_VERSION = 0.7.3
WPA_SUPPLICANT_DIR = wpa_supplicant-$(WPA_SUPPLICANT_VERSION)
WPA_SUPPLICANT_SOURCE = wpa_supplicant-$(WPA_SUPPLICANT_VERSION).tar.gz
WPA_SUPPLICANT_SITE = https://w1.fi/releases

$(DL_DIR)/$(WPA_SUPPLICANT_SOURCE):
	$(download) $(WPA_SUPPLICANT_SITE)/$(WPA_SUPPLICANT_SOURCE)

WPA_SUPPLICANT_DEPENDENCIES = openssl

wpa_supplicant: $(WPA_SUPPLICANT_DEPENDENCIES) $(DL_DIR)/$(WPA_SUPPLICANT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR)/wpa_supplicant; \
		$(INSTALL_DATA) $(PKG_FILES_DIR)/wpa_supplicant.config .config; \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) BINDIR=$(sbindir)
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/pre-wlan0.sh $(TARGET_sysconfdir)/network/pre-wlan0.sh
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/post-wlan0.sh $(TARGET_sysconfdir)/network/post-wlan0.sh
  ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	ln -sf /var/etc/wpa_supplicant.conf $(TARGET_sysconfdir)/wpa_supplicant.conf
  endif
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
