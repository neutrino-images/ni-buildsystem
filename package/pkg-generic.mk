################################################################################
#
# Generic packages
#
################################################################################

TARGET_MAKE_ENV =

define TARGET_MAKE
	@$(call MESSAGE,"Compiling")
	$(foreach hook,$($(PKG)_PRE_COMPILE_HOOKS),$(call $(hook))$(sep))
	$(Q)( \
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$(MAKE) \
			$($(PKG)_MAKE_OPTS); \
	)
	$(foreach hook,$($(PKG)_POST_COMPILE_HOOKS),$(call $(hook))$(sep))
endef

define TARGET_MAKE_INSTALL
	@$(call MESSAGE,"Installing")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)( \
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$(MAKE) install DESTDIR=$(TARGET_DIR) \
			$($(PKG)_MAKE_OPTS); \
	)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define generic-package
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call TARGET_MAKE))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call TARGET_MAKE_INSTALL))
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

HOST_MAKE_ENV =

define HOST_MAKE
	@$(call MESSAGE,"Compiling")
	$(foreach hook,$($(PKG)_PRE_COMPILE_HOOKS),$(call $(hook))$(sep))
	$(Q)( \
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$(MAKE) \
			$($(PKG)_MAKE_OPTS); \
	)
	$(foreach hook,$($(PKG)_POST_COMPILE_HOOKS),$(call $(hook))$(sep))
endef

define HOST_MAKE_INSTALL
	@$(call MESSAGE,"Installing")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)( \
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$(MAKE) install \
			$($(PKG)_MAKE_OPTS); \
	)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define host-generic-package
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call HOST_MAKE))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call HOST_MAKE_INSTALL))
	$(call HOST_FOLLOWUP)
endef
