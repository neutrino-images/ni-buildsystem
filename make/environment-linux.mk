#
# set up linux environment for other makefiles
#
# -----------------------------------------------------------------------------

ifeq ($(BOXMODEL),nevis)
  KERNEL_VERSION = 2.6.34.13
  KERNEL_DIR = linux-$(KERNEL_VERSION)
  KERNEL_SOURCE = git
  KERNEL_SITE = $(empty)

  KERNEL_BRANCH = ni/linux-2.6.34.15
  KERNEL_DTB = $(empty)

else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),apollo shiner kronos kronos_v2))
  KERNEL_VERSION = 3.10.93
  KERNEL_DIR = linux-$(KERNEL_VERSION)
  KERNEL_SOURCE = git
  KERNEL_SITE = $(empty)

  KERNEL_BRANCH = ni/linux-3.10.108
  ifeq ($(BOXMODEL),$(filter $(BOXMODEL),apollo shiner))
    KERNEL_DTB = $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR)/kernel-dtb/hd849x.dtb
    KERNEL_CONFIG = $(PKG_FILES_DIR)/kernel-apollo.defconfig
  else
    KERNEL_DTB = $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR)/kernel-dtb/en75x1.dtb
    KERNEL_CONFIG = $(PKG_FILES_DIR)/kernel-kronos.defconfig
  endif

else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7))
  KERNEL_VERSION = 4.10.12
  KERNEL_DIR = linux-$(KERNEL_VERSION)
  KERNEL_SOURCE = linux-$(KERNEL_VERSION)-arm.tar.gz
  KERNEL_SITE = http://downloads.mutant-digital.net

  KERNEL_BRANCH = $(empty)
  KERNEL_DTB = $(BUILD_DIR)/$(KERNEL_OBJ)/arch/$(TARGET_ARCH)/boot/dts/bcm7445-bcm97445svmb.dtb
  KERNEL_CONFIG = $(PKG_FILES_DIR)/kernel-hd5x.defconfig

  BOOT_PARTITION = 1

else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60))
  KERNEL_VERSION = 4.4.35
  KERNEL_DATE = 20200219
  KERNEL_DIR = linux-$(KERNEL_VERSION)
  KERNEL_SOURCE = linux-$(KERNEL_VERSION)-$(KERNEL_DATE)-arm.tar.gz
  KERNEL_SITE = http://source.mynonpublic.com/gfutures

  KERNEL_BRANCH = $(empty)
  KERNEL_DTB = $(BUILD_DIR)/$(KERNEL_OBJ)/arch/$(TARGET_ARCH)/boot/dts/hi3798mv200.dtb
  KERNEL_CONFIG = $(PKG_FILES_DIR)/kernel-hd6x.defconfig

  BOOT_PARTITION = 4

else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd61))
  KERNEL_VERSION = 4.4.35
  KERNEL_DATE = 20181228
  KERNEL_DIR = linux-$(KERNEL_VERSION)
  KERNEL_SOURCE = linux-$(KERNEL_VERSION)-$(KERNEL_DATE)-arm.tar.gz
  KERNEL_SITE = http://source.mynonpublic.com/gfutures

  KERNEL_BRANCH = $(empty)
  KERNEL_DTB = $(BUILD_DIR)/$(KERNEL_OBJ)/arch/$(TARGET_ARCH)/boot/dts/hi3798mv200.dtb
  KERNEL_CONFIG = $(PKG_FILES_DIR)/kernel-hd6x.defconfig

  BOOT_PARTITION = 4

else ifeq ($(BOXMODEL),vusolo4k)
  KERNEL_VERSION = 3.14.28-1.8
  KERNEL_DIR = linux
  KERNEL_SOURCE = stblinux-3.14-1.8.tar.bz2
  KERNEL_SITE = http://code.vuplus.com/download/release/kernel

  KERNEL_BRANCH = $(empty)
  KERNEL_DTB = $(empty)

  VMLINUZ_INITRD_VERSION = 20190911
  VMLINUZ_INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ_INITRD_VERSION).tar.gz
  VMLINUZ_INITRD_SITE = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ_INITRD = vmlinuz-initrd-7366c0

  BOOT_PARTITION = 1

