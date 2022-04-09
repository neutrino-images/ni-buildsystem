################################################################################
#
# rc.local-scripts
#
################################################################################

rc_local-scripts: | $(TARGET_DIR)
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rc.local.init $(TARGET_sysconfdir)/init.d/rc.local
	$(UPDATE-RC.D) rc.local start 99 2 3 4 5 .
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rc.local $(TARGET_sysconfdir)/rc.local
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rc.local-var $(TARGET_localstatedir)/etc/rc.local
endif
