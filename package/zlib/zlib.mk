################################################################################
#
# zlib
#
################################################################################

ZLIB_VERSION = 1.2.11
ZLIB_DIR = zlib-$(ZLIB_VERSION)
ZLIB_SOURCE = zlib-$(ZLIB_VERSION).tar.xz
ZLIB_SITE = https://sourceforge.net/projects/libpng/files/zlib/$(ZLIB_VERSION)

$(DL_DIR)/$(ZLIB_SOURCE):
	$(download) $(ZLIB_SITE)/$(ZLIB_SOURCE)

ZLIB_CONF_ENV = \
	mandir=$(REMOVE_mandir)

ZLIB_CONF_OPTS = \
	--prefix=$(prefix) \
	--shared \
	--uname=Linux

zlib: $(DL_DIR)/$(ZLIB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		./configure $($(PKG)_CONF_OPTS); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
