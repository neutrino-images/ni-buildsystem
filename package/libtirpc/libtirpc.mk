################################################################################
#
# libtirpc
#
################################################################################

LIBTIRPC_VERSION = 1.3.3
LIBTIRPC_DIR = libtirpc-$(LIBTIRPC_VERSION)
LIBTIRPC_SOURCE = libtirpc-$(LIBTIRPC_VERSION).tar.bz2
LIBTIRPC_SITE = https://sourceforge.net/projects/libtirpc/files/libtirpc/$(LIBTIRPC_VERSION)

LIBTIRPC_CONF_OPTS = \
	--disable-gssapi \
	--without-openldap

ifeq ($(BOXSERIES),hd1)
  define LIBTIRPC_DISABLE_IPV6
	$(SED) '/^\(udp\|tcp\)6/ d' $(TARGET_sysconfdir)/netconfig
  endef
  LIBTIRPC_TARGET_FINALIZE_HOOKS += LIBTIRPC_DISABLE_IPV6
endif

libtirpc: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

HOST_LIBTIRPC_CONF_OPTS = \
	--disable-gssapi

host-libtirpc: | $(HOST_DIR)
	$(call host-autotools-package)
