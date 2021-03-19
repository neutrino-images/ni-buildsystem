#
# makefile to build neutrino-plugins
#
# -----------------------------------------------------------------------------

plugins:
	$(MAKE) neutrino-plugins
	$(MAKE) logo-addon
	$(MAKE) neutrino-mediathek
	$(MAKE) doscam-webif-skin
ifneq ($(BOXSERIES),hd1)
	$(MAKE) channellogos
  ifneq ($(BOXMODEL),kronos_v2)
	$(MAKE) links
  endif
endif

# -----------------------------------------------------------------------------

NEUTRINO_PLUGINS_OBJ       = $(NI_NEUTRINO_PLUGINS)-obj
NEUTRINO_PLUGINS_BUILD_DIR = $(BUILD_DIR)/$(NEUTRINO_PLUGINS_OBJ)

# -----------------------------------------------------------------------------

NEUTRINO_PLUGINS_DEPENDENCIES = ffmpeg
NEUTRINO_PLUGINS_DEPENDENCIES += libcurl
NEUTRINO_PLUGINS_DEPENDENCIES += libpng
NEUTRINO_PLUGINS_DEPENDENCIES += libjpeg-turbo
NEUTRINO_PLUGINS_DEPENDENCIES += giflib
NEUTRINO_PLUGINS_DEPENDENCIES += freetype
NEUTRINO_PLUGINS_DEPENDENCIES += lua-curl
NEUTRINO_PLUGINS_DEPENDENCIES += lua-feedparser
NEUTRINO_PLUGINS_DEPENDENCIES += luaexpat
NEUTRINO_PLUGINS_DEPENDENCIES += luajson
NEUTRINO_PLUGINS_DEPENDENCIES += luaposix

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
	--enable-maintainer-mode \
	--enable-silent-rules \
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
	--disable-logoupdater \
	--disable-logoview \
	--disable-mountpointmanagement \
	--disable-stbup

ifeq ($(BOXTYPE),coolstream)
  ifeq ($(BOXSERIES),hd1)
    NEUTRINO_PLUGINS_CONF_OPTS += \
	--disable-spiegel_tv_doc \
	--disable-tierwelt_tv
  endif
  NEUTRINO_PLUGINS_CONF_OPTS += \
	--disable-showiframe \
	--disable-stb_startup \
	--disable-imgbackup \
	--disable-rcu_switcher
endif

# -----------------------------------------------------------------------------

ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
  NEUTRINO_PLUGINS_BOXMODEL = $(BOXSERIES)
else
  NEUTRINO_PLUGINS_BOXMODEL = $(BOXMODEL)
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

NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS  =
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += emmrd
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += fritzcallmonitor
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += openvpn
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += rcu_switcher
#NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += stbup
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += tuxcald
NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS += tuxmaild

NEUTRINO_PLUGINS_INIT_SCRIPTS  = $(NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS)
NEUTRINO_PLUGINS_INIT_SCRIPTS += turnoff_power

define NEUTRINO_PLUGINS_RUNLEVEL_LINKS_INSTALL
	for script in $(NEUTRINO_PLUGINS_INIT_SCRIPTS_DEFAULTS); do \
		if [ -x $(TARGET_sysconfdir)/init.d/$$script ]; then \
			$(UPDATE-RC.D) $$script defaults 80 20; \
		fi; \
	done
	if [ -x $(TARGET_sysconfdir)/init.d/turnoff_power ]; then \
		$(UPDATE-RC.D) turnoff_power start 99 0 .; \
	fi
endef

define NEUTRINO_PLUGINS_RUNLEVEL_LINKS_UNINSTALL
	for link in $(NEUTRINO_PLUGINS_INIT_SCRIPTS); do \
		find $(TARGET_sysconfdir) -type l -name [SK]??$$link -print0 | \
			xargs --no-run-if-empty -0 rm -f; \
	done
endef

# -----------------------------------------------------------------------------

neutrino-plugins: neutrino $(NEUTRINO_PLUGINS_BUILD_DIR)/config.status
	$(MAKE) -C $(NEUTRINO_PLUGINS_BUILD_DIR)
	$(MAKE) -C $(NEUTRINO_PLUGINS_BUILD_DIR) install DESTDIR=$(TARGET_DIR)
	$(NEUTRINO_PLUGINS_RUNLEVEL_LINKS_INSTALL)
	$(TOUCH)

# -----------------------------------------------------------------------------

neutrino-plugins-uninstall:
	-make -C $(NEUTRINO_PLUGINS_BUILD_DIR) uninstall DESTDIR=$(TARGET_DIR)
	$(NEUTRINO_PLUGINS_RUNLEVEL_LINKS_UNINSTALL)

neutrino-plugins-distclean:
	-make -C $(NEUTRINO_PLUGINS_BUILD_DIR) distclean

neutrino-plugins-clean: neutrino-plugins-uninstall neutrino-plugins-distclean
	rm -f $(NEUTRINO_PLUGINS_BUILD_DIR)/config.status
	rm -f $(DEPS_DIR)/neutrino-plugins

neutrino-plugins-clean-all: neutrino-plugins-clean
	rm -rf $(NEUTRINO_PLUGINS_BUILD_DIR)

# -----------------------------------------------------------------------------

# To build single plugins from neutrino-plugins repository call
# make neutrino-plugin-<subdir>; e.g. make neutrino-plugin-tuxwetter

