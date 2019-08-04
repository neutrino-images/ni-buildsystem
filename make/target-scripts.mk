#
# makefile to install system scripts
#
# -----------------------------------------------------------------------------

init-scripts: \
	$(TARGET_DIR)/etc/init.d/globals \
	$(TARGET_DIR)/etc/init.d/functions \
	$(TARGET_DIR)/etc/init.d/camd \
	$(TARGET_DIR)/etc/init.d/camd_datefix \
	$(TARGET_DIR)/etc/init.d/coredump \
	$(TARGET_DIR)/etc/init.d/crond \
	$(TARGET_DIR)/etc/init.d/custom-poweroff \
	$(TARGET_DIR)/etc/init.d/fstab \
	$(TARGET_DIR)/etc/init.d/hostname \
	$(TARGET_DIR)/etc/init.d/inetd \
	$(TARGET_DIR)/etc/init.d/swap \
	$(TARGET_DIR)/etc/init.d/syslogd

$(TARGET_DIR)/etc/init.d/globals:
	$(INSTALL_DATA) -D $(IMAGEFILES)/scripts/init.globals $@

$(TARGET_DIR)/etc/init.d/functions:
	$(INSTALL_DATA) -D $(IMAGEFILES)/scripts/init.functions $@

$(TARGET_DIR)/etc/init.d/camd:
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/camd.init $@
	ln -sf camd $(TARGET_DIR)/etc/init.d/S99camd
	ln -sf camd $(TARGET_DIR)/etc/init.d/K01camd

$(TARGET_DIR)/etc/init.d/camd_datefix:
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/camd_datefix.init $@

$(TARGET_DIR)/etc/init.d/coredump:
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 hd51 bre2ze4k))
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/coredump.init $@
endif

$(TARGET_DIR)/etc/init.d/crond:
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/crond.init $@
	ln -sf crond $(TARGET_DIR)/etc/init.d/S55crond
	ln -sf crond $(TARGET_DIR)/etc/init.d/K55crond

$(TARGET_DIR)/etc/init.d/custom-poweroff:
ifeq ($(BOXTYPE), coolstream)
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/custom-poweroff.init $@
endif

$(TARGET_DIR)/etc/init.d/fstab:
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/fstab.init $@
	ln -sf fstab $(TARGET_DIR)/etc/init.d/S01fstab
	ln -sf fstab $(TARGET_DIR)/etc/init.d/K99fstab

$(TARGET_DIR)/etc/init.d/hostname:
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/hostname.init $@

$(TARGET_DIR)/etc/init.d/inetd:
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/inetd.init $@
	ln -sf inetd $(TARGET_DIR)/etc/init.d/S53inetd
	ln -sf inetd $(TARGET_DIR)/etc/init.d/K80inetd

$(TARGET_DIR)/etc/init.d/swap:
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 bre2ze4k))
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/swap.init $@
	ln -sf swap $(TARGET_DIR)/etc/init.d/K99swap
endif

$(TARGET_DIR)/etc/init.d/syslogd:
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/syslogd.init $@
	ln -sf syslogd $(TARGET_DIR)/etc/init.d/K98syslogd

# -----------------------------------------------------------------------------

scripts: \
	$(TARGET_DIR)/sbin/service \
	$(TARGET_DIR)/sbin/flash_eraseall \
	$(TARGET_SHARE_DIR)/udhcpc/default.script

$(TARGET_DIR)/sbin/service:
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/service $@

$(TARGET_DIR)/sbin/flash_eraseall:
ifeq ($(BOXTYPE), coolstream)
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/flash_eraseall $@
endif

$(TARGET_SHARE_DIR)/udhcpc/default.script:
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/udhcpc-default.script $@
