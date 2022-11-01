################################################################################
#
# neutrino-plugins
#
################################################################################

NEUTRINO_PLUGINS_OBJ       = $(NI_NEUTRINO_PLUGINS)-obj
NEUTRINO_PLUGINS_BUILD_DIR = $(BUILD_DIR)/$(NEUTRINO_PLUGINS_OBJ)

# -----------------------------------------------------------------------------

NEUTRINO_PLUGINS_DEPENDENCIES = ffmpeg libcurl libpng libjpeg-turbo giflib \
	freetype lua-curl lua-feedparser luaexpat luajson luaposix

# -----------------------------------------------------------------------------

NEUTRINO_PLUGINS_CONF_ENV = \
	$(TARGET_CONFIGURE_ENV)

# -----------------------------------------------------------------------------

NEUTRINO_PLUGINS_CONF_OPTS = \
	--build=$(GNU_HOST_NAME) \
	--host=$(TARGET) \
	--target=$(TARGET) \
	--prefix=$(prefix) \
	--sysconfdir=$(sysconfdir) \
	$(if $(findstring 1,$(KBUILD_VERBOSE)),--disable-silent-rules,--enable-silent-rules) \
	--enable-maintainer-mode \
	\
	--with-lua-libdir=$(libdir)/lua/$(LUA_ABIVERSION) \
	--with-lua-datadir=$(datadir)/lua/$(LUA_ABIVERSION) \
	\
	--with-neutrino-source=$(SOURCE_DIR)/$(NI_NEUTRINO) \
	--with-neutrino-build=$(NEUTRINO_BUILD_DIR) \
	\
	--with-target=cdk \
	--with-targetprefix=$(prefix) \
	--with-boxtype=$(BOXTYPE)

ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
  NEUTRINO_PLUGINS_CONF_OPTS += --with-boxmodel=$(BOXSERIES)
else
  NEUTRINO_PLUGINS_CONF_OPTS += --with-boxmodel=$(BOXMODEL)
endif

NEUTRINO_PLUGINS_CONF_OPTS += \
	--disable-ard_mediathek \
	--disable-logoupdater \
	--disable-logoview \
	--disable-mountpointmanagement \
	--disable-filmon \
	--disable-stbup

ifeq ($(BOXTYPE),coolstream)
  ifeq ($(BOXSERIES),hd1)
    NEUTRINO_PLUGINS_CONF_OPTS += \
	--disable-plutotv \
	--disable-rakutentv \
	--disable-spiegel_tv_doc \
	--disable-tierwelt_tv
  endif
  NEUTRINO_PLUGINS_CONF_OPTS += \
	--disable-showiframe \
	--disable-stb_startup \
	--disable-imgbackup \
	--disable-replay \
	--disable-rcu_switcher
endif

# -----------------------------------------------------------------------------

$(NEUTRINO_PLUGINS_BUILD_DIR)/config.status: $(NEUTRINO_PLUGINS_DEPENDENCIES)
	test -d $(NEUTRINO_PLUGINS_BUILD_DIR) || $(INSTALL) -d $(NEUTRINO_PLUGINS_BUILD_DIR)
	$(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/autogen.sh
	$(CD) $(NEUTRINO_PLUGINS_BUILD_DIR); \
		$(NEUTRINO_PLUGINS_CONF_ENV) \
		$(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/configure \
			$(NEUTRINO_PLUGINS_CONF_OPTS)

# -----------------------------------------------------------------------------

NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS =
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += emmrd
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += fritzcallmonitor
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += openvpn
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += plugins-hide
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += rcu_switcher
#NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += stbup
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += tuxcald
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += tuxmaild

NEUTRINO_PLUGINS_INIT_SCRIPTS  = $(NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS)
NEUTRINO_PLUGINS_INIT_SCRIPTS += initfb
NEUTRINO_PLUGINS_INIT_SCRIPTS += turnoff_power

define NEUTRINO_PLUGINS_RUNLEVEL_LINKS_INSTALL
	for script in $(NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS); do \
		if [ -x $(TARGET_sysconfdir)/init.d/$$script ]; then \
			$(UPDATE-RC.D) $$script defaults 80 20; \
		fi; \
	done
	if [ -x $(TARGET_sysconfdir)/init.d/initfb ]; then \
		$(UPDATE-RC.D) initfb start 06 S .; \
	fi
	if [ -x $(TARGET_sysconfdir)/init.d/turnoff_power ]; then \
		$(UPDATE-RC.D) turnoff_power start 99 0 .; \
	fi
endef

define NEUTRINO_PLUGINS_RUNLEVEL_LINKS_UNINSTALL
	for script in $(NEUTRINO_PLUGINS_INIT_SCRIPTS); do \
		if [ -x $(TARGET_DIR)/etc/init.d/$$script ]; then \
			$(REMOVE-RC.D) $$script remove; \
		fi; \
	done
endef

# -----------------------------------------------------------------------------

neutrino-plugins: neutrino $(NEUTRINO_PLUGINS_BUILD_DIR)/config.status
	$(MAKE) -C $(NEUTRINO_PLUGINS_BUILD_DIR)
	$(MAKE) -C $(NEUTRINO_PLUGINS_BUILD_DIR) install DESTDIR=$(TARGET_DIR)
	$(NEUTRINO_PLUGINS_RUNLEVEL_LINKS_INSTALL)
	$(call TOUCH)

# -----------------------------------------------------------------------------

neutrino-plugins-uninstall:
	$(NEUTRINO_PLUGINS_RUNLEVEL_LINKS_UNINSTALL)
	-make -C $(NEUTRINO_PLUGINS_BUILD_DIR) uninstall DESTDIR=$(TARGET_DIR)

neutrino-plugins-distclean:
	-make -C $(NEUTRINO_PLUGINS_BUILD_DIR) distclean

neutrino-plugins-clean: neutrino-plugins-uninstall neutrino-plugins-distclean
	rm -f $(NEUTRINO_PLUGINS_BUILD_DIR)/config.status
	rm -f $(DEPS_DIR)/neutrino-plugins

neutrino-plugins-clean-all: neutrino-plugins-clean
	rm -rf $(NEUTRINO_PLUGINS_BUILD_DIR)
