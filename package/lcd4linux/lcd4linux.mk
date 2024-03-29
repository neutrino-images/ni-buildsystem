################################################################################
#
# lcd4linux
#
################################################################################

LCD4LINUX_VERSION = master
LCD4LINUX_DIR = lcd4linux.git
LCD4LINUX_SOURCE = lcd4linux.git
LCD4LINUX_SITE = https://github.com/TangoCash
LCD4LINUX_SITE_METHOD = git

LCD4LINUX_DEPENDENCIES = ncurses libgd libdpf

LCD4LINUX_DRIVERS = DPF,SamsungSPF,PNG
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vuduo4k vuduo4kse vusolo4k vuultimo4k vuuno4kse))
  LCD4LINUX_DRIVERS += ,VUPLUS4K
endif

LCD4LINUX_CONF_OPTS = \
	--with-ncurses=$(TARGET_libdir) \
	--with-drivers='$(LCD4LINUX_DRIVERS)' \
	--with-plugins='all,!dbus,!mpris_dbus,!asterisk,!isdn,!pop3,!ppp,!seti,!huawei,!imon,!kvv,!sample,!w1retap,!wireless,!xmms,!gps,!mpd,!mysql,!qnaplog,!iconv' \

define LCD4LINUX_INSTALL_SKEL
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
endef
LCD4LINUX_TARGET_FINALIZE_HOOKS += LCD4LINUX_INSTALL_SKEL

define LCD4LINUX_BOOTSTRAP
	$(CD) $(PKG_BUILD_DIR); \
		./bootstrap
endef
LCD4LINUX_PRE_CONFIGURE_HOOKS += LCD4LINUX_BOOTSTRAP

define LCD4LINUX_MAKE_VCS_VERSION
	$(CD) $(PKG_BUILD_DIR); \
		$(MAKE) vcs_version
endef
LCD4LINUX_PRE_BUILD_HOOKS += LCD4LINUX_MAKE_VCS_VERSION

lcd4linux: | $(TARGET_DIR)
	$(call autotools-package)
