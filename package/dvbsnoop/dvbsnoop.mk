################################################################################
#
# dvbsnoop
#
################################################################################

DVBSNOOP_VERSION = git
DVBSNOOP_DIR = dvbsnoop.$(DVBSNOOP_VERSION)
DVBSNOOP_SOURCE = dvbsnoop.$(DVBSNOOP_VERSION)
DVBSNOOP_SITE = https://github.com/Duckbox-Developers

dvbsnoop: | $(TARGET_DIR)
	$(call autotools-package)
