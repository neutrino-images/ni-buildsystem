################################################################################
#
# mdev
#
################################################################################

define MDEV_INSTALL_MDEV_CONF
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/mdev-$(BOXTYPE).conf $(TARGET_sysconfdir)/mdev.conf
	$(SED) 's|%(BOOT_PARTITION)|$(BOOT_PARTITION)|' $(TARGET_sysconfdir)/mdev.conf
endef
MDEV_INDIVIDUAL_HOOKS += MDEV_INSTALL_MDEV_CONF

define MDEV_INSTALL_LIB_MDEV_SCRIPTS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/common/mdev-log-only	$(TARGET_base_libdir)/mdev/common/mdev-log-only
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/common/mdev-modprobe	$(TARGET_base_libdir)/mdev/common/mdev-modprobe
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/common/mdev-module		$(TARGET_base_libdir)/mdev/common/mdev-module

	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/fs/mdev-mmcblk		$(TARGET_base_libdir)/mdev/fs/mdev-mmcblk
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/fs/mdev-mount-$(BOXTYPE)	$(TARGET_base_libdir)/mdev/fs/mdev-mount

	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/net/mdev-wlan		$(TARGET_base_libdir)/mdev/net/mdev-wlan

	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/usb/mdev-coldplug-setenv	$(TARGET_base_libdir)/mdev/usb/mdev-coldplug-setenv
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/usb/mdev-usb-$(BOXTYPE)	$(TARGET_base_libdir)/mdev/usb/mdev-usb
endef
MDEV_INDIVIDUAL_HOOKS += MDEV_INSTALL_LIB_MDEV_SCRIPTS

define MDEV_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/mdev.init $(TARGET_sysconfdir)/init.d/mdev
endef

ifeq ($(BOXTYPE),coolstream)
define MDEV_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_base_libdir)/mdev/fs/mdev-mmcblk
endef
MDEV_TARGET_FINALIZE_HOOKS += MDEV_TARGET_CLEANUP
endif

mdev: | $(TARGET_DIR)
	$(call virtual-package)
