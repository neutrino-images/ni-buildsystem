################################################################################
#
# graphlcd-base
#
################################################################################

GRAPHLCD_BASE_VERSION = 2.0.3
GRAPHLCD_BASE_DIR = graphlcd-base-$(GRAPHLCD_BASE_VERSION)
GRAPHLCD_BASE_SOURCE = graphlcd-base-$(GRAPHLCD_BASE_VERSION).tar.bz2
GRAPHLCD_BASE_SITE = https://vdr-projects.e-tobi.net/git/graphlcd-base/snapshot

GRAPHLCD_BASE_DEPENDENCIES = freetype libiconv libusb

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vuduo4k vuduo4kse vusolo4k vuultimo4k vuuno4kse))
GRAPHLCD_BASE_PATCH_CUSTOM = 0005-add-vuplus-driver.patch-custom
endif

GRAPHLCD_BASE_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

GRAPHLCD_BASE_MAKE_INSTALL_OPTS = \
	PREFIX=$(prefix)

define GRAPHLCD_BASE_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_sysconfdir)/udev
endef
GRAPHLCD_BASE_TARGET_FINALIZE_HOOKS += GRAPHLCD_BASE_TARGET_CLEANUP

graphlcd-base: $(GRAPHLCD_BASE_DEPENDENCIES) | $(TARGET_DIR)
	$(call generic-package)
