################################################################################
#
# util-linux
#
################################################################################

UTIL_LINUX_VERSION = 2.36.2
UTIL_LINUX_DIR = util-linux-$(UTIL_LINUX_VERSION)
UTIL_LINUX_SOURCE = util-linux-$(UTIL_LINUX_VERSION).tar.xz
UTIL_LINUX_SITE = $(KERNEL_MIRROR)/linux/utils/util-linux/v$(basename $(UTIL_LINUX_VERSION))

UTIL_LINUX_DEPENDENCIES = ncurses zlib

UTIL_LINUX_AUTORECONF = YES

UTIL_LINUX_CONF_OPTS = \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--runstatedir=$(runstatedir) \
	--localedir=$(REMOVE_localedir) \
	--docdir=$(REMOVE_docdir) \
	--disable-gtk-doc \
	\
	--disable-all-programs \
	\
	--enable-libfdisk \
	--enable-libsmartcols \
	--enable-libuuid \
	--enable-libblkid \
	--enable-libmount \
	\
	--disable-makeinstall-chown \
	--disable-makeinstall-setuid \
	--disable-makeinstall-chown \
	\
	--without-audit \
	--without-cap-ng \
	--without-btrfs \
	--without-ncursesw \
	--without-python \
	--without-readline \
	--without-slang \
	--without-smack \
	--without-libmagic \
	--without-systemd \
	--without-systemdsystemunitdir \
	--without-tinfo \
	--without-udev \
	--without-utempter

util-linux: | $(TARGET_DIR)
	$(call autotools-package)
