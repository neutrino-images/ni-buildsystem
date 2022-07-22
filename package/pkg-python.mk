################################################################################
#
# Python package infrastructure
#
################################################################################

HOST_PYTHON3_ENV = \
	CC="$(HOSTCC)" \
	CFLAGS="$(HOST_CFLAGS)" \
	LDFLAGS="$(HOST_LDFLAGS)" \
	LDSHARED="$(HOSTCC) -shared" \
	PYTHONPATH=$(HOST_DIR)/$(HOST_PYTHON3_SITEPACKAGES_DIR)

HOST_PYTHON3_OPTS = \
	$(if $(VERBOSE),,-q)

define HOST_PYTHON3_BUILD_CMDS_DEFAULT
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_PYTHON3_ENV) \
		$(HOST_PYTHON3_BINARY) ./setup.py build --executable=/usr/bin/python \
			$(HOST_PYTHON3_OPTS)
endef

define HOST_PYTHON3_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define HOST_PYTHON3_INSTALL_CMDS_DEFAULT
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_PYTHON3_ENV) \
		$(HOST_PYTHON3_BINARY) ./setup.py install --root=$(HOST_DIR) --prefix= \
			$(HOST_PYTHON3_OPTS)
endef

define HOST_PYTHON3_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define host-python3-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call HOST_PYTHON3_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call HOST_PYTHON3_INSTALL))
	$(call HOST_FOLLOWUP)
endef
