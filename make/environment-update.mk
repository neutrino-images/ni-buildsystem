#
# set up update environment for other makefiles
#
# -----------------------------------------------------------------------------

UPDATE_TEMP_DIR = $(BUILD_DIR)/temp_inst

UPDATE_INST_DIR	= $(UPDATE_TEMP_DIR)/inst
UPDATE_CTRL_DIR	= $(UPDATE_TEMP_DIR)/ctrl

POSTINSTALL_SH	= $(UPDATE_CTRL_DIR)/postinstall.sh
PREINSTALL_SH	= $(UPDATE_CTRL_DIR)/preinstall.sh

# defaults for Neutrino-Update
UPDATE_DATE	= $(shell date +%Y%m%d%H%M)
UPDATE_VERSION_MAJOR = $(IMAGE_VERSION_MAJOR)
UPDATE_VERSION_MINOR = $(IMAGE_VERSION_MINOR)
UPDATE_VERSION	= $(IMAGE_VERSION)

UPDATE_PREFIX	= $(IMAGE_PREFIX)
UPDATE_SUFFIX	= $(IMAGE_SUFFIX)-update

UPDATE_NAME	= $(UPDATE_PREFIX)-$(UPDATE_SUFFIX)
UPDATE_DESC	= "Neutrino [$(BOXTYPE_SC)][$(BOXSERIES)] Update"
UPDATE_TYPE	= U
# Release	= 0
# Beta		= 1
# Nightly	= 2
# Selfmade	= 9
# Locale	= L
# Settings	= S
# Update	= U
# Addon		= A
# Text		= T

UPDATE_VERSION_STRING = $(UPDATE_TYPE)$(UPDATE_VERSION_MAJOR)$(UPDATE_VERSION_MINOR)$(UPDATE_DATE)

UPDATE_SITE	= $(NI_SERVER)/$(NI_SUBDIR)
UPDATE_MD5FILE	= update.txt
UPDATE_MD5FILE_BOXSERIES= update-$(BOXTYPE_SC)-$(BOXSERIES).txt
UPDATE_MD5FILE_BOXMODEL	= update-$(BOXTYPE_SC)-$(BOXMODEL).txt
