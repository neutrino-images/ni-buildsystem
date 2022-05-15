################################################################################
#
# ushare
#
################################################################################

USHARE_VERSION = 2.1
USHARE_DIR = uShare-$(USHARE_VERSION)
USHARE_SOURCE = uShare_v$(USHARE_VERSION).tar.gz
USHARE_SITE = $(call github,ddugovic,uShare,v$(USHARE_VERSION))

USHARE_DEPENDENCIES = libupnp

USHARE_CONF_OPTS = \
	--prefix=$(prefix) \
	--sysconfdir=$(REMOVE_sysconfdir) \
	--disable-dlna \
	--disable-nls \
	--disable-strip \
	--cross-compile \
	--cross-prefix=$(TARGET_CROSS)

USHARE_MAKE_OPTS = \
	LDFLAGS="$(TARGET_LDFLAGS)"

define USHARE_LINK_CONFIG_H
	ln -sf ../config.h $(PKG_BUILD_DIR)/src/
endef
USHARE_POST_PATCH_HOOKS += USHARE_LINK_CONFIG_H

define USHARE_INSTALL_CONF
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/ushare.conf $(TARGET_sysconfdir)/ushare.conf
	$(SED) 's|%(BOXTYPE)|$(BOXTYPE)|; s|%(BOXMODEL)|$(BOXMODEL)|' $(TARGET_sysconfdir)/ushare.conf
endef
USHARE_TARGET_FINALIZE_HOOKS += USHARE_INSTALL_CONF

define USHARE_INSTALL_INIT_SCRIPT
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/ushare.init $(TARGET_sysconfdir)/init.d/ushare
	$(UPDATE-RC.D) ushare defaults 75 25
endef
USHARE_TARGET_FINALIZE_HOOKS += USHARE_INSTALL_INIT_SCRIPT

ushare: | $(TARGET_DIR)
	$(call DEPENDENCIES)
	$(call DOWNLOAD,$($(PKG)_SOURCE))
	$(call STARTUP)
	$(call EXTRACT,$(BUILD_DIR))
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		./configure $($(PKG)_CONF_OPTS); \
		$(TARGET_MAKE_ENV) \
		$(MAKE) $($(PKG)_MAKE_OPTS); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(call TARGET_FOLLOWUP)
