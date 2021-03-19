#
# makefile to build development tools
#
# -----------------------------------------------------------------------------

VALGRIND_VERSION = 3.13.0
VALGRIND_DIR = valgrind-$(VALGRIND_VERSION)
VALGRIND_SOURCE = valgrind-$(VALGRIND_VERSION).tar.bz2
VALGRIND_SITE = ftp://sourceware.org/pub/valgrind

$(DL_DIR)/$(VALGRIND_SOURCE):
	$(download) $(VALGRIND_SITE)/$(VALGRIND_SOURCE)

VALGRIND_PATCH  = valgrind-fix-build-$(TARGET_CPU).patch

VALGRIND_AUTORECONF = YES

VALGRIND_CONF_OPTS = \
	--enable-only32bit \
	--datadir=$(REMOVE_datadir)

valgrind: $(DL_DIR)/$(VALGRIND_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(call apply_patches,$(PKG_PATCH)); \
		$(CONFIGURE); \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_libdir)/valgrind/,*.a *.xml)
	-rm $(addprefix $(TARGET_bindir)/,cg_* callgrind_* ms_print)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

STRACE_VERSION = 5.1
STRACE_DIR = strace-$(STRACE_VERSION)
STRACE_SOURCE = strace-$(STRACE_VERSION).tar.xz
STRACE_SITE = https://strace.io/files/$(STRACE_VERSION)

$(DL_DIR)/$(STRACE_SOURCE):
	$(download) $(STRACE_SITE)/$(STRACE_SOURCE)

strace: $(DL_DIR)/$(STRACE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(STRACE_DIR)
	$(UNTAR)/$(STRACE_SOURCE)
	$(CHDIR)/$(STRACE_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_bindir)/,strace-graph strace-log-merge)
	$(REMOVE)/$(STRACE_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

GDB_VERSION = 8.3
GDB_DIR = gdb-$(GDB_VERSION)
GDB_SOURCE = gdb-$(GDB_VERSION).tar.xz
GDB_SITE = https://sourceware.org/pub/gdb/releases

$(DL_DIR)/$(GDB_SOURCE):
	$(download) $(GDB_SITE)/$(GDB_SOURCE)

GDB_DEPENDENCIES = zlib ncurses

GDB_CONF_OPTS = \
	--infodir=$(REMOVE_infodir) \
	--disable-binutils \
	--disable-gdbserver \
	--disable-gdbtk \
	--disable-sim \
	--disable-tui \
	--disable-werror \
	--with-curses \
	--with-zlib \
	--without-mpfr \
	--without-uiout \
	--without-x \
	--enable-static

gdb: $(GDB_DEPENDENCIES) $(DL_DIR)/$(GDB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(GDB_DIR)
	$(UNTAR)/$(GDB_SOURCE)
	$(CHDIR)/$(GDB_DIR); \
		$(CONFIGURE); \
		$(MAKE) all-gdb; \
		$(MAKE) install-gdb DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_datadir)/,system-gdbinit)
	find $(TARGET_datadir)/gdb/syscalls -type f -not -name 'arm-linux.xml' -not -name 'gdb-syscalls.dtd' -print0 | xargs -0 rm --
	$(REMOVE)/$(GDB_DIR)
	$(TOUCH)
