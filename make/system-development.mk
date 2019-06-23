#
# makefile to build development tools
#
# -----------------------------------------------------------------------------

valgrind: valgrind-$(BOXSERIES)

# -----------------------------------------------------------------------------

VALGRIND_VER = 3.13.0

$(ARCHIVE)/valgrind-$(VALGRIND_VER).tar.bz2:
	$(WGET) ftp://sourceware.org/pub/valgrind/valgrind-$(VALGRIND_VER).tar.bz2

VALGRIND_PATCH  = valgrind-fix-$(BOXSERIES)-build.patch

$(D)/valgrind-bre2ze4k \
$(D)/valgrind-hd51 \
$(D)/valgrind-hd2: $(ARCHIVE)/valgrind-$(VALGRIND_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/valgrind-$(VALGRIND_VER)
	$(UNTAR)/valgrind-$(VALGRIND_VER).tar.bz2
	$(CHDIR)/valgrind-$(VALGRIND_VER); \
		$(call apply_patches, $(VALGRIND_PATCH)); \
		export AR=$(TARGET)-ar; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--enable-only32bit \
			--mandir=/.remove \
			--datadir=/.remove \
			; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/valgrind.pc
	rm $(TARGET_DIR)/bin/callgrind_annotate
	rm $(TARGET_DIR)/bin/callgrind_control
	rm $(TARGET_DIR)/bin/cg_annotate
	rm $(TARGET_DIR)/bin/cg_diff
	rm $(TARGET_DIR)/bin/ms_print
	$(REMOVE)/valgrind-$(VALGRIND_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

VALGRIND-HD1_PATCH  = valgrind12305-nevis-patch.diff
VALGRIND-HD1_PATCH += valgrind-automake-1.11.2.patch

$(D)/valgrind-hd1:
	$(REMOVE)/valgrind
	svn co -r 12305 svn://svn.valgrind.org/valgrind/trunk $(BUILD_TMP)/valgrind; \
	$(CHDIR)/valgrind; \
		svn up --force -r {2011-12-13} VEX; \
		$(call apply_patches, $(VALGRIND-HD1_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--enable-only32bit \
			--mandir=/.remove \
			--datadir=/.remove \
			; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/valgrind.pc
	$(REMOVE)/valgrind
	$(TOUCH)

# -----------------------------------------------------------------------------

STRACE_VER = 4.21

$(ARCHIVE)/strace-$(STRACE_VER).tar.xz:
	$(WGET) http://sourceforge.net/projects/strace/files/strace/$(STRACE_VER)/strace-$(STRACE_VER).tar.xz

$(D)/strace: $(ARCHIVE)/strace-$(STRACE_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/strace-$(STRACE_VER)
	$(UNTAR)/strace-$(STRACE_VER).tar.xz
	$(CHDIR)/strace-$(STRACE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--enable-silent-rules \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm $(TARGET_DIR)/bin/strace-graph
	rm $(TARGET_DIR)/bin/strace-log-merge
	$(REMOVE)/strace-$(STRACE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GDB_VER = 8.1.1

$(ARCHIVE)/gdb-$(GDB_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/gdb/gdb-$(GDB_VER).tar.xz

$(D)/gdb: $(D)/zlib $(D)/libncurses $(ARCHIVE)/gdb-$(GDB_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/gdb-$(GDB_VER)
	$(UNTAR)/gdb-$(GDB_VER).tar.xz
	$(CHDIR)/gdb-$(GDB_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--infodir=/.remove \
			--disable-binutils \
			--disable-werror \
			--with-curses \
			--with-zlib \
			--enable-static \
			; \
		$(MAKE) all-gdb; \
		$(MAKE) install-gdb DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_SHARE_DIR)/gdb/system-gdbinit
	find $(TARGET_SHARE_DIR)/gdb/syscalls -type f -not -name 'arm-linux.xml' -not -name 'gdb-syscalls.dtd' -print0 | xargs -0 rm --
	$(REMOVE)/gdb-$(GDB_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

PHONY += valgrind
