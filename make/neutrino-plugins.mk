#
# makefile to build neutrino-plugins
#
# -----------------------------------------------------------------------------

plugins: \
	$(D)/neutrino-plugins \
	$(D)/logo-addon \
	$(D)/neutrino-mediathek \
	$(D)/doscam-webif-skin
	make plugins-$(BOXSERIES)

plugins-hd1:
	# nothing to do

plugins-hd2 \
plugins-hd51 \
plugins-bre2ze4k: \
	$(D)/channellogos
ifneq ($(BOXMODEL), kronos_v2)
	make links
endif

# -----------------------------------------------------------------------------

NP_OBJ_DIR = $(BUILD_TMP)/$(NI-NEUTRINO-PLUGINS)

NP_DEPS  = $(D)/ffmpeg
NP_DEPS += $(D)/libcurl
NP_DEPS += $(D)/libpng
NP_DEPS += $(D)/libjpeg
NP_DEPS += $(D)/giflib
NP_DEPS += $(D)/freetype
NP_DEPS += $(D)/luaexpat
NP_DEPS += $(D)/luajson
NP_DEPS += $(D)/luacurl
NP_DEPS += $(D)/luaposix
NP_DEPS += $(D)/lua-feedparser

NP_CONFIGURE_ADDITIONS = \
		--disable-logoupdater \
		--disable-logoview \
		--disable-mountpointmanagement \
		--disable-stbup

ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd1 hd2))
  NP_CONFIGURE_ADDITIONS += \
		--disable-showiframe \
		--disable-stb_startup \
		--disable-imgbackup-hd51
endif

