################################################################################
#
# vuplus platform-util
#
################################################################################

VUSOLO4K_PLATFORM_UTIL_VERSION = $(VUSOLO4K_DRIVERS_VERSION)
VUSOLO4K_PLATFORM_UTIL_DIR = platform-util-vusolo4k
VUSOLO4K_PLATFORM_UTIL_SOURCE = platform-util-vusolo4k-17.1-$(VUSOLO4K_PLATFORM_UTIL_VERSION).r0.tar.gz
VUSOLO4K_PLATFORM_UTIL_SITE = http://code.vuplus.com/download/release/platform-util

VUDUO4K_PLATFORM_UTIL_VERSION = $(VUDUO4K_DRIVERS_VERSION)
VUDUO4K_PLATFORM_UTIL_DIR = platform-util-vuduo4k
VUDUO4K_PLATFORM_UTIL_SOURCE = platform-util-vuduo4k-18.1-$(VUDUO4K_PLATFORM_UTIL_VERSION).r0.tar.gz
VUDUO4K_PLATFORM_UTIL_SITE = http://code.vuplus.com/download/release/platform-util

VUDUO4KSE_PLATFORM_UTIL_VERSION = $(VUDUO4KSE_DRIVERS_VERSION)
VUDUO4KSE_PLATFORM_UTIL_DIR = platform-util-vuduo4kse
VUDUO4KSE_PLATFORM_UTIL_SOURCE = platform-util-vuduo4kse-17.1-$(VUDUO4KSE_PLATFORM_UTIL_VERSION).r0.tar.gz
VUDUO4KSE_PLATFORM_UTIL_SITE = http://code.vuplus.com/download/release/platform-util

VUULTIMO4K_PLATFORM_UTIL_VERSION = $(VUULTIMO4K_DRIVERS_VERSION)
VUULTIMO4K_PLATFORM_UTIL_DIR = platform-util-vuultimo4k
VUULTIMO4K_PLATFORM_UTIL_SOURCE = platform-util-vuultimo4k-17.1-$(VUULTIMO4K_PLATFORM_UTIL_VERSION).r0.tar.gz
VUULTIMO4K_PLATFORM_UTIL_SITE = http://code.vuplus.com/download/release/platform-util

VUZERO4K_PLATFORM_UTIL_VERSION = $(VUZERO4K_DRIVERS_VERSION)
VUZERO4K_PLATFORM_UTIL_DIR = platform-util-vuzero4k
VUZERO4K_PLATFORM_UTIL_SOURCE = platform-util-vuzero4k-17.1-$(VUZERO4K_PLATFORM_UTIL_VERSION).r0.tar.gz
VUZERO4K_PLATFORM_UTIL_SITE = http://code.vuplus.com/download/release/platform-util

VUUNO4K_PLATFORM_UTIL_VERSION = $(VUUNO4K_DRIVERS_VERSION)
VUUNO4K_PLATFORM_UTIL_DIR = platform-util-vuuno4k
VUUNO4K_PLATFORM_UTIL_SOURCE = platform-util-vuuno4k-17.1-$(VUUNO4K_PLATFORM_UTIL_VERSION).r0.tar.gz
VUUNO4K_PLATFORM_UTIL_SITE = http://code.vuplus.com/download/release/platform-util

VUUNO4KSE_PLATFORM_UTIL_VERSION = $(VUUNO4KSE_DRIVERS_VERSION)
VUUNO4KSE_PLATFORM_UTIL_DIR = platform-util-vuuno4kse
VUUNO4KSE_PLATFORM_UTIL_SOURCE = platform-util-vuuno4kse-17.1-$(VUUNO4KSE_PLATFORM_UTIL_VERSION).r0.tar.gz
VUUNO4KSE_PLATFORM_UTIL_SITE = http://code.vuplus.com/download/release/platform-util

# -----------------------------------------------------------------------------

VUPLUS_PLATFORM_UTIL_VERSION = $($(call UPPERCASE,$(BOXMODEL))_PLATFORM_UTIL_VERSION)
VUPLUS_PLATFORM_UTIL_DIR = $($(call UPPERCASE,$(BOXMODEL))_PLATFORM_UTIL_DIR)
VUPLUS_PLATFORM_UTIL_SOURCE = $($(call UPPERCASE,$(BOXMODEL))_PLATFORM_UTIL_SOURCE)
VUPLUS_PLATFORM_UTIL_SITE = $($(call UPPERCASE,$(BOXMODEL))_PLATFORM_UTIL_SITE)

define VUPLUS_PLATFORM_UTIL_INSTALL_BINARIES
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/* $(TARGET_bindir)
endef
VUPLUS_PLATFORM_UTIL_INDIVIDUAL_HOOKS += VUPLUS_PLATFORM_UTIL_INSTALL_BINARIES

define VUPLUS_PLATFORM_UTIL_INSTALL_INIT_SCRIPT
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/vuplus-platform-util.init $(TARGET_sysconfdir)/init.d/vuplus-platform-util
endef
VUPLUS_PLATFORM_UTIL_INDIVIDUAL_HOOKS += VUPLUS_PLATFORM_UTIL_INSTALL_INIT_SCRIPT

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vuduo4k))
define VUPLUS_PLATFORM_UTIL_INSTALL_BP3FLASH_SH
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/bp3flash.sh $(TARGET_bindir)/bp3flash.sh
endef
VUPLUS_PLATFORM_UTIL_INDIVIDUAL_HOOKS += VUPLUS_PLATFORM_UTIL_INSTALL_BP3FLASH_SH
endif

vuplus-platform-util: | $(TARGET_DIR)
	$(call individual-package)
