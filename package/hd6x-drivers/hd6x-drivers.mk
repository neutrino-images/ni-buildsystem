################################################################################
#
# hd6x-drivers
#
################################################################################

HD60_DRIVERS_VERSION = 20200731
HD60_DRIVERS_DIR = hd60-drivers
HD60_DRIVERS_SOURCE = hd60-drivers-$(KERNEL_VERSION)-$(HD60_DRIVERS_VERSION).zip
HD60_DRIVERS_SITE = http://source.mynonpublic.com/gfutures

HD61_DRIVERS_VERSION = 20200731
HD61_DRIVERS_DIR = hd61-drivers
HD61_DRIVERS_SOURCE = hd61-drivers-$(KERNEL_VERSION)-$(HD61_DRIVERS_VERSION).zip
HD61_DRIVERS_SITE = http://source.mynonpublic.com/gfutures

MULTIBOX_DRIVERS_VERSION = 20201204
MULTIBOX_DRIVERS_DIR = multibox-drivers
MULTIBOX_DRIVERS_SOURCE = multibox-drivers-$(KERNEL_VERSION)-$(MULTIBOX_DRIVERS_VERSION).zip
MULTIBOX_DRIVERS_SITE = http://source.mynonpublic.com/maxytec

MULTIBOXSE_DRIVERS_VERSION = 20211129
MULTIBOXSE_DRIVERS_DIR = multiboxse-drivers
MULTIBOXSE_DRIVERS_SOURCE = multiboxse-drivers-$(KERNEL_VERSION)-$(MULTIBOXSE_DRIVERS_VERSION).zip
MULTIBOXSE_DRIVERS_SITE = http://source.mynonpublic.com/maxytec

hd60-drivers \
hd61-drivers \
multibox-drivers \
multiboxse-drivers: hd6x-drivers

# -----------------------------------------------------------------------------

HD6X_DRIVERS_VERSION = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_VERSION)
HD6X_DRIVERS_DIR = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_DIR)
HD6X_DRIVERS_SOURCE = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_SOURCE)
HD6X_DRIVERS_SITE = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_SITE)

#HD6X_DRIVERS_DEPENDENCIES = kernel # because of $(LINUX_RUN_DEPMOD)

# fix non-existing subdir in zip
HD6X_DRIVERS_EXTRACT_DIR = $($(PKG)_DIR)

define HD6X_DRIVERS_INSTALL_MODULES
	$(INSTALL) -d $(TARGET_modulesdir)/extra
	$(INSTALL_COPY) $($(PKG)_BUILD_DIR)/*.ko $(TARGET_modulesdir)/extra
endef
HD6X_DRIVERS_INDIVIDUAL_HOOKS += HD6X_DRIVERS_INSTALL_MODULES

define HD6X_DRIVERS_INSTALL_TURNOFF_POWER
	$(INSTALL_EXEC) $($(PKG)_BUILD_DIR)/turnoff_power $(TARGET_bindir)
endef
HD6X_DRIVERS_INDIVIDUAL_HOOKS += HD6X_DRIVERS_INSTALL_TURNOFF_POWER

define HD6X_DRIVERS_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_modulesdir)/extra/hi_play.ko
endef
HD6X_DRIVERS_TARGET_FINALIZE_HOOKS += HD6X_DRIVERS_TARGET_CLEANUP

define HD6X_DRIVERS_LINUX_RUN_DEPMOD
	$(LINUX_RUN_DEPMOD)
endef
HD6X_DRIVERS_TARGET_FINALIZE_HOOKS += HD6X_DRIVERS_LINUX_RUN_DEPMOD

hd6x-drivers: | $(TARGET_DIR)
	$(call individual-package)