else ifeq ($(BOXMODEL),vuduo4k)
  KERNEL_VERSION = 4.1.45-1.17
  KERNEL_DIR = linux
  KERNEL_SOURCE = stblinux-4.1-1.17.tar.bz2
  KERNEL_SITE = http://code.vuplus.com/download/release/kernel

  KERNEL_BRANCH = $(empty)
  KERNEL_DTB = $(empty)

  VMLINUZ_INITRD_VERSION = 20190911
  VMLINUZ_INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ_INITRD_VERSION).tar.gz
  VMLINUZ_INITRD_SITE = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ_INITRD = vmlinuz-initrd-7278b1

  BOOT_PARTITION = 6

else ifeq ($(BOXMODEL),vuduo4kse)
  KERNEL_VERSION = 4.1.45-1.17
  KERNEL_DIR = linux
  KERNEL_SOURCE = stblinux-4.1-1.17.tar.bz2
  KERNEL_SITE = http://code.vuplus.com/download/release/kernel

  KERNEL_BRANCH = $(empty)
  KERNEL_DTB = $(empty)

  VMLINUZ_INITRD_VERSION = 20201010
  VMLINUZ_INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ_INITRD_VERSION).tar.gz
  VMLINUZ_INITRD_SITE = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ_INITRD = vmlinuz-initrd-7445d0

  BOOT_PARTITION = 6

else ifeq ($(BOXMODEL),vuultimo4k)
  KERNEL_VERSION = 3.14.28-1.12
  KERNEL_DIR = linux
  KERNEL_SOURCE = stblinux-3.14-1.12.tar.bz2
  KERNEL_SITE = http://code.vuplus.com/download/release/kernel

  KERNEL_BRANCH = $(empty)
  KERNEL_DTB = $(empty)

  VMLINUZ_INITRD_VERSION = 20190911
  VMLINUZ_INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ_INITRD_VERSION).tar.gz
  VMLINUZ_INITRD_SITE = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ_INITRD = vmlinuz-initrd-7445d0

  BOOT_PARTITION = 1

else ifeq ($(BOXMODEL),vuzero4k)
  KERNEL_VERSION = 4.1.20-1.9
  KERNEL_DIR = linux
  KERNEL_SOURCE = stblinux-4.1-1.9.tar.bz2
  KERNEL_SITE = http://code.vuplus.com/download/release/kernel

  KERNEL_BRANCH = $(empty)
  KERNEL_DTB = $(empty)

  VMLINUZ_INITRD_VERSION = 20190911
  VMLINUZ_INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ_INITRD_VERSION).tar.gz
  VMLINUZ_INITRD_SITE = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ_INITRD = vmlinuz-initrd-7260a0

  BOOT_PARTITION = 4

else ifeq ($(BOXMODEL),vuuno4k)
  KERNEL_VERSION = 3.14.28-1.12
  KERNEL_DIR = linux
  KERNEL_SOURCE = stblinux-3.14-1.12.tar.bz2
  KERNEL_SITE = http://code.vuplus.com/download/release/kernel

  KERNEL_BRANCH = $(empty)
  KERNEL_DTB = $(empty)

  VMLINUZ_INITRD_VERSION = 20191010
  VMLINUZ_INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ_INITRD_VERSION).tar.gz
  VMLINUZ_INITRD_SITE = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ_INITRD = vmlinuz-initrd-7439b0

  BOOT_PARTITION = 1

