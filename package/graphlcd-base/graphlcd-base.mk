################################################################################
#
# graphlcd-base
#
################################################################################

GRAPHLCD_BASE_VERSION = git
GRAPHLCD_BASE_DIR = graphlcd-base.$(GRAPHLCD_BASE_VERSION)
GRAPHLCD_BASE_SOURCE = graphlcd-base.$(GRAPHLCD_BASE_VERSION)
GRAPHLCD_BASE_SITE = https://projects.vdr-developer.org/git

GRAPHLCD_BASE_DEPENDENCIES = freetype libiconv libusb

GRAPHLCD_BASE_PATCH  = 0001-graphlcd.patch
GRAPHLCD_BASE_PATCH += 0003-strip-graphlcd-conf.patch
GRAPHLCD_BASE_PATCH += 0004-material-colors.patch
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vuduo4k vuduo4kse vusolo4k vuultimo4k vuuno4kse))
  GRAPHLCD_BASE_PATCH += 0005-add-vuplus-driver.patch
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
