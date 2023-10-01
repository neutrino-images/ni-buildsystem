################################################################################
#
# ninja
#
################################################################################

NINJA_VERSION_MAJOR = 1.11.1
NINJA_VERSION = $(NINJA_VERSION_MAJOR).g95dee.kitware.jobserver-1
NINJA_DIR = ninja-$(NINJA_VERSION)
NINJA_SOURCE = ninja-$(NINJA_VERSION).tar.gz
NINJA_SITE = $(call github,Kitware,ninja,v$(NINJA_VERSION))

# -----------------------------------------------------------------------------

HOST_NINJA_BINARY = $(HOST_DIR)/bin/ninja

host-ninja: | $(HOST_DIR)
	$(call host-cmake-package)
