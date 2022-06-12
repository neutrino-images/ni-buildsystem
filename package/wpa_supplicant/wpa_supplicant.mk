################################################################################
#
# wpa_supplicant
#
################################################################################

WPA_SUPPLICANT_VERSION = $(if $(filter $(BOXTYPE),coolstream),0.7.3,2.10)
WPA_SUPPLICANT_DIR = wpa_supplicant-$(WPA_SUPPLICANT_VERSION)
WPA_SUPPLICANT_SOURCE = wpa_supplicant-$(WPA_SUPPLICANT_VERSION).tar.gz
WPA_SUPPLICANT_SITE = https://w1.fi/releases

WPA_SUPPLICANT_DEPENDENCIES = openssl

ifeq ($(BOXTYPE),coolstream)
WPA_SUPPLICANT_CONFIG = $(PKG_FILES_DIR)/wpa_supplicant.config-$(WPA_SUPPLICANT_VERSION)
else
WPA_SUPPLICANT_CONFIG = $(PKG_FILES_DIR)/wpa_supplicant.config
WPA_SUPPLICANT_DEPENDENCIES += libnl
endif

define WPA_SUPPLICANT_INSTALL_CONFIG
	$(INSTALL_DATA) $(WPA_SUPPLICANT_CONFIG) $(PKG_BUILD_DIR)/wpa_supplicant/.config
endef
WPA_SUPPLICANT_POST_PATCH_HOOKS += WPA_SUPPLICANT_INSTALL_CONFIG

define WPA_SUPPLICANT_INSTALL_FILES
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/pre-wlan0.sh $(TARGET_sysconfdir)/network/pre-wlan0.sh
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/post-wlan0.sh $(TARGET_sysconfdir)/network/post-wlan0.sh
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/wpa_supplicant.conf $(TARGET_sysconfdir)/wpa_supplicant.conf
endef
WPA_SUPPLICANT_TARGET_FINALIZE_HOOKS += WPA_SUPPLICANT_INSTALL_FILES

ifeq ($(PERSISTENT_VAR_PARTITION),yes)
define WPA_SUPPLICANT_INSTALL_LINK
	ln -sf /var/etc/wpa_supplicant.conf $(TARGET_sysconfdir)/wpa_supplicant.conf
endef
WPA_SUPPLICANT_TARGET_FINALIZE_HOOKS += WPA_SUPPLICANT_INSTALL_LINK
endif

wpa_supplicant: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR)/wpa_supplicant; \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) BINDIR=$(sbindir)
	$(call TARGET_FOLLOWUP)
