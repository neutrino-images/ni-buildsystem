################################################################################
#
# hdparm
#
################################################################################

HDPARM_VERSION = 9.65
HDPARM_DIR = hdparm-$(HDPARM_VERSION)
HDPARM_SOURCE = hdparm-$(HDPARM_VERSION).tar.gz
HDPARM_SITE = https://sourceforge.net/projects/hdparm/files/hdparm

HDPARM_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

HDPARM_MAKE_OPTS = \
	mandir=$(REMOVE_mandir)

hdparm: | $(TARGET_DIR)
	$(call generic-package)
