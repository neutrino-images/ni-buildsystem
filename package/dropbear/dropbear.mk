################################################################################
#
# dropbear
#
################################################################################

DROPBEAR_VERSION = 2022.83
DROPBEAR_DIR = dropbear-$(DROPBEAR_VERSION)
DROPBEAR_SOURCE = dropbear-$(DROPBEAR_VERSION).tar.bz2
DROPBEAR_SITE = http://matt.ucc.asn.au/dropbear/releases

DROPBEAR_DEPENDENCIES = zlib

DROPBEAR_CONF_OPTS = \
	--disable-lastlog \
	--disable-wtmp \
	--disable-wtmpx \
	--disable-loginfunc \
	--disable-pam \
	--disable-harden \
	--enable-bundled-libtom

DROPBEAR_MAKE_OPTS = \
	SCPPROGRESS=1 \
	PROGRAMS="dropbear dbclient dropbearkey scp"

define DROPBEAR_CONFIGURE_LOCALOPTIONS
	# Ensure that dropbear doesn't use crypt() when it's not available
	echo '#if !HAVE_CRYPT'				>> $($(PKG)_BUILD_DIR)/localoptions.h
	echo '#define DROPBEAR_SVR_PASSWORD_AUTH 0'	>> $($(PKG)_BUILD_DIR)/localoptions.h
	echo '#endif'					>> $($(PKG)_BUILD_DIR)/localoptions.h
	# disable SMALL_CODE define
	echo '#define DROPBEAR_SMALL_CODE 0'		>> $($(PKG)_BUILD_DIR)/localoptions.h
	# fix PATH define
	echo '#define DEFAULT_PATH "/sbin:/bin:/usr/sbin:/usr/bin:/var/bin"' >> $($(PKG)_BUILD_DIR)/localoptions.h
endef
DROPBEAR_POST_CONFIGURE_HOOKS = DROPBEAR_CONFIGURE_LOCALOPTIONS

define DROPBEAR_INSTALL_ETC_DROPBEAR
	$(INSTALL) -d $(TARGET_sysconfdir)/dropbear
endef
DROPBEAR_TARGET_FINALIZE_HOOKS += DROPBEAR_INSTALL_ETC_DROPBEAR

define DROPBEAR_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/dropbear.init $(TARGET_sysconfdir)/init.d/dropbear
	$(UPDATE-RC.D) dropbear defaults 75 25
endef

dropbear: | $(TARGET_DIR)
	$(call autotools-package)
