################################################################################
#
# gawk
#
################################################################################

GAWK_VERSION = 5.2.2
GAWK_DIR = gawk-$(GAWK_VERSION)
GAWK_SOURCE = gawk-$(GAWK_VERSION).tar.xz
GAWK_SITE = $(GNU_MIRROR)/gawk

# -----------------------------------------------------------------------------

HOST_GAWK_CONF_OPTS = \
	--without-readline \
	--without-mpfr

define HOST_GAWK_CREATE_SYMLINK
	test -e $(HOST_DIR)/bin/awk || ln -sf gawk $(HOST_DIR)/bin/awk
endef
HOST_GAWK_POST_INSTALL_HOOKS += HOST_GAWK_CREATE_SYMLINK

host-gawk: | $(HOST_DIR)
	$(call host-autotools-package)
