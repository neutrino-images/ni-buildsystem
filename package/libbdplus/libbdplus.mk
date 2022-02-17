################################################################################
#
# libbdplus
#
################################################################################

LIBBDPLUS_VERSION = 0.1.2
LIBBDPLUS_DIR = libbdplus-$(LIBBDPLUS_VERSION)
LIBBDPLUS_SOURCE = libbdplus-$(LIBBDPLUS_VERSION).tar.bz2
LIBBDPLUS_SITE = ftp://ftp.videolan.org/pub/videolan/libbdplus/$(LIBBDPLUS_VERSION)

$(DL_DIR)/$(LIBBDPLUS_SOURCE):
	$(download) $(LIBBDPLUS_SITE)/$(LIBBDPLUS_SOURCE)

LIBBDPLUS_DEPENDENCIES = libaacs

LIBBDPLUS_CONF_OPTS = \
	--enable-shared \
	--disable-static

libbdplus: $(LIBBDPLUS_DEPENDENCIES) $(DL_DIR)/$(LIBBDPLUS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		./bootstrap; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(INSTALL) -d $(TARGET_DIR)/.config/bdplus/vm0
	$(INSTALL_COPY) $(PKG_FILES_DIR)/* $(TARGET_DIR)/.config/bdplus/vm0
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
