################################################################################
#
# dvbsnoop
#
################################################################################

DVBSNOOP_VERSION = master
DVBSNOOP_DIR = dvbsnoop.git
DVBSNOOP_SOURCE = dvbsnoop.git
DVBSNOOP_SITE = https://github.com/Duckbox-Developers
DVBSNOOP_SITE_METHOD = git

dvbsnoop: | $(TARGET_DIR)
	$(call autotools-package)
