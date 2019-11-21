#
# makefile to install system scripts
#
# -----------------------------------------------------------------------------

init-scripts: \
	$(TARGET_DIR)/etc/init.d/globals \
	$(TARGET_DIR)/etc/init.d/functions \
	$(TARGET_DIR)/etc/init.d/rc \
	$(TARGET_DIR)/etc/init.d/rcK \
	$(TARGET_DIR)/etc/init.d/camd \
	$(TARGET_DIR)/etc/init.d/camd_datefix \
	$(TARGET_DIR)/etc/init.d/coredump \
	$(TARGET_DIR)/etc/init.d/crond \
	$(TARGET_DIR)/etc/init.d/custom-poweroff \
	$(TARGET_DIR)/etc/init.d/fstab \
	$(TARGET_DIR)/etc/init.d/hostname \
	$(TARGET_DIR)/etc/init.d/inetd \
	$(TARGET_DIR)/etc/init.d/networking \
	$(TARGET_DIR)/etc/init.d/partitions-by-name \
	$(TARGET_DIR)/etc/init.d/resizerootfs \
	$(TARGET_DIR)/etc/init.d/swap \
	$(TARGET_DIR)/etc/init.d/sys_update.sh \
	$(TARGET_DIR)/etc/init.d/syslogd

$(TARGET_DIR)/etc/init.d/globals:
	$(INSTALL_DATA) -D $(TARGET_FILES)/scripts/init.globals $(@)

$(TARGET_DIR)/etc/init.d/functions:
	$(INSTALL_DATA) -D $(TARGET_FILES)/scripts/init.functions $(@)

$(TARGET_DIR)/etc/init.d/rc:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/files-etc/init.d/rc $(@)

$(TARGET_DIR)/etc/init.d/rcK:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/files-etc/init.d/rcK $(@)

$(TARGET_DIR)/etc/init.d/camd:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/camd.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 98 01

$(TARGET_DIR)/etc/init.d/camd_datefix:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/camd_datefix.init $(@)

$(TARGET_DIR)/etc/init.d/coredump:
ifneq ($(BOXMODEL), nevis)
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/coredump.init $(@)
	$(UPDATE-RC.D) $(@F) start 40 S .
endif

$(TARGET_DIR)/etc/init.d/crond:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/crond.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 50

$(TARGET_DIR)/etc/init.d/custom-poweroff:
ifeq ($(BOXTYPE), coolstream)
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/custom-poweroff.init $(@)
	$(UPDATE-RC.D) $(@F) start 99 0 6 .
endif

$(TARGET_DIR)/etc/init.d/fstab:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/fstab.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 01 98

$(TARGET_DIR)/etc/init.d/hostname:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/hostname.init $(@)

$(TARGET_DIR)/etc/init.d/inetd:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/inetd.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 50

$(TARGET_DIR)/etc/init.d/networking:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/networking.init $(@)
	$(UPDATE-RC.D) $(@F) stop 98 0 6 .

$(TARGET_DIR)/etc/init.d/partitions-by-name:
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), hd51 bre2ze4k h7))
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/partitions-by-name.init $(@)
endif

$(TARGET_DIR)/etc/init.d/resizerootfs:
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), hd51 bre2ze4k h7))
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/resizerootfs.init $(@)
endif

$(TARGET_DIR)/etc/init.d/swap:
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), hd51 bre2ze4k h7 vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/swap.init $(@)
	$(UPDATE-RC.D) $(@F) stop 98 0 6 .
endif

$(TARGET_DIR)/etc/init.d/sys_update.sh:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/sys_update.sh $(@)

$(TARGET_DIR)/etc/init.d/syslogd:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/syslogd.init $(@)
	$(UPDATE-RC.D) $(@F) stop 98 0 6 .

# -----------------------------------------------------------------------------

scripts: \
	$(TARGET_DIR)/sbin/service \
	$(TARGET_DIR)/sbin/flash_eraseall \
	$(TARGET_DIR)/sbin/update-rc.d \
	$(TARGET_SHARE_DIR)/udhcpc/default.script

$(TARGET_DIR)/sbin/service:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/service $(@)

$(TARGET_DIR)/sbin/flash_eraseall:
ifeq ($(BOXTYPE), coolstream)
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/flash_eraseall $(@)
endif

$(TARGET_DIR)/sbin/update-rc.d:
	$(INSTALL_EXEC) -D $(HELPERS_DIR)/update-rc.d $(@)

$(TARGET_SHARE_DIR)/udhcpc/default.script:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/udhcpc-default.script $(@)
