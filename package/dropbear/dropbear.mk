################################################################################
#
# dropbear
#
################################################################################

DROPBEAR_VERSION = 2022.82
DROPBEAR_DIR = dropbear-$(DROPBEAR_VERSION)
DROPBEAR_SOURCE = dropbear-$(DROPBEAR_VERSION).tar.bz2
DROPBEAR_SITE = http://matt.ucc.asn.au/dropbear/releases

$(DL_DIR)/$(DROPBEAR_SOURCE):
	$(download) $(DROPBEAR_SITE)/$(DROPBEAR_SOURCE)

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
	PROGRAMS="dropbear dbclient dropbearkey scp"

dropbear: $(DROPBEAR_DEPENDENCIES) $(DL_DIR)/$(DROPBEAR_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		# Ensure that dropbear doesn't use crypt() when it's not available; \
		echo '#if !HAVE_CRYPT'				>> localoptions.h; \
		echo '#define DROPBEAR_SVR_PASSWORD_AUTH 0'	>> localoptions.h; \
		echo '#endif'					>> localoptions.h; \
		# disable SMALL_CODE define; \
		echo '#define DROPBEAR_SMALL_CODE 0'		>> localoptions.h; \
		# fix PATH define; \
		echo '#define DEFAULT_PATH "/sbin:/bin:/usr/sbin:/usr/bin:/var/bin"' >> localoptions.h; \
		$(MAKE) $($(PKG)_MAKE_OPTS) SCPPROGRESS=1; \
		$(MAKE) $($(PKG)_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	$(INSTALL) -d $(TARGET_sysconfdir)/dropbear
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/dropbear.init $(TARGET_sysconfdir)/init.d/dropbear
	$(UPDATE-RC.D) dropbear defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
