################################################################################
#
# iozone
#
################################################################################

IOZONE_VERSION = 3_490
IOZONE_DIR = iozone$(IOZONE_VERSION)
IOZONE_SOURCE = iozone$(IOZONE_VERSION).tar
IOZONE_SITE = http://www.iozone.org/src/current

$(DL_DIR)/$(IOZONE_SOURCE):
	$(download) $(IOZONE_SITE)/$(IOZONE_SOURCE)

iozone: $(DL_DIR)/$(IOZONE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR)/src/current; \
		$(SED) "s/= gcc/= $(TARGET_CC)/" makefile; \
		$(SED) "s/= cc/= $(TARGET_CC)/" makefile; \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) linux-arm; \
		$(INSTALL_EXEC) -D iozone $(TARGET_bindir)/iozone
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
