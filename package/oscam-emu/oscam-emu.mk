################################################################################
#
# oscam-emu
#
################################################################################

OSCAM_EMU_VERSION = master
OSCAM_EMU_DIR = oscam-emu.git
OSCAM_EMU_SOURCE = oscam-emu.git
OSCAM_EMU_SITE = https://github.com/oscam-emu
OSCAM_EMU_SITE_METHOD = git

OSCAM_EMU_PATCH_FILE = oscam-emu.patch                   	

OSCAM_EMU ?= no

oscam-emu:
	$(call download-package)
