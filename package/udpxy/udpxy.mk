################################################################################
#
# udpxy
#
################################################################################

UDPXY_VERSION = git
UDPXY_DIR = udpxy.$(UDPXY_VERSION)
UDPXY_SOURCE = udpxy.$(UDPXY_VERSION)
UDPXY_SITE = https://github.com/pcherenkov

UDPXY_SUBDIR = chipmunk

UDPXY_CHECKOUT = tags/1.0-25.1

UDPXY_MAKE_OPTS = \
	NO_UDPXREC=yes

UDPXY_MAKE_OPTS += \
	PREFIX=$(prefix) \
	MANPAGE_DIR=$(TARGET_DIR)$(REMOVE_mandir)

define UDPXY_INSTALL_INIT_SCRIPT
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/udpxy.init $(TARGET_sysconfdir)/init.d/udpxy
	$(UPDATE-RC.D) udpxy defaults 75 25
endef
UDPXY_TARGET_FINALIZE_HOOKS += UDPXY_INSTALL_INIT_SCRIPT

udpxy: | $(TARGET_DIR)
	$(call generic-package)
