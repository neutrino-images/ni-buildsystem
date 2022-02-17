################################################################################
#
# lcd4linux
#
################################################################################

LCD4LINUX_VERSION = git
LCD4LINUX_DIR = lcd4linux.$(LCD4LINUX_VERSION)
LCD4LINUX_SOURCE = lcd4linux.$(LCD4LINUX_VERSION)
LCD4LINUX_SITE = https://github.com/TangoCash

LCD4LINUX_DEPENDENCIES = ncurses libgd libdpf

LCD4LINUX_DRIVERS = DPF,SamsungSPF,PNG
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vuduo4k vuduo4kse vusolo4k vuultimo4k vuuno4kse))
  LCD4LINUX_DRIVERS += ,VUPLUS4K
endif

LCD4LINUX_CONF_OPTS = \
	--libdir=$(TARGET_libdir) \
	--includedir=$(TARGET_includedir) \
	--bindir=$(TARGET_bindir) \
	--docdir=$(REMOVE_docdir) \
	--with-ncurses=$(TARGET_libdir) \
	--with-drivers='$(LCD4LINUX_DRIVERS)' \
	--with-plugins='all,!dbus,!mpris_dbus,!asterisk,!isdn,!pop3,!ppp,!seti,!huawei,!imon,!kvv,!sample,!w1retap,!wireless,!xmms,!gps,!mpd,!mysql,!qnaplog,!iconv' \

lcd4linux: $(LCD4LINUX_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		./bootstrap; \
		$(CONFIGURE); \
		$(MAKE) vcs_version; \
		$(MAKE); \
		$(MAKE) install
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
