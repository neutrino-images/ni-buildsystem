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

PYTHON_SETUPTOOLS_CMD = \
	./setup.py

TARGET_PYTHON_SETUPTOOLS_BUILD_OPTS = \
	--executable=$(TARGET_PYTHON_INTERPRETER)

TARGET_PYTHON_SETUPTOOLS_INSTALL_OPTS = \
	--install-headers=$(TARGET_PYTHON_INCLUDE_DIR) \
	--executable=$(TARGET_PYTHON_INTERPRETER) \
	--root=$(TARGET_DIR) \
	--prefix=$(prefix) \
	--single-version-externally-managed

HOST_PYTHON_SETUPTOOLS_BUILD_OPTS =

HOST_PYTHON_SETUPTOOLS_INSTALL_OPTS = \
	--prefix=$(HOST_DIR) \
	--single-version-externally-managed

# -----------------------------------------------------------------------------

TARGET_PYTHON_ENV = \
	$(TARGET_CONFIGURE_ENV) \
	LDSHARED="$(TARGET_CC) -shared" \
	PYTHONPATH="$(TARGET_PYTHON_PATH)" \
	PYTHONNOUSERSITE=1

TARGET_PYTHON_ENV += \
	_python_sysroot=$(TARGET_DIR) \
	_python_prefix=$(prefix) \
	_python_exec_prefix=$(exec_prefix)

TARGET_PYTHON_OPTS = \
	$(if $(VERBOSE),,-q)

define TARGET_PYTHON_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_PYTHON_ENV) $($(PKG)_BUILD_ENV) \
		$(HOST_PYTHON_BINARY) $(PYTHON_SETUPTOOLS_CMD) build $(TARGET_PYTHON_SETUPTOOLS_BUILD_OPTS) \
			$(TARGET_PYTHON_OPTS) $($(PKG)_BUILD_OPTS)
endef

define TARGET_PYTHON_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define TARGET_PYTHON_INSTALL_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_PYTHON_ENV) $($(PKG)_INSTALL_ENV) \
		$(HOST_PYTHON_BINARY) $(PYTHON_SETUPTOOLS_CMD) install $(TARGET_PYTHON_SETUPTOOLS_INSTALL_OPTS) \
			$(TARGET_PYTHON_OPTS) $($(PKG)_INSTALL_OPTS)
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

HOST_PYTHON_ENV = \
	$(HOST_CONFIGURE_ENV) \
	LDSHARED="$(HOSTCC) -shared" \
	PYTHONPATH=$(HOST_PYTHON_PATH) \
	PYTHONNOUSERSITE=1

HOST_PYTHON_OPTS = \
	$(if $(VERBOSE),,-q)

define HOST_PYTHON_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(HOST_PYTHON_ENV) $($(PKG)_BUILD_ENV) \
		$(HOST_PYTHON_BINARY) $(PYTHON_SETUPTOOLS_CMD) build $(HOST_PYTHON_SETUPTOOLS_BUILD_OPTS)\
			$(HOST_PYTHON_OPTS) $($(PKG)_BUILD_OPTS)
endef

define HOST_PYTHON_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define HOST_PYTHON_INSTALL_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(HOST_PYTHON_ENV) $($(PKG)_INSTALL_ENV) \
		$(HOST_PYTHON_BINARY) $(PYTHON_SETUPTOOLS_CMD) install $(HOST_PYTHON_SETUPTOOLS_INSTALL_OPTS) \
			$(HOST_PYTHON_OPTS) $($(PKG)_INSTALL_OPTS)
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
