################################################################################
#
# sysvinit
#
################################################################################

SYSVINIT_VERSION = 3.00
SYSVINIT_DIR = sysvinit-$(SYSVINIT_VERSION)
SYSVINIT_SOURCE = sysvinit-$(SYSVINIT_VERSION).tar.xz
SYSVINIT_SITE = http://download.savannah.nongnu.org/releases/sysvinit

$(DL_DIR)/$(SYSVINIT_SOURCE):
	$(download) $(SYSVINIT_SITE)/$(SYSVINIT_SOURCE)

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
  define SYSVINIT_INSTALL_RCS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rcS-vuplus $(TARGET_sysconfdir)/init.d/rcS
  endef
else
  define SYSVINIT_INSTALL_RCS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rcS-$(BOXSERIES) $(TARGET_sysconfdir)/init.d/rcS
  endef
endif

define SYSVINIT_INSTALL_FILES
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/inittab $(TARGET_sysconfdir)/inittab
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/default-rcS $(TARGET_sysconfdir)/default/rcS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rc $(TARGET_sysconfdir)/init.d/rc
	$(SYSVINIT_INSTALL_RCS)
	$(SED) "s|%(BOXMODEL)|$(BOXMODEL)|g" $(TARGET_sysconfdir)/init.d/rcS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rcK $(TARGET_sysconfdir)/init.d/rcK
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/service $(TARGET_sbindir)/service
	$(INSTALL_EXEC) -D support/scripts/update-rc.d $(TARGET_sbindir)/update-rc.d
	$(MAKE) rc_local-scripts
endef

sysvinit: $(DL_DIR)/$(SYSVINIT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) -C src SULOGINLIBS=-lcrypt; \
		$(MAKE) install ROOT=$(TARGET_DIR) MANDIR=$(REMOVE_mandir)
	$(TARGET_RM) $(addprefix $(TARGET_base_sbindir)/,bootlogd fstab-decode logsave telinit)
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,last lastb mesg readbootlog utmpdump wall)
	$($(PKG)_INSTALL_FILES)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
