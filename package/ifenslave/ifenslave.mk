################################################################################
#
# ifenslave
#
################################################################################

IFENSLAVE_VERSION = 2.9
IFENSLAVE_DIR = ifenslave
IFENSLAVE_SOURCE = ifenslave_$(IFENSLAVE_VERSION).tar.xz
IFENSLAVE_SITE = http://snapshot.debian.org/archive/debian/20170102T091407Z/pool/main/i/ifenslave

ifenslave: | $(TARGET_DIR)
	$(call DOWNLOAD,$($(PKG)_SOURCE))
	$(call STARTUP)
	$(call EXTRACT,$(BUILD_DIR))
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/ifenslave $(TARGET_base_sbindir)/ifenslave
	$(call FOLLOWUP)
