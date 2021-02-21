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

NEUTRINO-PLUGINS_OBJ       = $(NI-NEUTRINO-PLUGINS)-obj
NEUTRINO-PLUGINS_BUILD_DIR = $(BUILD_DIR)/$(NEUTRINO-PLUGINS_OBJ)

# -----------------------------------------------------------------------------

NEUTRINO-PLUGINS_DEPS  = ffmpeg
NEUTRINO-PLUGINS_DEPS += libcurl
NEUTRINO-PLUGINS_DEPS += libpng
NEUTRINO-PLUGINS_DEPS += libjpeg-turbo
NEUTRINO-PLUGINS_DEPS += giflib
NEUTRINO-PLUGINS_DEPS += freetype
NEUTRINO-PLUGINS_DEPS += luaexpat
NEUTRINO-PLUGINS_DEPS += luajson
NEUTRINO-PLUGINS_DEPS += luacurl
NEUTRINO-PLUGINS_DEPS += luaposix
NEUTRINO-PLUGINS_DEPS += lua-feedparser

# -----------------------------------------------------------------------------

NEUTRINO-PLUGINS_CONF_ENV = \
	$(MAKE_ENV)

# -----------------------------------------------------------------------------

NEUTRINO-PLUGINS_CONF_OPTS = \
	--host=$(TARGET) \
	--build=$(BUILD) \
	--prefix=$(prefix) \
	--sysconfdir=$(sysconfdir) \
	--enable-maintainer-mode \
	--enable-silent-rules \
	\
	--with-neutrino-source=$(SOURCE_DIR)/$(NI-NEUTRINO) \
	--with-neutrino-build=$(NEUTRINO_BUILD_DIR) \
	\
	--with-target=cdk \
	--with-targetprefix=$(prefix) \
	--with-boxtype=$(BOXTYPE)

ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
  NEUTRINO-PLUGINS_CONF_OPTS += --with-boxmodel=$(BOXSERIES)
else
  NEUTRINO-PLUGINS_CONF_OPTS += --with-boxmodel=$(BOXMODEL)
endif

NEUTRINO-PLUGINS_CONF_OPTS += \
	--disable-logoupdater \
	--disable-logoview \
	--disable-mountpointmanagement \
	--disable-stbup

ifeq ($(BOXTYPE),coolstream)
  ifeq ($(BOXSERIES),hd1)
    NEUTRINO-PLUGINS_CONF_OPTS += \
	--disable-spiegel_tv_doc \
	--disable-tierwelt_tv
  endif
  NEUTRINO-PLUGINS_CONF_OPTS += \
	--disable-showiframe \
	--disable-stb_startup \
	--disable-imgbackup \
	--disable-rcu_switcher
endif

# -----------------------------------------------------------------------------

ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
  NEUTRINO-PLUGINS_BOXMODEL = $(BOXSERIES)
else
  NEUTRINO-PLUGINS_BOXMODEL = $(BOXMODEL)
endif

# -----------------------------------------------------------------------------

