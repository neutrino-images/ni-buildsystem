################################################################################
#
# esbuild
#
################################################################################

# keep in step with ESBUILD_VERSION in ni-neutrino's test/web/fetch-types.sh
ESBUILD_VERSION = 0.28.2
ESBUILD_DIR = esbuild-$(ESBUILD_VERSION)
ESBUILD_SOURCE = esbuild-$(ESBUILD_VERSION).tar.gz
ESBUILD_SITE = $(call github,evanw,esbuild,v$(ESBUILD_VERSION))
ESBUILD_GOMOD = github.com/evanw/esbuild

ESBUILD_BUILD_TARGETS = cmd/esbuild

# -----------------------------------------------------------------------------

HOST_ESBUILD_BINARY = $(HOST_DIR)/bin/esbuild

host-esbuild: | $(HOST_DIR)
	$(call host-golang-package)
