################################################################################
#
# hdparm
#
################################################################################

HDPARM_VERSION = 9.63
HDPARM_DIR = hdparm-$(HDPARM_VERSION)
HDPARM_SOURCE = hdparm-$(HDPARM_VERSION).tar.gz
HDPARM_SITE = https://sourceforge.net/projects/hdparm/files/hdparm

hdparm: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) mandir=$(REMOVE_mandir)
	$(call TARGET_FOLLOWUP)
