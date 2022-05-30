################################################################################
#
# wget2
#
################################################################################

WGET2_VERSION = 2.0.1
WGET2_DIR = wget2-$(WGET2_VERSION)
WGET2_SOURCE = wget2-$(WGET2_VERSION).tar.gz
WGET2_SITE = $(GNU_MIRROR)/wget

WGET2_DEPENDENCIES = openssl

WGET2_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--sysconfdir=$(REMOVE_sysconfdir) \
	--with-gnu-ld \
	--with-ssl=openssl \
	--disable-debug \
	CFLAGS="$(TARGET_CFLAGS) -DOPENSSL_NO_ENGINE"

define WGET2_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_bindir)/wget2_noinstall
endef
WGET2_TARGET_FINALIZE_HOOKS += WGET2_TARGET_CLEANUP

wget2: | $(TARGET_DIR)
	$(call autotools-package)
