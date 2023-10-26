################################################################################
#
# patch
#
################################################################################

PATCH_VERSION = 2.7.6
PATCH_DIR = patch-$(PATCH_VERSION)
PATCH_SOURCE = patch-$(PATCH_VERSION).tar.xz
PATCH_SITE = $(GNU_MIRROR)/patch

# -----------------------------------------------------------------------------

HOST_PATCH_DEPENDENCIES = host-attr

HOST_PATCH_CONF_OPTS = \
	--enable-xattr

host-patch: | $(HOST_DIR)
	$(call host-autotools-package)
