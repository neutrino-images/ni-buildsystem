################################################################################
#
# Luke package infrastructure - TARGET only
#
################################################################################

define LUKE_CONFIGURE
	@$(call MESSAGE,"Configuring $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_CONFIGURE_CMDS)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

define LUKE_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_BUILD_ENV) $($(PKG)_ENV) \
		$(HOST_LUA_BINARY) build-aux/luke \
			$($(PKG)_BUILD_OPTS)
endef

define LUKE_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define LUKE_INSTALL_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_INSTALL_ENV) $($(PKG)_ENV) \
		$(HOST_LUA_BINARY) build-aux/luke install \
			$($(PKG)_INSTALL_OPTS)
endef

define LUKE_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define luke-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $($(PKG)_CONFIGURE_CMDS),$(call LUKE_CONFIGURE))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call LUKE_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call LUKE_INSTALL))
	$(call TARGET_FOLLOWUP)
endef
