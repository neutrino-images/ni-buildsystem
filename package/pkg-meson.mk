################################################################################
#
# Meson packages
#
################################################################################

define MESON_CROSS_CONFIG_HOOK # (dest dir)
	$(INSTALL) -d $(1)
	( \
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
		echo "pkgconfig = '$(PKG_CONFIG)'"; \
		echo ""; \
		echo "[built-in options]"; \
		echo "c_args = '$(TARGET_CFLAGS)'"; \
		echo "c_link_args = '$(TARGET_LDFLAGS)'"; \
		echo "cpp_args = '$(TARGET_CXXFLAGS)'"; \
		echo "cpp_link_args = '$(TARGET_LDFLAGS)'"; \
		echo "prefix = '$(prefix)'"; \
		echo ""; \
		echo "[properties]"; \
		echo "needs_exe_wrapper = true"; \
		echo "sys_root = '$(TARGET_DIR)'"; \
		echo "pkg_config_libdir = '$(PKG_CONFIG_LIBDIR)'"; \
		echo ""; \
		echo "[host_machine]"; \
		echo "system = 'linux'"; \
		echo "cpu_family = '$(TARGET_ARCH)'"; \
		echo "cpu = '$(TARGET_CPU)'"; \
		echo "endian = '$(TARGET_ENDIAN)'" \
	) > $(1)/meson-cross.config
endef

# -----------------------------------------------------------------------------

define TARGET_MESON_CONFIGURE
	@$(call MESSAGE,"Configuring")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(call MESON_CROSS_CONFIG_HOOK,$(PKG_BUILD_DIR)/build)
	$(Q)( \
	unset CC CXX CPP LD AR NM STRIP; \
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$($(PKG)_CONF_ENV) \
		$(HOST_MESON_BINARY) \
			--buildtype=release \
			--cross-file=$(PKG_BUILD_DIR)/build/meson-cross.config \
			-Db_pie=false \
			-Dstrip=false \
			$($(PKG)_CONF_OPTS) \
			$(PKG_BUILD_DIR) $(PKG_BUILD_DIR)/build; \
	)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

define TARGET_NINJA_BUILD
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_NINJA_ENV) \
		$(HOST_NINJA_BINARY) -C $(PKG_BUILD_DIR)/build \
			$($(PKG)_NINJA_OPTS)
endef

define TARGET_NINJA_INSTALL
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_NINJA_ENV) \
		$(HOST_NINJA_BINARY) -C $(PKG_BUILD_DIR)/build install DESTDIR=$(TARGET_DIR) \
			$($(PKG)_NINJA_OPTS)
endef

# -----------------------------------------------------------------------------

define meson-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(call TARGET_MESON_CONFIGURE)
	$(call TARGET_NINJA_BUILD)
	$(call TARGET_NINJA_INSTALL)
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

define HOST_MESON_CONFIGURE
	@$(call MESSAGE,"Configuring")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(Q)( \
	unset CC CXX CPP LD AR NM STRIP; \
	PKG_CONFIG=/usr/bin/pkg-config \
	PKG_CONFIG_PATH=$(HOST_DIR)/lib/pkgconfig \
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$($(PKG)_CONF_ENV) \
		$(HOST_MESON_BINARY) \
			--prefix=$(HOST_DIR) \
			--buildtype=release \
			$($(PKG)_CONF_OPTS) \
			$(PKG_BUILD_DIR) $(PKG_BUILD_DIR)/build; \
	)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

define HOST_NINJA_BUILD
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_MAKE_ENV) $($(PKG)_NINJA_ENV) \
		$(HOST_NINJA_BINARY) -C $(PKG_BUILD_DIR)/build \
			$($(PKG)_NINJA_OPTS)
endef

define HOST_NINJA_INSTALL
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_MAKE_ENV) $($(PKG)_NINJA_ENV) \
		$(HOST_NINJA_BINARY) -C $(PKG_BUILD_DIR)/build install \
			$($(PKG)_NINJA_OPTS)
endef

# -----------------------------------------------------------------------------

define host-meson-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(call HOST_MESON_CONFIGURE)
	$(call HOST_NINJA)
	$(call HOST_NINJA_INSTALL)
	$(call HOST_FOLLOWUP)
endef
