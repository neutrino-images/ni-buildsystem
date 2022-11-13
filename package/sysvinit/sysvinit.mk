################################################################################
#
# sysvinit
#
################################################################################

SYSVINIT_VERSION = 3.04
SYSVINIT_DIR = sysvinit-$(SYSVINIT_VERSION)
SYSVINIT_SOURCE = sysvinit-$(SYSVINIT_VERSION).tar.xz
SYSVINIT_SITE = http://download.savannah.nongnu.org/releases/sysvinit

SYSVINIT_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV) \
	ULOGINLIBS=-lcrypt

SYSVINIT_MAKE_OPTS = \
	-C src

SYSVINIT_MAKE_INSTALL_OPTS = \
	ROOT=$(TARGET_DIR) \
	MANDIR=$(REMOVE_mandir)

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
  define SYSVINIT_INSTALL_RCS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rcS-vuplus $(TARGET_sysconfdir)/init.d/rcS
  endef
else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),e4hdultra protek4k))
  define SYSVINIT_INSTALL_RCS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rcS-$(BOXSERIES)-e4hdultra $(TARGET_sysconfdir)/init.d/rcS
  endef
else
  define SYSVINIT_INSTALL_RCS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rcS-$(BOXSERIES) $(TARGET_sysconfdir)/init.d/rcS
  endef
endif

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),e4hdultra))
  define SYSVINIT_MODIFY_RCS
	$(SED) "s|%(BOXMODEL)|e4hd|g" $(TARGET_sysconfdir)/init.d/rcS
  endef
else
  define SYSVINIT_MODIFY_RCS
	$(SED) "s|%(BOXMODEL)|$(BOXMODEL)|g" $(TARGET_sysconfdir)/init.d/rcS
  endef
endif

define SYSVINIT_INSTALL_FILES
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/inittab $(TARGET_sysconfdir)/inittab
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/default-rcS $(TARGET_sysconfdir)/default/rcS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rc $(TARGET_sysconfdir)/init.d/rc
	$(SYSVINIT_INSTALL_RCS)
	$(SYSVINIT_MODIFY_RCS)
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rcK $(TARGET_sysconfdir)/init.d/rcK
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/service $(TARGET_sbindir)/service
	$(INSTALL_EXEC) -D support/scripts/update-rc.d $(TARGET_sbindir)/update-rc.d
endef
SYSVINIT_TARGET_FINALIZE_HOOKS += SYSVINIT_INSTALL_FILES

define SYSVINIT_MAKE_RC_LOCAL_SCRIPTS
	$(MAKE) rc_local-scripts
endef
SYSVINIT_TARGET_FINALIZE_HOOKS += SYSVINIT_MAKE_RC_LOCAL_SCRIPTS

define SYSVINIT_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_base_sbindir)/,bootlogd fstab-decode logsave telinit)
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,last lastb mesg readbootlog utmpdump wall)
endef
SYSVINIT_TARGET_FINALIZE_HOOKS += SYSVINIT_TARGET_CLEANUP

sysvinit: | $(TARGET_DIR)
	$(call generic-package)
