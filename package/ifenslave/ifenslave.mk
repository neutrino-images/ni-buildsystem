################################################################################
#
# ifenslave
#
################################################################################

IFENSLAVE_VERSION = 2.9
IFENSLAVE_DIR = ifenslave
IFENSLAVE_SOURCE = ifenslave_$(IFENSLAVE_VERSION).tar.xz
IFENSLAVE_SITE = http://snapshot.debian.org/archive/debian/20170102T091407Z/pool/main/i/ifenslave

$(DL_DIR)/$(IFENSLAVE_SOURCE):
	$(DOWNLOAD) $(IFENSLAVE_SITE)/$(IFENSLAVE_SOURCE)

ifenslave: $(DL_DIR)/$(IFENSLAVE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/ifenslave $(TARGET_base_sbindir)/ifenslave
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
