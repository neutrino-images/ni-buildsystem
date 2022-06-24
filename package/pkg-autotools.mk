################################################################################
#
# Autotools packages
#
################################################################################

define AUTORECONF_HOOK
	$(Q)( \
	if [ "$($(PKG)_AUTORECONF)" == "YES" ]; then \
		$(call MESSAGE,"Autoreconfiguring"); \
		$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
			$($(PKG)_AUTORECONF_ENV) autoreconf -fi $($(PKG)_AUTORECONF_OPTS); \
	fi; \
	)
endef

# -----------------------------------------------------------------------------

TARGET_CONFIGURE_ENV = \
	$(TARGET_MAKE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"

TARGET_CONFIGURE_ENV += \
	PKG_CONFIG=$(PKG_CONFIG) \
	PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" \
	PKG_CONFIG_SYSROOT_DIR=$(PKG_CONFIG_SYSROOT_DIR)

TARGET_CONFIGURE_ENV += \
	$($(PKG)_CONF_ENV)

TARGET_CONFIGURE_OPTS = \
	--build=$(GNU_HOST_NAME) \
	--host=$(TARGET) \
	--target=$(TARGET) \
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

TARGET_CONFIGURE_OPTS += \
	$($(PKG)_CONF_OPTS)

define TARGET_CONFIGURE
	@$(call MESSAGE,"Configuring")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(call AUTORECONF_HOOK)
	$(Q)( \
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		test -f ./configure || ./autogen.sh && \
		CONFIG_SITE=/dev/null \
		$(TARGET_CONFIGURE_ENV) ./configure $(TARGET_CONFIGURE_OPTS); \
	)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define autotools-package
	$(call PREPARE)
	$(call TARGET_CONFIGURE)
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

HOST_CONFIGURE_ENV = \
	$(HOST_MAKE_OPTS) \
	CFLAGS="$(HOST_CFLAGS)" \
	CPPFLAGS="$(HOST_CPPFLAGS)" \
	CXXFLAGS="$(HOST_CXXFLAGS)" \
	LDFLAGS="$(HOST_LDFLAGS)"

HOST_CONFIGURE_ENV += \
	PKG_CONFIG=/usr/bin/pkg-config \
	PKG_CONFIG_LIBDIR="$(HOST_DIR)/lib/pkgconfig"

HOST_CONFIGURE_ENV += \
	$($(PKG)_CONF_ENV)

HOST_CONFIGURE_OPTS = \
	--prefix=$(HOST_DIR) \
	--sysconfdir=$(HOST_DIR)/etc

HOST_CONFIGURE_OPTS += \
	$($(PKG)_CONF_OPTS)

define HOST_CONFIGURE
	@$(call MESSAGE,"Configuring")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(call AUTORECONF_HOOK)
	$(Q)( \
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		test -f ./configure || ./autogen.sh && \
		CONFIG_SITE=/dev/null \
		$(HOST_CONFIGURE_ENV) ./configure $(HOST_CONFIGURE_OPTS); \
	)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define host-autotools-package
	$(call PREPARE)
	$(call HOST_CONFIGURE)
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(MAKE); \
		$(MAKE) install
	$(call HOST_FOLLOWUP)
endef
