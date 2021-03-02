#
# makefile to install system scripts
#
# -----------------------------------------------------------------------------

init-scripts: \
	$(TARGET_sysconfdir)/init.d/globals \
	$(TARGET_sysconfdir)/init.d/functions \
	\
	$(TARGET_sysconfdir)/init.d/camd \
	$(TARGET_sysconfdir)/init.d/camd_datefix \
	$(TARGET_sysconfdir)/init.d/coredump \
	$(TARGET_sysconfdir)/init.d/crond \
	$(TARGET_sysconfdir)/init.d/custom-poweroff \
	$(TARGET_sysconfdir)/init.d/fstab \
	$(TARGET_sysconfdir)/init.d/hostname \
	$(TARGET_sysconfdir)/init.d/inetd \
	$(TARGET_sysconfdir)/init.d/mdev \
	$(TARGET_sysconfdir)/init.d/networking \
	$(TARGET_sysconfdir)/init.d/partitions-by-name \
	$(TARGET_sysconfdir)/init.d/proc \
	$(TARGET_sysconfdir)/init.d/rc.local \
	$(TARGET_sysconfdir)/init.d/resizerootfs \
	$(TARGET_sysconfdir)/init.d/sys_update.sh \
	$(TARGET_sysconfdir)/init.d/syslogd \
	$(TARGET_sysconfdir)/init.d/sendsigs \
	$(TARGET_sysconfdir)/init.d/umountfs \
	$(TARGET_sysconfdir)/init.d/suspend \
	$(TARGET_sysconfdir)/init.d/user-initscripts \
	\
	$(TARGET_sysconfdir)/init.d/stb_update.sh \
	\
	$(TARGET_sysconfdir)/init.d/var_mount.sh \
	$(TARGET_sysconfdir)/init.d/var_update.sh

$(TARGET_sysconfdir)/init.d/globals:
	$(INSTALL_DATA) -D $(TARGET_FILES)/scripts/init.globals $(@)

$(TARGET_sysconfdir)/init.d/functions:
	$(INSTALL_DATA) -D $(TARGET_FILES)/scripts/init.functions $(@)

$(TARGET_sysconfdir)/init.d/camd:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/camd.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 98 01

$(TARGET_sysconfdir)/init.d/camd_datefix:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/camd_datefix.init $(@)

$(TARGET_sysconfdir)/init.d/coredump:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/coredump.init $(@)
	$(UPDATE-RC.D) $(@F) start 40 S .

$(TARGET_sysconfdir)/init.d/crond:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/crond.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 50

$(TARGET_sysconfdir)/init.d/custom-poweroff:
ifeq ($(BOXTYPE),coolstream)
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/custom-poweroff.init $(@)
	$(UPDATE-RC.D) $(@F) start 99 0 6 .
endif

$(TARGET_sysconfdir)/init.d/fstab:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/fstab.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 01 98

$(TARGET_sysconfdir)/init.d/hostname:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/hostname.init $(@)

$(TARGET_sysconfdir)/init.d/inetd:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/inetd.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 50

$(TARGET_sysconfdir)/init.d/mdev:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/mdev.init $(@)

$(TARGET_sysconfdir)/init.d/networking:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/networking.init $(@)
	$(UPDATE-RC.D) $(@F) stop 98 0 6 .

$(TARGET_sysconfdir)/init.d/partitions-by-name:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 hd60 hd61))
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/partitions-by-name.init $(@)
endif

$(TARGET_sysconfdir)/init.d/proc:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 hd60 hd61 vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/proc.init $(@)
	$(UPDATE-RC.D) $(@F) start 90 S .
endif

$(TARGET_sysconfdir)/init.d/rc.local:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/rc.local.init $(@)
	$(UPDATE-RC.D) $(@F) start 99 2 3 4 5 .
	$(INSTALL_EXEC) -D $(TARGET_FILES)/files-etc/rc.local $(TARGET_sysconfdir)/rc.local

$(TARGET_sysconfdir)/init.d/resizerootfs:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 hd60 hd61))
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/resizerootfs.init $(@)
endif

$(TARGET_sysconfdir)/init.d/sys_update.sh:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/sys_update.sh $(@)

$(TARGET_sysconfdir)/init.d/syslogd:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/syslogd.init $(@)
	$(UPDATE-RC.D) $(@F) stop 98 0 6 .

$(TARGET_sysconfdir)/init.d/sendsigs:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60 hd61))
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/sendsigs.init $(@)
	$(UPDATE-RC.D) $(@F) start 85 0 .
endif

$(TARGET_sysconfdir)/init.d/umountfs:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60 hd61))
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/umountfs.init $(@)
	$(UPDATE-RC.D) $(@F) start 86 0 .
endif

$(TARGET_sysconfdir)/init.d/suspend:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60 hd61))
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/suspend.init $(@)
	$(UPDATE-RC.D) $(@F) start 89 0 .
endif

$(TARGET_sysconfdir)/init.d/user-initscripts:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/user-initscripts.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 98 01

$(TARGET_sysconfdir)/init.d/stb_update.sh:
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/stb_update_$(BOXSERIES).sh $(@)
endif

$(TARGET_sysconfdir)/init.d/var_mount.sh:
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/var_mount.sh $(@)
endif

$(TARGET_sysconfdir)/init.d/var_update.sh:
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/var_update.sh $(@)
endif

# -----------------------------------------------------------------------------

scripts: \
	$(TARGET_datadir)/udhcpc/default.script

$(TARGET_datadir)/udhcpc/default.script:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/udhcpc-default.script $(@)
