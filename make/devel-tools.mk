#Makefile to build devel-tools

valgrind: valgrind-$(BOXSERIES)

$(D)/valgrind-hd2: $(ARCHIVE)/valgrind-$(VALGRIND_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/valgrind-$(VALGRIND_VER).tar.bz2
	cd $(BUILD_TMP)/valgrind-$(VALGRIND_VER) && \
	$(PATCH)/valgrind-fix-coolstream-hd2-build.patch && \
	$(PATCH)/valgrind-fix-build-with-kernel-4.x.patch && \
		export AR=$(TARGET)-ar && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix= \
			--enable-only32bit \
			--mandir=/.remove \
			--datadir=/.remove && \
		$(MAKE) all && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/valgrind.pc
	rm $(TARGETPREFIX)/bin/callgrind_annotate
	rm $(TARGETPREFIX)/bin/callgrind_control
	rm $(TARGETPREFIX)/bin/cg_annotate
	rm $(TARGETPREFIX)/bin/cg_diff
	rm $(TARGETPREFIX)/bin/ms_print
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
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/valgrind.pc
	$(REMOVE)/valgrind
	touch $@

# strace 4.9 needs newer kernel or at least a kernel-patch
# https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=79b5dc0c64d88cda3da23b2e22a5cec0964372ac
$(D)/strace: $(ARCHIVE)/strace-4.8.tar.xz | $(TARGETPREFIX)
	$(UNTAR)/strace-4.8.tar.xz
	cd $(BUILD_TMP)/strace-4.8 && \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(BUILD_TMP)/.remove \
			--enable-silent-rules && \
		$(MAKE) all && \
		make install prefix=$(TARGETPREFIX)
	rm $(TARGETPREFIX)/bin/strace-graph
	rm $(TARGETPREFIX)/bin/strace-log-merge
	$(REMOVE)/strace-4.8
	touch $@

$(D)/gdb: $(ARCHIVE)/gdb-$(GDB_VER).tar.xz $(D)/zlib $(D)/libncurses | $(TARGETPREFIX)
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
		make install-gdb prefix=$(TARGETPREFIX)
	rm -rf $(TARGETPREFIX)/share/gdb/system-gdbinit
	find $(TARGETPREFIX)/share/gdb/syscalls -type f -not -name 'arm-linux.xml' -not -name 'gdb-syscalls.dtd' -print0 | xargs -0 rm --
	$(REMOVE)/gdb-$(GDB_VER)
	touch $@

devel-tools: $(D)/gdb $(D)/strace

PHONY += devel-tools
