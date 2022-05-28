################################################################################
#
# zlib
#
################################################################################

ZLIB_VERSION = 1.2.11
ZLIB_DIR = zlib-$(ZLIB_VERSION)
ZLIB_SOURCE = zlib-$(ZLIB_VERSION).tar.xz
ZLIB_SITE = https://sourceforge.net/projects/libpng/files/zlib/$(ZLIB_VERSION)

ZLIB_CONF_ENV = \
	mandir=$(REMOVE_mandir)

ZLIB_CONF_OPTS = \
	--prefix=$(prefix) \
	--shared \
	--uname=Linux

zlib: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		./configure $($(PKG)_CONF_OPTS); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(call TARGET_FOLLOWUP)

# -----------------------------------------------------------------------------

HOST_ZLIB_VERSION = $(ZLIB_VERSION)
HOST_ZLIB_DIR = $(ZLIB_DIR)
HOST_ZLIB_SOURCE = $(ZLIB_SOURCE)
HOST_ZLIB_SITE = $(ZLIB_SITE)

#HOST_ZLIB_CONF_ENV = \
#	libdir=$(HOST_DIR)/lib \
#	includedir=$(HOST_DIR)/include

HOST_ZLIB_CONF_OPTS = \
	--prefix="" \
	--shared \
	--uname=Linux

host-zlib: | $(HOST_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(HOST_CONFIGURE_ENV) \
		./configure $($(PKG)_CONF_OPTS); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(HOST_DIR)
	$(call HOST_FOLLOWUP)
