################################################################################
#
# mediainfo
#
################################################################################

MEDIAINFO_VERSION = 20.08
MEDIAINFO_DIR = MediaInfo
MEDIAINFO_SOURCE = mediainfo_$(MEDIAINFO_VERSION).tar.bz2
MEDIAINFO_SITE = https://mediaarea.net/download/source/mediainfo/$(MEDIAINFO_VERSION)

$(DL_DIR)/$(MEDIAINFO_SOURCE):
	$(download) $(MEDIAINFO_SITE)/$(MEDIAINFO_SOURCE)

MEDIAINFO_DEPENDENCIES = libmediainfo

MEDIAINFO_AUTORECONF = YES

mediainfo: $(MEDIAINFO_DEPENDENCIES) $(DL_DIR)/$(MEDIAINFO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(MEDIAINFO_DIR)
	$(UNTAR)/$(MEDIAINFO_SOURCE)
	$(CHDIR)/$(MEDIAINFO_DIR)/Project/GNU/CLI; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(MEDIAINFO_DIR)
	$(TOUCH)
