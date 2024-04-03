################################################################################
#
# Meson package infrastructure
#
################################################################################

define MESON_CROSS_COMPILATION_CONF_HOOK # (dest dir)
	$(INSTALL) -d $(1)
	$(Q)( \
		echo "# Note: Buildsystems's and Meson's terminologies differ about the meaning"; \
		echo "# of 'build', 'host' and 'target':"; \
		echo "# - Buildsystems's 'host' is Meson's 'build'"; \
		echo "# - Buildsystems's 'target' is Meson's 'host'"; \
		echo ""; \
		echo "[binaries]"; \
		echo "c = '$(TARGET_CC)'"; \
		echo "cpp = '$(TARGET_CXX)'"; \
		echo "ar = '$(TARGET_AR)'"; \
		echo "strip = '$(TARGET_STRIP)'"; \
		echo "nm = '$(TARGET_NM)'"; \
		echo "cmake = '$(HOST_CMAKE_BINARY)'"; \
		echo "pkgconfig = '$(PKG_CONFIG)'"; \
		echo ""; \
		echo "[built-in options]"; \
		echo "c_args = '$(TARGET_CFLAGS)'"; \
		echo "c_link_args = '$(TARGET_LDFLAGS)'"; \
		echo "cpp_args = '$(TARGET_CXXFLAGS)'"; \
		echo "cpp_link_args = '$(TARGET_LDFLAGS)'"; \
		echo "prefix = '$(prefix)'"; \
		echo "cmake_prefix_path = '$(TARGET_libdir)/cmake'"; \
		echo ""; \
		echo "[properties]"; \
		echo "needs_exe_wrapper = true"; \
		echo "sys_root = '$(TARGET_DIR)'"; \
		echo "pkg_config_libdir = '$(PKG_CONFIG_PATH)'"; \
		echo "cmake_defaults = true"; \
		echo ""; \
		echo "[host_machine]"; \
		echo "system = 'linux'"; \
		echo "cpu_family = '$(TARGET_ARCH)'"; \
		echo "cpu = '$(TARGET_CPU)'"; \
		echo "endian = '$(TARGET_ENDIAN)'" \
	) > $(1)/cross-compilation.conf
endef

MESON_PKG_BUILD_DIR = $(PKG_BUILD_DIR)/build

# -----------------------------------------------------------------------------

# Pass PYTHONNOUSERSITE environment variable when invoking Meson or Ninja,
# so $(HOST_DIR)/bin/python3 will not look for Meson modules in
# $HOME/.local/lib/python3.x/site-packages
#
HOST_MESON_CMD = PYTHONNOUSERSITE=y $(HOST_MESON_BINARY)
HOST_NINJA_CMD = PYTHONNOUSERSITE=y $(HOST_NINJA_BINARY) $(if $(VERBOSE),-v)

# -----------------------------------------------------------------------------

define TARGET_MESON_CMDS_DEFAULT
	unset CC CXX CPP LD AR NM STRIP; \
	$(CD) $(PKG_BUILD_DIR); \
		PATH=$(PATH) \
		$($(PKG)_CONF_ENV) \
		$(HOST_MESON_CMD) setup \
			--prefix=$(prefix) \
			--buildtype=release \
			--cross-file=$(MESON_PKG_BUILD_DIR)/cross-compilation.conf \
			-Db_pie=false \
			-Dstrip=false \
			$($(PKG)_CONF_OPTS) \
			$(PKG_BUILD_DIR) $(MESON_PKG_BUILD_DIR)
endef

define TARGET_MESON_CONFIGURE
	@$(call MESSAGE,"Configuring $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call MESON_CROSS_COMPILATION_CONF_HOOK,$(MESON_PKG_BUILD_DIR))
	$(Q)$(call $(PKG)_CONFIGURE_CMDS)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

define TARGET_NINJA_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_NINJA_ENV) \
		$(HOST_NINJA_CMD) -C $(MESON_PKG_BUILD_DIR) \
			$($(PKG)_NINJA_OPTS)
endef

define TARGET_NINJA_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define TARGET_NINJA_INSTALL_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_NINJA_ENV) \
		DESTDIR=$(TARGET_DIR) \
		$(HOST_NINJA_CMD) -C $(MESON_PKG_BUILD_DIR) install
endef

define TARGET_NINJA_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define meson-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_CONFIGURE)),,$(call TARGET_MESON_CONFIGURE))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call TARGET_NINJA_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call TARGET_NINJA_INSTALL))
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

define HOST_MESON_CMDS_DEFAULT
	unset CC CXX CPP LD AR NM STRIP; \
	PKG_CONFIG=/usr/bin/pkg-config \
	PKG_CONFIG_PATH=$(HOST_DIR)/lib/pkgconfig \
	$(CD) $(PKG_BUILD_DIR); \
		PATH=$(PATH) \
		$($(PKG)_CONF_ENV) \
		$(HOST_MESON_CMD) setup \
			--prefix=$(HOST_DIR) \
			--default-library=shared \
			--buildtype=release \
			--wrap-mode=nodownload \
			$($(PKG)_CONF_OPTS) \
			$(PKG_BUILD_DIR) $(MESON_PKG_BUILD_DIR)
endef

define HOST_MESON_CONFIGURE
	@$(call MESSAGE,"Configuring $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_CONFIGURE_CMDS)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

define HOST_NINJA_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(HOST_MAKE_ENV) $($(PKG)_NINJA_ENV) \
		$(HOST_NINJA_CMD) -C $(MESON_PKG_BUILD_DIR) \
			$($(PKG)_NINJA_OPTS)
endef

define HOST_NINJA_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define HOST_NINJA_INSTALL_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(HOST_MAKE_ENV) $($(PKG)_NINJA_ENV) \
		$(HOST_NINJA_CMD) -C $(MESON_PKG_BUILD_DIR) install
endef

define HOST_NINJA_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define host-meson-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_CONFIGURE)),,$(call HOST_MESON_CONFIGURE))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call HOST_NINJA_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call HOST_NINJA_INSTALL))
	$(call HOST_FOLLOWUP)
endef
