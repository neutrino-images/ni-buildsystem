################################################################################
#
# libaacs
#
################################################################################

LIBAACS_VERSION = 0.9.0
LIBAACS_DIR = libaacs-$(LIBAACS_VERSION)
LIBAACS_SOURCE = libaacs-$(LIBAACS_VERSION).tar.bz2
LIBAACS_SITE = ftp://ftp.videolan.org/pub/videolan/libaacs/$(LIBAACS_VERSION)

$(DL_DIR)/$(LIBAACS_SOURCE):
	$(download) $(LIBAACS_SITE)/$(LIBAACS_SOURCE)

LIBAACS_DEPENDENCIES = libgcrypt

LIBAACS_CONF_OPTS = \
	--enable-shared \
	--disable-static

libaacs: $(LIBAACS_DEPENDENCIES) $(DL_DIR)/$(LIBAACS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		./bootstrap; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(INSTALL) -d $(TARGET_DIR)/.cache/aacs/vuk
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/KEYDB.cfg $(TARGET_DIR)/.config/aacs/KEYDB.cfg
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
