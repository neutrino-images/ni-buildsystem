################################################################################
#
# opus
#
################################################################################

OPUS_VERSION = 1.5.2
OPUS_DIR = opus-$(OPUS_VERSION)
OPUS_SOURCE = opus-$(OPUS_VERSION).tar.gz
OPUS_SITE = https://downloads.xiph.org/releases/opus

OPUS_CONF_OPTS = \
	--disable-doc \
	--disable-extra-programs

opus: | $(TARGET_DIR)
	$(call autotools-package)
