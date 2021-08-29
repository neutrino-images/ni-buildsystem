################################################################################
#
# ethtool
#
################################################################################

ETHTOOL_VERSION = 5.13
ETHTOOL_DIR = ethtool-$(ETHTOOL_VERSION)
ETHTOOL_SOURCE = ethtool-$(ETHTOOL_VERSION).tar.xz
ETHTOOL_SITE = $(KERNEL_MIRROR)/software/network/ethtool

ETHTOOL_CONF_OPTS = \
	--libdir=$(TARGET_libdir) \
	--disable-pretty-dump \
	--disable-netlink

ethtool: | $(TARGET_DIR)
	$(call autotools-package)
