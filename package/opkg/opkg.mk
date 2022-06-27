################################################################################
#
# opkg
#
################################################################################

OPKG_VERSION = 0.6.0
OPKG_DIR = opkg-$(OPKG_VERSION)
OPKG_SOURCE = opkg-$(OPKG_VERSION).tar.gz
OPKG_SITE = https://downloads.yoctoproject.org/releases/opkg

OPKG_DEPENDENCIES = libarchive

OPKG_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-curl \
	--disable-gpg

define OPKG_INSTALL_DIRECTORIES
	$(INSTALL) -d $(TARGET_libdir)/opkg
	$(INSTALL) -d $(TARGET_sysconfdir)/opkg
endef
OPKG_TARGET_FINALIZE_HOOKS += OPKG_INSTALL_DIRECTORIES

opkg: | $(TARGET_DIR)
	$(call autotools-package)
