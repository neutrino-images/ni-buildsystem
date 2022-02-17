################################################################################
#
# gptfdisk
#
################################################################################

GPTFDISK_VERSION = 1.0.8
GPTFDISK_DIR = gptfdisk-$(GPTFDISK_VERSION)
GPTFDISK_SOURCE = gptfdisk-$(GPTFDISK_VERSION).tar.gz
GPTFDISK_SITE = https://sourceforge.net/projects/gptfdisk/files/gptfdisk/$(GPTFDISK_VERSION)

$(DL_DIR)/$(GPTFDISK_SOURCE):
	$(download) $(GPTFDISK_SITE)/$(GPTFDISK_SOURCE)

GPTFDISK_DEPENDENCIES = popt e2fsprogs ncurses

GPTFDISK_SBINARIES = sgdisk

gptfdisk: $(GPTFDISK_DEPENDENCIES) $(DL_DIR)/$(GPTFDISK_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) $($(PKG)_SBINARIES); \
		for sbin in $($(PKG)_SBINARIES); do \
			$(INSTALL_EXEC) -D $$sbin $(TARGET_sbindir)/$$sbin; \
		done
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
