################################################################################
#
# init-scripts
#
################################################################################

INIT_SCRIPTS_DIR = $(PACKAGE_DIR)/init-scripts/files

init-scripts: \
	$(TARGET_sysconfdir)/init.d/globals \
	$(TARGET_sysconfdir)/init.d/functions \
	\
	$(TARGET_sysconfdir)/init.d/camd \
	$(TARGET_sysconfdir)/init.d/camd_datefix \
	$(TARGET_sysconfdir)/init.d/coredump \
	$(TARGET_sysconfdir)/init.d/custom-poweroff \
	$(TARGET_sysconfdir)/init.d/fstab \
	$(TARGET_sysconfdir)/init.d/hostname \
	$(TARGET_sysconfdir)/init.d/partitions-by-name \
	$(TARGET_sysconfdir)/init.d/proc \
	$(TARGET_sysconfdir)/init.d/resizerootfs \
	$(TARGET_sysconfdir)/init.d/sys_update.sh \
	$(TARGET_sysconfdir)/init.d/sendsigs \
	$(TARGET_sysconfdir)/init.d/umountfs \
	$(TARGET_sysconfdir)/init.d/suspend \
	$(TARGET_sysconfdir)/init.d/user-initscripts \
	\
	$(TARGET_sysconfdir)/init.d/stb_update.sh \
	\
	$(TARGET_sysconfdir)/init.d/rootx-mount \
	$(TARGET_sysconfdir)/init.d/var_mount.sh \
	$(TARGET_sysconfdir)/init.d/var_update.sh

$(TARGET_sysconfdir)/init.d/globals:
	$(INSTALL_DATA) -D $(INIT_SCRIPTS_DIR)/init.globals $(@)

$(TARGET_sysconfdir)/init.d/functions:
	$(INSTALL_DATA) -D $(INIT_SCRIPTS_DIR)/init.functions $(@)

$(TARGET_sysconfdir)/init.d/camd:
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/camd.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 98 01

$(TARGET_sysconfdir)/init.d/camd_datefix:
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/camd_datefix.init $(@)

$(TARGET_sysconfdir)/init.d/coredump:
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/coredump.init $(@)
	$(UPDATE-RC.D) $(@F) start 40 S .

$(TARGET_sysconfdir)/init.d/custom-poweroff:
ifeq ($(BOXTYPE),coolstream)
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/custom-poweroff.init $(@)
	$(UPDATE-RC.D) $(@F) start 99 0 6 .
endif

$(TARGET_sysconfdir)/init.d/fstab:
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/fstab.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 01 98

$(TARGET_sysconfdir)/init.d/hostname:
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/hostname.init $(@)

$(TARGET_sysconfdir)/init.d/partitions-by-name:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 hd60 hd61 multiboxse))
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/partitions-by-name.init $(@)
endif

$(TARGET_sysconfdir)/init.d/proc:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 hd60 hd61 multiboxse vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/proc.init $(@)
	$(UPDATE-RC.D) $(@F) start 90 S .
endif

$(TARGET_sysconfdir)/init.d/resizerootfs:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 hd60 hd61 multiboxse))
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/resizerootfs.init $(@)
endif

$(TARGET_sysconfdir)/init.d/sys_update.sh:
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/sys_update.sh $(@)

$(TARGET_sysconfdir)/init.d/sendsigs:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60 hd61 multiboxse))
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/sendsigs.init $(@)
	$(UPDATE-RC.D) $(@F) start 85 0 .
endif

$(TARGET_sysconfdir)/init.d/umountfs:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60 hd61 multiboxse))
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/umountfs.init $(@)
	$(UPDATE-RC.D) $(@F) start 86 0 .
endif

$(TARGET_sysconfdir)/init.d/suspend:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60 hd61 multiboxse))
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/suspend.init $(@)
	$(UPDATE-RC.D) $(@F) start 89 0 .
endif

$(TARGET_sysconfdir)/init.d/user-initscripts:
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/user-initscripts.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 98 01

$(TARGET_sysconfdir)/init.d/stb_update.sh:
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/stb_update_$(BOXSERIES).sh $(@)
endif

$(TARGET_sysconfdir)/init.d/rootx-mount:
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd2))
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/rootx-mount.init $(@)
	$(UPDATE-RC.D) $(@F) defaults 01 98
endif

$(TARGET_sysconfdir)/init.d/var_mount.sh:
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/var_mount.sh $(@)
endif

$(TARGET_sysconfdir)/init.d/var_update.sh:
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(INSTALL_EXEC) -D $(INIT_SCRIPTS_DIR)/var_update.sh $(@)
endif
