################################################################################
#
# mtd-utils
#
################################################################################

MTD_UTILS_VERSION = 2.1.2
MTD_UTILS_DIR = mtd-utils-$(MTD_UTILS_VERSION)
MTD_UTILS_SOURCE = mtd-utils-$(MTD_UTILS_VERSION).tar.bz2
MTD_UTILS_SITE = ftp://ftp.infradead.org/pub/mtd-utils

MTD_UTILS_DEPENDENCIES =

MTD_UTILS_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--sbindir=$(base_sbindir).$(@F) \
	--mandir=$(REMOVE_mandir) \
	--disable-tests \
	--without-zstd \
	--without-ubifs \
	--without-xattr

ifeq ($(BOXSERIES),hd2)
  MTD_UTILS_DEPENDENCIES += zlib lzo
  MTD_UTILS_CONF_OPTS += --with-jffs
else
  MTD_UTILS_CONF_OPTS += --without-jffs
endif

MTD_UTILS_SBINARIES = flash_erase flash_eraseall
ifeq ($(BOXSERIES),hd2)
  MTD_UTILS_SBINARIES += nanddump nandtest nandwrite mkfs.jffs2
endif

define MTD_UTILS_INSTALL_BINARIES
	for sbin in $(MTD_UTILS_SBINARIES); do \
		rm -f $(TARGET_sbindir)/$$sbin; \
		$(INSTALL_EXEC) -D $(TARGET_base_sbindir).$(@F)/$$sbin $(TARGET_base_sbindir)/$$sbin; \
	done
	rm -r $(TARGET_base_sbindir).$(@F)
endef
MTD_UTILS_TARGET_FINALIZE_HOOKS += MTD_UTILS_INSTALL_BINARIES

mtd-utils: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

HOST_MTD_UTILS_CONF_ENV = \
	ZLIB_CFLAGS=" " \
	ZLIB_LIBS="-lz" \
	UUID_CFLAGS=" " \
	UUID_LIBS="-luuid"

HOST_MTD_UTILS_CONF_OPTS = \
	--without-ubifs \
	--without-xattr \
	--disable-tests

host-mtd-utils: | $(HOST_DIR)
	$(call host-autotools-package)
