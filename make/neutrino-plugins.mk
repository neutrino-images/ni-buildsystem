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
plugins-bre2ze4k \
plugins-hd51: \
	$(D)/channellogos
ifneq ($(BOXMODEL), kronos_v2)
	make links
endif

# -----------------------------------------------------------------------------

NP_OBJ_DIR = $(BUILD_TMP)/$(NI_NEUTRINO-PLUGINS)

NP_DEPS  = ffmpeg
NP_DEPS += libcurl
NP_DEPS += libpng
NP_DEPS += libjpeg
NP_DEPS += giflib
NP_DEPS += freetype
NP_DEPS += lua-feedparser

NP_CONFIGURE_ADDITIONS = \
		--disable-logoupdater \
		--disable-logoview \
		--disable-mountpointmanagement \
		--disable-stbup

ifneq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 bre2ze4k))
  NP_CONFIGURE_ADDITIONS += \
		--disable-showiframe \
		--disable-stb_startup \
		--disable-imgbackup-hd51
endif

$(NP_OBJ_DIR)/config.status: $(NP_DEPS)
	test -d $(NP_OBJ_DIR) || mkdir -p $(NP_OBJ_DIR)
	$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/autogen.sh
	$(CD) $(NP_OBJ_DIR); \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/configure \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--enable-maintainer-mode \
			--enable-silent-rules \
			\
			--with-neutrino-source=$(SOURCE_DIR)/$(NI_NEUTRINO) \
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

$(D)/channellogos: $(SOURCE_DIR)/$(NI_LOGO-STUFF) $(SHAREICONS)
	rm -rf $(SHAREICONS)/logo
	mkdir -p $(SHAREICONS)/logo
	install -m 0644 $(SOURCE_DIR)/$(NI_LOGO-STUFF)/logos/* $(SHAREICONS)/logo
	mkdir -p $(SHAREICONS)/logo/events
	install -m 0644 $(SOURCE_DIR)/$(NI_LOGO-STUFF)/logos-events/* $(SHAREICONS)/logo/events
	$(CD) $(SOURCE_DIR)/$(NI_LOGO-STUFF)/logo-links; \
		./logo-linker.sh logo-links.db $(SHAREICONS)/logo
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/logo-addon: $(SOURCE_DIR)/$(NI_LOGO-STUFF) $(SHAREPLUGINS)
	install -m 0755 $(SOURCE_DIR)/$(NI_LOGO-STUFF)/logo-addon/*.sh $(SHAREPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_LOGO-STUFF)/logo-addon/*.cfg $(SHAREPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_LOGO-STUFF)/logo-addon/*.png $(SHAREPLUGINS)/
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/doscam-webif-skin:
	install -D -m 0644 $(IMAGEFILES)/doscam-webif-skin/doscam_ni-dark.css $(TARGET_DIR)/share/doscam/skin/doscam_ni-dark.css
	install -D -m 0644 $(IMAGEFILES)/doscam-webif-skin/IC_doscam_ni.tpl $(TARGET_DIR)/share/doscam/tpl/IC_doscam_ni.tpl
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/neutrino-mediathek: $(SHAREPLUGINS) | $(TARGET_DIR)
	$(REMOVE)/mediathek.git
	get-git-source.sh https://github.com/neutrino-mediathek/mediathek.git $(ARCHIVE)/mediathek.git
	$(CPDIR)/mediathek.git
	$(CHDIR)/mediathek.git; \
		cp -a plugins/* $(SHAREPLUGINS)/; \
		cp -a share $(TARGET_DIR)
	$(REMOVE)/mediathek.git
	$(TOUCH)

# -----------------------------------------------------------------------------

LINKS_VER = 2.17

$(ARCHIVE)/links-$(LINKS_VER).tar.bz2:
	$(WGET) http://links.twibright.com/download/links-$(LINKS_VER).tar.bz2

LINKS_PATCH  = links-$(LINKS_VER).patch
LINKS_PATCH += links-$(LINKS_VER)-ac-prog-cxx.patch
LINKS_PATCH += links-$(LINKS_VER)-input-$(BOXTYPE).patch
LINKS_PATCH += links-$(LINKS_VER)-accept_https_play.patch

$(D)/links: $(D)/libpng $(D)/libjpeg $(D)/openssl $(ARCHIVE)/links-$(LINKS_VER).tar.bz2 $(SHAREPLUGINS) | $(TARGET_DIR)
	$(REMOVE)/links-$(LINKS_VER)
	$(UNTAR)/links-$(LINKS_VER).tar.bz2
	$(CHDIR)/links-$(LINKS_VER)/intl; \
		sed -i -e 's|^T_SAVE_HTML_OPTIONS,.*|T_SAVE_HTML_OPTIONS, "HTML-Optionen speichern",|' german.lng; \
		echo "english" > index.txt; \
		echo "german" >> index.txt; \
		./gen-intl
	$(CHDIR)/links-$(LINKS_VER); \
		$(call apply_patches, $(LINKS_PATCH)); \
		autoreconf -vfi; \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
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
	mv -f $(BIN)/links $(SHAREPLUGINS)/links.so
	cp -a $(IMAGEFILES)/links/* $(TARGET_DIR)/
	$(REMOVE)/links-$(LINKS_VER)
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
