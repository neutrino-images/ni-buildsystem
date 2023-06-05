################################################################################
#
# This file contains various utility functions used by the package
# infrastructure, or by the packages themselves.
#
################################################################################

pkgname = $(basename $(@F))

pkg = $(call LOWERCASE,$(pkgname))
PKG = $(call UPPERCASE,$(pkgname))

PKG_PARENT = $(subst HOST_,,$(PKG))
PKG_PACKAGE = $(if $(filter $(firstword $(subst -, ,$(pkg))),host),HOST,TARGET)

PKG_BUILD_DIR = $(BUILD_DIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR)
PKG_FILES_DIR = $(PACKAGE_DIR)/$(subst host-,,$(pkgname))/files
PKG_PATCHES_DIR = $(PACKAGE_DIR)/$(subst host-,,$(pkgname))/patches

# -----------------------------------------------------------------------------

# check for necessary $(PKG) variables
define PKG_CHECK_VARIABLES

# auto-assign HOST_ variables
ifeq ($(PKG_PACKAGE),HOST)
  ifndef $(PKG)_VERSION
    $(PKG)_VERSION = $$($(PKG_PARENT)_VERSION)
  endif
  ifndef $(PKG)_DIR
    $(PKG)_DIR = $$($(PKG_PARENT)_DIR)
  endif
  ifndef $(PKG)_SOURCE
    $(PKG)_SOURCE = $$($(PKG_PARENT)_SOURCE)
  endif
  ifndef $(PKG)_SITE
    $(PKG)_SITE = $$($(PKG_PARENT)_SITE)
  endif
endif

# extract
ifndef $(PKG)_EXTRACT_DIR
  $(PKG)_EXTRACT_DIR =
endif

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
    ifeq ($(PKG_PACKAGE),HOST)
      $(PKG)_CONFIGURE_CMDS = $$(HOST_CMAKE_CMDS_DEFAULT)
    else
      $(PKG)_CONFIGURE_CMDS = $$(TARGET_CMAKE_CMDS_DEFAULT)
    endif
  else ifeq ($(PKG_MODE),MESON)
    ifeq ($(PKG_PACKAGE),HOST)
      $(PKG)_CONFIGURE_CMDS = $$(HOST_MESON_CMDS_DEFAULT)
    else
      $(PKG)_CONFIGURE_CMDS = $$(TARGET_MESON_CMDS_DEFAULT)
    endif
  else
    ifeq ($(PKG_PACKAGE),HOST)
      $(PKG)_CONFIGURE_CMDS = $$(HOST_CONFIGURE_CMDS_DEFAULT)
    else
      $(PKG)_CONFIGURE_CMDS = $$(TARGET_CONFIGURE_CMDS_DEFAULT)
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
ifndef $(PKG)_BUILD_CMDS
  ifeq ($(PKG_MODE),$(filter $(PKG_MODE),AUTOTOOLS CMAKE GENERIC KCONFIG))
    ifeq ($(PKG_PACKAGE),HOST)
      $(PKG)_BUILD_CMDS = $$(HOST_MAKE_BUILD_CMDS_DEFAULT)
    else
      $(PKG)_BUILD_CMDS = $$(TARGET_MAKE_BUILD_CMDS_DEFAULT)
    endif
  else ifeq ($(PKG_MODE),MESON)
    ifeq ($(PKG_PACKAGE),HOST)
      $(PKG)_BUILD_CMDS = $$(HOST_NINJA_BUILD_CMDS_DEFAULT)
    else
      $(PKG)_BUILD_CMDS = $$(TARGET_NINJA_BUILD_CMDS_DEFAULT)
    endif
  else ifeq ($(PKG_MODE),PYTHON3)
    ifeq ($(PKG_PACKAGE),HOST)
      $(PKG)_BUILD_CMDS = $$(HOST_PYTHON3_BUILD_CMDS_DEFAULT)
    endif
  else ifeq ($(PKG_MODE),KERNEL_MODULE)
    $(PKG)_BUILD_CMDS = $$(KERNEL_MODULE_BUILD_CMDS_DEFAULT)
  else
    $(PKG)_BUILD_CMDS = echo "$(PKG_NO_BUILD)"
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
  ifeq ($(PKG_MODE),KERNEL_MODULE)
    $(PKG)_MAKE_INSTALL_ARGS = modules_install
  else
    $(PKG)_MAKE_INSTALL_ARGS = install
  endif
endif
ifndef $(PKG)_MAKE_INSTALL_OPTS
  $(PKG)_MAKE_INSTALL_OPTS = $$($(PKG)_MAKE_OPTS)
endif

