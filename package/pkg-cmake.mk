################################################################################
#
# CMake package infrastructure
#
################################################################################

TARGET_CMAKE_CONF_ENV =

TARGET_CMAKE_CONF_OPTS = \
	--no-warn-unused-cli

TARGET_CMAKE_CONF_OPTS += \
	-G$($(PKG)_GENERATOR) \
	-DCMAKE_MAKE_PROGRAM="$($(PKG)_GENERATOR_PROGRAM)" \
	-DENABLE_SHARED=ON \
	-DENABLE_STATIC=OFF \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_DOC=OFF \
	-DBUILD_DOCS=OFF \
	-DBUILD_EXAMPLE=OFF \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_TEST=OFF \
	-DBUILD_TESTS=OFF \
	-DBUILD_TESTING=OFF \
	-DCMAKE_COLOR_MAKEFILE=OFF \
	-DCMAKE_BUILD_TYPE="Release" \
	-DCMAKE_SYSTEM_NAME="Linux" \
	-DCMAKE_SYSTEM_PROCESSOR="$(TARGET_ARCH)" \
	-DCMAKE_INSTALL_PREFIX="$(prefix)" \
	-DCMAKE_INSTALL_DOCDIR="$(REMOVE_docdir)" \
	-DCMAKE_INSTALL_MANDIR="$(REMOVE_mandir)" \
	-DCMAKE_PREFIX_PATH="$(TARGET_DIR)" \
	-DCMAKE_LIBRARY_PATH="$(TARGET_libdir)" \
	-DCMAKE_INCLUDE_PATH="$(TARGET_includedir)" \
	-DCMAKE_C_COMPILER="$(TARGET_CC)" \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) -DNDEBUG" \
	-DCMAKE_CPP_COMPILER="$(TARGET_CPP)" \
	-DCMAKE_CPP_FLAGS="$(TARGET_CFLAGS) -DNDEBUG" \
	-DCMAKE_CXX_COMPILER="$(TARGET_CXX)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CFLAGS) -DNDEBUG" \
	-DCMAKE_LINKER="$(TARGET_LD)" \
	-DCMAKE_AR="$(TARGET_AR)" \
	-DCMAKE_AS="$(TARGET_AS)" \
	-DCMAKE_NM="$(TARGET_NM)" \
	-DCMAKE_OBJCOPY="$(TARGET_OBJCOPY)" \
	-DCMAKE_OBJDUMP="$(TARGET_OBJDUMP)" \
	-DCMAKE_RANLIB="$(TARGET_RANLIB)" \
	-DCMAKE_READELF="$(TARGET_READELF)" \
	-DCMAKE_STRIP="$(TARGET_STRIP)"

TARGET_CMAKE_CONF_OPTS += \
	$(if $(VERBOSE),,-DCMAKE_RULE_MESSAGES=OFF -DCMAKE_INSTALL_MESSAGE=NEVER) \

ifeq ($$($(PKG)_SUPPORTS_IN_SOURCE_BUILD),YES)
CMAKE_PKG_BUILD_DIR = $(PKG_BUILD_DIR)
else
CMAKE_PKG_BUILD_DIR = $(PKG_BUILD_DIR)/build
endif

define TARGET_CMAKE_CONFIGURE_CMDS_DEFAULT
	$(INSTALL) -d $(CMAKE_PKG_BUILD_DIR)
	$(CD) $(CMAKE_PKG_BUILD_DIR); \
		rm -f CMakeCache.txt; \
		$(TARGET_CMAKE_CONF_ENV) $($(PKG)_CONF_ENV) \
		$(HOST_CMAKE_BINARY) $(PKG_BUILD_DIR) \
			$(TARGET_CMAKE_CONF_OPTS) $($(PKG)_CONF_OPTS)
endef

define TARGET_CMAKE_CONFIGURE
	@$(call MESSAGE,"Configuring $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_CONFIGURE_CMDS)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

define TARGET_CMAKE_BUILD_CMDS_DEFAULT
	$(TARGET_MAKE_ENV) $($(PKG)_BUILD_ENV) \
	$(HOST_CMAKE_BINARY) --build $(CMAKE_PKG_BUILD_DIR) -j$(PARALLEL_JOBS) \
		$($(PKG)_BUILD_OPTS)
endef

define TARGET_CMAKE_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define TARGET_CMAKE_INSTALL_CMDS_DEFAULT
	$(TARGET_MAKE_ENV) $($(PKG)_INSTALL_ENV) \
	DESTDIR=$(TARGET_DIR) \
	$(HOST_CMAKE_BINARY) --install $(CMAKE_PKG_BUILD_DIR) \
		$($(PKG)_INSTALL_OPTS)
endef

define TARGET_CMAKE_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define cmake-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_CONFIGURE)),,$(call TARGET_CMAKE_CONFIGURE))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call TARGET_CMAKE_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call TARGET_CMAKE_INSTALL))
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

HOST_CMAKE_CONF_ENV =

HOST_CMAKE_CONF_OPTS += \
	--no-warn-unused-cli

HOST_CMAKE_CONF_OPTS += \
	-G$($(PKG)_GENERATOR) \
	-DCMAKE_MAKE_PROGRAM="$($(PKG)_GENERATOR_PROGRAM)" \
	-DENABLE_STATIC=OFF \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_DOC=OFF \
	-DBUILD_DOCS=OFF \
	-DBUILD_EXAMPLE=OFF \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_TEST=OFF \
	-DBUILD_TESTS=OFF \
	-DBUILD_TESTING=OFF \
	-DCMAKE_COLOR_MAKEFILE=OFF \
	-DCMAKE_INSTALL_PREFIX="$(HOST_DIR)" \
	-DCMAKE_PREFIX_PATH="$(HOST_DIR)"

define HOST_CMAKE_CONFIGURE_CMDS_DEFAULT
	$(INSTALL) -d $(CMAKE_PKG_BUILD_DIR)
	$(CD) $(CMAKE_PKG_BUILD_DIR); \
		rm -f CMakeCache.txt; \
		$(HOST_CMAKE_CONF_ENV) $($(PKG)_CONF_ENV) \
		$(HOST_CMAKE_BINARY) $(PKG_BUILD_DIR) \
			$(HOST_CMAKE_CONF_OPTS) $($(PKG)_CONF_OPTS)
endef

define HOST_CMAKE_CONFIGURE
	@$(call MESSAGE,"Configuring $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_CONFIGURE_CMDS)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

define HOST_CMAKE_BUILD_CMDS_DEFAULT
	$(HOST_MAKE_ENV) $($(PKG)_BUILD_ENV) \
	$(HOST_CMAKE_BINARY) --build $(CMAKE_PKG_BUILD_DIR) -j$(PARALLEL_JOBS) \
		$($(PKG)_BUILD_OPTS)
endef

define HOST_CMAKE_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define HOST_CMAKE_INSTALL_CMDS_DEFAULT
	$(HOST_MAKE_ENV) $($(PKG)_INSTALL_ENV) \
	$(HOST_CMAKE_BINARY) --install $(CMAKE_PKG_BUILD_DIR) \
		$($(PKG)_INSTALL_OPTS)
endef

define HOST_CMAKE_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define host-cmake-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_CONFIGURE)),,$(call HOST_CMAKE_CONFIGURE))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call HOST_CMAKE_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call HOST_CMAKE_INSTALL))
	$(call HOST_FOLLOWUP)
endef
