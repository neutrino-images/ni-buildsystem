################################################################################
#
# giflib
#
################################################################################

GIFLIB_VERSION = 5.2.1
GIFLIB_DIR = giflib-$(GIFLIB_VERSION)
GIFLIB_SOURCE = giflib-$(GIFLIB_VERSION).tar.gz
GIFLIB_SITE = https://sourceforge.net/projects/giflib/files

$(DL_DIR)/$(GIFLIB_SOURCE):
	$(download) $(GIFLIB_SITE)/$(GIFLIB_SOURCE)

giflib: $(DL_DIR)/$(GIFLIB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install-include install-lib DESTDIR=$(TARGET_DIR) PREFIX=$(prefix)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