# install commands
ifndef $(PKG)_INSTALL_CMDS
  ifeq ($(PKG_MODE),$(filter $(PKG_MODE),AUTOTOOLS CMAKE GENERIC KCONFIG))
    ifeq ($(PKG_PACKAGE),HOST)
      $(PKG)_INSTALL_CMDS = $$(HOST_MAKE_INSTALL_CMDS_DEFAULT)
    else
      $(PKG)_INSTALL_CMDS = $$(TARGET_MAKE_INSTALL_CMDS_DEFAULT)
    endif
  else ifeq ($(PKG_MODE),MESON)
    ifeq ($(PKG_PACKAGE),HOST)
      $(PKG)_INSTALL_CMDS = $$(HOST_NINJA_INSTALL_CMDS_DEFAULT)
    else
      $(PKG)_INSTALL_CMDS = $$(TARGET_NINJA_INSTALL_CMDS_DEFAULT)
    endif
  else ifeq ($(PKG_MODE),PYTHON3)
    ifeq ($(PKG_PACKAGE),HOST)
      $(PKG)_INSTALL_CMDS = $$(HOST_PYTHON3_INSTALL_CMDS_DEFAULT)
    endif
  else ifeq ($(PKG_MODE),KERNEL_MODULE)
    $(PKG)_INSTALL_CMDS = $$(KERNEL_MODULE_INSTALL_CMDS_DEFAULT)
  else
    $(PKG)_INSTALL_CMDS = echo "$(PKG_NO_INSTALL)"
  endif
endif

# ninja
ifndef $(PKG)_NINJA_ENV
  $(PKG)_NINJA_ENV =
endif
ifndef $(PKG)_NINJA_OPTS
  $(PKG)_NINJA_OPTS =
endif

# kconfig
ifeq ($(PKG_MODE),KCONFIG)
  ifndef $(PKG)_KCONFIG_FILE
    $(PKG)_KCONFIG_FILE = .config
  endif
  $(PKG)_KCONFIG_DOTCONFIG = $$($(PKG)_KCONFIG_FILE)
endif

# auto-assign some dependencies
ifndef $(PKG)_DEPENDENCIES
  $(PKG)_DEPENDENCIES =
endif
ifeq ($(PKG_MODE),MESON)
  $(PKG)_DEPENDENCIES += host-meson
endif
ifeq ($(PKG_MODE),KERNEL_MODULE)
  $(PKG)_DEPENDENCIES += kernel-$(BOXTYPE)
endif
ifeq ($(PKG_MODE),PYTHON3)
  $(PKG)_DEPENDENCIES += host-python3
  $(PKG)_DEPENDENCIES += $$(if $$(filter $$(pkg),host-python-setuptools),,host-python-setuptools)
endif

endef # PKG_CHECK_VARIABLES

pkg-check-variables = $(call PKG_CHECK_VARIABLES)

# -----------------------------------------------------------------------------

pkg-mode = $(call UPPERCASE,$(subst -package,,$(subst host-,,$(0))))

# -----------------------------------------------------------------------------

# PKG "control-flag" variables
PKG_NO_DOWNLOAD = pkg-no-download
PKG_NO_EXTRACT = pkg-no-extract
PKG_NO_PATCHES = pkg-no-patches
PKG_NO_BUILD = pkg-no-build
PKG_NO_INSTALL = pkg-no-install

# -----------------------------------------------------------------------------

# clean-up
define CLEANUP
	if [ "$($(PKG)_DIR)" ]; then \
		$(call MESSAGE,"Clean-up $(pkgname)"); \
		$(CD) $(BUILD_DIR); \
			rm -rf $($(PKG)_DIR); \
	fi
endef

# -----------------------------------------------------------------------------

# start-up build
define STARTUP
	@$(call MESSAGE,"Start-up build $(pkgname)")
	$(Q)$(call CLEANUP)
endef

# -----------------------------------------------------------------------------

# end-up build
define ENDUP
	@$(call SUCCESS,"End-up build $(pkgname)")
	@$(call draw_line);
endef

# -----------------------------------------------------------------------------

# resolve dependencies
define DEPENDENCIES
	@$(call MESSAGE,"Resolving dependencies for $(pkgname)")
	$(foreach dependency,$($(PKG)_DEPENDENCIES),$(Q)$(MAKE) $(dependency)$(sep))
endef

# -----------------------------------------------------------------------------

# download archives into download directory
GET_ARCHIVE = wget --no-check-certificate -t3 -T60 -c -P

GET_GIT_ARCHIVE = support/scripts/get-git-archive.sh
GET_GIT_SOURCE = support/scripts/get-git-source.sh
GET_HG_SOURCE = support/scripts/get-hg-source.sh
GET_SVN_SOURCE = support/scripts/get-svn-source.sh

