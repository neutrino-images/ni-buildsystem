################################################################################
#
# hd5x-drivers
#
################################################################################

HD51_DRIVERS_VERSION = 20191120
HD51_DRIVERS_DIR = hd51-drivers
HD51_DRIVERS_SOURCE = hd51-drivers-$(KERNEL_VERSION)-$(HD51_DRIVERS_VERSION).zip
HD51_DRIVERS_SITE = http://source.mynonpublic.com/gfutures

BRE2ZE4K_DRIVERS_VERSION = 20191120
BRE2ZE4K_DRIVERS_DIR = bre2ze4k-drivers
BRE2ZE4K_DRIVERS_SOURCE = bre2ze4k-drivers-$(KERNEL_VERSION)-$(BRE2ZE4K_DRIVERS_VERSION).zip
BRE2ZE4K_DRIVERS_SITE = http://source.mynonpublic.com/gfutures

H7_DRIVERS_VERSION = 20191123
H7_DRIVERS_DIR = h7-drivers
H7_DRIVERS_SOURCE = h7-drivers-$(KERNEL_VERSION)-$(H7_DRIVERS_VERSION).zip
H7_DRIVERS_SITE = http://source.mynonpublic.com/zgemma

E4HDULTRA_DRIVERS_VERSION = 20191101
E4HDULTRA_DRIVERS_DIR = e4hd-drivers
E4HDULTRA_DRIVERS_SOURCE = e4hd-drivers-$(KERNEL_VERSION)-$(E4HDULTRA_DRIVERS_VERSION).zip
E4HDULTRA_DRIVERS_SITE = http://source.mynonpublic.com/ceryon

PROTEK4K_DRIVERS_VERSION = 20191101
PROTEK4K_DRIVERS_DIR = protek4k-drivers
PROTEK4K_DRIVERS_SOURCE = protek4k-drivers-$(KERNEL_VERSION)-$(PROTEK4K_DRIVERS_VERSION).zip
PROTEK4K_DRIVERS_SITE = http://source.mynonpublic.com/ceryon

hd51-drivers \
bre2ze4k-drivers \
h7-drivers \
e4hdultra-drivers \
protek4k-drivers: hd5x-drivers

# -----------------------------------------------------------------------------

HD5X_DRIVERS_VERSION = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_VERSION)
HD5X_DRIVERS_DIR = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_DIR)
HD5X_DRIVERS_SOURCE = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_SOURCE)
HD5X_DRIVERS_SITE = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_SITE)

# fix non-existing subdir in zip
HD5X_DRIVERS_EXTRACT_DIR = $($(PKG)_DIR)

define HD5X_DRIVERS_INSTALL_MODULES
	$(INSTALL) -d $(TARGET_modulesdir)/extra
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/*.ko $(TARGET_modulesdir)/extra
endef
HD5X_DRIVERS_INDIVIDUAL_HOOKS += HD5X_DRIVERS_INSTALL_MODULES

define HD5X_DRIVERS_LINUX_RUN_DEPMOD
	$(LINUX_RUN_DEPMOD)
endef
HD5X_DRIVERS_TARGET_FINALIZE_HOOKS += HD5X_DRIVERS_LINUX_RUN_DEPMOD

hd5x-drivers: | $(TARGET_DIR)
	$(call individual-package)
