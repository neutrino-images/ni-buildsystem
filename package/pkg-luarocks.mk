################################################################################
#
# LuaRocks package infrastructure
#
################################################################################

TARGET_LUAROCKS_CFLAGS = $(TARGET_CFLAGS) -fPIC

define TARGET_LUAROCKS_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_BUILD_ENV) $($(PKG)_ENV) \
		LUAROCKS_CONFIG=$(HOST_LUAROCKS_CONFIG_TARGET) \
		$(HOST_LUAROCKS_BINARY) make \
			--keep \
			--deps-mode none \
			--tree "$(TARGET_prefix)" \
			DEPS_DIR="$(TARGET_prefix)" \
			LUA_INCDIR="$(TARGET_includedir)" \
			LUA_LIBDIR="$(TARGET_libdir)" \
			CC=$(TARGET_CC) \
			LD=$(TARGET_CC) \
			CFLAGS="$(TARGET_LUAROCKS_CFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			LIBFLAG="-shared $(TARGET_LDFLAGS)" \
			$($(PKG)_BUILD_OPTS) $($(PKG)_ROCKSPEC)
endef

define TARGET_LUAROCKS_BUILD
	@$(call MESSAGE,"Building and/or installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define luarocks-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call TARGET_LUAROCKS_BUILD))
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

HOST_LUAROCKS_CFLAGS = $(HOST_CFLAGS) -fPIC

define HOST_LUAROCKS_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_BUILD_ENV) $($(PKG)_ENV) \
		LUAROCKS_CONFIG=$(HOST_LUAROCKS_CONFIG_HOST) \
		$(HOST_LUAROCKS_BINARY) make \
			--keep \
			--deps-mode none \
			DEPS_DIR="$(HOST_DIR)" \
			CFLAGS="$(HOST_LUAROCKS_CFLAGS)" \
			LDFLAGS="$(HOST_LDFLAGS)" \
			LIBFLAG="-shared $(HOST_LDFLAGS)" \
			$($(PKG)_BUILD_OPTS) $($(PKG)_ROCKSPEC)
endef

define HOST_LUAROCKS_BUILD
	@$(call MESSAGE,"Building and/or installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define host-luarocks-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call HOST_LUAROCKS_BUILD))
	$(call HOST_FOLLOWUP)
endef
