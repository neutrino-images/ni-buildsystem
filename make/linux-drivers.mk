#
# makefile to build linux-drivers
#
# -----------------------------------------------------------------------------

RTL8192EU_VER    = git
RTL8192EU_DIR    = rtl8192eu-linux-driver.$(RTL8192EU_VER)
RTL8192EU_SOURCE = rtl8192eu-linux-driver.$(RTL8192EU_VER)
RTL8192EU_SITE   = https://github.com/mange/$(RTL8192EU_SOURCE)

rtl8192eu: kernel | $(TARGET_DIR)
	$(REMOVE)/$(RTL8192EU_DIR)
	$(GET-GIT-SOURCE) $(RTL8192EU_SITE) $(DL_DIR)/$(RTL8192EU_SOURCE)
	$(CPDIR)/$(RTL8192EU_SOURCE)
	$(CHDIR)/$(RTL8192EU_DIR); \
		$(MAKE) $(KERNEL_MAKEVARS); \
		$(INSTALL_DATA) 8192eu.ko $(TARGET_modulesdir)/kernel/drivers/net/wireless/
	make depmod
	$(REMOVE)/$(RTL8192EU_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

RTL8812AU_VER    = 4.3.14
RTL8812AU_DIR    = rtl8812AU-driver-$(RTL8812AU_VER)
RTL8812AU_SOURCE = rtl8812AU-driver-$(RTL8812AU_VER).zip
RTL8812AU_SITE   = http://source.mynonpublic.com

$(DL_DIR)/$(RTL8812AU_SOURCE):
	$(DOWNLOAD) $(RTL8812AU_SITE)/$(RTL8812AU_SOURCE)

rtl8812au: kernel $(DL_DIR)/$(RTL8812AU_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(RTL8812AU_DIR)
	$(UNZIP)/$(RTL8812AU_SOURCE)
	$(CHDIR)/$(RTL8812AU_DIR); \
		$(APPLY_PATCHES); \
		$(MAKE) $(KERNEL_MAKEVARS); \
		$(INSTALL_DATA) 8812au.ko $(TARGET_modulesdir)/kernel/drivers/net/wireless/
	make depmod
	$(REMOVE)/$(RTL8812AU_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

RTL8822BU_VER    = 1.0.0.9-20180511a
RTL8822BU_DIR    = rtl8822bu
RTL8822BU_SOURCE = rtl8822bu-driver-$(RTL8822BU_VER).zip
RTL8822BU_SITE   = http://source.mynonpublic.com

$(DL_DIR)/$(RTL8822BU_SOURCE):
	$(DOWNLOAD) $(RTL8822BU_SITE)/$(RTL8822BU_SOURCE)

rtl8822bu: kernel $(DL_DIR)/$(RTL8822BU_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(RTL8822BU_DIR)
	$(UNZIP)/$(RTL8822BU_SOURCE)
	$(CHDIR)/$(RTL8822BU_DIR); \
		$(APPLY_PATCHES); \
		$(MAKE) $(KERNEL_MAKEVARS); \
		$(INSTALL_DATA) 88x2bu.ko $(TARGET_modulesdir)/kernel/drivers/net/wireless/
	make depmod
	$(REMOVE)/$(RTL8822BU_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HD6x-MALI-DRIVERS_VER    = DX910-SW-99002-r7p0-00rel0
HD6x-MALI-DRIVERS_DIR    = $(HD6x-MALI-DRIVERS_VER)
HD6x-MALI-DRIVERS_SOURCE = $(HD6x-MALI-DRIVERS_VER).tgz
HD6x-MALI-DRIVERS_SITE   = https://developer.arm.com/-/media/Files/downloads/mali-drivers/kernel/mali-utgard-gpu

$(DL_DIR)/$(HD6x-MALI-DRIVERS_SOURCE):
	$(DOWNLOAD) $(HD6x-MALI-DRIVERS_SITE)/$(HD6x-MALI-DRIVERS_SOURCE)

HD6x-MALI-DRIVERS_PATCH  = hi3798mv200-support.patch

HD6x-MALI-DRIVERS_MAKEVARS = \
	M=$(BUILD_DIR)/$(HD6x-MALI-DRIVERS_DIR)/driver/src/devicedrv/mali \
	EXTRA_CFLAGS="-DCONFIG_MALI_DVFS=y -DCONFIG_GPU_AVS_ENABLE=y" \
	CONFIG_MALI_SHARED_INTERRUPTS=y \
	CONFIG_MALI400=m \
	CONFIG_MALI450=y \
	CONFIG_MALI_DVFS=y \
	CONFIG_GPU_AVS_ENABLE=y

hd6x-mali-drivers: kernel-$(BOXTYPE) hd6x-libgles-headers $(DL_DIR)/$(HD6x-MALI-DRIVERS_SOURCE) | $(TARGET_DIR)
	$(START_BUILD)
	$(REMOVE)/$(HD6x-MALI-DRIVERS_DIR)
	$(UNTAR)/$(HD6x-MALI-DRIVERS_SOURCE)
	$(CHDIR)/$(HD6x-MALI-DRIVERS_DIR); \
		$(call apply_patches, $(HD6x-MALI-DRIVERS_PATCH)); \
		$(MAKE) -C $(BUILD_DIR)/$(KERNEL_OBJ) $(KERNEL_MAKEVARS) $(HD6x-MALI-DRIVERS_MAKEVARS); \
		$(MAKE) -C $(BUILD_DIR)/$(KERNEL_OBJ) $(KERNEL_MAKEVARS) $(HD6x-MALI-DRIVERS_MAKEVARS) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	make depmod
	$(REMOVE)/$(HD6x-MALI-DRIVERS_DIR)
	$(TOUCH)
