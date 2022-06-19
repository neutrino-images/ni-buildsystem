################################################################################
#
# gptfdisk
#
################################################################################

GPTFDISK_VERSION = 1.0.9
GPTFDISK_DIR = gptfdisk-$(GPTFDISK_VERSION)
GPTFDISK_SOURCE = gptfdisk-$(GPTFDISK_VERSION).tar.gz
GPTFDISK_SITE = https://sourceforge.net/projects/gptfdisk/files/gptfdisk/$(GPTFDISK_VERSION)

GPTFDISK_DEPENDENCIES = popt e2fsprogs ncurses

GPTFDISK_SBINARIES = sgdisk

define GPTFDISK_INSTALL_SBINARIES
	$(foreach sbinary,$($(PKG)_SBINARIES),\
		rm -f $(TARGET_sbindir)/$(sbinary); \
		$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/$(sbinary) $(TARGET_sbindir)/$(sbinary)$(sep) \
	)
endef
GPTFDISK_PRE_FOLLOWUP_HOOKS += GPTFDISK_INSTALL_SBINARIES

gptfdisk: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) $($(PKG)_SBINARIES)
	$(call TARGET_FOLLOWUP)
