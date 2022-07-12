################################################################################
#
# hd6x-mali-drivers
#
################################################################################

HD6X_MALI_DRIVERS_VERSION = DX910-SW-99002-r7p0-00rel0
HD6X_MALI_DRIVERS_DIR = $(HD6X_MALI_DRIVERS_VERSION)
HD6X_MALI_DRIVERS_SOURCE = $(HD6X_MALI_DRIVERS_VERSION).tgz
HD6X_MALI_DRIVERS_SITE = https://developer.arm.com/-/media/Files/downloads/mali-drivers/kernel/mali-utgard-gpu

HD6X_MALI_DEPENDENCIES = kernel-$(BOXTYPE) hd6x-libgles-headers

HD6X_MALI_DRIVERS_MAKE_OPTS = \
	-C $(KERNEL_OBJ_DIR)

HD6X_MALI_DRIVERS_MAKE_OPTS += \
	M=$(BUILD_DIR)/$(HD6X_MALI_DRIVERS_DIR)/driver/src/devicedrv/mali \
	EXTRA_CFLAGS="-DCONFIG_MALI_DVFS=y -DCONFIG_GPU_AVS_ENABLE=y" \
	CONFIG_MALI_SHARED_INTERRUPTS=y \
	CONFIG_MALI400=m \
	CONFIG_MALI450=y \
	CONFIG_MALI_DVFS=y \
	CONFIG_GPU_AVS_ENABLE=y

hd6x-mali-drivers: | $(TARGET_DIR)
	$(call kernel-module)
