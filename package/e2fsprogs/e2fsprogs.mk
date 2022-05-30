################################################################################
#
# e2fsprogs
#
################################################################################

# for coolstream: formatting ext4 failes with newer versions then 1.43.8
E2FSPROGS_VERSION = $(if $(filter $(BOXTYPE),coolstream),1.43.8,1.46.5)
E2FSPROGS_DIR = e2fsprogs-$(E2FSPROGS_VERSION)
E2FSPROGS_SOURCE = e2fsprogs-$(E2FSPROGS_VERSION).tar.gz
E2FSPROGS_SITE = https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(E2FSPROGS_VERSION)

$(DL_DIR)/$(E2FSPROGS_SOURCE):
	$(download) $(E2FSPROGS_SITE)/$(E2FSPROGS_SOURCE)

# Use libblkid and libuuid from util-linux
E2FSPROGS_DEPENDENCIES = util-linux

#E2FSPROGS_AUTORECONF = YES

E2FSPROGS_CONF_ENV = \
	ac_cv_path_LDCONFIG=true

E2FSPROGS_CONF_OPTS = \
	--with-root-prefix="$(base_prefix)" \
	--libdir=$(libdir) \
	--includedir=$(includedir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-backtrace \
	--disable-bmap-stats \
	--disable-debugfs \
	--disable-defrag \
	--disable-e2initrd-helper \
	--disable-fuse2fs \
	--disable-imager \
	--disable-jbd-debug \
	--disable-mmp \
	--disable-nls \
	--disable-profile \
	--disable-rpath \
	--disable-tdb \
	--disable-testio-debug \
	--disable-libblkid \
	--disable-libuuid \
	--disable-uuidd \
	--enable-elf-shlibs \
	--enable-fsck \
	--enable-symlink-build \
	--enable-symlink-install \
	--enable-verbose-makecmds \
	--without-libintl-prefix \
	--without-libiconv-prefix \
	--with-gnu-ld \
	--with-crond-dir=no

e2fsprogs: $(E2FSPROGS_DEPENDENCIES) $(DL_DIR)/$(E2FSPROGS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE1) install install-libs DESTDIR=$(TARGET_DIR)
	$(TARGET_RM) $(addprefix $(TARGET_base_sbindir)/,dumpe2fs e2mmpstatus e2undo logsave)
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,chattr compile_et lsattr mk_cmds uuidgen)
	$(TARGET_RM) $(addprefix $(TARGET_sbindir)/,e2freefrag e4crypt filefrag)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_E2FSPROGS_VERSION = $(E2FSPROGS_VERSION)
HOST_E2FSPROGS_DIR = $(E2FSPROGS_DIR)
HOST_E2FSPROGS_SOURCE = $(E2FSPROGS_SOURCE)
HOST_E2FSPROGS_SITE = $(E2FSPROGS_SITE)

#$(DL_DIR)/$(HOST_E2FSPROGS_SOURCE):
#	$(download) $(HOST_E2FSPROGS_SITE)/$(HOST_E2FSPROGS_SOURCE)

HOST_E2FSPROGS_CONF_OPTS = \
	--enable-symlink-install \
	--with-crond-dir=no

host-e2fsprogs: $(DL_DIR)/$(HOST_E2FSPROGS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(HOST_CONFIGURE);\
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
