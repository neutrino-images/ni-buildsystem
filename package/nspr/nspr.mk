################################################################################
#
# nspr
#
################################################################################

NSPR_VERSION = 4.35
NSPR_DIR = nspr-$(NSPR_VERSION)
NSPR_SOURCE = nspr-$(NSPR_VERSION).tar.gz
NSPR_SITE = https://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v$(NSPR_VERSION)/src

NSPR_CONF_OPTS = \
	--build=$(GNU_HOST_NAME) \
	--host=$(GNU_TARGET_NAME) \
	--target=$(GNU_TARGET_NAME) \
	--prefix=$(prefix) \
	--disable-64bit

# configure lives in the nspr/ subdirectory; the shared libraries only
define NSPR_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR)/nspr; \
		$(TARGET_CONFIGURE_ENVIRONMENT) \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		HOST_CC="gcc" HOST_CFLAGS="-g -O2" HOST_LDFLAGS="-lc" \
		./configure $(NSPR_CONF_OPTS)
endef

define NSPR_BUILD_CMDS
	$(MAKE) -C $(PKG_BUILD_DIR)/nspr LIBRARY=
endef

define NSPR_INSTALL_CMDS
	$(MAKE) -C $(PKG_BUILD_DIR)/nspr LIBRARY= DESTDIR=$(TARGET_DIR) install
endef

nspr: | $(TARGET_DIR)
	$(call generic-package)
