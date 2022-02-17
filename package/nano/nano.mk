################################################################################
#
# nano
#
################################################################################

NANO_VERSION = 5.8
NANO_DIR = nano-$(NANO_VERSION)
NANO_SOURCE = nano-$(NANO_VERSION).tar.gz
NANO_SITE = $(GNU_MIRROR)/nano

$(DL_DIR)/$(NANO_SOURCE):
	$(download) $(NANO_SITE)/$(NANO_SOURCE)

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

nano: $(NANO_DEPENDENCIES) $(DL_DIR)/$(NANO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(NANO_MAKE_ENV) $(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL) -d $(TARGET_sysconfdir)/profile.d
	echo "export EDITOR=nano" > $(TARGET_sysconfdir)/profile.d/editor.sh
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
