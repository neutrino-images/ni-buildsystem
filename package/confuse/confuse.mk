################################################################################
#
# confuse
#
################################################################################

CONFUSE_VERSION = 3.3
CONFUSE_DIR = confuse-$(CONFUSE_VERSION)
CONFUSE_SOURCE = confuse-$(CONFUSE_VERSION).tar.xz
CONFUSE_SITE = https://github.com/martinh/libconfuse/releases/download/v$(CONFUSE_VERSION)

CONFUSE_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--localedir=$(REMOVE_localedir) \
	--enable-static \
	--disable-shared

confuse: | $(TARGET_DIR)
	$(call autotools-package)
