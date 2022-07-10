################################################################################
#
# hd-idle
#
################################################################################

HD_IDLE_VERSION = 1.05
HD_IDLE_DIR = hd-idle
HD_IDLE_SOURCE = hd-idle-$(HD_IDLE_VERSION).tgz
HD_IDLE_SITE = https://sourceforge.net/projects/hd-idle/files

define HD_IDLE_INSTALL_CMDS
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/hd-idle $(TARGET_sbindir)/hd-idle
endef

hd-idle: | $(TARGET_DIR)
	$(call generic-package)
