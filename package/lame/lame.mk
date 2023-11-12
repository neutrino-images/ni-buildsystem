################################################################################
#
# lame
#
################################################################################

LAME_VERSION = 3.100
LAME_DIR = lame-$(LAME_VERSION)
LAME_SOURCE = lame-$(LAME_VERSION).tar.gz
LAME_SITE = http://downloads.sourceforge.net/project/lame/lame/$(LAME_VERSION)

LAME_DEPENDENCIES = ncurses

LAME_CONF_ENV = \
	GTK_CONFIG=/bin/false

LAME_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-gtktest \
	--enable-dynamic-frontends

lame: | $(TARGET_DIR)
	$(call autotools-package)
