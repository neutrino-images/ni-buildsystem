################################################################################
#
# rc.local-scripts
#
################################################################################

define RC_LOCAL_SCRIPTS_INSTALL
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rc.local $(TARGET_sysconfdir)/rc.local
endef
RC_LOCAL_SCRIPTS_INDIVIDUAL_HOOKS += RC_LOCAL_SCRIPTS_INSTALL

ifeq ($(PERSISTENT_VAR_PARTITION),yes)
define RC_LOCAL_SCRIPTS_INSTALL_VAR
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rc.local-var $(TARGET_localstatedir)/etc/rc.local
endef
RC_LOCAL_SCRIPTS_INDIVIDUAL_HOOKS += RC_LOCAL_SCRIPTS_INSTALL_VAR
endif

define RC_LOCAL_SCRIPTS_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rc.local.init $(TARGET_sysconfdir)/init.d/rc.local
	$(UPDATE-RC.D) rc.local start 99 2 3 4 5 .
endef

rc_local-scripts: | $(TARGET_DIR)
	$(call virtual-package)
