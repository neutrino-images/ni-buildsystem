#Makefile to build devel-tools

valgrind: valgrind-$(BOXSERIES)

$(D)/valgrind-hd51 \
$(D)/valgrind-hd2: $(ARCHIVE)/valgrind-$(VALGRIND_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/valgrind-$(VALGRIND_VER).tar.bz2
	cd $(BUILD_TMP)/valgrind-$(VALGRIND_VER) && \
	$(PATCH)/valgrind-fix-$(BOXSERIES)-build.patch && \
		export AR=$(TARGET)-ar && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix= \
			--enable-only32bit \
			--mandir=/.remove \
			--datadir=/.remove && \
		$(MAKE) all && \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/valgrind.pc
	rm $(TARGET_DIR)/bin/callgrind_annotate
	rm $(TARGET_DIR)/bin/callgrind_control
	rm $(TARGET_DIR)/bin/cg_annotate
	rm $(TARGET_DIR)/bin/cg_diff
	rm $(TARGET_DIR)/bin/ms_print
	$(REMOVE)/valgrind-$(VALGRIND_VER)
	touch $@

$(D)/valgrind-hd1:
	svn co -r 12305 svn://svn.valgrind.org/valgrind/trunk $(BUILD_TMP)/valgrind && \
	pushd $(BUILD_TMP)/valgrind && \
	svn up --force -r {2011-12-13} VEX && \
	$(PATCH)/valgrind12305-nevis-patch.diff && \
	$(PATCH)/valgrind-automake-1.11.2.patch && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix= \
			--enable-only32bit \
			--mandir=/.remove \
			--datadir=/.remove && \
		$(MAKE) all && \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/valgrind.pc
	$(REMOVE)/valgrind
	touch $@

$(D)/strace: $(ARCHIVE)/strace-$(STRACE_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/strace-$(STRACE_VER).tar.xz
	cd $(BUILD_TMP)/strace-$(STRACE_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(BUILD_TMP)/.remove \
			--enable-silent-rules && \
		$(MAKE) all && \
		make install prefix=$(TARGET_DIR)
	rm $(TARGET_DIR)/bin/strace-graph
	rm $(TARGET_DIR)/bin/strace-log-merge
	$(REMOVE)/strace-$(STRACE_VER)
	touch $@

$(D)/gdb: $(D)/zlib $(D)/libncurses $(ARCHIVE)/gdb-$(GDB_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/gdb-$(GDB_VER)
	$(UNTAR)/gdb-$(GDB_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gdb-$(GDB_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(BUILD_TMP)/.remove \
			--infodir=$(BUILD_TMP)/.remove \
			--disable-binutils \
			--disable-werror \
			--with-curses \
			--with-zlib \
			--enable-static; \
		$(MAKE) all-gdb; \
		make install-gdb prefix=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/share/gdb/system-gdbinit
	find $(TARGET_DIR)/share/gdb/syscalls -type f -not -name 'arm-linux.xml' -not -name 'gdb-syscalls.dtd' -print0 | xargs -0 rm --
	$(REMOVE)/gdb-$(GDB_VER)
	touch $@
