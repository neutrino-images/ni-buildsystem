################################################################################
#
# ninja
#
################################################################################

NINJA_VERSION = 1.13.2
NINJA_DIR = ninja-$(NINJA_VERSION)
NINJA_SOURCE = ninja-$(NINJA_VERSION).tar.gz
NINJA_SITE = $(call github,ninja-build,ninja,v$(NINJA_VERSION))

# -----------------------------------------------------------------------------

HOST_NINJA_BINARY = $(HOST_DIR)/bin/ninja

host-ninja: | $(HOST_DIR)
	$(call host-cmake-package)
