#
# makefile to build linux-drivers
#
# -----------------------------------------------------------------------------

RTL8192EU_VER    = git
RTL8192EU_SOURCE = rtl8192eu-linux-driver.$(RTL8192EU_VER)
RTL8192EU_SITE   = https://github.com/mange/$(RTL8192EU_SOURCE)

rtl8192eu: kernel-$(BOXTYPE) | $(TARGET_DIR)
	$(REMOVE)/$(RTL8192EU_SOURCE)
	$(GET-GIT-SOURCE) $(RTL8192EU_SITE) $(DL_DIR)/$(RTL8192EU_SOURCE)
	$(CPDIR)/$(RTL8192EU_SOURCE)
	$(CHDIR)/$(RTL8192EU_SOURCE); \
		$(MAKE) $(KERNEL_MAKEVARS); \
		$(INSTALL_DATA) 8192eu.ko $(TARGET_MODULES_DIR)/kernel/drivers/net/wireless/
	make depmod
	$(REMOVE)/$(RTL8192EU_SOURCE)
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
