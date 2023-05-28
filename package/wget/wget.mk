################################################################################
#
# wget
#
################################################################################

WGET_VERSION = 1.21.3
WGET_DIR = wget-$(WGET_VERSION)
WGET_SOURCE = wget-$(WGET_VERSION).tar.gz
WGET_SITE = $(GNU_MIRROR)/wget

WGET_DEPENDENCIES = openssl

WGET_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--sysconfdir=$(REMOVE_sysconfdir) \
	--with-gnu-ld \
	--with-ssl=openssl \
	--disable-debug \
	CFLAGS="$(TARGET_CFLAGS) -DOPENSSL_NO_ENGINE"

wget: | $(TARGET_DIR)
	$(call autotools-package)
