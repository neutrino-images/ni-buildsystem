################################################################################
#
# parted
#
################################################################################

PARTED_VERSION = 3.2
PARTED_DIR = parted-$(PARTED_VERSION)
PARTED_SOURCE = parted-$(PARTED_VERSION).tar.xz
PARTED_SITE = $(GNU_MIRROR)/parted

PARTED_DEPENDENCIES = util-linux

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),armbox mipsbox))
  PARTED_DEPENDENCIES += libiconv
endif

PARTED_AUTORECONF = YES

PARTED_CONF_OPTS = \
	--infodir=$(REMOVE_infodir) \
	--enable-shared \
	--disable-static \
	--disable-debug \
	--disable-pc98 \
	--disable-nls \
	--disable-device-mapper \
	--without-readline

parted: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

HOST_PARTED_DEPENDENCIES = host-util-linux

HOST_PARTED_AUTORECONF = YES

HOST_PARTED_CONF_OPTS = \
	--enable-static \
	--disable-shared \
	--disable-device-mapper \
	--without-readline

host-parted: | $(HOST_DIR)
	$(call host-autotools-package)