neutrino-plugin-%: $(NEUTRINO_PLUGINS_BUILD_DIR)/config.status
	$(MAKE) -C $(NEUTRINO_PLUGINS_BUILD_DIR)/$(subst neutrino-plugin-,,$(@))
	$(MAKE) -C $(NEUTRINO_PLUGINS_BUILD_DIR)/$(subst neutrino-plugin-,,$(@)) install DESTDIR=$(TARGET_DIR)

# -----------------------------------------------------------------------------

channellogos: $(SOURCE_DIR)/$(NI_LOGO_STUFF) $(SHARE_ICONS)
	rm -rf $(SHARE_LOGOS)
	$(INSTALL) -d $(SHARE_LOGOS)
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_LOGO_STUFF)/logos/* $(SHARE_LOGOS)
	$(INSTALL) -d $(SHARE_LOGOS)/events
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_LOGO_STUFF)/logos-events/* $(SHARE_LOGOS)/events
	$(CD) $(SOURCE_DIR)/$(NI_LOGO_STUFF)/logo-links; \
		./logo-linker.sh logo-links.db $(SHARE_LOGOS)
	$(TOUCH)

# -----------------------------------------------------------------------------

logo-addon: $(SOURCE_DIR)/$(NI_LOGO_STUFF) $(SHARE_PLUGINS)
	$(INSTALL_EXEC) $(SOURCE_DIR)/$(NI_LOGO_STUFF)/logo-addon/*.sh $(SHARE_PLUGINS)/
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_LOGO_STUFF)/logo-addon/*.cfg $(SHARE_PLUGINS)/
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_LOGO_STUFF)/logo-addon/*.png $(SHARE_PLUGINS)/
	$(TOUCH)

# -----------------------------------------------------------------------------

doscam-webif-skin:
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/doscam_ni-dark.css $(TARGET_datadir)/doscam/skin/doscam_ni-dark.css
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/IC_doscam_ni.tpl $(TARGET_datadir)/doscam/tpl/IC_doscam_ni.tpl
	$(TOUCH)

# -----------------------------------------------------------------------------

NEUTRINO_MEDIATHEK_VERSION = git
NEUTRINO_MEDIATHEK_DIR = mediathek.$(NEUTRINO_MEDIATHEK_VERSION)
NEUTRINO_MEDIATHEK_SOURCE = mediathek.$(NEUTRINO_MEDIATHEK_VERSION)
NEUTRINO_MEDIATHEK_SITE = https://github.com/neutrino-mediathek

neutrino-mediathek: $(SHARE_PLUGINS) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET-GIT-SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(INSTALL_COPY) plugins/* $(SHARE_PLUGINS)/; \
		$(INSTALL_COPY) share/* $(TARGET_datadir)
	$(REMOVE)/$(PKG_DIR)
	# temporarily use beta-version from our board
	rm -rf $(SHARE_PLUGINS)/neutrino-mediathek*
	$(INSTALL_COPY) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/plugins/mediathek/* $(SHARE_PLUGINS)/
	$(TOUCH)

# -----------------------------------------------------------------------------

LINKS_VERSION = 2.20.2
LINKS_DIR = links-$(LINKS_VERSION)
LINKS_SOURCE = links-$(LINKS_VERSION).tar.bz2
LINKS_SITE = http://links.twibright.com/download

$(DL_DIR)/$(LINKS_SOURCE):
	$(download) $(LINKS_SITE)/$(LINKS_SOURCE)

LINKS_DEPENDENCIES = libpng libjpeg-turbo openssl

LINKS_PATCH  = links.patch
LINKS_PATCH += links-ac-prog-cxx.patch
LINKS_PATCH += links-accept_https_play.patch

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),coolstream))
  LINKS_PATCH += links-input-nevis_ir.patch
else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k))
  LINKS_PATCH += links-input-event1.patch
else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),h7))
  LINKS_PATCH += links-input-event2.patch
endif

LINKS_AUTORECONF = YES

LINKS_CONF_OPTS = \
	--enable-graphics \
	--with-fb \
	--with-libjpeg \
	--with-ssl=$(TARGET_DIR) \
	--without-atheos \
	--without-directfb \
	--without-libtiff \
	--without-lzma \
	--without-pmshell \
	--without-svgalib \
	--without-x

links: $(LINKS_DEPENDENCIES) $(DL_DIR)/$(LINKS_SOURCE) $(SHARE_PLUGINS) | $(TARGET_DIR)
	$(REMOVE)/$(LINKS_DIR)
	$(UNTAR)/$(LINKS_SOURCE)
	$(CHDIR)/$(LINKS_DIR)/intl; \
		$(SED) 's|^T_SAVE_HTML_OPTIONS,.*|T_SAVE_HTML_OPTIONS, "HTML-Optionen speichern",|' german.lng; \
		echo "english" > index.txt; \
		echo "german" >> index.txt; \
		./gen-intl
	$(CHDIR)/$(LINKS_DIR); \
		$(call apply_patches,$(LINKS_PATCH)); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv -f $(TARGET_bindir)/links $(SHARE_PLUGINS)/links.so
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
	$(REMOVE)/$(LINKS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

PHONY += plugins

PHONY += neutrino-plugins-uninstall neutrino-plugins-distclean
PHONY += neutrino-plugins-clean neutrino-plugins-clean-all
PHONY += neutrino-plugin-%