define DOWNLOAD # (site,source)
	@$(call MESSAGE,"Downloading $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_DOWNLOAD_HOOKS),$(call $(hook))$(sep))
	$(Q)( \
	DOWNLOAD_SITE=$(1); \
	DOWNLOAD_SOURCE=$(2); \
	case "$($(PKG)_SITE_METHOD)" in \
	  ni-git) \
	    $(GET_GIT_SOURCE) $${DOWNLOAD_SITE}/$${DOWNLOAD_SOURCE} $(SOURCE_DIR)/$${DOWNLOAD_SOURCE}; \
	  ;; \
	  git) \
	    $(GET_GIT_SOURCE) $${DOWNLOAD_SITE}/$${DOWNLOAD_SOURCE} $(DL_DIR)/$${DOWNLOAD_SOURCE}; \
	  ;; \
	  hg) \
	    $(GET_HG_SOURCE) $${DOWNLOAD_SITE}/$${DOWNLOAD_SOURCE} $(DL_DIR)/$${DOWNLOAD_SOURCE}; \
	  ;; \
	  svn) \
	    $(GET_SVN_SOURCE) $${DOWNLOAD_SITE}/$${DOWNLOAD_SOURCE} $(DL_DIR)/$${DOWNLOAD_SOURCE}; \
	  ;; \
	  curl) \
	    $(CD) $(DL_DIR); \
	      curl --remote-name --time-cond $${DOWNLOAD_SOURCE} $${DOWNLOAD_SITE}/$${DOWNLOAD_SOURCE} || true; \
	  ;; \
	  *) \
	    if [ ! -f $(DL_DIR)/$${DOWNLOAD_SOURCE} ]; then \
	      $(GET_ARCHIVE) $(DL_DIR) $${DOWNLOAD_SITE}/$${DOWNLOAD_SOURCE}; \
	    fi; \
	  ;; \
	esac \
	)
	$(foreach hook,$($(PKG)_POST_DOWNLOAD_HOOKS),$(call $(hook))$(sep))
endef

# just a wrapper for niceness
download-package = $(call DOWNLOAD,$($(PKG)_SITE),$($(PKG)_SOURCE))

# -----------------------------------------------------------------------------

# unpack archives into given directory
define EXTRACT # (directory)
	@$(call MESSAGE,"Extracting $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_EXTRACT_HOOKS),$(call $(hook))$(sep))
	$(Q)( \
	EXTRACT_DIR=$(1); \
	if [ "$($(PKG)_EXTRACT_DIR)" ]; then \
		EXTRACT_DIR=$(1)/$($(PKG)_EXTRACT_DIR); \
		$(INSTALL) -d $${EXTRACT_DIR}; \
	fi; \
	case "$($(PKG)_SITE_METHOD)" in \
	  ni-git) \
	    cp -a -t $${EXTRACT_DIR} $(SOURCE_DIR)/$($(PKG)_SOURCE); \
	    $(call MESSAGE,"git checkout $($(PKG)_VERSION)"); \
	    $(CD) $${EXTRACT_DIR}/$($(PKG)_DIR); git checkout $($(PKG)_VERSION); \
	  ;; \
	  git) \
	    cp -a -t $${EXTRACT_DIR} $(DL_DIR)/$($(PKG)_SOURCE); \
	    $(call MESSAGE,"git checkout $($(PKG)_VERSION)"); \
	    $(CD) $${EXTRACT_DIR}/$($(PKG)_DIR); git checkout $($(PKG)_VERSION); \
	  ;; \
	  hg) \
	    cp -a -t $${EXTRACT_DIR} $(DL_DIR)/$($(PKG)_SOURCE); \
	    $(call MESSAGE,"hg checkout $($(PKG)_VERSION)"); \
	    $(CD) $${EXTRACT_DIR}/$($(PKG)_DIR); hg checkout $($(PKG)_VERSION); \
	  ;; \
	  svn) \
	    cp -a -t $${EXTRACT_DIR} $(DL_DIR)/$($(PKG)_SOURCE); \
	    $(call MESSAGE,"svn checkout $($(PKG)_VERSION)"); \
	    $(CD) $${EXTRACT_DIR}/$($(PKG)_DIR); svn checkout $($(PKG)_SITE) -r $($(PKG)_VERSION); \
	  ;; \
	  *) \
	    case "$($(PKG)_SOURCE)" in \
	      *.tar | *.tar.bz2 | *.tbz | *.tar.gz | *.tgz | *.tar.xz | *.txz) \
	        tar -xf $(DL_DIR)/$($(PKG)_SOURCE) -C $${EXTRACT_DIR}; \
	      ;; \
	      *.zip) \
	        unzip -o -q $(DL_DIR)/$($(PKG)_SOURCE) -d $${EXTRACT_DIR}; \
	      ;; \
	      *) \
	        $(call WARNING,"Cannot extract $($(PKG)_SOURCE)"); \
	        false; \
	      ;; \
	    esac; \
	  ;; \
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
	@$(call MESSAGE,"Patching $(pkgname)")
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
define PREPARE # (control-flag(s))
	$(eval $(pkg-check-variables))
	$(call STARTUP)
	$(call DEPENDENCIES)
	$(if $(filter $(1),$(PKG_NO_DOWNLOAD)),,$(call DOWNLOAD,$($(PKG)_SITE),$($(PKG)_SOURCE)))
	$(if $(filter $(1),$(PKG_NO_EXTRACT)),,$(call EXTRACT,$(BUILD_DIR)))
	$(if $(filter $(1),$(PKG_NO_PATCHES)),,$(call APPLY_PATCHES,$($(PKG)_PATCH),$($(PKG)_PATCH_CUSTOM)))
