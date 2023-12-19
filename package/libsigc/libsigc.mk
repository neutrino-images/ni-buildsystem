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

libsigc: | $(TARGET_DIR)
	$(call meson-package)
