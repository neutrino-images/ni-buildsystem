#
# makefile to build development tools
#
# -----------------------------------------------------------------------------

valgrind: valgrind-$(BOXSERIES)

# -----------------------------------------------------------------------------

VALGRIND_VER    = 3.13.0
VALGRIND_TMP    = valgrind-$(VALGRIND_VER)
VALGRIND_SOURCE = valgrind-$(VALGRIND_VER).tar.bz2
VALGRIND_URL    = ftp://sourceware.org/pub/valgrind

$(ARCHIVE)/$(VALGRIND_SOURCE):
	$(DOWNLOAD) $(VALGRIND_URL)/$(VALGRIND_SOURCE)

VALGRIND_PATCH  = valgrind-fix-$(BOXSERIES)-build.patch

$(D)/valgrind-bre2ze4k \
$(D)/valgrind-hd51 \
$(D)/valgrind-hd2: $(ARCHIVE)/$(VALGRIND_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(VALGRIND_TMP)
	$(UNTAR)/$(VALGRIND_SOURCE)
	$(CHDIR)/$(VALGRIND_TMP); \
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
	rm -f $(addprefix $(TARGET_LIB_DIR)/valgrind/,*.a *.xml)
	rm -f $(addprefix $(TARGET_BIN_DIR)/,cg_* callgrind_* ms_print)
	$(REMOVE)/$(VALGRIND_TMP)
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

STRACE_VER    = 5.1
STRACE_TMP    = strace-$(STRACE_VER)
STRACE_SOURCE = strace-$(STRACE_VER).tar.xz
STRACE_URL    = https://strace.io/files/$(STRACE_VER)

$(ARCHIVE)/$(STRACE_SOURCE):
	$(DOWNLOAD) $(STRACE_URL)/$(STRACE_SOURCE)

$(D)/strace: $(ARCHIVE)/$(STRACE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(STRACE_TMP)
	$(UNTAR)/$(STRACE_SOURCE)
	$(CHDIR)/$(STRACE_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--enable-silent-rules \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(addprefix $(TARGET_BIN_DIR)/,strace-graph strace-log-merge)
	$(REMOVE)/$(STRACE_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

GDB_VER    = 8.1.1
GDB_TMP    = gdb-$(GDB_VER)
GDB_SOURCE = gdb-$(GDB_VER).tar.xz
GDB_URL    = https://sourceware.org/pub/gdb/releases

$(ARCHIVE)/$(GDB_SOURCE):
	$(DOWNLOAD) $(GDB_URL)/$(GDB_SOURCE)

$(D)/gdb: $(D)/zlib $(D)/ncurses $(ARCHIVE)/$(GDB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(GDB_TMP)
	$(UNTAR)/$(GDB_SOURCE)
	$(CHDIR)/$(GDB_TMP); \
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
	rm -rf $(addprefix $(TARGET_SHARE_DIR)/,system-gdbinit)
	find $(TARGET_SHARE_DIR)/gdb/syscalls -type f -not -name 'arm-linux.xml' -not -name 'gdb-syscalls.dtd' -print0 | xargs -0 rm --
	$(REMOVE)/$(GDB_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

PHONY += valgrind