endef

# -----------------------------------------------------------------------------

# rewrite libtool libraries
REWRITE_LIBTOOL_RULES = "\
	s,^libdir=.*,libdir='$(1)',; \
	s,\(^dependency_libs='\| \|-L\|^dependency_libs='\)/lib,\ $(1),g"

REWRITE_LIBTOOL_TAG = rewritten=1

define rewrite_libtool # (libdir)
	for la in $$(find $(1) -name "*.la" -type f); do \
		if ! grep -q "$(REWRITE_LIBTOOL_TAG)" $${la}; then \
			$(call MESSAGE,"Rewriting $${la#$(TARGET_DIR)/}"); \
			$(SED) $(REWRITE_LIBTOOL_RULES) $${la}; \
			echo -e "\n# Adapted to buildsystem\n$(REWRITE_LIBTOOL_TAG)" >> $${la}; \
		fi; \
	done
endef

# rewrite libtool libraries automatically
define REWRITE_LIBTOOL
	$(foreach libdir,$(TARGET_base_libdir) $(TARGET_libdir),\
		$(Q)$(call rewrite_libtool,$(libdir))$(sep))
endef

# -----------------------------------------------------------------------------

# rewrite pkg-config files
REWRITE_CONFIG_RULES = "\
	s,^prefix=.*,prefix='$(TARGET_prefix)',; \
	s,^exec_prefix=.*,exec_prefix='$(TARGET_exec_prefix)',; \
	s,^libdir=.*,libdir='$(TARGET_libdir)',; \
	s,^includedir=.*,includedir='$(TARGET_includedir)',"

define rewrite_config_script # (config-script)
	mv $(TARGET_bindir)/$(1) $(HOST_DIR)/bin
	$(call MESSAGE,"Rewriting $(1)")
	$(SED) $(REWRITE_CONFIG_RULES) $(HOST_DIR)/bin/$(1)
endef

# rewrite config scripts automatically
define REWRITE_CONFIG_SCRIPTS
	$(foreach config_script,$($(PKG)_CONFIG_SCRIPTS),
		$(Q)$(call rewrite_config_script,$(config_script))$(sep))
endef

# -----------------------------------------------------------------------------

define TOUCH
	touch $(if $(findstring host-,$(@)),$(HOST_DEPS_DIR),$(DEPS_DIR))/$(@)
endef

# -----------------------------------------------------------------------------

# follow-up build
define HOST_FOLLOWUP
	@$(call MESSAGE,"Follow-up build $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_FOLLOWUP_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call CLEANUP)
	$(foreach hook,$($(PKG)_HOST_FINALIZE_HOOKS),$(call $(hook))$(sep))
	$(foreach hook,$($(PKG)_POST_FOLLOWUP_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call TOUCH)
	$(Q)$(call ENDUP)
endef

define TARGET_FOLLOWUP
	@$(call MESSAGE,"Follow-up build $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_FOLLOWUP_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call CLEANUP)
	$(Q)$(call REWRITE_CONFIG_SCRIPTS)
	$(Q)$(call REWRITE_LIBTOOL)
	$(if $(filter $(BS_INIT_SYSV),y),$($(PKG)_INSTALL_INIT_SYSV))
	$(foreach hook,$($(PKG)_TARGET_FINALIZE_HOOKS),$(call $(hook))$(sep))
	$(foreach hook,$($(PKG)_POST_FOLLOWUP_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call TOUCH)
	$(Q)$(call ENDUP)
endef
