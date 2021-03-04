################################################################################
#
# ifupdown-scripts
#
################################################################################

ifupdown-scripts: | $(TARGET_DIR)
	$(INSTALL) -d $(TARGET_sysconfdir)/network/if-{up,pre-up,post-up,down,pre-down,post-down}.d
  ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/interfaces $(TARGET_localstatedir)/etc/network/interfaces
	ln -sf /var/etc/network/interfaces $(TARGET_sysconfdir)/network/interfaces
  else
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/interfaces $(TARGET_sysconfdir)/network/interfaces
  endif
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/network.init $(TARGET_sysconfdir)/init.d/network
	$(UPDATE-RC.D) network stop 98 0 6 .
