################################################################################
#
# This file contains various utility functions used by the package
# infrastructure, or by the packages themselves.
#
################################################################################

pkgname = $(basename $(@F))
pkg = $(call LOWERCASE,$(pkgname))
PKG = $(call UPPERCASE,$(pkgname))

PKG_BUILD_DIR = $(BUILD_DIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR)
PKG_FILES_DIR = $(PACKAGE_DIR)/$(subst host-,,$(pkgname))/files
PKG_PATCHES_DIR = $(PACKAGE_DIR)/$(subst host-,,$(pkgname))/patches

PKG_HOST_PACKAGE = $(if $(filter $(firstword $(subst -, ,$(pkg))),host),YES,NO)
PKG_TARGET_PACKAGE = $(if $(filter $(PKG_HOST_PACKAGE),NO),YES,NO)

# -----------------------------------------------------------------------------

# check for necessary $(PKG) variables
define PKG_CHECK_VARIABLES

# patch
ifndef $(PKG)_PATCH
  $(PKG)_PATCH = $$(PKG_PATCHES_DIR)
endif
ifndef $(PKG)_PATCH_CUSTOM
  $(PKG)_PATCH_CUSTOM =
endif

# autoreconf
ifndef $(PKG)_AUTORECONF
  $(PKG)_AUTORECONF = NO
endif
ifndef $(PKG)_AUTORECONF_CMD
  $(PKG)_AUTORECONF_CMD = autoreconf -fi
endif
ifndef $(PKG)_AUTORECONF_ENV
  $(PKG)_AUTORECONF_ENV =
endif
ifndef $(PKG)_AUTORECONF_OPTS
  $(PKG)_AUTORECONF_OPTS =
endif

# cmake / configure / meson
ifndef $(PKG)_CMAKE
  $(PKG)_CMAKE = cmake
endif
ifndef $(PKG)_CONFIGURE_CMD
  $(PKG)_CONFIGURE_CMD = configure
endif
ifndef $(PKG)_CONFIGURE_CMDS
  ifeq ($(PKG_HOST_PACKAGE),YES)
    $(PKG)_CONFIGURE_CMDS = $$(HOST_CONFIGURE_CMDS)
  else
    $(PKG)_CONFIGURE_CMDS = $$(TARGET_CONFIGURE_CMDS)
  endif
endif
ifndef $(PKG)_CONF_ENV
  $(PKG)_CONF_ENV =
endif
ifndef $(PKG)_CONF_OPTS
  $(PKG)_CONF_OPTS =
endif

# make
ifndef $(PKG)_MAKE
  $(PKG)_MAKE = $$(MAKE)
endif
ifndef $(PKG)_MAKE_CMDS
  ifeq ($(PKG_HOST_PACKAGE),YES)
    $(PKG)_MAKE_CMDS = $$(HOST_MAKE_CMDS)
  else
    $(PKG)_MAKE_CMDS = $$(TARGET_MAKE_CMDS)
  endif
endif
ifndef $(PKG)_MAKE_ENV
  $(PKG)_MAKE_ENV =
endif
ifndef $(PKG)_MAKE_ARGS
  $(PKG)_MAKE_ARGS =
endif
ifndef $(PKG)_MAKE_OPTS
  $(PKG)_MAKE_OPTS =
endif

# make install
ifndef $(PKG)_MAKE_INSTALL
  $(PKG)_MAKE_INSTALL = $$($(PKG)_MAKE)
endif
ifndef $(PKG)_MAKE_INSTALL_CMDS
  ifeq ($(PKG_HOST_PACKAGE),YES)
    $(PKG)_MAKE_INSTALL_CMDS = $$(HOST_MAKE_INSTALL_CMDS)
  else
    $(PKG)_MAKE_INSTALL_CMDS = $$(TARGET_MAKE_INSTALL_CMDS)
  endif
endif
ifndef $(PKG)_MAKE_INSTALL_ENV
  $(PKG)_MAKE_INSTALL_ENV = $$($(PKG)_MAKE_ENV)
endif
ifndef $(PKG)_MAKE_INSTALL_ARGS
  $(PKG)_MAKE_INSTALL_ARGS = install
endif
ifndef $(PKG)_MAKE_INSTALL_OPTS
  $(PKG)_MAKE_INSTALL_OPTS = $$($(PKG)_MAKE_OPTS)
endif

# ninja
ifndef $(PKG)_NINJA_ENV
  $(PKG)_NINJA_ENV =
endif
ifndef $(PKG)_NINJA_OPTS
  $(PKG)_NINJA_OPTS =
endif

endef # PKG_CHECK_VARIABLES

pkg-check-variables = $(call PKG_CHECK_VARIABLES)

# -----------------------------------------------------------------------------

# PKG "control-flag" variables
PKG_NO_EXTRACT = pkg-no-extract
PKG_NO_PATCHES = pkg-no-patches
PKG_NO_BUILD = pkg-no-build
PKG_NO_INSTALL = pkg-no-install
