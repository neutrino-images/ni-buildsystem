################################################################################
#
# libsigc++
#
################################################################################

LIBSIGC_VERSION = 2.10.3
LIBSIGC_DIR = libsigc++-$(LIBSIGC_VERSION)
LIBSIGC_SOURCE = libsigc++-$(LIBSIGC_VERSION).tar.xz
LIBSIGC_SITE = https://download.gnome.org/sources/libsigc++/$(basename $(LIBSIGC_VERSION))

$(DL_DIR)/$(LIBSIGC_SOURCE):
	$(download) $(LIBSIGC_SITE)/$(LIBSIGC_SOURCE)

LIBSIGC_CONF_OPTS = \
	--disable-benchmark \
	--disable-documentation \
	--disable-warnings \
	--without-boost

libsigc: $(DL_DIR)/$(LIBSIGC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
		cp sigc++config.h $(TARGET_includedir)
	ln -sf ./sigc++-2.0/sigc++ $(TARGET_includedir)/sigc++
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
