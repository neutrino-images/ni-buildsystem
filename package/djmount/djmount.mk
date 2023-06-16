################################################################################
#
# djmount
#
################################################################################

DJMOUNT_VERSION = 0.71
DJMOUNT_DIR = djmount-$(DJMOUNT_VERSION)
DJMOUNT_SOURCE = djmount-$(DJMOUNT_VERSION).tar.gz
DJMOUNT_SITE = https://sourceforge.net/projects/djmount/files/djmount/$(DJMOUNT_VERSION)

DJMOUNT_DEPENDENCIES = libfuse

DJMOUNT_AUTORECONF = YES

DJMOUNT_CONF_OPTS = \
	--with-fuse-prefix=$(TARGET_prefix) \
	--disable-debug

DJMOUNT_MAKE = \
	$(MAKE1)

define DJMOUNT_TOUCH_CONFIG_RPATH
	touch $($(PKG)_BUILD_DIR)/libupnp/config.aux/config.rpath
endef
DJMOUNT_PRE_CONFIGURE_HOOKS += DJMOUNT_TOUCH_CONFIG_RPATH

define DJMOUNT_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/djmount.init $(TARGET_sysconfdir)/init.d/djmount
	$(UPDATE-RC.D) djmount defaults 75 25
endef

djmount: | $(TARGET_DIR)
	$(call autotools-package)
