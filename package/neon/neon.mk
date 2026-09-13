################################################################################
#
# neon
#
################################################################################

NEON_VERSION = 0.37.1
NEON_DIR = neon-$(NEON_VERSION)
NEON_SOURCE = neon-$(NEON_VERSION).tar.gz
NEON_SITE = https://notroj.github.io/neon

NEON_DEPENDENCIES = zlib openssl expat libxml2

NEON_CONFIG_SCRIPTS = neon-config

NEON_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--without-gssapi \
	--with-zlib \
	--with-ssl \
	--with-expat=yes \
	--with-libxml2=yes

NEON_CONF_ENV= \
	ac_cv_prog_XML2_CONFIG=$(TARGET_DIR)/usr/bin/xml2-config

neon: | $(TARGET_DIR)
	$(call autotools-package)
