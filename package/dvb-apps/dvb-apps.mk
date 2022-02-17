################################################################################
#
# dvb-apps
#
################################################################################

DVB_APPS_VERSION = git
DVB_APPS_DIR = dvb-apps.$(DVB_APPS_VERSION)
DVB_APPS_SOURCE = dvb-apps.$(DVB_APPS_VERSION)
DVB_APPS_SITE = https://github.com/openpli-arm

DVB_APPS_DEPENDENCIES = kernel-headers libiconv

DVB_APPS_MAKE_OPTS = \
	KERNEL_HEADERS=$(KERNEL_HEADERS_DIR) \
	enable_shared=no \
	PERL5LIB=$(PKG_BUILD_DIR)/util/scan \

dvb-apps: $(DVB_APPS_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) LDLIBS="-liconv" \
		$(MAKE) $($(PKG)_MAKE_OPTS); \
		$(MAKE) $($(PKG)_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
