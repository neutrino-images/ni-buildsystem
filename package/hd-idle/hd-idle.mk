################################################################################
#
# hd-idle
#
################################################################################

HD_IDLE_VERSION = 1.05
HD_IDLE_DIR = hd-idle
HD_IDLE_SOURCE = hd-idle-$(HD_IDLE_VERSION).tgz
HD_IDLE_SITE = https://sourceforge.net/projects/hd-idle/files

$(DL_DIR)/$(HD_IDLE_SOURCE):
	$(download) $(HD_IDLE_SITE)/$(HD_IDLE_SOURCE)

hd-idle: $(DL_DIR)/$(HD_IDLE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(INSTALL_EXEC) -D hd-idle $(TARGET_sbindir)/hd-idle
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
