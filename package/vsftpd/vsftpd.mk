################################################################################
#
# vsftpd
#
################################################################################

VSFTPD_VERSION = 3.0.3
VSFTPD_DIR = vsftpd-$(VSFTPD_VERSION)
VSFTPD_SOURCE = vsftpd-$(VSFTPD_VERSION).tar.gz
VSFTPD_SITE = https://security.appspot.com/downloads

$(DL_DIR)/$(VSFTPD_SOURCE):
	$(download) $(VSFTPD_SITE)/$(VSFTPD_SOURCE)

VSFTPD_LIBS += -lcrypt $$($(PKG_CONFIG) --libs libssl libcrypto)

VSFTPD_DEPENDENCIES = openssl

vsftpd: $(VSFTPD_DEPENDENCIES) $(DL_DIR)/$(VSFTPD_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(SED) 's/.*VSF_BUILD_PAM/#undef VSF_BUILD_PAM/' builddefs.h; \
		$(SED) 's/.*VSF_BUILD_SSL/#define VSF_BUILD_SSL/' builddefs.h; \
		$(MAKE) clean; \
		$(MAKE) $(TARGET_CONFIGURE_ENV) LIBS="$($(PKG)_LIBS)"; \
		$(INSTALL_EXEC) -D vsftpd $(TARGET_sbindir)/vsftpd
	$(INSTALL) -d $(TARGET_datadir)/empty
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/vsftpd.conf $(TARGET_sysconfdir)/vsftpd.conf
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/vsftpd.chroot_list $(TARGET_sysconfdir)/vsftpd.chroot_list
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/vsftpd.init $(TARGET_sysconfdir)/init.d/vsftpd
	$(UPDATE-RC.D) vsftpd defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
