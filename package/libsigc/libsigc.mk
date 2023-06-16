################################################################################
#
# libsigc++
#
################################################################################

LIBSIGC_VERSION = 2.10.3
LIBSIGC_DIR = libsigc++-$(LIBSIGC_VERSION)
LIBSIGC_SOURCE = libsigc++-$(LIBSIGC_VERSION).tar.xz
LIBSIGC_SITE = https://download.gnome.org/sources/libsigc++/$(basename $(LIBSIGC_VERSION))

LIBSIGC_CONF_OPTS = \
	--disable-benchmark \
	--disable-documentation \
	--disable-warnings \
	--without-boost

define LIBSIGC_INSTALL_HEADER
	cp $($(PKG)_BUILD_DIR)/sigc++config.h $(TARGET_includedir)
	ln -sf ./sigc++-2.0/sigc++ $(TARGET_includedir)/sigc++
endef
LIBSIGC_POST_INSTALL_HOOKS += LIBSIGC_INSTALL_HEADER

libsigc: | $(TARGET_DIR)
	$(call autotools-package)
