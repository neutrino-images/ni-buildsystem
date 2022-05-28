################################################################################
#
# util-linux
#
################################################################################

UTIL_LINUX_VERSION = $(if $(filter $(BOXSERIES),hd1),2.36.2,2.38)
UTIL_LINUX_DIR = util-linux-$(UTIL_LINUX_VERSION)
UTIL_LINUX_SOURCE = util-linux-$(UTIL_LINUX_VERSION).tar.xz
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1))
UTIL_LINUX_SITE = $(KERNEL_MIRROR)/linux/utils/util-linux/v$(basename $(UTIL_LINUX_VERSION))
else
UTIL_LINUX_SITE = $(KERNEL_MIRROR)/linux/utils/util-linux/v$(UTIL_LINUX_VERSION)
endif

UTIL_LINUX_DEPENDENCIES = ncurses zlib

#UTIL_LINUX_AUTORECONF = YES

define UTIL_LINUX_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_base_bindir)/,dmesg findmnt lsblk)
	$(TARGET_RM) $(addprefix $(TARGET_base_sbindir)/,blkzone blockdev cfdisk chcpu ctrlaltdel fdisk findfs fsck fsfreeze fstrim mkfs mkswap sfdisk swaplabel swapoff swapon)
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,choom col colcrt colrm column fincore flock getopt hexdump ipcmk irqtop isosize linux32 linux64 look lscpu lsipc lslocks lsns mcookie namei prlimit renice rev script scriptlive scriptreplay setarch setsid uname26 uuidgen uuidparse whereis)
	$(TARGET_RM) $(addprefix $(TARGET_sbindir)/,ldattach readprofile rtcwake uuidd)
	$(TARGET_RM) $(addprefix $(TARGET_datadir)/bash-completion/completions/,blkzone blockdev cfdisk chcpu col colcrt colrm column ctrlaltdel dmesg fdisk fincore findfs findmnt flock fsck fsfreeze fstrim getopt hexdump ipcmk irqtop isosize ldattach look lsblk lscpu lsipc lslocks lsns mcookie mkfs mkswap namei prlimit readprofile renice rev rtcwake script scriptlive scriptreplay setarch setsid sfdisk swaplabel swapoff swapon uuidd uuidgen uuidparse whereis)
endef
UTIL_LINUX_TARGET_FINALIZE_HOOKS += UTIL_LINUX_TARGET_CLEANUP

#	--runstatedir=$(runstatedir) \

UTIL_LINUX_CONF_OPTS = \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--localedir=$(REMOVE_localedir) \
	--docdir=$(REMOVE_docdir) \
	--disable-gtk-doc \
	\
	--disable-agetty \
	--disable-bfs \
	--disable-cal \
	--disable-chfn-chsh \
	--disable-chmem \
	--disable-cramfs \
	--disable-eject \
	--disable-fallocate \
	--disable-fdformat \
	--disable-fsck \
	--disable-hardlink \
	--disable-hwclock \
	--disable-ipcrm \
	--disable-ipcs \
	--disable-kill \
	--disable-last \
	--disable-line \
	--disable-logger \
	--disable-login \
	--disable-login-chown-vcs \
	--disable-login-stat-mail \
	--disable-losetup \
	--disable-lsirq \
	--disable-lslogins \
	--disable-lsmem \
	--disable-mesg \
	--disable-minix \
	--disable-more \
	--disable-mount \
	--disable-mountpoint \
	--disable-newgrp \
	--disable-nls \
	--disable-nologin \
	--disable-nsenter \
	--disable-partx \
	--disable-pg \
	--disable-pg-bell \
	--disable-pivot_root \
	--disable-pylibmount \
	--disable-raw \
	--disable-rename \
	--disable-rfkill \
	--disable-runuser \
	--disable-schedutils \
	--disable-setpriv \
	--disable-setterm \
	--disable-su \
	--disable-sulogin \
	--disable-switch_root \
	--disable-tunelp \
	--disable-ul \
	--disable-unshare \
	--disable-use-tty-group \
	--disable-utmpdump \
	--disable-vipw \
	--disable-wall \
	--disable-wdctl \
	--disable-wipefs \
	--disable-write \
	--disable-zramctl \
	\
	--disable-makeinstall-chown \
	--disable-makeinstall-setuid \
	\
	--enable-libfdisk \
	--enable-libsmartcols \
	--enable-libuuid \
	--enable-libblkid \
	--enable-libmount \
	\
	--without-audit \
	--without-cap-ng \
	--without-btrfs \
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

ifeq ($(BS_PACKAGE_NCURSES_WCHAR),y)
  UTIL_LINUX_CONF_ENV += \
	NCURSESW6_CONFIG=$(HOST_DIR)/bin/$(NCURSES_CONFIG_SCRIPTS)
  UTIL_LINUX_CONF_OPTS += \
	--with-ncursesw
else
  UTIL_LINUX_CONF_ENV += \
	NCURSES6_CONFIG=$(HOST_DIR)/bin/$(NCURSES_CONFIG_SCRIPTS)
  UTIL_LINUX_CONF_OPTS += \
	--without-ncursesw \
	--with-ncurses \
	--disable-widechar
endif

util-linux: | $(TARGET_DIR)
	$(call autotools-package)