else ifeq ($(BOXMODEL),vuuno4kse)
  KERNEL_VERSION = 4.1.20-1.9
  KERNEL_DIR = linux
  KERNEL_SOURCE = stblinux-4.1-1.9.tar.bz2
  KERNEL_SITE = http://code.vuplus.com/download/release/kernel

  KERNEL_BRANCH = $(empty)
  KERNEL_DTB = $(empty)

  VMLINUZ_INITRD_VERSION = 20191010
  VMLINUZ_INITRD_SOURCE = vmlinuz-initrd_$(BOXMODEL)_$(VMLINUZ_INITRD_VERSION).tar.gz
  VMLINUZ_INITRD_SITE = https://bitbucket.org/max_10/vmlinuz-initrd-$(BOXMODEL)/downloads
  VMLINUZ_INITRD = vmlinuz-initrd-7439b0

  BOOT_PARTITION = 1

else ifeq ($(BOXMODEL),vuduo)
  KERNEL_VERSION = 3.9.6
  KERNEL_DIR = linux
  KERNEL_SOURCE = stblinux-$(KERNEL_VERSION).tar.bz2
  KERNEL_SITE = http://code.vuplus.com/download/release/kernel

  KERNEL_BRANCH = $(empty)
  KERNEL_DTB = $(empty)

endif

KERNEL_PATCH = $($(call UPPERCASE,$(BOXMODEL))_PATCH)

KERNEL_OBJ     = linux-$(KERNEL_VERSION)-obj
KERNEL_MODULES = linux-$(KERNEL_VERSION)-modules
KERNEL_HEADERS = linux-$(KERNEL_VERSION)-headers

KERNEL_CONFIG ?= $(PKG_FILES_DIR)/kernel-$(BOXMODEL).defconfig
KERNEL_NAME    = NI $(shell echo $(BOXFAMILY) | sed 's/.*/\u&/') Kernel

# -----------------------------------------------------------------------------

KERNEL_modulesdir = $(BUILD_DIR)/$(KERNEL_MODULES)/lib/modules/$(KERNEL_VERSION)

ifeq ($(BOXMODEL),nevis)
  KERNEL_UIMAGE   = $(BUILD_DIR)/$(KERNEL_OBJ)/arch/$(TARGET_ARCH)/boot/Image
else
  KERNEL_UIMAGE   = $(BUILD_DIR)/$(KERNEL_OBJ)/arch/$(TARGET_ARCH)/boot/uImage
endif
KERNEL_ZIMAGE     = $(BUILD_DIR)/$(KERNEL_OBJ)/arch/$(TARGET_ARCH)/boot/zImage
KERNEL_ZIMAGE_DTB = $(BUILD_DIR)/$(KERNEL_OBJ)/arch/$(TARGET_ARCH)/boot/zImage_dtb
KERNEL_VMLINUX    = $(BUILD_DIR)/$(KERNEL_OBJ)/vmlinux

# -----------------------------------------------------------------------------

KERNEL_MAKE_VARS = \
	ARCH=$(TARGET_ARCH) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	INSTALL_MOD_PATH=$(BUILD_DIR)/$(KERNEL_MODULES) \
	INSTALL_HDR_PATH=$(BUILD_DIR)/$(KERNEL_HEADERS) \
	LOCALVERSION= \
	O=$(BUILD_DIR)/$(KERNEL_OBJ)

# Compatibility variables
KERNEL_MAKE_VARS += \
	KVER=$(KERNEL_VERSION) \
	KSRC=$(BUILD_DIR)/$(KERNEL_DIR)

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vuduo))
  KERNEL_IMAGE = vmlinux
else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60 hd61))
  KERNEL_IMAGE = uImage
else
  KERNEL_IMAGE = zImage
endif

KERNEL_MAKE_TARGETS = $(KERNEL_IMAGE)

# build also the kernel-dtb for arm-hd5x and arm-hd6x
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 hd60 hd61))
  KERNEL_MAKE_TARGETS += $(notdir $(KERNEL_DTB))
endif
