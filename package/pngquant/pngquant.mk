################################################################################
#
# pngquant
#
################################################################################

PNGQUANT_VERSION = 2.18.0
PNGQUANT_DIR = pngquant-$(PNGQUANT_VERSION)
PNGQUANT_SOURCE = pngquant-$(PNGQUANT_VERSION)-src.tar.gz
PNGQUANT_SITE = https://pngquant.org

# -----------------------------------------------------------------------------

HOST_PNGQUANT_DEPENDENCIES = host-libpng

HOST_PNGQUANT_BINARY = $(HOST_DIR)/bin/pngquant

HOST_PNGQUANT_CONF_ENV = \
	CC=$(HOSTCC_NOCCACHE)

HOST_PNGQUANT_CONF_OPTS = \
	--prefix=$(HOST_DIR) \
	--without-lcms2 \
	--disable-sse

define HOST_PNGQUANT_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(HOST_CONFIGURE_ENV) $($(PKG)_CONF_ENV) \
		./configure \
			$($(PKG)_CONF_OPTS)
endef

host-pngquant: | $(HOST_DIR)
	$(call host-generic-package)
