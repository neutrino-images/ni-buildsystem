################################################################################
#
# libbdplus
#
################################################################################

LIBBDPLUS_VERSION = 0.2.0
LIBBDPLUS_DIR = libbdplus-$(LIBBDPLUS_VERSION)
LIBBDPLUS_SOURCE = libbdplus-$(LIBBDPLUS_VERSION).tar.bz2
LIBBDPLUS_SITE = https://download.videolan.org/pub/videolan/libbdplus/$(LIBBDPLUS_VERSION)

LIBBDPLUS_DEPENDENCIES = libaacs

LIBBDPLUS_CONF_OPTS = \
	--enable-shared \
	--disable-static

define LIBBDPLUS_BOOTSTRAP
	$(CHDIR)/$($(PKG)_DIR); \
		./bootstrap
endef
LIBBDPLUS_PRE_CONFIGURE_HOOKS += LIBBDPLUS_BOOTSTRAP

define LIBBDPLUS_INSTALL_FILES
	$(INSTALL) -d $(TARGET_DIR)/.config/bdplus/vm0
	$(INSTALL_COPY) $(PKG_FILES_DIR)/* $(TARGET_DIR)/.config/bdplus/vm0
endef
LIBBDPLUS_TARGET_FINALIZE_HOOKS += LIBBDPLUS_INSTALL_FILES

libbdplus: | $(TARGET_DIR)
	$(call autotools-package)
