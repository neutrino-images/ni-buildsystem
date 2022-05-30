################################################################################
#
# libudev-tero
#
################################################################################

LIBUDEV_ZERO_VERSION = 1.0.1
LIBUDEV_ZERO_DIR = libudev-zero-$(LIBUDEV_ZERO_VERSION)
LIBUDEV_ZERO_SOURCE = libudev-zero-$(LIBUDEV_ZERO_VERSION).tar.gz
LIBUDEV_ZERO_SITE = $(call github,illiliti,libudev-zero,$(LIBUDEV_ZERO_VERSION))

LIBUDEV_ZERO_MAKE_OPTS = \
	PREFIX=$(prefix)

libudev-zero: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) $($(PKG)_MAKE_OPTS); \
		$(MAKE) $($(PKG)_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	$(call TARGET_FOLLOWUP)
