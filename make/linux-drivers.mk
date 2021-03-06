#
# makefile to build linux-drivers
#
# -----------------------------------------------------------------------------

RTL8192EU_VERSION = git
RTL8192EU_DIR = rtl8192eu-linux-driver.$(RTL8192EU_VERSION)
RTL8192EU_SOURCE = rtl8192eu-linux-driver.$(RTL8192EU_VERSION)
RTL8192EU_SITE = https://github.com/mange/$(RTL8192EU_SOURCE)

rtl8192eu: kernel-$(BOXTYPE) | $(TARGET_DIR)
	$(REMOVE)/$(RTL8192EU_DIR)
	$(GET_GIT_SOURCE) $(RTL8192EU_SITE) $(DL_DIR)/$(RTL8192EU_SOURCE)
	$(CPDIR)/$(RTL8192EU_SOURCE)
	$(CHDIR)/$(RTL8192EU_DIR); \
		$(MAKE) $(KERNEL_MAKE_VARS); \
		$(INSTALL_DATA) 8192eu.ko $(TARGET_modulesdir)/kernel/drivers/net/wireless/
	$(LINUX_RUN_DEPMOD)
	$(REMOVE)/$(RTL8192EU_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

RTL8812AU_VERSION = 4.3.14
RTL8812AU_DIR = rtl8812AU-driver-$(RTL8812AU_VERSION)
RTL8812AU_SOURCE = rtl8812AU-driver-$(RTL8812AU_VERSION).zip
RTL8812AU_SITE = http://source.mynonpublic.com

$(DL_DIR)/$(RTL8812AU_SOURCE):
	$(download) $(RTL8812AU_SITE)/$(RTL8812AU_SOURCE)

rtl8812au: kernel-$(BOXTYPE) $(DL_DIR)/$(RTL8812AU_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(RTL8812AU_DIR)
	$(UNZIP)/$(RTL8812AU_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(RTL8812AU_DIR); \
		$(MAKE) $(KERNEL_MAKE_VARS); \
		$(INSTALL_DATA) 8812au.ko $(TARGET_modulesdir)/kernel/drivers/net/wireless/
	$(LINUX_RUN_DEPMOD)
	$(REMOVE)/$(RTL8812AU_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

RTL8822BU_VERSION = 1.0.0.9-20180511a
RTL8822BU_DIR = rtl8822bu
RTL8822BU_SOURCE = rtl8822bu-driver-$(RTL8822BU_VERSION).zip
RTL8822BU_SITE = http://source.mynonpublic.com

$(DL_DIR)/$(RTL8822BU_SOURCE):
	$(download) $(RTL8822BU_SITE)/$(RTL8822BU_SOURCE)

rtl8822bu: kernel-$(BOXTYPE) $(DL_DIR)/$(RTL8822BU_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(RTL8822BU_DIR)
	$(UNZIP)/$(RTL8822BU_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(RTL8822BU_DIR); \
		$(MAKE) $(KERNEL_MAKE_VARS); \
		$(INSTALL_DATA) 88x2bu.ko $(TARGET_modulesdir)/kernel/drivers/net/wireless/
	$(LINUX_RUN_DEPMOD)
	$(REMOVE)/$(RTL8822BU_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HD6X_MALI_DRIVERS_VERSION = DX910-SW-99002-r7p0-00rel0
HD6X_MALI_DRIVERS_DIR = $(HD6X_MALI_DRIVERS_VERSION)
HD6X_MALI_DRIVERS_SOURCE = $(HD6X_MALI_DRIVERS_VERSION).tgz
HD6X_MALI_DRIVERS_SITE = https://developer.arm.com/-/media/Files/downloads/mali-drivers/kernel/mali-utgard-gpu

$(DL_DIR)/$(HD6X_MALI_DRIVERS_SOURCE):
	$(download) $(HD6X_MALI_DRIVERS_SITE)/$(HD6X_MALI_DRIVERS_SOURCE)

HD6X_MALI_DRIVERS_MAKE_VARS = \
	M=$(BUILD_DIR)/$(HD6X_MALI_DRIVERS_DIR)/driver/src/devicedrv/mali \
	EXTRA_CFLAGS="-DCONFIG_MALI_DVFS=y -DCONFIG_GPU_AVS_ENABLE=y" \
	CONFIG_MALI_SHARED_INTERRUPTS=y \
	CONFIG_MALI400=m \
	CONFIG_MALI450=y \
	CONFIG_MALI_DVFS=y \
	CONFIG_GPU_AVS_ENABLE=y

hd6x-mali-drivers: kernel-$(BOXTYPE) hd6x-libgles-headers $(DL_DIR)/$(HD6X_MALI_DRIVERS_SOURCE) | $(TARGET_DIR)
	$(START_BUILD)
	$(REMOVE)/$(HD6X_MALI_DRIVERS_DIR)
	$(UNTAR)/$(HD6X_MALI_DRIVERS_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(HD6X_MALI_DRIVERS_DIR); \
		$(MAKE) -C $(KERNEL_OBJ_DIR) $(KERNEL_MAKE_VARS) $(HD6X_MALI_DRIVERS_MAKE_VARS); \
		$(MAKE) -C $(KERNEL_OBJ_DIR) $(KERNEL_MAKE_VARS) $(HD6X_MALI_DRIVERS_MAKE_VARS) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	$(LINUX_RUN_DEPMOD)
	$(REMOVE)/$(HD6X_MALI_DRIVERS_DIR)
	$(TOUCH)
