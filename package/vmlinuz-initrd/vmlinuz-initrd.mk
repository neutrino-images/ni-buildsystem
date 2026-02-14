################################################################################
#
# vmlinuz-initrd
#
################################################################################

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))

VMLINUZ_INITRD_VERSION = master
VMLINUZ_INITRD_DIR = $(NI_DRIVERS_BIN)
VMLINUZ_INITRD_SOURCE = $(NI_DRIVERS_BIN)
VMLINUZ_INITRD_SITE = https://github.com/neutrino-images
VMLINUZ_INITRD_SITE_METHOD = ni-git

ifeq ($(BOXMODEL),vusolo4k)
  VMLINUZ_INITRD_DATE = 20230801
  VMLINUZ_INITRD_FILE = vmlinuz-initrd-7366c0
else ifeq ($(BOXMODEL),vuduo4k)
  VMLINUZ_INITRD_DATE = 20230801
  VMLINUZ_INITRD_FILE = vmlinuz-initrd-7278b1
else ifeq ($(BOXMODEL),vuduo4kse)
  VMLINUZ_INITRD_DATE = 20230801
  VMLINUZ_INITRD_FILE = vmlinuz-initrd-7445d0
else ifeq ($(BOXMODEL),vuultimo4k)
  VMLINUZ_INITRD_DATE = 20230801
  VMLINUZ_INITRD_FILE = vmlinuz-initrd-7445d0
else ifeq ($(BOXMODEL),vuzero4k)
  VMLINUZ_INITRD_DATE = 20230801
  VMLINUZ_INITRD_FILE = vmlinuz-initrd-7260a0
else ifeq ($(BOXMODEL),vuuno4k)
  VMLINUZ_INITRD_DATE = 20230801
  VMLINUZ_INITRD_FILE = vmlinuz-initrd-7439b0
else ifeq ($(BOXMODEL),vuuno4kse)
  VMLINUZ_INITRD_DATE = 20230801
  VMLINUZ_INITRD_FILE = vmlinuz-initrd-7439b0
endif

define VMLINUZ_INITRD_INSTALL
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/$(DRIVERS_BIN_DIR)/vmlinuz-initrd/$(VMLINUZ_INITRD_DATE)/$(VMLINUZ_INITRD_FILE) \
		-C $(BUILD_DIR)/$(VMLINUZ_INITRD_FILE)
endef
VMLINUZ_INITRD_INDIVIDUAL_HOOKS += VMLINUZ_INITRD_INSTALL

vmlinuz-initrd:
	$(call individual-package,$(PKG_NO_PATCHES))

endif
