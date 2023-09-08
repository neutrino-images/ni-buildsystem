################################################################################
#
# kmod
#
################################################################################

KMOD_VERSION = 30
KMOD_DIR = kmod-$(KMOD_VERSION)
KMOD_SOURCE = kmod-$(KMOD_VERSION).tar.xz
KMOD_SITE = https://mirrors.edge.kernel.org/pub/linux/utils/kernel/kmod

# -----------------------------------------------------------------------------

HOST_KMOD_DEPENDENCIES += host-zlib

HOST_KMOD_AUTORECONF = YES

HOST_KMOD_CONF_OPTS = \
	--disable-debug \
	--disable-logging \
	--disable-manpages \
	--without-openssl \
	--without-xz \
	--with-zlib

HOST_DEPMOD = $(HOST_DIR)/sbin/depmod

# We only install depmod, since that's the only tool used for the host.
define HOST_KMOD_INSTALL_TOOLS
	$(INSTALL) -d $(dir $(HOST_DEPMOD))
	ln -sf ../bin/kmod $(HOST_DEPMOD)
endef
HOST_KMOD_POST_INSTALL_HOOKS += HOST_KMOD_INSTALL_TOOLS

host-kmod: | $(HOST_DIR)
	$(call host-autotools-package)
