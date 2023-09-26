################################################################################
#
# WAF package infrastructure - TARGET only
#
################################################################################

# The version of waflib has to match with the version of waf,
# otherwise waf errors out with:
# Waf script 'X' and library 'Y' do not match
define WAF_PACKAGE_REMOVE_WAF_LIB
	rm -rf $(PKG_BUILD_DIR)/waf $(PKG_BUILD_DIR)/waflib
endef

# -----------------------------------------------------------------------------

WAF_OPTS = $(if $(VERBOSE),-v) -j $(PARALLEL_JOBS)

WAF_CONFIGURE_OPTS = \
	--target=$(GNU_TARGET_NAME) \
	\
	--prefix=$(prefix) \
	--libdir=$(libdir) \
	\
	--mandir=$(REMOVE_mandir)

define WAF_CONFIGURE_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_CONFIGURE_ENV) $($(PKG)_CONF_ENV) \
		$(HOST_PYTHON3_BINARY) $($(PKG)_WAF) \
			configure $(WAF_CONFIGURE_OPTS) \
			$($(PKG)_CONF_OPTS) \
			$($(PKG)_WAF_OPTS)
endef

define WAF_CONFIGURE
	@$(call MESSAGE,"Configuring $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call WAF_CONFIGURE_CMDS_DEFAULT)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

define WAF_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$(HOST_PYTHON3_BINARY) $($(PKG)_WAF) \
			build $(WAF_OPTS) \
			$($(PKG)_BUILD_OPTS) \
			$($(PKG)_WAF_OPTS)
endef

define WAF_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define WAF_INSTALL_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$(HOST_PYTHON3_BINARY) $($(PKG)_WAF) \
			install --destdir=$(TARGET_DIR) \
			$($(PKG)_INSTALL_OPTS) \
			$($(PKG)_WAF_OPTS)
endef

define WAF_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define waf-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_CONFIGURE)),,$(call WAF_CONFIGURE))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call WAF_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call WAF_INSTALL))
	$(call TARGET_FOLLOWUP)
endef
