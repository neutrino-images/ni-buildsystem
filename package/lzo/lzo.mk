################################################################################
#
# lzo
#
################################################################################

LZO_VERSION = 2.10
LZO_DIR = lzo-$(LZO_VERSION)
LZO_SOURCE = lzo-$(LZO_VERSION).tar.gz
LZO_SITE = https://www.oberhumer.com/opensource/lzo/download

LZO_CONF_OPTS = \
	--docdir=$(REMOVE_docdir)

lzo: | $(TARGET_DIR)
	$(call autotools-package)
