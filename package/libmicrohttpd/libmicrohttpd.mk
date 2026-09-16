################################################################################
#
# libmicrohttpd
#
################################################################################

# 1.0.3 fixed connection list traversal skipping ready connections while
# another is suspended, which is the ordinary shape here: every event stream
# and every live stream suspends one. 1.0.4 and 1.0.5 fixed request smuggling
# (CWE-444), which matters because reading needs no password and the legacy
# paths write
LIBMICROHTTPD_VERSION = 1.0.10
LIBMICROHTTPD_DIR = libmicrohttpd-$(LIBMICROHTTPD_VERSION)
LIBMICROHTTPD_SOURCE = libmicrohttpd-$(LIBMICROHTTPD_VERSION).tar.gz
LIBMICROHTTPD_SITE = $(GNU_MIRROR)/libmicrohttpd

LIBMICROHTTPD_SHA256 = 04bfe8ef75db7d629a33de767599765cecadc56274a39822d5d081030d577685

# checked where it lands: this is fetched because older ones have holes, and
# GET_ARCHIVE passes --no-check-certificate
define LIBMICROHTTPD_VERIFY_ARCHIVE
	$(Q)have=`sha256sum $(DL_DIR)/$(LIBMICROHTTPD_SOURCE) | cut -d' ' -f1`; \
	if [ "$$have" != "$(LIBMICROHTTPD_SHA256)" ]; then \
		echo "$(LIBMICROHTTPD_SOURCE): sha256 $$have, expected $(LIBMICROHTTPD_SHA256)"; \
		echo "what came down is not that archive; $(DL_DIR)/$(LIBMICROHTTPD_SOURCE) is left there to be looked at"; \
		false; \
	fi
endef
LIBMICROHTTPD_POST_DOWNLOAD_HOOKS += LIBMICROHTTPD_VERIFY_ARCHIVE

LIBMICROHTTPD_DEPENDENCIES = openssl

# no https: the box terminates nothing itself and it would pull gnutls in
LIBMICROHTTPD_CONF_OPTS = \
	--enable-shared \
	--disable-static \
	--disable-examples \
	--disable-doc \
	--disable-curl \
	--disable-https

libmicrohttpd: | $(TARGET_DIR)
	$(call autotools-package)
