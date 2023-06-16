################################################################################
#
# vuplus-drivers
#
################################################################################

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUSOLO4K_DRIVERS_VERSION = 20190424
else
VUSOLO4K_DRIVERS_VERSION = 20190424
endif
VUSOLO4K_DRIVERS_DIR = vuplus-dvb-proxy-vusolo4k
VUSOLO4K_DRIVERS_SOURCE = vuplus-dvb-proxy-vusolo4k-3.14.28-$(VUSOLO4K_DRIVERS_VERSION).r0.tar.gz
VUSOLO4K_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUDUO4K_DRIVERS_VERSION = 20191218
else
VUDUO4K_DRIVERS_VERSION = 20191218
endif
VUDUO4K_DRIVERS_DIR = vuplus-dvb-proxy-vuduo4k
VUDUO4K_DRIVERS_SOURCE = vuplus-dvb-proxy-vuduo4k-4.1.45-$(VUDUO4K_DRIVERS_VERSION).r0.tar.gz
VUDUO4K_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUDUO4KSE_DRIVERS_VERSION = 20210407
else
VUDUO4KSE_DRIVERS_VERSION = 20210407
#VUDUO4KSE_DRIVERS_VERSION = 20200903
endif
VUDUO4KSE_DRIVERS_DIR = vuplus-dvb-proxy-vuduo4kse
VUDUO4KSE_DRIVERS_SOURCE = vuplus-dvb-proxy-vuduo4kse-4.1.45-$(VUDUO4KSE_DRIVERS_VERSION).r0.tar.gz
VUDUO4KSE_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUULTIMO4K_DRIVERS_VERSION = 20190424
else
VUULTIMO4K_DRIVERS_VERSION = 20190424
endif
VUULTIMO4K_DRIVERS_DIR = vuplus-dvb-proxy-vuultimo4k
VUULTIMO4K_DRIVERS_SOURCE = vuplus-dvb-proxy-vuultimo4k-3.14.28-$(VUULTIMO4K_DRIVERS_VERSION).r0.tar.gz
VUULTIMO4K_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUZERO4K_DRIVERS_VERSION = 20210407
else
VUZERO4K_DRIVERS_VERSION = 20210407
#VUZERO4K_DRIVERS_VERSION = 20190424
endif
VUZERO4K_DRIVERS_DIR = vuplus-dvb-proxy-vuzero4k
VUZERO4K_DRIVERS_SOURCE = vuplus-dvb-proxy-vuzero4k-4.1.20-$(VUZERO4K_DRIVERS_VERSION).r0.tar.gz
VUZERO4K_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUUNO4K_DRIVERS_VERSION = 20190424
else
VUUNO4K_DRIVERS_VERSION = 20190424
endif
VUUNO4K_DRIVERS_DIR = vuplus-dvb-proxy-vuuno4k
VUUNO4K_DRIVERS_SOURCE = vuplus-dvb-proxy-vuuno4k-3.14.28-$(VUUNO4K_DRIVERS_VERSION).r0.tar.gz
VUUNO4K_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUUNO4KSE_DRIVERS_VERSION = 20210407
else
VUUNO4KSE_DRIVERS_VERSION = 20210407
#VUUNO4KSE_DRIVERS_VERSION = 20190424
endif
VUUNO4KSE_DRIVERS_DIR = vuplus-dvb-proxy-vuuno4kse
VUUNO4KSE_DRIVERS_SOURCE = vuplus-dvb-proxy-vuuno4kse-4.1.20-$(VUUNO4KSE_DRIVERS_VERSION).r0.tar.gz
VUUNO4KSE_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

VUDUO_DRIVERS_VERSION = 20151124
VUDUO_DRIVERS_DIR = vuplus-dvb-modules-bm750
VUDUO_DRIVERS_SOURCE = vuplus-dvb-modules-bm750-3.9.6-$(VUDUO_DRIVERS_VERSION).tar.gz
VUDUO_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-modules

vusolo4k-drivers \
vuduo4k-drivers \
vuduo4kse-drivers \
vuultimo4k-drivers \
vuzero4k-drivers \
vuuno4k-drivers \
vuuno4kse-drivers \
vuduo-drivers: vuplus-drivers

# -----------------------------------------------------------------------------

VUPLUS_DRIVERS_VERSION = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_VERSION)
VUPLUS_DRIVERS_DIR = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_DIR)
VUPLUS_DRIVERS_SOURCE = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_SOURCE)
VUPLUS_DRIVERS_SITE = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_SITE)

#VUPLUS_DRIVERS_DEPENDENCIES = kernel # because of $(LINUX_RUN_DEPMOD)

# fix non-existing subdir in zip
VUPLUS_DRIVERS_EXTRACT_DIR = $($(PKG)_DIR)

define VUPLUS_DRIVERS_INSTALL_MODULES
	$(INSTALL) -d $(TARGET_modulesdir)/extra
	$(INSTALL_COPY) $($(PKG)_BUILD_DIR)/*.ko $(TARGET_modulesdir)/extra
endef
VUPLUS_DRIVERS_INDIVIDUAL_HOOKS += VUPLUS_DRIVERS_INSTALL_MODULES

define VUPLUS_DRIVERS_LINUX_RUN_DEPMOD
	$(LINUX_RUN_DEPMOD)
endef
VUPLUS_DRIVERS_TARGET_FINALIZE_HOOKS += VUPLUS_DRIVERS_LINUX_RUN_DEPMOD

vuplus-drivers: | $(TARGET_DIR)
	$(call individual-package)
