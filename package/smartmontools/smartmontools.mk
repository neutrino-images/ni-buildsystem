################################################################################
#
# smartmontools
#
################################################################################

SMARTMONTOOLS_VERSION = 7.3
SMARTMONTOOLS_DIR = smartmontools-$(SMARTMONTOOLS_VERSION)
SMARTMONTOOLS_SOURCE = smartmontools-$(SMARTMONTOOLS_VERSION).tar.gz
SMARTMONTOOLS_SITE = https://sourceforge.net/projects/smartmontools/files/smartmontools/$(SMARTMONTOOLS_VERSION)

SMARTMONTOOLS_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--with-drivedbdir=no \
	--with-initscriptdir=no \
	--with-smartdplugindir=no \
	--with-smartdscriptdir=$(REMOVE_sysconfdir) \
	--with-update-smart-drivedb=no \
	--without-gnupg

define SMARTMONTOOLS_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_sysconfdir)/smartd.conf
	$(TARGET_RM) $(TARGET_sbindir)/smartd
endef
SMARTMONTOOLS_TARGET_FINALIZE_HOOKS += SMARTMONTOOLS_TARGET_CLEANUP

smartmontools: | $(TARGET_DIR)
	$(call autotools-package)
