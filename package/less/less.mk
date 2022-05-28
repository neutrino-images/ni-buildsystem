################################################################################
#
# less
#
################################################################################

LESS_VERSION = 590
LESS_DIR = less-$(LESS_VERSION)
LESS_SOURCE = less-$(LESS_VERSION).tar.gz
LESS_SITE = $(GNU_MIRROR)/less

LESS_DEPENDENCIES = ncurses

less: | $(TARGET_DIR)
	$(call autotools-package)
