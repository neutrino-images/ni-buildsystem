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

# cmake
ifndef $(PKG)_CMAKE
  $(PKG)_CMAKE = cmake
endif

# configure
ifndef $(PKG)_CONFIGURE_CMD
  $(PKG)_CONFIGURE_CMD = configure
endif
ifndef $(PKG)_CONF_ENV
  $(PKG)_CONF_ENV =
endif
ifndef $(PKG)_CONF_OPTS
  $(PKG)_CONF_OPTS =
endif

# configure commands
ifndef $(PKG)_CONFIGURE_CMDS
  ifeq ($(PKG_MODE),CMAKE)
    ifeq ($(PKG_HOST_PACKAGE),YES)
      $(PKG)_CONFIGURE_CMDS = $$(HOST_CMAKE_CMDS)
    else
      $(PKG)_CONFIGURE_CMDS = $$(TARGET_CMAKE_CMDS)
    endif
  else ifeq ($(PKG_MODE),MESON)
    ifeq ($(PKG_HOST_PACKAGE),YES)
      $(PKG)_CONFIGURE_CMDS = $$(HOST_MESON_CMDS)
    else
      $(PKG)_CONFIGURE_CMDS = $$(TARGET_MESON_CMDS)
    endif
  else
    ifeq ($(PKG_HOST_PACKAGE),YES)
      $(PKG)_CONFIGURE_CMDS = $$(HOST_CONFIGURE_CMDS)
    else
      $(PKG)_CONFIGURE_CMDS = $$(TARGET_CONFIGURE_CMDS)
    endif
  endif
endif

# make
ifndef $(PKG)_MAKE
  $(PKG)_MAKE = $$(MAKE)
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

# build commands
# TODO: python, kernel
ifndef $(PKG)_BUILD_CMDS
  ifeq ($(PKG_MODE),$(filter $(PKG_MODE),AUTOTOOLS CMAKE GENERIC))
    ifeq ($(PKG_HOST_PACKAGE),YES)
      $(PKG)_BUILD_CMDS = $$(HOST_MAKE_BUILD_CMDS)
    else
      $(PKG)_BUILD_CMDS = $$(TARGET_MAKE_BUILD_CMDS)
    endif
  else ifeq ($(PKG_MODE),$(filter $(PKG_MODE),MESON))
    ifeq ($(PKG_HOST_PACKAGE),YES)
      $(PKG)_BUILD_CMDS = $$(HOST_NINJA_BUILD_CMDS)
    else
      $(PKG)_BUILD_CMDS = $$(TARGET_NINJA_BUILD_CMDS)
    endif
  endif
endif

# make install
ifndef $(PKG)_MAKE_INSTALL
  $(PKG)_MAKE_INSTALL = $$($(PKG)_MAKE)
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

# install commands
# TODO: python, kernel
ifndef $(PKG)_INSTALL_CMDS
  ifeq ($(PKG_MODE),$(filter $(PKG_MODE),AUTOTOOLS CMAKE GENERIC))
    ifeq ($(PKG_HOST_PACKAGE),YES)
      $(PKG)_INSTALL_CMDS = $$(HOST_MAKE_INSTALL_CMDS)
    else
      $(PKG)_INSTALL_CMDS = $$(TARGET_MAKE_INSTALL_CMDS)
    endif
  else ifeq ($(PKG_MODE),$(filter $(PKG_MODE),MESON))
    ifeq ($(PKG_HOST_PACKAGE),YES)
      $(PKG)_INSTALL_CMDS = $$(HOST_NINJA_INSTALL_CMDS)
    else
      $(PKG)_INSTALL_CMDS = $$(TARGET_NINJA_INSTALL_CMDS)
    endif
  endif
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

pkg-mode = $(call UPPERCASE,$(firstword $(subst -, ,$(subst host-,,$(0)))))

# -----------------------------------------------------------------------------

# PKG "control-flag" variables
PKG_NO_EXTRACT = pkg-no-extract
PKG_NO_PATCHES = pkg-no-patches
PKG_NO_BUILD = pkg-no-build
PKG_NO_INSTALL = pkg-no-install

