################################################################################
#
# vsftpd
#
################################################################################

VSFTPD_VERSION = 3.0.5
VSFTPD_DIR = vsftpd-$(VSFTPD_VERSION)
VSFTPD_SOURCE = vsftpd-$(VSFTPD_VERSION).tar.gz
VSFTPD_SITE = https://security.appspot.com/downloads

VSFTPD_DEPENDENCIES = openssl

VSFTPD_LIBS += -lcrypt $$($(PKG_CONFIG) --libs libssl libcrypto)

VSFTPD_MAKE_OPTS = \
	$(TARGET_CONFIGURE_ENV) \
	LIBS="$(VSFTPD_LIBS)"

define VSFTPD_PATCH_BUILDDEFS_H
	$(SED) 's/.*VSF_BUILD_PAM/#undef VSF_BUILD_PAM/' $(PKG_BUILD_DIR)/builddefs.h
	$(SED) 's/.*VSF_BUILD_SSL/#define VSF_BUILD_SSL/' $(PKG_BUILD_DIR)/builddefs.h
endef
VSFTPD_POST_PATCH_HOOKS += VSFTPD_PATCH_BUILDDEFS_H

define VSFTPD_INSTALL_CMDS
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/vsftpd $(TARGET_sbindir)/vsftpd
endef

define VSFTPD_INSTALL_FILES
	$(INSTALL) -d $(TARGET_datadir)/empty
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/vsftpd.conf $(TARGET_sysconfdir)/vsftpd.conf
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/vsftpd.chroot_list $(TARGET_sysconfdir)/vsftpd.chroot_list
endef
VSFTPD_TARGET_FINALIZE_HOOKS += VSFTPD_INSTALL_FILES

define VSFTPD_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/vsftpd.init $(TARGET_sysconfdir)/init.d/vsftpd
	$(UPDATE-RC.D) vsftpd defaults 75 25
endef

vsftpd: | $(TARGET_DIR)
	$(call generic-package)
