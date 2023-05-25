################################################################################
#
# fribidi
#
################################################################################

FRIBIDI_VERSION = 1.0.13
FRIBIDI_DIR = fribidi-$(FRIBIDI_VERSION)
FRIBIDI_SOURCE = fribidi-$(FRIBIDI_VERSION).tar.xz
FRIBIDI_SITE = https://github.com/fribidi/fribidi/releases/download/v$(FRIBIDI_VERSION)

FRIBIDI_CONF_OPTS = \
	--disable-debug \
	--disable-deprecated

fribidi: | $(TARGET_DIR)
	$(call autotools-package)
