################################################################################
#
# expat
#
################################################################################

EXPAT_VERSION = 2.2.9
EXPAT_DIR = expat-$(EXPAT_VERSION)
EXPAT_SOURCE = expat-$(EXPAT_VERSION).tar.bz2
EXPAT_SITE = https://sourceforge.net/projects/expat/files/expat/$(EXPAT_VERSION)

EXPAT_AUTORECONF = YES

EXPAT_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--without-xmlwf \
	--without-docbook

expat: | $(TARGET_DIR)
	$(call autotools-package)
