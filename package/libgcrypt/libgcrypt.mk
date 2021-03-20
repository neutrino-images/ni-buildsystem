################################################################################
#
# libgcrypt
#
################################################################################

LIBGCRYPT_VERSION = 1.8.5
LIBGCRYPT_DIR = libgcrypt-$(LIBGCRYPT_VERSION)
LIBGCRYPT_SOURCE = libgcrypt-$(LIBGCRYPT_VERSION).tar.gz
LIBGCRYPT_SITE = ftp://ftp.gnupg.org/gcrypt/libgcrypt

LIBGCRYPT_DEPENDENCIES = libgpg-error

LIBGCRYPT_CONFIG_SCRIPTS = libgcrypt-config

LIBGCRYPT_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-maintainer-mode \
	--enable-silent-rules \
	--enable-shared \
	--disable-static \
	--disable-tests

define LIBGCRYPT_TARGET_CLEANUP
	-rm $(addprefix $(TARGET_bindir)/,dumpsexp hmac256 mpicalc)
endef
LIBGCRYPT_TARGET_FINALIZE_HOOKS += LIBGCRYPT_TARGET_CLEANUP

libgcrypt: | $(TARGET_DIR)
	$(call autotools-package)
