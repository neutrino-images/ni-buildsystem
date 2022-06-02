################################################################################
#
# djmount
#
################################################################################

DJMOUNT_VERSION = 0.71
DJMOUNT_DIR = djmount-$(DJMOUNT_VERSION)
DJMOUNT_SOURCE = djmount-$(DJMOUNT_VERSION).tar.gz
DJMOUNT_SITE = https://sourceforge.net/projects/djmount/files/djmount/$(DJMOUNT_VERSION)

$(DL_DIR)/$(DJMOUNT_SOURCE):
	$(download) $(DJMOUNT_SITE)/$(DJMOUNT_SOURCE)

DJMOUNT_DEPENDENCIES = libfuse

DJMOUNT_AUTORECONF = YES

DJMOUNT_CONF_OPTS = \
	--with-fuse-prefix=$(TARGET_prefix) \
	--disable-debug

djmount: $(DJMOUNT_DEPENDENCIES) $(DL_DIR)/$(DJMOUNT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		touch libupnp/config.aux/config.rpath; \
		$(TARGET_CONFIGURE); \
		$(MAKE1); \
		$(MAKE1) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/djmount.init $(TARGET_sysconfdir)/init.d/djmount
	$(UPDATE-RC.D) djmount defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
