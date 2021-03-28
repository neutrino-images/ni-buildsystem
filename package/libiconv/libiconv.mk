################################################################################
#
# libiconv
#
################################################################################

LIBICONV_VERSION = 1.15
LIBICONV_DIR = libiconv-$(LIBICONV_VERSION)
LIBICONV_SOURCE = libiconv-$(LIBICONV_VERSION).tar.gz
LIBICONV_SITE = $(GNU_MIRROR)/libiconv

LIBICONV_CONF_ENV = \
	CPPFLAGS="$(TARGET_CPPFLAGS) -fPIC"

LIBICONV_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-static \
	--disable-shared \
	--enable-relocatable

define LIBICONV_DISABLE_PRELOAD
	$(SED) '/preload/d' $(PKG_BUILD_DIR)/Makefile.in
endef
LIBICONV_POST_PATCH_HOOKS += LIBICONV_DISABLE_PRELOAD

libiconv: | $(TARGET_DIR)
	$(call autotools-package)
