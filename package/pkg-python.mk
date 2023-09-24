################################################################################
#
# Python package infrastructure
#
################################################################################

TARGET_PYTHON_ENV = \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	LDSHARED="$(TARGET_CC) -shared" \
	PYTHONPATH=$(PYTHON_SITE_PACKAGES_DIR)

TARGET_PYTHON_OPTS = \
	$(if $(VERBOSE),,-q)

define TARGET_PYTHON_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_PYTHON_ENV) \
		CPPFLAGS="$(TARGET_CPPFLAGS) -I$(PYTHON_INCLUDE_DIR)" \
		$(HOST_PYTHON_BINARY) ./setup.py build --executable=/usr/bin/python \
			$(TARGET_PYTHON_OPTS)
endef

define TARGET_PYTHON_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define TARGET_PYTHON_INSTALL_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_PYTHON_ENV) \
		CPPFLAGS="$(TARGET_CPPFLAGS) -I$(PYTHON_INCLUDE_DIR)" \
		$(HOST_PYTHON_BINARY) ./setup.py install --root=$(TARGET_DIR) --prefix=/usr \
			$(TARGET_PYTHON_OPTS)
endef

define PYTHON_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define python-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call PYTHON_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call PYTHON_INSTALL))
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

HOST_PYTHON_ENV = \
	CC="$(HOSTCC)" \
	CFLAGS="$(HOST_CFLAGS)" \
	LDFLAGS="$(HOST_LDFLAGS)" \
	LDSHARED="$(HOSTCC) -shared" \
	PYTHONPATH=$(HOST_PYTHON_SITE_PACKAGES_DIR)

HOST_PYTHON_OPTS = \
	$(if $(VERBOSE),,-q)

define HOST_PYTHON_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(HOST_PYTHON_ENV) \
		$(HOST_PYTHON_BINARY) ./setup.py build \
			$(HOST_PYTHON_OPTS)
endef

define HOST_PYTHON_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define HOST_PYTHON_INSTALL_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(HOST_PYTHON_ENV) \
		$(HOST_PYTHON_BINARY) ./setup.py install --prefix=$(HOST_DIR) \
			$(HOST_PYTHON_OPTS)
endef

define HOST_PYTHON_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define host-python-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call HOST_PYTHON_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call HOST_PYTHON_INSTALL))
	$(call HOST_FOLLOWUP)
endef
