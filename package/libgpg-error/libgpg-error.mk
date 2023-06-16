################################################################################
#
# libgpg-error
#
################################################################################

LIBGPG_ERROR_VERSION = 1.46
LIBGPG_ERROR_DIR = libgpg-error-$(LIBGPG_ERROR_VERSION)
LIBGPG_ERROR_SOURCE = libgpg-error-$(LIBGPG_ERROR_VERSION).tar.bz2
LIBGPG_ERROR_SITE = ftp://ftp.gnupg.org/gcrypt/libgpg-error

LIBGPG_ERROR_AUTORECONF = YES

LIBGPG_ERROR_CONFIG_SCRIPTS = gpgrt-config

LIBGPG_ERROR_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-shared \
	--disable-doc \
	--disable-languages \
	--disable-static \
	--disable-tests

# fix build for libgcrypt 1.10.1
LIBGPG_ERROR_CONFIG_SCRIPTS += gpg-error-config
LIBGPG_ERROR_CONF_OPTS += \
	--enable-install-gpg-error-config \

define LIBGPG_ERROR_LINKING_HEADER
	ln -sf lock-obj-pub.arm-unknown-linux-gnueabi.h $($(PKG)_BUILD_DIR)/src/syscfg/lock-obj-pub.$(GNU_TARGET_NAME).h
	ln -sf lock-obj-pub.arm-unknown-linux-gnueabi.h $($(PKG)_BUILD_DIR)/src/syscfg/lock-obj-pub.linux-uclibcgnueabi.h
endef
LIBGPG_ERROR_POST_EXTRACT_HOOKS += LIBGPG_ERROR_LINKING_HEADER

define LIBGPG_ERROR_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,gpg-error)
endef
LIBGPG_ERROR_TARGET_FINALIZE_HOOKS += LIBGPG_ERROR_TARGET_CLEANUP

libgpg-error: | $(TARGET_DIR)
	$(call autotools-package)
