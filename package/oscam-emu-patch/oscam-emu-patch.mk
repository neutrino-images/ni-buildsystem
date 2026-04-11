################################################################################
#
# oscam-emu-patch
#
################################################################################

OSCAM_EMU_PATCH_VERSION = master
OSCAM_EMU_PATCH_DIR = oscam-emu-patch.git
OSCAM_EMU_PATCH_SOURCE = oscam-emu-patch.git
OSCAM_EMU_PATCH_SITE = https://github.com/oscam-mirror
OSCAM_EMU_PATCH_SITE_METHOD = git

OSCAM_EMU_PATCH_FILE = oscam-emu.patch                   	

OSCAM_EMU_PATCH ?= no

oscam-emu-patch:
	$(call download-package)
