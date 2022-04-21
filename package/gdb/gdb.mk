################################################################################
#
# gdb
#
################################################################################

GDB_VERSION = 11.2
GDB_DIR = gdb-$(GDB_VERSION)
GDB_SOURCE = gdb-$(GDB_VERSION).tar.xz
GDB_SITE = https://sourceware.org/pub/gdb/releases

GDB_DEPENDENCIES = zlib ncurses gmp

GDB_CONF_ENV = \
	ac_cv_type_uintptr_t=yes \
	gt_cv_func_gettext_libintl=yes \
	ac_cv_func_dcgettext=yes \
	gdb_cv_func_sigsetjmp=yes \
	bash_cv_func_strcoll_broken=no \
	bash_cv_must_reinstall_sighandlers=no \
	bash_cv_func_sigsetjmp=present \
	bash_cv_have_mbstate_t=yes \
	gdb_cv_func_sigsetjmp=yes

# Starting with gdb 7.11, the bundled gnulib tries to use
# rpl_gettimeofday (gettimeofday replacement) due to the code being
# unable to determine if the replacement function should be used or
# not when cross-compiling with uClibc or musl as C libraries. So use
# gl_cv_func_gettimeofday_clobber=no to not use rpl_gettimeofday,
# assuming musl and uClibc have a properly working gettimeofday
# implementation. It needs to be passed to GDB_CONF_ENV to build
# gdbserver only but also to GDB_MAKE_ENV, because otherwise it does
# not get passed to the configure script of nested packages while
# building gdbserver with full debugger.
GDB_CONF_ENV += gl_cv_func_gettimeofday_clobber=no
GDB_MAKE_ENV += gl_cv_func_gettimeofday_clobber=no

# Similarly, starting with gdb 8.1, the bundled gnulib tries to use
# rpl_strerror. Let's tell gnulib the C library implementation works
# well enough.
GDB_CONF_ENV += \
	gl_cv_func_working_strerror=yes \
	gl_cv_func_strerror_0_works=yes
GDB_MAKE_ENV += \
	gl_cv_func_working_strerror=yes \
	gl_cv_func_strerror_0_works=yes

# Starting with glibc 2.25, the proc_service.h header has been copied
# from gdb to glibc so other tools can use it. However, that makes it
# necessary to make sure that declaration of prfpregset_t declaration
# is consistent between gdb and glibc. In gdb, however, there is a
# workaround for a broken prfpregset_t declaration in glibc 2.3 which
# uses AC_TRY_RUN to detect if it's needed, which doesn't work in
# cross-compilation. So pass the cache option to configure.
# It needs to be passed to GDB_CONF_ENV to build gdbserver only but
# also to GDB_MAKE_ENV, because otherwise it does not get passed to the
# configure script of nested packages while building gdbserver with full
# debugger.
GDB_CONF_ENV += gdb_cv_prfpregset_t_broken=no
GDB_MAKE_ENV += gdb_cv_prfpregset_t_broken=no

GDB_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-binutils \
	--disable-gdbserver \
	--disable-gdbtk \
	--disable-inprocess-agent \
	--disable-sim \
	--disable-tui \
	--disable-werror \
	--with-curses \
	--with-zlib \
	--without-included-gettext \
	--without-mpfr \
	--without-uiout \
	--without-x \
	--enable-static

define GDB_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,gcore gdb-add-index)
endef
GDB_TARGET_FINALIZE_HOOKS += GDB_TARGET_CLEANUP

gdb: | $(TARGET_DIR)
	$(call autotools-package)
