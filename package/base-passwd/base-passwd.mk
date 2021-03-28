################################################################################
#
# base-passwd
#
################################################################################

BASE_PASSWD_VERSION = 3.5.29
BASE_PASSWD_DIR = base-passwd-$(BASE_PASSWD_VERSION)
BASE_PASSWD_SOURCE = base-passwd_$(BASE_PASSWD_VERSION).tar.gz
BASE_PASSWD_SITE = https://launchpad.net/debian/+archive/primary/+files

define BASE_PASSWD_INSTALL_MASTER_FILES
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/group.master $(TARGET_datadir)/base-passwd/group.master
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/passwd.master $(TARGET_datadir)/base-passwd/passwd.master
endef
BASE_PASSWD_PRE_FOLLOWUP_HOOKS += BASE_PASSWD_INSTALL_MASTER_FILES

base-passwd: | $(TARGET_DIR)
	$(call autotools-package)
