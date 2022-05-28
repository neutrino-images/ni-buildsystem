################################################################################
#
# libgcrypt
#
################################################################################

LIBGCRYPT_VERSION = 1.10.1
LIBGCRYPT_DIR = libgcrypt-$(LIBGCRYPT_VERSION)
LIBGCRYPT_SOURCE = libgcrypt-$(LIBGCRYPT_VERSION).tar.gz
LIBGCRYPT_SITE = https://gnupg.org/ftp/gcrypt/libgcrypt

LIBGCRYPT_DEPENDENCIES = libgpg-error

LIBGCRYPT_CONFIG_SCRIPTS = libgcrypt-config

LIBGCRYPT_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-shared \
	--disable-static \
	--disable-tests

define LIBGCRYPT_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,dumpsexp hmac256 mpicalc)
endef
LIBGCRYPT_TARGET_FINALIZE_HOOKS += LIBGCRYPT_TARGET_CLEANUP

libgcrypt: | $(TARGET_DIR)
	$(call autotools-package)
