################################################################################
#
# hdparm
#
################################################################################

HDPARM_VERSION = 9.60
HDPARM_DIR = hdparm-$(HDPARM_VERSION)
HDPARM_SOURCE = hdparm-$(HDPARM_VERSION).tar.gz
HDPARM_SITE = https://sourceforge.net/projects/hdparm/files/hdparm

$(DL_DIR)/$(HDPARM_SOURCE):
	$(download) $(HDPARM_SITE)/$(HDPARM_SOURCE)

hdparm: $(DL_DIR)/$(HDPARM_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) mandir=$(REMOVE_mandir)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
