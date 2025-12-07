################################################################################
#
# ethtool
#
################################################################################

ETHTOOL_VERSION = 6.15
ETHTOOL_DIR = ethtool-$(ETHTOOL_VERSION)
ETHTOOL_SOURCE = ethtool-$(ETHTOOL_VERSION).tar.xz
ETHTOOL_SITE = $(KERNEL_MIRROR)/software/network/ethtool

ETHTOOL_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-pretty-dump \
	--disable-netlink \
	--with-bash-completion-dir=no

ethtool: | $(TARGET_DIR)
	$(call autotools-package)
