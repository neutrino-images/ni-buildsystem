#
# makefile to keep buildsystem helpers
#
# -----------------------------------------------------------------------------

# download archives into download directory
DOWNLOAD = wget --no-check-certificate -t3 -T60 -c -P $(DL_DIR)

# unpack archives into build directory
UNTAR = tar -C $(BUILD_DIR) -xf $(DL_DIR)
UNZIP = unzip -d $(BUILD_DIR) -o $(DL_DIR)

# clean up
REMOVE = rm -rf $(BUILD_DIR)

# build helper variables
CD    = set -e; cd
CHDIR = $(CD) $(BUILD_DIR)
MKDIR = mkdir -p $(BUILD_DIR)
CPDIR = cp -a -t $(BUILD_DIR) $(DL_DIR)
#TOUCH = @touch $(DEPS_DIR)/$(@)
TOUCH = @touch $(if $(findstring host-,$(@)),$(HOST_DEPS_DIR),$(DEPS_DIR))/$(@)
SED   = $(shell which sed || type -p sed) -i -e

INSTALL      = install
INSTALL_DATA = $(INSTALL) -m 0644
INSTALL_EXEC = $(INSTALL) -m 0755
INSTALL_COPY = cp -a

define INSTALL_EXIST # (source, dest)
	if [ -d $(dir $(1)) ]; then \
		$(INSTALL) -d $(2); \
		$(INSTALL_COPY) $(1) $(2); \
	fi
endef

GET-GIT-ARCHIVE = $(HELPERS_DIR)/get-git-archive.sh
GET-GIT-SOURCE  = $(HELPERS_DIR)/get-git-source.sh
GET-SVN-SOURCE  = $(HELPERS_DIR)/get-svn-source.sh
UPDATE-RC.D     = $(HELPERS_DIR)/update-rc.d -r $(TARGET_DIR)

# -----------------------------------------------------------------------------
# execute local scripts
define local-script
	@if [ -x $(LOCAL_DIR)/scripts/$(1) ]; then \
		$(LOCAL_DIR)/scripts/$(1) $(2) $(TARGET_DIR) $(BUILD_DIR); \
	fi
endef

# -----------------------------------------------------------------------------

# apply patch sets
define apply_patches
	l=$(strip $(2)); test -z $$l && l=1; \
	for i in $(1); do \
		if [ -e $$i -o -e $(PKG_PATCHES_DIR)/$$i ]; then \
			if [ -d $$i ]; then \
				for p in $$i/*; do \
					echo -e "$(TERM_YELLOW)Applying $${p#$(PKG_PATCHES_DIR)/}$(TERM_NORMAL)"; \
					if [ $${p:0:1} == "/" ]; then \
						patch -p$$l -i $$p; \
					else \
						patch -p$$l -i $(PKG_PATCHES_DIR)/$$p; \
					fi; \
				done; \
			else \
				echo -e "$(TERM_YELLOW)Applying $${i#$(PKG_PATCHES_DIR)/}$(TERM_NORMAL)"; \
				if [ $${i:0:1} == "/" ]; then \
					patch -p$$l -i $$i; \
				else \
					patch -p$$l -i $(PKG_PATCHES_DIR)/$$i; \
				fi; \
			fi; \
		fi; \
	done
endef

# apply patch sets automatically
APPLY_PATCHES = $(call apply_patches,$(PKG_PATCHES_DIR))

# -----------------------------------------------------------------------------

# github(user,package,version): returns site of GitHub repository
github = https://github.com/$(1)/$(2)/archive/$(3)

# -----------------------------------------------------------------------------

# rewrite libtool libraries
REWRITE_LIBTOOL_RULES = "s,^libdir=.*,libdir='$(1)',; \
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
REWRITE_LIBTOOL = $(foreach libdir,$(TARGET_base_libdir) $(TARGET_libdir),\
			$(call rewrite_libtool,$(libdir))$(sep))

# -----------------------------------------------------------------------------

# rewrite pkg-config files
REWRITE_CONFIG_RULES = "s,^prefix=.*,prefix='$(TARGET_prefix)',; \
			s,^exec_prefix=.*,exec_prefix='$(TARGET_exec_prefix)',; \
			s,^libdir=.*,libdir='$(TARGET_libdir)',; \
			s,^includedir=.*,includedir='$(TARGET_includedir)',"

REWRITE_CONFIG = $(SED) $(REWRITE_CONFIG_RULES)

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

PHONY += changelogs
