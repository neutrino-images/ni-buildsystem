################################################################################
#
# graphlcd-base
#
################################################################################

GRAPHLCD_BASE_VERSION = git
GRAPHLCD_BASE_DIR = graphlcd-base.$(GRAPHLCD_BASE_VERSION)
GRAPHLCD_BASE_SOURCE = graphlcd-base.$(GRAPHLCD_BASE_VERSION)
GRAPHLCD_BASE_SITE = https://projects.vdr-developer.org/git

GRAPHLCD_BASE_PATCH  = graphlcd.patch
GRAPHLCD_BASE_PATCH += 0003-strip-graphlcd-conf.patch
GRAPHLCD_BASE_PATCH += 0004-material-colors.patch
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vuduo4k vuduo4kse vusolo4k vuultimo4k vuuno4kse))
  GRAPHLCD_BASE_PATCH += 0005-add-vuplus-driver.patch
endif

GRAPHLCD_BASE_DEPENDENCIES = freetype libiconv libusb

graphlcd-base: $(GRAPHLCD_BASE_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCH))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) PREFIX=$(prefix)
	$(TARGET_RM) $(TARGET_sysconfdir)/udev
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
