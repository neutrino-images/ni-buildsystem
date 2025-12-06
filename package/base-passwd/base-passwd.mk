################################################################################
#
# base-passwd
#
################################################################################

BASE_PASSWD_VERSION = 3.6.8
BASE_PASSWD_DIR = work
BASE_PASSWD_SOURCE = base-passwd_$(BASE_PASSWD_VERSION).tar.xz
BASE_PASSWD_SITE = https://launchpad.net/debian/+archive/primary/+sourcefiles/base-passwd/$(BASE_PASSWD_VERSION)

BASE_PASSWD_AUTORECONF = YES

BASE_PASSWD_CONF_OPTS = \
	--disable-docs \
	--disable-selinux \
	--disable-debconf \
	--docdir=$(REMOVE_docdir)

define BASE_PASSWD_INSTALL_MASTER_FILES
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/group.master $(TARGET_datadir)/base-passwd/group.master
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/passwd.master $(TARGET_datadir)/base-passwd/passwd.master
endef
BASE_PASSWD_POST_INSTALL_HOOKS += BASE_PASSWD_INSTALL_MASTER_FILES

base-passwd: | $(TARGET_DIR)
	$(call autotools-package)
