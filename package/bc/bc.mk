################################################################################
#
# bc
#
################################################################################

BC_VERSION = 1.07.1
BC_DIR = bc-$(BC_VERSION)
BC_SOURCE = bc-$(BC_VERSION).tar.gz
BC_SITE = http://ftp.gnu.org/gnu/bc

# -----------------------------------------------------------------------------

HOST_BC_DEPENDENCIES = host-flex

# 0001-bc-use-MAKEINFO-variable-for-docs.patch and 0004-no-gen-libmath.patch
# are patching doc/Makefile.am and Makefile.am respectively
HOST_BC_AUTORECONF = YES

HOST_BC_CONF_ENV = \
	MAKEINFO=true

host-bc: | $(HOST_DIR)
	$(call host-autotools-package)
