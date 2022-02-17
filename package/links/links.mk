################################################################################
#
# links
#
################################################################################

LINKS_VERSION = 2.25
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
	$(call APPLY_PATCHES,$(LINKS_PATCH))
	$(CHDIR)/$(LINKS_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv -f $(TARGET_bindir)/links $(SHARE_PLUGINS)/links.so
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
	$(REMOVE)/$(LINKS_DIR)
	$(TOUCH)
