################################################################################
#
# udpxy
#
################################################################################

UDPXY_VERSION = tags/1.0-25.1
UDPXY_DIR = udpxy.git
UDPXY_SOURCE = udpxy.git
UDPXY_SITE = https://github.com/pcherenkov
UDPXY_SITE_METHOD = git

UDPXY_SUBDIR = chipmunk

UDPXY_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

UDPXY_MAKE_OPTS = \
	NO_UDPXREC=yes

UDPXY_MAKE_OPTS += \
	PREFIX=$(prefix) \
	MANPAGE_DIR=$(TARGET_DIR)$(REMOVE_mandir)

define UDPXY_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/udpxy.init $(TARGET_sysconfdir)/init.d/udpxy
	$(UPDATE-RC.D) udpxy defaults 75 25
endef

udpxy: | $(TARGET_DIR)
	$(call generic-package)
