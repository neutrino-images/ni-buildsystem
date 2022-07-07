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

GPTFDISK_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

GPTFDISK_MAKE_OPTS = \
	$(GPTFDISK_SBINARIES)

define GPTFDISK_INSTALL_CMDS
	$(foreach sbinary,$($(PKG)_SBINARIES),\
		rm -f $(TARGET_sbindir)/$(sbinary); \
		$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/$(sbinary) $(TARGET_sbindir)/$(sbinary)$(sep) \
	)
endef

gptfdisk: | $(TARGET_DIR)
	$(call generic-package)
