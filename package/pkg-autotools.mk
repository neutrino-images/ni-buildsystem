################################################################################
#
# Autotools package infrastructure
#
################################################################################

define AUTORECONF_HOOK
	if [ "$($(PKG)_AUTORECONF)" == "YES" ]; then \
		$(call MESSAGE,"Autoreconfiguring $(pkgname)"); \
		$(CD) $($(PKG)_BUILD_DIR); \
			$($(PKG)_AUTORECONF_ENV) \
			$($(PKG)_AUTORECONF_CMD) \
				$($(PKG)_AUTORECONF_OPTS); \
	fi
endef

# -----------------------------------------------------------------------------

TARGET_CONFIGURE_ENVIRONMENT = \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	CC="$(TARGET_CC)" \
	GCC="$(TARGET_CC)" \
	CPP="$(TARGET_CPP)" \
	CXX="$(TARGET_CXX)" \
	LD="$(TARGET_LD)" \
	AR="$(TARGET_AR)" \
	AS="$(TARGET_AS)" \
	NM="$(TARGET_NM)" \
	OBJCOPY="$(TARGET_OBJCOPY)" \
	OBJDUMP="$(TARGET_OBJDUMP)" \
	RANLIB="$(TARGET_RANLIB)" \
	READELF="$(TARGET_READELF)" \
	STRIP="$(TARGET_STRIP)" \
	ARCH=$(TARGET_ARCH)

TARGET_CONFIGURE_ENV += \
	$(TARGET_CONFIGURE_ENVIRONMENT) \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"

TARGET_CONFIGURE_ENV += \
	PKG_CONFIG=$(PKG_CONFIG) \
	PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" \
	PKG_CONFIG_SYSROOT_DIR=$(PKG_CONFIG_SYSROOT_DIR)

TARGET_CONFIGURE_ARGS = \
	ac_cv_func_mmap_fixed_mapped=yes \
	ac_cv_func_memcmp_working=yes \
	ac_cv_have_decl_malloc=yes \
	gl_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_calloc_0_nonnull=yes \
	ac_cv_func_realloc_0_nonnull=yes \
	lt_cv_sys_lib_search_path_spec=""

TARGET_CONFIGURE_OPTS = \
	--build=$(GNU_HOST_NAME) \
	--host=$(GNU_TARGET_NAME) \
	--target=$(GNU_TARGET_NAME) \
	\
	--program-prefix="" \
	--program-suffix="" \
	\
	--prefix=$(prefix) \
	--exec_prefix=$(exec_prefix) \
	--sysconfdir=$(sysconfdir) \
	--localstatedir=$(localstatedir) \
	\
	--mandir=$(REMOVE_mandir) \
	--infodir=$(REMOVE_infodir)

define TARGET_CONFIGURE_CMDS_DEFAULT
	$(CD) $($(PKG)_BUILD_DIR); \
		test -f ./$($(PKG)_CONFIGURE_CMD) || ./autogen.sh && \
		CONFIG_SITE=/dev/null \
		$(TARGET_CONFIGURE_ARGS) \
		$(TARGET_CONFIGURE_ENV) $($(PKG)_CONF_ENV) \
		./$($(PKG)_CONFIGURE_CMD) \
			$(TARGET_CONFIGURE_OPTS) $($(PKG)_CONF_OPTS)
endef

define TARGET_CONFIGURE
	@$(call MESSAGE,"Configuring $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call AUTORECONF_HOOK)
	$(Q)$(call $(PKG)_CONFIGURE_CMDS)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define autotools-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(call TARGET_CONFIGURE)
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call TARGET_MAKE_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call TARGET_MAKE_INSTALL))
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

HOST_CONFIGURE_ENVIRONMENT = \
	CC="$(HOSTCC)" \
	GCC="$(HOSTCC)" \
	CPP="$(HOSTCPP)" \
	CXX="$(HOSTCXX)" \
	LD="$(HOSTLD)" \
	AR="$(HOSTAR)" \
	AS="$(HOSTAS)" \
	NM="$(HOSTNM)" \
	OBJCOPY="$(HOSTOBJCOPY)" \
	RANLIB="$(HOSTRANLIB)"

HOST_CONFIGURE_ENV = \
	$(HOST_CONFIGURE_ENVIRONMENT) \
	CFLAGS="$(HOST_CFLAGS)" \
	CPPFLAGS="$(HOST_CPPFLAGS)" \
	CXXFLAGS="$(HOST_CXXFLAGS)" \
	LDFLAGS="$(HOST_LDFLAGS)"

HOST_CONFIGURE_ENV += \
	PKG_CONFIG=/usr/bin/pkg-config \
	PKG_CONFIG_LIBDIR="$(HOST_DIR)/lib/pkgconfig"

HOST_CONFIGURE_OPTS = \
	--prefix=$(HOST_DIR) \
	--sysconfdir=$(HOST_DIR)/etc

define HOST_CONFIGURE_CMDS_DEFAULT
	$(CD) $($(PKG)_BUILD_DIR); \
		test -f ./$($(PKG)_CONFIGURE_CMD) || ./autogen.sh && \
		CONFIG_SITE=/dev/null \
		$(HOST_CONFIGURE_ENV) $($(PKG)_CONF_ENV) \
		./$($(PKG)_CONFIGURE_CMD) \
			$(HOST_CONFIGURE_OPTS) $($(PKG)_CONF_OPTS)
endef

define HOST_CONFIGURE
	@$(call MESSAGE,"Configuring $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call AUTORECONF_HOOK)
	$(Q)$(call $(PKG)_CONFIGURE_CMDS)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define host-autotools-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(call HOST_CONFIGURE)
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call HOST_MAKE_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call HOST_MAKE_INSTALL))
	$(call HOST_FOLLOWUP)
endef
