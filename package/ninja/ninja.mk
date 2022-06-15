################################################################################
#
# ninja
#
################################################################################

NINJA_VERSION = 1.10.2
NINJA_DIR = ninja-$(NINJA_VERSION)
NINJA_SOURCE = ninja-$(NINJA_VERSION).tar.gz
NINJA_SITE = $(call github,ninja-build,ninja,v$(NINJA_VERSION))

# -----------------------------------------------------------------------------

HOST_NINJA_VERSION = $(NINJA_VERSION)
HOST_NINJA_DIR = $(NINJA_DIR)
HOST_NINJA_SOURCE = $(NINJA_SOURCE)
HOST_NINJA_SITE = $(NINJA_SITE)

HOST_NINJA = $(HOST_DIR)/bin/ninja

host-ninja: | $(HOST_DIR)
	$(call host-cmake-package)
