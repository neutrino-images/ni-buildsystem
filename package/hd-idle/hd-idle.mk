################################################################################
#
# hd-idle
#
################################################################################

HD_IDLE_VERSION = 1.05
HD_IDLE_DIR = hd-idle
HD_IDLE_SOURCE = hd-idle-$(HD_IDLE_VERSION).tgz
HD_IDLE_SITE = https://sourceforge.net/projects/hd-idle/files

HD_IDLE_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

define HD_IDLE_INSTALL_BINARY
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/hd-idle $(TARGET_sbindir)/hd-idle
endef
HD_IDLE_PRE_FOLLOWUP_HOOKS += HD_IDLE_INSTALL_BINARY

hd-idle: | $(TARGET_DIR)
	$(call generic-package,$(PKG_NO_INSTALL))
