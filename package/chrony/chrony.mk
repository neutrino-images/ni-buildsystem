################################################################################
#
# chrony
#
################################################################################

CHRONY_VERSION = 4.8
CHRONY_DIR = chrony-$(CHRONY_VERSION)
CHRONY_SOURCE = chrony-$(CHRONY_VERSION).tar.gz
CHRONY_SITE = https://chrony-project.org/releases

CHRONY_CONF_OPTS = \
	--prefix=$(prefix) \
	--mandir=$(REMOVE_mandir)

define CHRONY_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_CONFIGURE_ARGS) \
		$(TARGET_CONFIGURE_ENV) \
                ./configure $(CHRONY_CONF_OPTS)
endef

define CHRONY_INSTALL_CHRONY_CONF
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/chrony.conf $(TARGET_sysconfdir)
endef
CHRONY_TARGET_FINALIZE_HOOKS += CHRONY_INSTALL_CHRONY_CONF

define CHRONY_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/chrony.init $(TARGET_sysconfdir)/init.d/chrony
	$(UPDATE-RC.D) chrony defaults 75 25
endef

chrony: | $(TARGET_DIR)
	$(call generic-package)
