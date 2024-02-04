################################################################################
#
# ncurses
#
################################################################################

NCURSES_VERSION = 6.1
NCURSES_DIR = ncurses-$(NCURSES_VERSION)
NCURSES_SOURCE = ncurses-$(NCURSES_VERSION).tar.gz
NCURSES_SITE = $(GNU_MIRROR)/ncurses

ifeq ($(BS_PACKAGE_NCURSES_WCHAR),y)
NCURSES_LIB_SUFFIX = w
endif

NCURSES_CONFIG_SCRIPTS = ncurses$(NCURSES_LIB_SUFFIX)6-config

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
	--without-cxx \
	--without-cxx-binding \
	--without-ada \
	--without-termlib \
	--without-ticlib \
	--without-manpages \
	--without-tests \
	--without-debug \
	--without-ada \
	--without-profile \
	--without-cxx-binding

ifeq ($(NCURSES_LIB_SUFFIX),w)

NCURSES_CONF_OPTS += --enable-widec
NCURSES_CONF_OPTS += --enable-ext-colors

NCURSES_LIBS = ncurses menu panel form

define NCURSES_LINK_LIBS_STATIC
	$(foreach lib,$(NCURSES_LIBS:%=lib%), \
		ln -sf $(lib)$(NCURSES_LIB_SUFFIX).a $(TARGET_libdir)/$(lib).a
	)
	ln -sf libncurses$(NCURSES_LIB_SUFFIX).a $(TARGET_libdir)/libcurses.a
endef

define NCURSES_LINK_LIBS_SHARED
	$(foreach lib,$(NCURSES_LIBS:%=lib%), \
		ln -sf $(lib)$(NCURSES_LIB_SUFFIX).so $(TARGET_libdir)/$(lib).so
	)
	ln -sf libncurses$(NCURSES_LIB_SUFFIX).so $(TARGET_libdir)/libcurses.so
endef

define NCURSES_LINK_PC
	$(foreach pc,$(NCURSES_LIBS), \
		ln -sf $(pc)$(NCURSES_LIB_SUFFIX).pc $(TARGET_libdir)/pkgconfig/$(pc).pc
	)
endef

NCURSES_TARGET_FINALIZE_HOOKS += NCURSES_LINK_LIBS_STATIC
NCURSES_TARGET_FINALIZE_HOOKS += NCURSES_LINK_LIBS_SHARED
NCURSES_TARGET_FINALIZE_HOOKS += NCURSES_LINK_PC

endif # NCURSES_LIB_SUFFIX

define NCURSES_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,captoinfo clear infocmp infotocap reset tabs tic toe)
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/,libform* libmenu* libpanel*)
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/pkgconfig/,form*.pc menu*.pc panel*.pc)
endef
NCURSES_TARGET_FINALIZE_HOOKS += NCURSES_TARGET_CLEANUP

ncurses: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

HOST_NCURSES_CONF_ENV = \
	ac_cv_path_LDCONFIG=""

HOST_NCURSES_CONF_OPTS = \
	--with-shared \
	--without-gpm \
	--without-manpages \
	--without-cxx \
	--without-cxx-binding \
	--without-ada \
	--with-default-terminfo-dir=/usr/share/terminfo \
	--disable-db-install \
	--without-normal

host-ncurses: | $(HOST_DIR)
	$(call host-autotools-package)
