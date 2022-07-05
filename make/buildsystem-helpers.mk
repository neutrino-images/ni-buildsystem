#
# makefile to keep buildsystem helpers
#
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

define TOUCH
	@touch $(if $(findstring host-,$(@)),$(HOST_DEPS_DIR),$(DEPS_DIR))/$(@)
endef

# -----------------------------------------------------------------------------

# download archives into download directory
GET_ARCHIVE = wget --no-check-certificate -t3 -T60 -c -P

# for compatibility with "old" infrastructure
download = $(GET_ARCHIVE) $(DL_DIR)

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
	for i in $(1); do \
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
	$(if $(filter $(1),$(PKG_NO_PATCHES)),,$(call APPLY_PATCHES,$($(PKG)_PATCH)))
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

# unpack archives into build directory
UNTAR = tar -C $(BUILD_DIR) -xf $(DL_DIR)
UNZIP = unzip -d $(BUILD_DIR) -o $(DL_DIR)

# clean up
REMOVE = rm -rf $(BUILD_DIR)

# build helper variables
INSTALL      = $(shell which install || type -p install || echo install)
INSTALL_DATA = $(INSTALL) -m 0644
INSTALL_EXEC = $(INSTALL) -m 0755
INSTALL_COPY = cp -a

define INSTALL_EXIST # (source, dest)
	if [ -d $(dir $(1)) ]; then \
		$(INSTALL) -d $(2); \
		$(INSTALL_COPY) $(1) $(2); \
	fi
endef

CD    = set -e; cd
CHDIR = $(CD) $(BUILD_DIR)
MKDIR = $(INSTALL) -d $(BUILD_DIR)
CPDIR = cp -a -t $(BUILD_DIR) $(DL_DIR)
SED   = $(shell which sed || type -p sed || echo sed) -i -e

GET_GIT_ARCHIVE = support/scripts/get-git-archive.sh
GET_GIT_SOURCE  = support/scripts/get-git-source.sh
GET_HG_SOURCE   = support/scripts/get-hg-source.sh
GET_SVN_SOURCE  = support/scripts/get-svn-source.sh
UPDATE-RC.D     = support/scripts/update-rc.d -r $(TARGET_DIR)
REMOVE-RC.D     = support/scripts/update-rc.d -f -r $(TARGET_DIR)
TARGET_RM       = support/scripts/target-remove.sh $(TARGET_DIR) $(REMOVE_DIR)

# -----------------------------------------------------------------------------

# execute local scripts
define local-script
	@if [ -x $(LOCAL_DIR)/scripts/$(1) ]; then \
		$(LOCAL_DIR)/scripts/$(1) $(2) $(TARGET_DIR) $(BUILD_DIR); \
	fi
endef

# -----------------------------------------------------------------------------

# github(user,package,version): returns site of GitHub repository
github = https://github.com/$(1)/$(2)/archive/$(3)

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

# -----------------------------------------------------------------------------

get-cc-version \
get-gcc-version:
	$(Q)$(TARGET_CC) --version

get-cpp-version:
	$(Q)$(TARGET_CPP) --version

get-cxx-version:
	$(Q)$(TARGET_CXX) --version

# -----------------------------------------------------------------------------

# Create reversed changelog using git log --reverse.
# Remove duplicated commits and re-reverse the changelog using awk.
# This keeps the original commit and removes all picked duplicates.
define make-changelog
	git log --reverse --pretty=oneline --no-merges --abbrev-commit | \
	awk '!seen[substr($$0,12)]++' | \
	awk '{a[i++]=$$0} END {for (j=i-1; j>=0;) print a[j--]}'
endef

changelogs:
	$(call make-changelog) > $(STAGING_DIR)/changelog-buildsystem
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO); \
		$(call make-changelog) > $(STAGING_DIR)/changelog-neutrino
	$(CD) $(SOURCE_DIR)/$(NI_LIBSTB_HAL); \
		$(call make-changelog) > $(STAGING_DIR)/changelog-libstb-hal

# -----------------------------------------------------------------------------

done:
	$(call draw_line);
	@$(call SUCCESS,"Done")
	$(call draw_line);

# -----------------------------------------------------------------------------

PHONY += changelogs
PHONY += done
