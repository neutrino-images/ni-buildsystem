################################################################################
#
# This file contains various utility functions used by the package
# infrastructure, or by the packages themselves.
#
################################################################################

pkgname = $(basename $(@F))
pkg = $(call LOWERCASE,$(pkgname))
PKG = $(call UPPERCASE,$(pkgname))

PKG_BUILD_DIR = $(BUILD_DIR)/$($(PKG)_DIR)
PKG_FILES_DIR = $(PACKAGE_DIR)/$(subst host-,,$(pkgname))/files
PKG_PATCHES_DIR = $(PACKAGE_DIR)/$(subst host-,,$(pkgname))/patches

# -----------------------------------------------------------------------------

# Compatibility variables (marked to remove)
PKG_DIR         = $($(PKG)_DIR)
PKG_SOURCE      = $($(PKG)_SOURCE)
PKG_SITE        = $($(PKG)_SITE)
PKG_PATCH       = $($(PKG)_PATCH)
