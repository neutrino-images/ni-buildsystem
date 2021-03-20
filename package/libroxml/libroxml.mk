################################################################################
#
# libroxml
#
################################################################################

LIBROXML_VERSION = 3.0.2
LIBROXML_DIR = libroxml-$(LIBROXML_VERSION)
LIBROXML_SOURCE = libroxml-$(LIBROXML_VERSION).tar.gz
LIBROXML_SITE = http://download.libroxml.net/pool/v3.x

LIBROXML_CONF_OPTS = \
	--disable-roxml

libroxml: | $(TARGET_DIR)
	$(call autotools-package)
