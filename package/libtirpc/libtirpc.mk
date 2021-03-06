################################################################################
#
# libtirpc
#
################################################################################

LIBTIRPC_VERSION = 1.2.6
LIBTIRPC_DIR = libtirpc-$(LIBTIRPC_VERSION)
LIBTIRPC_SOURCE = libtirpc-$(LIBTIRPC_VERSION).tar.bz2
LIBTIRPC_SITE = https://sourceforge.net/projects/libtirpc/files/libtirpc/$(LIBTIRPC_VERSION)

LIBTIRPC_AUTORECONF = YES

LIBTIRPC_CONF_OPTS = \
	--disable-gssapi

ifeq ($(BOXSERIES),hd1)
  define LIBTIRPC_DISABLE_IPV6
	$(SED) '/^\(udp\|tcp\)6/ d' $(TARGET_sysconfdir)/netconfig
  endef
  LIBTIRPC_TARGET_FINALIZE_HOOKS += LIBTIRPC_DISABLE_IPV6
endif

libtirpc: | $(TARGET_DIR)
	$(call autotools-package)
