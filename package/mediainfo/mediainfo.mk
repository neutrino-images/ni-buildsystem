################################################################################
#
# mediainfo
#
################################################################################

MEDIAINFO_VERSION = 22.03
MEDIAINFO_DIR = MediaInfo
MEDIAINFO_SOURCE = mediainfo_$(MEDIAINFO_VERSION).tar.bz2
MEDIAINFO_SITE = https://mediaarea.net/download/source/mediainfo/$(MEDIAINFO_VERSION)

MEDIAINFO_SUBDIR = Project/GNU/CLI

MEDIAINFO_DEPENDENCIES = libmediainfo

MEDIAINFO_AUTORECONF = YES

mediainfo: | $(TARGET_DIR)
	$(call autotools-package)
