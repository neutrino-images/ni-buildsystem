################################################################################
#
# ethtool
#
################################################################################

ETHTOOL_VERSION = 6.0
ETHTOOL_DIR = ethtool-$(ETHTOOL_VERSION)
ETHTOOL_SOURCE = ethtool-$(ETHTOOL_VERSION).tar.xz
ETHTOOL_SITE = $(KERNEL_MIRROR)/software/network/ethtool

ETHTOOL_CONF_OPTS = \
	--disable-pretty-dump \
	--disable-netlink

ethtool: | $(TARGET_DIR)
	$(call autotools-package)
