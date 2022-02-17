################################################################################
#
# gdb
#
################################################################################

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
	$(TARGET_RM) $(addprefix $(TARGET_datadir)/,system-gdbinit)
	find $(TARGET_datadir)/gdb/syscalls -type f -not -name 'arm-linux.xml' -not -name 'gdb-syscalls.dtd' -print0 | xargs -0 rm --
	$(REMOVE)/$(GDB_DIR)
	$(TOUCH)
