#
# makefile to keep buildsystem helpers
#
# -----------------------------------------------------------------------------

# for compatibility with "old" infrastructure
download = $(GET_ARCHIVE) $(DL_DIR)

# unpack archives into build directory
UNTAR = tar -C $(BUILD_DIR) -xf $(DL_DIR)
UNZIP = unzip -d $(BUILD_DIR) -o $(DL_DIR)

# for compatibility with "old" infrastructure
REMOVE = rm -rf $(BUILD_DIR)

# build helper variables
define TOOLFIND # (tool)
$(shell PATH=$(PATH) which $(1) || type -p $(1) || echo $(1))
endef

INSTALL = $(call TOOLFIND,install)
INSTALL_DATA = $(INSTALL) -m 0644
INSTALL_EXEC = $(INSTALL) -m 0755
INSTALL_COPY = cp -a

define INSTALL_EXIST # (source, dest)
	if [ -d $(dir $(1)) ]; then \
		$(INSTALL) -d $(2); \
		$(INSTALL_COPY) $(1) $(2); \
	fi
endef

PATCH = $(call TOOLFIND,patch) -p1 -i
PATCH0 = $(call TOOLFIND,patch) -p0 -i
SED = $(call TOOLFIND,sed) -i -e

CD = set -e; cd
CHDIR = $(CD) $(BUILD_DIR)
MKDIR = $(INSTALL) -d $(BUILD_DIR)

UPDATE-RC.D = support/scripts/update-rc.d -r $(TARGET_DIR)
REMOVE-RC.D = support/scripts/update-rc.d -f -r $(TARGET_DIR)
TARGET_RM = $(Q)support/scripts/target-remove.sh $(TARGET_DIR) $(REMOVE_DIR)
PYINSTALLER = $(BASE_DIR)/support/scripts/pyinstaller.py

AUTOCONF_VER = $(shell autoconf --version | head -1 | awk '{print $$4}')
AUTOCONF_VER_ge_270 = $(shell echo $(AUTOCONF_VER) \>= 2.70 | bc)

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

get-cc-version \
get-gcc-version:
	$(Q)$(TARGET_CC) --version

get-cpp-version:
	$(Q)$(TARGET_CPP) --version

get-cxx-version:
	$(Q)$(TARGET_CXX) --version

which-%:
	@TOOL=$$(which $(subst which-,,$(@))) \
		&& echo $$TOOL && $$TOOL --version | head -1

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
	@$(call draw_line);
	@$(call SUCCESS,"Build done for $(TARGET_BOX)")
	@$(call draw_line);

# -----------------------------------------------------------------------------

PHONY += changelogs
PHONY += done
