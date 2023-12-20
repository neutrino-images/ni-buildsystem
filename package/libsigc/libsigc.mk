################################################################################
#
# libsigc++
#
################################################################################

LIBSIGC_VERSION_MAJOR = 2.12
LIBSIGC_VERSION = $(LIBSIGC_VERSION_MAJOR).0
LIBSIGC_DIR = libsigc++-$(LIBSIGC_VERSION)
LIBSIGC_SOURCE = libsigc++-$(LIBSIGC_VERSION).tar.xz
LIBSIGC_SITE = https://download.gnome.org/sources/libsigc++/$(LIBSIGC_VERSION_MAJOR)

LIBSIGC_CONF_OPTS = \
	-Dbuild-examples=false \
	-Dbuild-tests=false \
	-Dvalidation=false

define LIBSIGC_LINKING_INCLUDEDIR
	ln -sf sigc++-2.0/sigc++ $(TARGET_includedir)/sigc++
endef
LIBSIGC_TARGET_FINALIZE_HOOKS += LIBSIGC_LINKING_INCLUDEDIR

define LIBSIGC_INSTALL_HEADER
	$(INSTALL_DATA) $(TARGET_libdir)/sigc++-2.0/include/sigc++config.h $(TARGET_includedir)
endef
LIBSIGC_TARGET_FINALIZE_HOOKS += LIBSIGC_INSTALL_HEADER

define LIBSIGC_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_libdir)/sigc++-2.0
endef
LIBSIGC_TARGET_FINALIZE_HOOKS += LIBSIGC_TARGET_CLEANUP

libsigc: | $(TARGET_DIR)
	$(call meson-package)