$(NEUTRINO-PLUGINS_BUILD_DIR)/config.status: $(NEUTRINO-PLUGINS_DEPS)
	test -d $(NEUTRINO-PLUGINS_BUILD_DIR) || mkdir -p $(NEUTRINO-PLUGINS_BUILD_DIR)
	$(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/autogen.sh
	$(CD) $(NEUTRINO-PLUGINS_BUILD_DIR); \
		$(NEUTRINO-PLUGINS_CONF_ENV) \
		$(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/configure \
			$(NEUTRINO-PLUGINS_CONF_OPTS)

# -----------------------------------------------------------------------------

NEUTRINO-PLUGINS_INIT-SCRIPTS_DEFAULTS  =
NEUTRINO-PLUGINS_INIT-SCRIPTS_DEFAULTS += emmrd
NEUTRINO-PLUGINS_INIT-SCRIPTS_DEFAULTS += fritzcallmonitor
NEUTRINO-PLUGINS_INIT-SCRIPTS_DEFAULTS += openvpn
NEUTRINO-PLUGINS_INIT-SCRIPTS_DEFAULTS += rcu_switcher
#NEUTRINO-PLUGINS_INIT-SCRIPTS_DEFAULTS += stbup
NEUTRINO-PLUGINS_INIT-SCRIPTS_DEFAULTS += tuxcald
NEUTRINO-PLUGINS_INIT-SCRIPTS_DEFAULTS += tuxmaild

NEUTRINO-PLUGINS_INIT-SCRIPTS  = $(NEUTRINO-PLUGINS_INIT-SCRIPTS_DEFAULTS)
NEUTRINO-PLUGINS_INIT-SCRIPTS += turnoff_power

define NEUTRINO-PLUGINS_RUNLEVEL-LINKS_INSTALL
	for script in $(NEUTRINO-PLUGINS_INIT-SCRIPTS_DEFAULTS); do \
		if [ -x $(TARGET_sysconfdir)/init.d/$$script ]; then \
			$(UPDATE-RC.D) $$script defaults 80 20; \
		fi; \
	done
	if [ -x $(TARGET_sysconfdir)/init.d/turnoff_power ]; then \
		$(UPDATE-RC.D) turnoff_power start 99 0 .; \
	fi
endef

define NEUTRINO-PLUGINS_RUNLEVEL-LINKS_UNINSTALL
	for link in $(NEUTRINO-PLUGINS_INIT-SCRIPTS); do \
		find $(TARGET_sysconfdir) -type l -name [SK]??$$link -print0 | \
			xargs --no-run-if-empty -0 rm -f; \
	done
endef

# -----------------------------------------------------------------------------

neutrino-plugins: neutrino $(NEUTRINO-PLUGINS_BUILD_DIR)/config.status
	$(MAKE) -C $(NEUTRINO-PLUGINS_BUILD_DIR)
	$(MAKE) -C $(NEUTRINO-PLUGINS_BUILD_DIR) install DESTDIR=$(TARGET_DIR)
	$(NEUTRINO-PLUGINS_RUNLEVEL-LINKS_INSTALL)
	$(TOUCH)

# -----------------------------------------------------------------------------

neutrino-plugins-uninstall:
	-make -C $(NEUTRINO-PLUGINS_BUILD_DIR) uninstall DESTDIR=$(TARGET_DIR)
	$(NEUTRINO-PLUGINS_RUNLEVEL-LINKS_UNINSTALL)

neutrino-plugins-distclean:
	-make -C $(NEUTRINO-PLUGINS_BUILD_DIR) distclean

neutrino-plugins-clean: neutrino-plugins-uninstall neutrino-plugins-distclean
	rm -f $(NEUTRINO-PLUGINS_BUILD_DIR)/config.status
	rm -f $(DEPS_DIR)/neutrino-plugins

neutrino-plugins-clean-all: neutrino-plugins-clean
	rm -rf $(NEUTRINO-PLUGINS_BUILD_DIR)

# -----------------------------------------------------------------------------

# To build single plugins from neutrino-plugins repository call
# make neutrino-plugin-<subdir>; e.g. make neutrino-plugin-tuxwetter

neutrino-plugin-%: $(NEUTRINO-PLUGINS_BUILD_DIR)/config.status
	$(MAKE) -C $(NEUTRINO-PLUGINS_BUILD_DIR)/$(subst neutrino-plugin-,,$(@))
	$(MAKE) -C $(NEUTRINO-PLUGINS_BUILD_DIR)/$(subst neutrino-plugin-,,$(@)) install DESTDIR=$(TARGET_DIR)

# -----------------------------------------------------------------------------

channellogos: $(SOURCE_DIR)/$(NI-LOGO-STUFF) $(SHARE_ICONS)
	rm -rf $(SHARE_LOGOS)
	mkdir -p $(SHARE_LOGOS)
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI-LOGO-STUFF)/logos/* $(SHARE_LOGOS)
	mkdir -p $(SHARE_LOGOS)/events
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI-LOGO-STUFF)/logos-events/* $(SHARE_LOGOS)/events
	$(CD) $(SOURCE_DIR)/$(NI-LOGO-STUFF)/logo-links; \
		./logo-linker.sh logo-links.db $(SHARE_LOGOS)
	$(TOUCH)

# -----------------------------------------------------------------------------

logo-addon: $(SOURCE_DIR)/$(NI-LOGO-STUFF) $(SHARE_PLUGINS)
	$(INSTALL_EXEC) $(SOURCE_DIR)/$(NI-LOGO-STUFF)/logo-addon/*.sh $(SHARE_PLUGINS)/
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI-LOGO-STUFF)/logo-addon/*.cfg $(SHARE_PLUGINS)/
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI-LOGO-STUFF)/logo-addon/*.png $(SHARE_PLUGINS)/
	$(TOUCH)

# -----------------------------------------------------------------------------

doscam-webif-skin:
	$(INSTALL_DATA) -D $(TARGET_FILES)/doscam-webif-skin/doscam_ni-dark.css $(TARGET_datadir)/doscam/skin/doscam_ni-dark.css
	$(INSTALL_DATA) -D $(TARGET_FILES)/doscam-webif-skin/IC_doscam_ni.tpl $(TARGET_datadir)/doscam/tpl/IC_doscam_ni.tpl
	$(TOUCH)

# -----------------------------------------------------------------------------

NEUTRINO-MEDIATHEK_VER    = git
NEUTRINO-MEDIATHEK_DIR    = mediathek.$(NEUTRINO-MEDIATHEK_VER)
NEUTRINO-MEDIATHEK_SOURCE = mediathek.$(NEUTRINO-MEDIATHEK_VER)
NEUTRINO-MEDIATHEK_SITE   = https://github.com/neutrino-mediathek

neutrino-mediathek: $(SHARE_PLUGINS) | $(TARGET_DIR)
	$(REMOVE)/$(NEUTRINO-MEDIATHEK_DIR)
	$(GET-GIT-SOURCE) $(NEUTRINO-MEDIATHEK_SITE)/$(NEUTRINO-MEDIATHEK_SOURCE) $(DL_DIR)/$(NEUTRINO-MEDIATHEK_SOURCE)
	$(CPDIR)/$(NEUTRINO-MEDIATHEK_SOURCE)
	$(CHDIR)/$(NEUTRINO-MEDIATHEK_DIR); \
		$(INSTALL_COPY) plugins/* $(SHARE_PLUGINS)/; \
		$(INSTALL_COPY) share/* $(TARGET_datadir)
	$(REMOVE)/$(NEUTRINO-MEDIATHEK_DIR)
	# temporarily use beta-version from our board
	rm -rf $(SHARE_PLUGINS)/neutrino-mediathek*
	$(INSTALL_COPY) $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/plugins/mediathek/* $(SHARE_PLUGINS)/
	$(TOUCH)

# -----------------------------------------------------------------------------

LINKS_VER    = 2.20.2
LINKS_DIR    = links-$(LINKS_VER)
LINKS_SOURCE = links-$(LINKS_VER).tar.bz2
LINKS_SITE   = http://links.twibright.com/download

$(DL_DIR)/$(LINKS_SOURCE):
	$(DOWNLOAD) $(LINKS_SITE)/$(LINKS_SOURCE)

LINKS_DEPS   = libpng libjpeg-turbo openssl

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

links: $(LINKS_DEPS) $(DL_DIR)/$(LINKS_SOURCE) $(SHARE_PLUGINS) | $(TARGET_DIR)
	$(REMOVE)/$(LINKS_DIR)
	$(UNTAR)/$(LINKS_SOURCE)
	$(CHDIR)/$(LINKS_DIR)/intl; \
		$(SED) 's|^T_SAVE_HTML_OPTIONS,.*|T_SAVE_HTML_OPTIONS, "HTML-Optionen speichern",|' german.lng; \
		echo "english" > index.txt; \
		echo "german" >> index.txt; \
		./gen-intl
	$(CHDIR)/$(LINKS_DIR); \
		$(call apply_patches,$(LINKS_PATCH)); \
		autoreconf -vfi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
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
			--without-x \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv -f $(TARGET_bindir)/links $(SHARE_PLUGINS)/links.so
	$(INSTALL_COPY) $(TARGET_FILES)/links/* $(TARGET_DIR)/
	$(REMOVE)/$(LINKS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

PHONY += plugins

PHONY += neutrino-plugins-uninstall neutrino-plugins-distclean
PHONY += neutrino-plugins-clean neutrino-plugins-clean-all
PHONY += neutrino-plugin-%
