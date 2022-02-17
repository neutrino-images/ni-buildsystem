################################################################################
#
# ushare
#
################################################################################

USHARE_VERSION = 1.1a
USHARE_DIR = ushare-uShare_v$(USHARE_VERSION)
USHARE_SOURCE = uShare_v$(USHARE_VERSION).tar.gz
USHARE_SITE = https://github.com/GeeXboX/ushare/archive

$(DL_DIR)/$(USHARE_SOURCE):
	$(download) $(USHARE_SITE)/$(USHARE_SOURCE)

USHARE_DEPENDENCIES = libupnp

USHARE_CONF_OPTS = \
	--prefix=$(prefix) \
	--sysconfdir=$(sysconfdir) \
	--disable-dlna \
	--disable-nls \
	--cross-compile \
	--cross-prefix=$(TARGET_CROSS)

ushare: $(USHARE_DEPENDENCIES) $(DL_DIR)/$(USHARE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) ./configure $($(PKG)_CONF_OPTS); \
		ln -sf ../config.h src/; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/ushare.conf $(TARGET_sysconfdir)/ushare.conf
	$(SED) 's|%(BOXTYPE)|$(BOXTYPE)|; s|%(BOXMODEL)|$(BOXMODEL)|' $(TARGET_sysconfdir)/ushare.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/ushare.init $(TARGET_sysconfdir)/init.d/ushare
	$(UPDATE-RC.D) ushare defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
