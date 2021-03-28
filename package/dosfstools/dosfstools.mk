################################################################################
#
# dosfstools
#
################################################################################

DOSFSTOOLS_VERSION = 4.2
DOSFSTOOLS_DIR = dosfstools-$(DOSFSTOOLS_VERSION)
DOSFSTOOLS_SOURCE = dosfstools-$(DOSFSTOOLS_VERSION).tar.gz
DOSFSTOOLS_SITE = https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VERSION)

DOSFSTOOLS_CFLAGS = $(TARGET_CFLAGS) -D_GNU_SOURCE -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fomit-frame-pointer

DOSFSTOOLS_AUTORECONF = YES

DOSFSTOOLS_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--docdir=$(REMOVE_docdir) \
	--without-udev \
	--enable-compat-symlinks \
	CFLAGS="$(DOSFSTOOLS_CFLAGS)"

dosfstools: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

HOST_DOSFSTOOLS_VERSION = $(DOSFSTOOLS_VERSION)
HOST_DOSFSTOOLS_DIR = $(DOSFSTOOLS_DIR)
HOST_DOSFSTOOLS_SOURCE = $(DOSFSTOOLS_SOURCE)
HOST_DOSFSTOOLS_SITE = $(DOSFSTOOLS_SITE)

HOST_DOSFSTOOLS_AUTORECONF = YES

HOST_DOSFSTOOLS_CONF_OPTS = \
	--without-udev

define HOST_DOSFSTOOLS_SYMLINKING
	ln -sf mkfs.fat $(HOST_DIR)/sbin/mkfs.vfat
	ln -sf mkfs.fat $(HOST_DIR)/sbin/mkfs.msdos
	ln -sf mkfs.fat $(HOST_DIR)/sbin/mkdosfs
endef
HOST_DOSFSTOOLS_HOST_FINALIZE_HOOKS += HOST_DOSFSTOOLS_SYMLINKING

host-dosfstools: $(DL_DIR)/$(HOST_DOSFSTOOLS_SOURCE) | $(HOST_DIR)
	$(call host-autotools-package)