# -----------------------------------------------------------------------------

# clean-up
define CLEANUP
	$(Q)( \
	if [ "$($(PKG)_DIR)" ]; then \
		$(call MESSAGE,"Clean-up"); \
		rm -rf $(BUILD_DIR)/$($(PKG)_DIR); \
	fi; \
	)
endef

# -----------------------------------------------------------------------------

# start-up build
define STARTUP
	@$(call MESSAGE,"Start-up build")
	$(call CLEANUP)
endef

# -----------------------------------------------------------------------------

# resolve dependencies
define DEPENDENCIES
	@$(call MESSAGE,"Resolving dependencies")
	$(foreach dependency,$($(PKG)_DEPENDENCIES),$(MAKE) $(dependency)$(sep))
endef

# -----------------------------------------------------------------------------

# download archives into download directory
GET_ARCHIVE = wget --no-check-certificate -t3 -T60 -c -P

define DOWNLOAD
	$(foreach hook,$($(PKG)_PRE_DOWNLOAD_HOOKS),$(call $(hook))$(sep))
	$(Q)( \
	if [ "$($(PKG)_VERSION)" == "ni-git" ]; then \
	  $(call MESSAGE,"Downloading") ; \
	  $(GET_GIT_SOURCE) $($(PKG)_SITE)/$($(PKG)_SOURCE) $(SOURCE_DIR)/$($(PKG)_SOURCE); \
	elif [ "$($(PKG)_VERSION)" == "git" ]; then \
	  $(call MESSAGE,"Downloading") ; \
	  $(GET_GIT_SOURCE) $($(PKG)_SITE)/$($(PKG)_SOURCE) $(DL_DIR)/$($(PKG)_SOURCE); \
	elif [ "$($(PKG)_VERSION)" == "hg" ]; then \
	  $(call MESSAGE,"Downloading") ; \
	  $(GET_HG_SOURCE) $($(PKG)_SITE)/$($(PKG)_SOURCE) $(DL_DIR)/$($(PKG)_SOURCE); \
	elif [ "$($(PKG)_VERSION)" == "svn" ]; then \
	  $(call MESSAGE,"Downloading") ; \
	  $(GET_SVN_SOURCE) $($(PKG)_SITE)/$($(PKG)_SOURCE) $(DL_DIR)/$($(PKG)_SOURCE); \
	elif [ ! -f $(DL_DIR)/$(1) ]; then \
	  $(call MESSAGE,"Downloading") ; \
	  $(GET_ARCHIVE) $(DL_DIR) $($(PKG)_SITE)/$(1); \
	elif [ "$($(PKG)_VERSION)" == "curl-controlled" ]; then \
	  $(call MESSAGE,"Downloading") ; \
	  $(CD) $(DL_DIR); \
		  curl --remote-name --time-cond $($(PKG)_SOURCE) $($(PKG)_SITE)/$($(PKG)_SOURCE) || true; \
	fi; \
	)
	$(foreach hook,$($(PKG)_POST_DOWNLOAD_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

# unpack archives into given directory
define EXTRACT # (directory)
	@$(call MESSAGE,"Extracting")
	$(foreach hook,$($(PKG)_PRE_EXTRACT_HOOKS),$(call $(hook))$(sep))
	$(Q)( \
	case $($(PKG)_VERSION).$($(PKG)_SOURCE) in \
	  *.tar | *.tar.bz2 | *.tbz | *.tar.gz | *.tgz | *.tar.xz | *.txz) \
	    tar -xf ${DL_DIR}/$($(PKG)_SOURCE) -C $(1); \
	    ;; \
	  *.zip) \
	    unzip -o -q ${DL_DIR}/$($(PKG)_SOURCE) -d $(1); \
	    ;; \
	  ni-git.*) \
	    cp -a -t $(1) $(SOURCE_DIR)/$($(PKG)_SOURCE); \
	    if test $($(PKG)_CHECKOUT); then \
	      $(call MESSAGE,"git checkout $($(PKG)_CHECKOUT)"); \
	      $(CD) $(1)/$($(PKG)_DIR); git checkout $($(PKG)_CHECKOUT); \
	    fi; \
	    ;; \
	  *.git | git.*) \
	    cp -a -t $(1) $(DL_DIR)/$($(PKG)_SOURCE); \
	    if test $($(PKG)_CHECKOUT); then \
	      $(call MESSAGE,"git checkout $($(PKG)_CHECKOUT)"); \
	      $(CD) $(1)/$($(PKG)_DIR); git checkout $($(PKG)_CHECKOUT); \
	    fi; \
	    ;; \
	  *.hg | hg.*) \
	    cp -a -t $(1) $(DL_DIR)/$($(PKG)_SOURCE); \
	    if test $($(PKG)_CHECKOUT); then \
	      $(call MESSAGE,"hg checkout $($(PKG)_CHECKOUT)"); \
	      $(CD) $(1)/$($(PKG)_DIR); hg checkout $($(PKG)_CHECKOUT); \
	    fi; \
	    ;; \
	  *.svn | svn.*) \
	    cp -a -t $(1) $(DL_DIR)/$($(PKG)_SOURCE); \
	    if test $($(PKG)_CHECKOUT); then \
	      $(call MESSAGE,"svn checkout $($(PKG)_CHECKOUT)"); \
	      $(CD) $(1)/$($(PKG)_DIR); svn checkout $($(PKG)_CHECKOUT); \
	    fi; \
	    ;; \
	  *) \
	    $(call MESSAGE,"Cannot extract $($(PKG)_SOURCE)"); \
	    false ;; \
	esac \
	)
	$(foreach hook,$($(PKG)_POST_EXTRACT_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

PATCHES = \
	*.patch \
	*.patch-$(TARGET_CPU) \
	*.patch-$(TARGET_ARCH) \
	*.patch-$(BOXTYPE) \
	*.patch-$(BOXSERIES) \
	*.patch-$(BOXFAMILY) \
	*.patch-$(BOXMODEL)

# apply single patches or patch sets
define APPLY_PATCHES # (patches or directory)
	@$(call MESSAGE,"Patching")
	$(foreach hook,$($(PKG)_PRE_PATCH_HOOKS),$(call $(hook))$(sep))
	$(Q)( \
	$(CHDIR)/$($(PKG)_DIR); \
	for i in $(1) $(2); do \
		if [ "$$i" == "$(PKG_PATCHES_DIR)" -a ! -d $$i ]; then \
			continue; \
		fi; \
		if [ -d $$i ]; then \
			v=; \
			if [ -d $$i/$($(PKG)_VERSION) ]; then \
				v="$($(PKG)_VERSION)/"; \
			fi; \
			for p in $(addprefix $$i/$$v,$(PATCHES)); do \
				if [ -e $$p ]; then \
					$(call MESSAGE,"Applying $${p#$(PKG_PATCHES_DIR)/} (*)"); \
					patch -p1 -i $$p; \
				fi; \
			done; \
		else \
			$(call MESSAGE,"Applying $${i#$(PKG_PATCHES_DIR)/}"); \
			patch -p1 -i $(PKG_PATCHES_DIR)/$$i; \
		fi; \
	done; \
	)
	$(foreach hook,$($(PKG)_POST_PATCH_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

# prepare for build
define PREPARE
	$(eval $(pkg-check-variables))
	$(call STARTUP)
	$(call DEPENDENCIES)
	$(call DOWNLOAD,$($(PKG)_SOURCE))
	$(if $(filter $(1),$(PKG_NO_EXTRACT)),,$(call EXTRACT,$(BUILD_DIR)))
	$(if $(filter $(1),$(PKG_NO_PATCHES)),,$(call APPLY_PATCHES,$($(PKG)_PATCH),$($(PKG)_PATCH_CUSTOM)))
endef

# -----------------------------------------------------------------------------

# rewrite libtool libraries
REWRITE_LIBTOOL_RULES = "s,^libdir=.*,libdir='$(1)',; \
			 s,\(^dependency_libs='\| \|-L\|^dependency_libs='\)/lib,\ $(1),g"

REWRITE_LIBTOOL_TAG = rewritten=1

define rewrite_libtool # (libdir)
	$(Q)( \
	for la in $$(find $(1) -name "*.la" -type f); do \
		if ! grep -q "$(REWRITE_LIBTOOL_TAG)" $${la}; then \
			$(call MESSAGE,"Rewriting $${la#$(TARGET_DIR)/}"); \
			$(SED) $(REWRITE_LIBTOOL_RULES) $${la}; \
			echo -e "\n# Adapted to buildsystem\n$(REWRITE_LIBTOOL_TAG)" >> $${la}; \
		fi; \
	done; \
	)
endef

# rewrite libtool libraries automatically
define REWRITE_LIBTOOL
	$(foreach libdir,$(TARGET_base_libdir) $(TARGET_libdir),\
		$(call rewrite_libtool,$(libdir))$(sep))
endef

# -----------------------------------------------------------------------------

# rewrite pkg-config files
REWRITE_CONFIG_RULES = "s,^prefix=.*,prefix='$(TARGET_prefix)',; \
			s,^exec_prefix=.*,exec_prefix='$(TARGET_exec_prefix)',; \
			s,^libdir=.*,libdir='$(TARGET_libdir)',; \
			s,^includedir=.*,includedir='$(TARGET_includedir)',"

define rewrite_config_script # (config-script)
	$(Q)( \
	mv $(TARGET_bindir)/$(1) $(HOST_DIR)/bin; \
	$(call MESSAGE,"Rewriting $(1)"); \
	$(SED) $(REWRITE_CONFIG_RULES) $(HOST_DIR)/bin/$(1); \
	)
endef

# rewrite config scripts automatically
define REWRITE_CONFIG_SCRIPTS
	$(foreach config_script,$($(PKG)_CONFIG_SCRIPTS),
		$(call rewrite_config_script,$(config_script))$(sep))
endef

# -----------------------------------------------------------------------------

define TOUCH
	$(Q)touch $(if $(findstring host-,$(@)),$(HOST_DEPS_DIR),$(DEPS_DIR))/$(@)
endef

# -----------------------------------------------------------------------------

# follow-up build
define HOST_FOLLOWUP
	@$(call MESSAGE,"Follow-up build")
	$(foreach hook,$($(PKG)_PRE_FOLLOWUP_HOOKS),$(call $(hook))$(sep))
	$(call CLEANUP)
	$(foreach hook,$($(PKG)_HOST_FINALIZE_HOOKS),$(call $(hook))$(sep))
	$(foreach hook,$($(PKG)_POST_FOLLOWUP_HOOKS),$(call $(hook))$(sep))
	$(call TOUCH)
endef

define TARGET_FOLLOWUP
	@$(call MESSAGE,"Follow-up build")
	$(foreach hook,$($(PKG)_PRE_FOLLOWUP_HOOKS),$(call $(hook))$(sep))
	$(call REWRITE_CONFIG_SCRIPTS)
	$(call REWRITE_LIBTOOL)
	$(call CLEANUP)
	$(foreach hook,$($(PKG)_TARGET_FINALIZE_HOOKS),$(call $(hook))$(sep))
	$(foreach hook,$($(PKG)_POST_FOLLOWUP_HOOKS),$(call $(hook))$(sep))
	$(call TOUCH)
endef

# -----------------------------------------------------------------------------

#
# Manipulation of .config files based on the Kconfig infrastructure.
# Used by the BusyBox package, the Linux kernel package, and more.
#

define KCONFIG_ENABLE_OPT # (option, file)
	$(SED) "/\\<$(1)\\>/d" $(2)
	echo '$(1)=y' >> $(2)
endef

define KCONFIG_SET_OPT # (option, value, file)
	$(SED) "/\\<$(1)\\>/d" $(3)
	echo '$(1)=$(2)' >> $(3)
endef

define KCONFIG_DISABLE_OPT # (option, file)
	$(SED) "/\\<$(1)\\>/d" $(2)
	echo '# $(1) is not set' >> $(2)
endef
