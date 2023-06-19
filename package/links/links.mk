################################################################################
#
# links
#
################################################################################

LINKS_VERSION = 2.29
LINKS_DIR = links-$(LINKS_VERSION)
LINKS_SOURCE = links-$(LINKS_VERSION).tar.bz2
LINKS_SITE = http://links.twibright.com/download

LINKS_DEPENDENCIES = libpng libjpeg-turbo openssl zlib

LINKS_AUTORECONF = YES

LINKS_CONF_OPTS = \
	--enable-graphics \
	--with-fb \
	--with-libjpeg \
	--with-ssl=$(TARGET_DIR) --enable-ssl-pkgconfig \
	--with-zlib  \
	--without-atheos \
	--without-directfb \
	--without-libtiff \
	--without-lzma \
	--without-pmshell \
	--without-svgalib \
	--without-x

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),coolstream))
define LINKS_PATCH_RCINPUT_C
	$(SED) 's|"/dev/input/event0"|"/dev/input/nevis_ir"|' $(PKG_BUILD_DIR)/rcinput.c
endef
else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k e4hdultra protek4k))
define LINKS_PATCH_RCINPUT_C
	$(SED) 's|"/dev/input/event0"|"/dev/input/event1"|' $(PKG_BUILD_DIR)/rcinput.c
endef
else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),h7))
define LINKS_PATCH_RCINPUT_C
	$(SED) 's|"/dev/input/event0"|"/dev/input/event2"|' $(PKG_BUILD_DIR)/rcinput.c
endef
endif
LINKS_POST_PATCH_HOOKS += LINKS_PATCH_RCINPUT_C

define LINKS_PREPARE_INTL
	$(SED) 's|^T_SAVE_HTML_OPTIONS,.*|T_SAVE_HTML_OPTIONS, "HTML-Optionen speichern",|' $(PKG_BUILD_DIR)/intl/german.lng
	echo "english" > $(PKG_BUILD_DIR)/intl/index.txt
	echo "german" >> $(PKG_BUILD_DIR)/intl/index.txt
	$(CD) $(PKG_BUILD_DIR)/intl; \
		./gen-intl
endef
LINKS_PRE_CONFIGURE_HOOKS += LINKS_PREPARE_INTL

define LINKS_INSTALL_AS_NEUTRINO_PLUGIN
	$(INSTALL) -d $(SHARE_PLUGINS)
	mv -f $(TARGET_bindir)/links $(SHARE_PLUGINS)/links.so
	$(INSTALL_DATA) $(PKG_FILES_DIR)/links.cfg $(SHARE_PLUGINS)/links.cfg
endef
LINKS_TARGET_FINALIZE_HOOKS += LINKS_INSTALL_AS_NEUTRINO_PLUGIN

define LINKS_INSTALL_SKEL
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
endef
LINKS_TARGET_FINALIZE_HOOKS += LINKS_INSTALL_SKEL

links: | $(TARGET_DIR)
	$(call autotools-package)
