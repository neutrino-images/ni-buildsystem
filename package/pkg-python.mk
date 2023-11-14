################################################################################
#
# Python package infrastructure
#
################################################################################

TARGET_PYTHON_INTERPRETER = $(bindir)/python

TARGET_PYTHON_LIB_DIR = $(TARGET_libdir)/python$(PYTHON3_VERSION_MAJOR)
TARGET_PYTHON_INCLUDE_DIR = $(TARGET_includedir)/python$(PYTHON3_VERSION_MAJOR)
TARGET_PYTHON_SITE_PACKAGES_DIR = $(TARGET_PYTHON_LIB_DIR)/site-packages
TARGET_PYTHON_PATH = $(TARGET_PYTHON_LIB_DIR)

# ------------------------------------------------------------------------------

HOST_PYTHON_BINARY = $(HOST_DIR)/bin/python3

HOST_PYTHON_LIB_DIR = $(HOST_DIR)/lib/python$(PYTHON3_VERSION_MAJOR)
HOST_PYTHON_INCLUDE_DIR = $(HOST_DIR)/include/python$(PYTHON3_VERSION_MAJOR)
HOST_PYTHON_SITE_PACKAGES_DIR = $(HOST_PYTHON_LIB_DIR)/site-packages
HOST_PYTHON_PATH = $(HOST_PYTHON_LIB_DIR)

# -----------------------------------------------------------------------------

# Target python packages
TARGET_PKG_PYTHON_ENV = \
	$(TARGET_CONFIGURE_ENV) \
	LDSHARED="$(TARGET_CC) -shared" \
	PYTHONPATH="$(TARGET_PYTHON_PATH)" \
	PYTHONNOUSERSITE=1

TARGET_PKG_PYTHON_ENV += \
	_python_sysroot=$(TARGET_DIR) \
	_python_prefix=$(prefix) \
	_python_exec_prefix=$(exec_prefix)

# Host python packages
HOST_PKG_PYTHON_ENV = \
	$(HOST_CONFIGURE_ENV) \
	LDSHARED="$(HOSTCC) -shared" \
	PYTHONPATH=$(HOST_PYTHON_PATH) \
	PYTHONNOUSERSITE=1

# ------------------------------------------------------------------------------

# Target setuptools-based packages
TARGET_PKG_PYTHON_SETUPTOOLS_ENV = \
	$(TARGET_PKG_PYTHON_ENV)

TARGET_PKG_PYTHON_SETUPTOOLS_BUILD_OPTS = \
	$(if $(VERBOSE),,-q)

TARGET_PKG_PYTHON_SETUPTOOLS_INSTALL_OPTS = \
	$(if $(VERBOSE),,-q) \
	--install-headers=$(TARGET_PYTHON_INCLUDE_DIR) \
	--executable=$(TARGET_PYTHON_INTERPRETER) \
	--root=$(TARGET_DIR) \
	--prefix=$(prefix) \
	--single-version-externally-managed

# Host setuptools-based packages
HOST_PKG_PYTHON_SETUPTOOLS_ENV = \
	$(HOST_PKG_PYTHON_ENV)

HOST_PKG_PYTHON_SETUPTOOLS_BUILD_OPTS = \
	$(if $(VERBOSE),,-q)

HOST_PKG_PYTHON_SETUPTOOLS_INSTALL_OPTS = \
	$(if $(VERBOSE),,-q) \
	--prefix=$(HOST_DIR) \
	--root=/ \
	--single-version-externally-managed

# -----------------------------------------------------------------------------

# Target flit- and pep517-based packages
TARGET_PKG_PYTHON_PEP517_ENV = \
	$(TARGET_PKG_PYTHON_ENV)

TARGET_PKG_PYTHON_PEP517_BUILD_OPTS =

TARGET_PKG_PYTHON_PEP517_INSTALL_OPTS = \
	--interpreter=/usr/bin/python \
	--script-kind=posix \
	--purelib=$(TARGET_PYTHON_SITE_PACKAGES_DIR) \
	--headers=$(TARGET_PYTHON_INCLUDE_DIR) \
	--scripts=$(TARGET_bindir) \
	--data=$(TARGET_prefix)

# Host flit- and pep517-based packages
HOST_PKG_PYTHON_PEP517_ENV = \
	$(HOST_PKG_PYTHON_ENV)

HOST_PKG_PYTHON_PEP517_BUILD_OPTS =

HOST_PKG_PYTHON_PEP517_INSTALL_OPTS = \
	--interpreter=$(HOST_PYTHON_BINARY) \
	--script-kind=posix \
	--purelib=$(HOST_PYTHON_SITE_PACKAGES_DIR) \
	--headers=$(HOST_PYTHON_INCLUDE_DIR) \
	--scripts=$(HOST_DIR)/bin \
	--data=$(HOST_DIR)

HOST_PKG_PYTHON_PEP517_BOOTSTRAP_INSTALL_OPTS = \
	--installdir=$(HOST_PYTHON_SITE_PACKAGES_DIR)

# -----------------------------------------------------------------------------

define TARGET_PYTHON_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_PYTHON_BASE_ENV) $($(PKG)_BUILD_ENV) $($(PKG)_ENV) \
		$(HOST_PYTHON_BINARY) $($(PKG)_PYTHON_BASE_BUILD_CMD) \
			$($(PKG)_BUILD_OPTS)
endef

define TARGET_PYTHON_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define TARGET_PYTHON_INSTALL_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_PYTHON_BASE_ENV) $($(PKG)_INSTALL_ENV) $($(PKG)_ENV) \
		$(HOST_PYTHON_BINARY) $($(PKG)_PYTHON_BASE_INSTALL_CMD) \
			$($(PKG)_INSTALL_OPTS)
endef

define TARGET_PYTHON_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define python-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call TARGET_PYTHON_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call TARGET_PYTHON_INSTALL))
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

define HOST_PYTHON_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_PYTHON_BASE_ENV) $($(PKG)_BUILD_ENV) $($(PKG)_ENV) \
		$(HOST_PYTHON_BINARY) $($(PKG)_PYTHON_BASE_BUILD_CMD) \
			$($(PKG)_BUILD_OPTS)
endef

define HOST_PYTHON_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define HOST_PYTHON_INSTALL_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_PYTHON_BASE_ENV) $($(PKG)_INSTALL_ENV) $($(PKG)_ENV) \
		$(HOST_PYTHON_BINARY) $($(PKG)_PYTHON_BASE_INSTALL_CMD) \
			$($(PKG)_INSTALL_OPTS)
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
