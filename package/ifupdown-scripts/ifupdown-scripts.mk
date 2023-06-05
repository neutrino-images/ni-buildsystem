################################################################################
#
# ifupdown-scripts
#
################################################################################

define IFUPDOWN_SCRIPTS_INSTALL_IFUPDOWN_DIRS
	$(INSTALL) -d $(TARGET_sysconfdir)/network/if-{pre-up,up,post-up,pre-down,down,post-down}.d
endef
IFUPDOWN_SCRIPTS_INDIVIDUAL_HOOKS += IFUPDOWN_SCRIPTS_INSTALL_IFUPDOWN_DIRS

ifeq ($(PERSISTENT_VAR_PARTITION),yes)
define IFUPDOWN_SCRIPTS_INSTALL_INTERFACES
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/interfaces $(TARGET_localstatedir)/etc/network/interfaces
	ln -sf /var/etc/network/interfaces $(TARGET_sysconfdir)/network/interfaces
endef
else
define IFUPDOWN_SCRIPTS_INSTALL_INTERFACES
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/interfaces $(TARGET_sysconfdir)/network/interfaces
endef
endif
IFUPDOWN_SCRIPTS_INDIVIDUAL_HOOKS += IFUPDOWN_SCRIPTS_INSTALL_INTERFACES

define IFUPDOWN_SCRIPTS_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/network.init $(TARGET_sysconfdir)/init.d/network
	$(UPDATE-RC.D) network stop 98 0 6 .
endef

ifupdown-scripts: | $(TARGET_DIR)
	$(call virtual-package)
