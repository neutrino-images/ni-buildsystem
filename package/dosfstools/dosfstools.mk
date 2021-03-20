################################################################################
#
# dosfstools
#
################################################################################

DOSFSTOOLS_VERSION = 4.1
DOSFSTOOLS_DIR = dosfstools-$(DOSFSTOOLS_VERSION)
DOSFSTOOLS_SOURCE = dosfstools-$(DOSFSTOOLS_VERSION).tar.xz
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
