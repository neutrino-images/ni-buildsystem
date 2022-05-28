################################################################################
#
# nano
#
################################################################################

NANO_VERSION = 6.3
NANO_DIR = nano-$(NANO_VERSION)
NANO_SOURCE = nano-$(NANO_VERSION).tar.gz
NANO_SITE = $(GNU_MIRROR)/nano

NANO_DEPENDENCIES = ncurses

ifeq ($(BS_PACKAGE_NCURSES_WCHAR),y)
  NANO_CONF_ENV = \
	ac_cv_prog_NCURSESW_CONFIG=$(HOST_DIR)/bin/$(NCURSES_CONFIG_SCRIPTS)
else
  NANO_CONF_ENV = \
	ac_cv_prog_NCURSESW_CONFIG=false
  NANO_MAKE_ENV = \
	CURSES_LIB="-lncurses"
endif

NANO_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-nls \
	--disable-libmagic \
	--enable-tiny \
	--without-slang \
	--with-wordbounds

define NANO_INSTALL_EDITOR_SH
	$(INSTALL) -d $(TARGET_sysconfdir)/profile.d
	echo "export EDITOR=nano" > $(TARGET_sysconfdir)/profile.d/editor.sh
endef
NANO_PRE_FOLLOWUP_HOOKS += NANO_INSTALL_EDITOR_SH

nano: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(CONFIGURE); \
		$(NANO_MAKE_ENV) $(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(call TARGET_FOLLOWUP)
