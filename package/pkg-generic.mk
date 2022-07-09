################################################################################
#
# Generic package infrastructure
#
################################################################################

TARGET_MAKE_ENV =

define TARGET_MAKE_BUILD_CMDS_DEFAULT
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$($(PKG)_MAKE) $($(PKG)_MAKE_ARGS)\
			$($(PKG)_MAKE_OPTS)
endef

define TARGET_MAKE_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define TARGET_MAKE_INSTALL_CMDS_DEFAULT
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_MAKE_INSTALL_ENV) \
		$($(PKG)_MAKE_INSTALL) $($(PKG)_MAKE_INSTALL_ARGS) DESTDIR=$(TARGET_DIR) \
			$($(PKG)_MAKE_INSTALL_OPTS)
endef

define TARGET_MAKE_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define generic-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call TARGET_MAKE_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call TARGET_MAKE_INSTALL))
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

HOST_MAKE_ENV =

define HOST_MAKE_BUILD_CMDS_DEFAULT
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$($(PKG)_MAKE) $($(PKG)_MAKE_ARGS)\
			$($(PKG)_MAKE_OPTS)
endef

define HOST_MAKE_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define HOST_MAKE_INSTALL_CMDS_DEFAULT
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_MAKE_ENV) $($(PKG)_MAKE_INSTALL_ENV) \
		$($(PKG)_MAKE_INSTALL) $($(PKG)_MAKE_INSTALL_ARGS) \
			$($(PKG)_MAKE_INSTALL_OPTS)
endef

define HOST_MAKE_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define host-generic-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call HOST_MAKE_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call HOST_MAKE_INSTALL))
	$(call HOST_FOLLOWUP)
endef
