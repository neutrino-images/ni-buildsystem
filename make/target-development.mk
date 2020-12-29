#
# makefile to build development tools
#
# -----------------------------------------------------------------------------

VALGRIND_TARGET = $(if $(filter $(BOXMODEL),nevis),valgrind12305, valgrind3)

valgrind: $(VALGRIND_TARGET)
	$(TOUCH)

# -----------------------------------------------------------------------------

VALGRIND_VER    = 3.13.0
VALGRIND_DIR    = valgrind-$(VALGRIND_VER)
VALGRIND_SOURCE = valgrind-$(VALGRIND_VER).tar.bz2
VALGRIND_SITE   = ftp://sourceware.org/pub/valgrind

$(DL_DIR)/$(VALGRIND_SOURCE):
	$(DOWNLOAD) $(VALGRIND_SITE)/$(VALGRIND_SOURCE)

VALGRIND_PATCH  = valgrind-fix-build-$(TARGET_ARCH).patch

valgrind3: $(DL_DIR)/$(VALGRIND_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(VALGRIND_DIR)
	$(UNTAR)/$(VALGRIND_SOURCE)
	$(CHDIR)/$(VALGRIND_DIR); \
		$(call apply_patches,$(VALGRIND_PATCH)); \
		export AR=$(TARGET_AR); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--enable-only32bit \
			--mandir=$(REMOVE_mandir) \
			--datadir=$(REMOVE_datadir) \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF_PC)
	rm -f $(addprefix $(TARGET_libdir)/valgrind/,*.a *.xml)
	rm -f $(addprefix $(TARGET_bindir)/,cg_* callgrind_* ms_print)
	$(REMOVE)/$(VALGRIND_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

VALGRIND12305_PATCH  = valgrind12305-nevis-patch.diff
VALGRIND12305_PATCH += valgrind12305-automake-1.11.2.patch

valgrind12305: | $(TARGET_DIR)
	$(REMOVE)/valgrind
	svn co -r 12305 svn://svn.valgrind.org/valgrind/trunk $(BUILD_DIR)/valgrind; \
	$(CHDIR)/valgrind; \
		svn up --force -r {2011-12-13} VEX; \
		$(call apply_patches,$(VALGRIND12305_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--enable-only32bit \
			--mandir=$(REMOVE_mandir) \
			--datadir=$(REMOVE_datadir) \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF_PC)
	$(REMOVE)/valgrind
	$(TOUCH)

# -----------------------------------------------------------------------------

STRACE_VER    = 5.1
STRACE_DIR    = strace-$(STRACE_VER)
STRACE_SOURCE = strace-$(STRACE_VER).tar.xz
STRACE_SITE   = https://strace.io/files/$(STRACE_VER)

$(DL_DIR)/$(STRACE_SOURCE):
	$(DOWNLOAD) $(STRACE_SITE)/$(STRACE_SOURCE)

strace: $(DL_DIR)/$(STRACE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(STRACE_DIR)
	$(UNTAR)/$(STRACE_SOURCE)
	$(CHDIR)/$(STRACE_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--enable-silent-rules \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(addprefix $(TARGET_bindir)/,strace-graph strace-log-merge)
	$(REMOVE)/$(STRACE_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

GDB_VER    = 8.3
GDB_DIR    = gdb-$(GDB_VER)
GDB_SOURCE = gdb-$(GDB_VER).tar.xz
GDB_SITE   = https://sourceware.org/pub/gdb/releases

$(DL_DIR)/$(GDB_SOURCE):
	$(DOWNLOAD) $(GDB_SITE)/$(GDB_SOURCE)

GDB_DEPS   = zlib ncurses

gdb: $(GDB_DEPS) $(DL_DIR)/$(GDB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(GDB_DIR)
	$(UNTAR)/$(GDB_SOURCE)
	$(CHDIR)/$(GDB_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
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
			--enable-static \
			; \
		$(MAKE) all-gdb; \
		$(MAKE) install-gdb DESTDIR=$(TARGET_DIR)
	rm -rf $(addprefix $(TARGET_datadir)/,system-gdbinit)
	find $(TARGET_datadir)/gdb/syscalls -type f -not -name 'arm-linux.xml' -not -name 'gdb-syscalls.dtd' -print0 | xargs -0 rm --
	$(REMOVE)/$(GDB_DIR)
	$(TOUCH)
