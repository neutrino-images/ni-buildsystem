################################################################################
#
# flex
#
################################################################################

FLEX_VERSION = 2.6.4
FLEX_DIR = flex-$(FLEX_VERSION)
FLEX_SOURCE = flex-$(FLEX_VERSION).tar.gz
FLEX_SITE = https://github.com/westes/flex/files/981163

# -----------------------------------------------------------------------------

HOST_FLEX_DEPENDENCIES = host-m4

# 0001-build-AC_USE_SYSTEM_EXTENSIONS-in-configure.ac.patch
HOST_FLEX_AUTORECONF = YES

host-flex: | $(HOST_DIR)
	$(call host-autotools-package)
