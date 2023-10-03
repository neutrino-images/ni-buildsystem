################################################################################
#
# tar
#
################################################################################

TAR_VERSION = 1.35
TAR_SOURCE = tar-$(TAR_VERSION).tar.xz
TAR_DIR = tar-$(TAR_VERSION)
TAR_SITE = $(GNU_MIRROR)/tar

# -----------------------------------------------------------------------------

HOST_TAR_CONF_OPTS = \
	--without-selinux

host-tar: | $(HOST_DIR)
	$(call host-autotools-package)
