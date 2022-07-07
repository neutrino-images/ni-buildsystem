################################################################################
#
# Generic packages
#
################################################################################

TARGET_MAKE_ENV =

define TARGET_MAKE_CMDS
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$($(PKG)_MAKE) $($(PKG)_MAKE_ARGS)\
			$($(PKG)_MAKE_OPTS)
endef

define TARGET_MAKE
	@$(call MESSAGE,"Building")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define TARGET_MAKE_INSTALL_CMDS
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_MAKE_INSTALL_ENV) \
		$($(PKG)_MAKE_INSTALL) $($(PKG)_MAKE_INSTALL_ARGS) DESTDIR=$(TARGET_DIR) \
			$($(PKG)_MAKE_INSTALL_OPTS)
endef

define TARGET_MAKE_INSTALL
	@$(call MESSAGE,"Installing")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_MAKE_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define generic-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call TARGET_MAKE))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call TARGET_MAKE_INSTALL))
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

HOST_MAKE_ENV =

define HOST_MAKE_CMDS
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$($(PKG)_MAKE) $($(PKG)_MAKE_ARGS)\
			$($(PKG)_MAKE_OPTS)
endef

define HOST_MAKE
	@$(call MESSAGE,"Compiling")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define HOST_MAKE_INSTALL_CMDS
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_MAKE_ENV) $($(PKG)_MAKE_INSTALL_ENV) \
		$($(PKG)_MAKE_INSTALL) $($(PKG)_MAKE_INSTALL_ARGS) \
			$($(PKG)_MAKE_INSTALL_OPTS)
endef

define HOST_MAKE_INSTALL
	@$(call MESSAGE,"Installing")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_MAKE_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define host-generic-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call HOST_MAKE))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call HOST_MAKE_INSTALL))
	$(call HOST_FOLLOWUP)
endef
