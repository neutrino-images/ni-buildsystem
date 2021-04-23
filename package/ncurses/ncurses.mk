################################################################################
#
# ncurses
#
################################################################################

NCURSES_VERSION = 6.1
NCURSES_DIR = ncurses-$(NCURSES_VERSION)
NCURSES_SOURCE = ncurses-$(NCURSES_VERSION).tar.gz
NCURSES_SITE = $(GNU_MIRROR)/ncurses

NCURSES_CONFIG_SCRIPTS = ncurses6-config

NCURSES_CONF_OPTS = \
	--enable-pc-files \
	--with-pkg-config \
	--with-pkg-config-libdir=$(libdir)/pkgconfig \
	--with-shared \
	--with-fallbacks='linux vt100 xterm' \
	--disable-big-core \
	--disable-db-install \
	--disable-stripping \
	--with-progs \
	--without-termlib \
	--without-ticlib \
	--without-manpages \
	--without-tests \
	--without-debug \
	--without-ada \
	--without-profile \
	--without-cxx-binding

define NCURSES_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,captoinfo clear infocmp infotocap reset tabs tic toe)
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/,libform* libmenu* libpanel*)
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/pkgconfig/,form.pc menu.pc panel.pc)
endef
NCURSES_TARGET_FINALIZE_HOOKS += NCURSES_TARGET_CLEANUP

ncurses: | $(TARGET_DIR)
	$(call autotools-package)