$(NP_OBJ_DIR)/config.status: $(NP_DEPS)
	test -d $(NP_OBJ_DIR) || mkdir -p $(NP_OBJ_DIR)
	$(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/autogen.sh
	$(CD) $(NP_OBJ_DIR); \
		$(BUILD_ENV) \
		$(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/configure \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--enable-maintainer-mode \
			--enable-silent-rules \
			\
			--with-neutrino-source=$(SOURCE_DIR)/$(NI-NEUTRINO) \
			--with-neutrino-build=$(N_OBJ_DIR) \
			\
			$(NP_CONFIGURE_ADDITIONS) \
			\
			--with-target=cdk \
			--with-targetprefix= \
			--with-boxtype=$(BOXTYPE) \
			--with-boxmodel=$(BOXSERIES)

# -----------------------------------------------------------------------------

$(D)/neutrino-plugins: $(D)/neutrino $(NP_OBJ_DIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(NP_OBJ_DIR) all     DESTDIR=$(TARGET_DIR)
	$(MAKE) -C $(NP_OBJ_DIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

neutrino-plugins-uninstall:
	-make -C $(NP_OBJ_DIR) uninstall DESTDIR=$(TARGET_DIR)

neutrino-plugins-distclean:
	-make -C $(NP_OBJ_DIR) distclean

neutrino-plugins-clean: neutrino-plugins-uninstall neutrino-plugins-distclean
	rm -f $(NP_OBJ_DIR)/config.status
	rm -f $(D)/neutrino-plugins

neutrino-plugins-clean-all: neutrino-plugins-clean
	rm -rf $(NP_OBJ_DIR)

# -----------------------------------------------------------------------------

# To build single plugins from neutrino-plugins repository call
# make neutrino-plugin-<subdir>; e.g. make neutrino-plugin-tuxwetter

neutrino-plugin-%: $(NP_OBJ_DIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(NP_OBJ_DIR)/$(subst neutrino-plugin-,,$@) all install DESTDIR=$(TARGET_DIR)

# -----------------------------------------------------------------------------

$(D)/channellogos: $(SOURCE_DIR)/$(NI-LOGO-STUFF) $(SHAREICONS)
	rm -rf $(SHAREICONS)/logo
	install -d $(SHAREICONS)/logo
	install -m 0644 $(SOURCE_DIR)/$(NI-LOGO-STUFF)/logos/* $(SHAREICONS)/logo
	install -d $(SHAREICONS)/logo/events
	install -m 0644 $(SOURCE_DIR)/$(NI-LOGO-STUFF)/logos-events/* $(SHAREICONS)/logo/events
	$(CD) $(SOURCE_DIR)/$(NI-LOGO-STUFF)/logo-links; \
		./logo-linker.sh logo-links.db $(SHAREICONS)/logo
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/logo-addon: $(SOURCE_DIR)/$(NI-LOGO-STUFF) $(SHAREPLUGINS)
	install -m 0755 $(SOURCE_DIR)/$(NI-LOGO-STUFF)/logo-addon/*.sh $(SHAREPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI-LOGO-STUFF)/logo-addon/*.cfg $(SHAREPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI-LOGO-STUFF)/logo-addon/*.png $(SHAREPLUGINS)/
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/doscam-webif-skin:
	install -D -m 0644 $(IMAGEFILES)/doscam-webif-skin/doscam_ni-dark.css $(TARGET_SHARE_DIR)/doscam/skin/doscam_ni-dark.css
	install -D -m 0644 $(IMAGEFILES)/doscam-webif-skin/IC_doscam_ni.tpl $(TARGET_SHARE_DIR)/doscam/tpl/IC_doscam_ni.tpl
	$(TOUCH)

# -----------------------------------------------------------------------------

NEUTRINO-MEDIATHEK_VER    = git
NEUTRINO-MEDIATHEK_TMP    = mediathek.$(NEUTRINO-MEDIATHEK_VER)
NEUTRINO-MEDIATHEK_SOURCE = mediathek.$(NEUTRINO-MEDIATHEK_VER)
NEUTRINO-MEDIATHEK_URL    = https://github.com/neutrino-mediathek

$(D)/neutrino-mediathek: $(SHAREPLUGINS) | $(TARGET_DIR)
	$(REMOVE)/$(NEUTRINO-MEDIATHEK_TMP)
	get-git-source.sh $(NEUTRINO-MEDIATHEK_URL)/$(NEUTRINO-MEDIATHEK_SOURCE) $(ARCHIVE)/$(NEUTRINO-MEDIATHEK_SOURCE)
	$(CPDIR)/$(NEUTRINO-MEDIATHEK_SOURCE)
	$(CHDIR)/$(NEUTRINO-MEDIATHEK_TMP); \
		cp -a plugins/* $(SHAREPLUGINS)/; \
		cp -a share $(TARGET_DIR)
	$(REMOVE)/$(NEUTRINO-MEDIATHEK_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LINKS_VER    = 2.19
LINKS_TMP    = links-$(LINKS_VER)
LINKS_SOURCE = links-$(LINKS_VER).tar.bz2
LINKS_URL    = http://links.twibright.com/download

$(ARCHIVE)/$(LINKS_SOURCE):
	$(DOWNLOAD) $(LINKS_URL)/$(LINKS_SOURCE)

LINKS_PATCH  = links.patch
LINKS_PATCH += links-ac-prog-cxx.patch
LINKS_PATCH += links-input-$(BOXTYPE).patch
LINKS_PATCH += links-accept_https_play.patch

$(D)/links: $(D)/libpng $(D)/libjpeg $(D)/openssl $(ARCHIVE)/$(LINKS_SOURCE) $(SHAREPLUGINS) | $(TARGET_DIR)
	$(REMOVE)/$(LINKS_TMP)
	$(UNTAR)/$(LINKS_SOURCE)
	$(CHDIR)/$(LINKS_TMP)/intl; \
		sed -i -e 's|^T_SAVE_HTML_OPTIONS,.*|T_SAVE_HTML_OPTIONS, "HTML-Optionen speichern",|' german.lng; \
		echo "english" > index.txt; \
		echo "german" >> index.txt; \
		./gen-intl
	$(CHDIR)/$(LINKS_TMP); \
		$(call apply_patches, $(LINKS_PATCH)); \
		autoreconf -vfi; \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
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
	mv -f $(TARGET_BIN_DIR)/links $(SHAREPLUGINS)/links.so
	cp -a $(IMAGEFILES)/links/* $(TARGET_DIR)/
	$(REMOVE)/$(LINKS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

PHONY += plugins
PHONY += plugins-hd1
PHONY += plugins-hd2
PHONY += plugins-hd51
PHONY += plugins-bre2ze4k

PHONY += neutrino-plugins-uninstall neutrino-plugins-distclean
PHONY += neutrino-plugins-clean neutrino-plugins-clean-all
PHONY += neutrino-plugin-%
