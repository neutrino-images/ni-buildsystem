################################################################################
#
# libcurl
#
################################################################################

LIBCURL_VERSION = 8.0.1
LIBCURL_DIR = curl-$(LIBCURL_VERSION)
LIBCURL_SOURCE = curl-$(LIBCURL_VERSION).tar.bz2
LIBCURL_SITE = https://curl.haxx.se/download

LIBCURL_DEPENDENCIES = zlib openssl rtmpdump ca-bundle

LIBCURL_CONFIG_SCRIPTS = curl-config

LIBCURL_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	$(if $(filter $(BOXSERIES),hd1),--disable-ipv6,--enable-ipv6) \
	--disable-manual \
	--disable-file \
	--disable-rtsp \
	--disable-dict \
	--disable-ldap \
	--disable-ldaps \
	--disable-curldebug \
	--disable-static \
	--disable-imap \
	--disable-gopher \
	--disable-pop3 \
	--disable-smtp \
	--disable-verbose \
	--disable-manual \
	--disable-ntlm-wb \
	--disable-ares \
	--without-libidn2 \
	--without-winidn \
	--without-libpsl \
	--without-zstd \
	--with-ca-path=$(CA_BUNDLE_CERTS_DIR) \
	--with-random=/dev/urandom \
	--with-ssl=$(TARGET_prefix) \
	--with-librtmp=$(TARGET_libdir) \
	--enable-optimize

libcurl: | $(TARGET_DIR)
	$(call autotools-package)
