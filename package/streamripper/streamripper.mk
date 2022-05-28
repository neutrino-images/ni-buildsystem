################################################################################
#
# streamripper
#
################################################################################

STREAMRIPPER_VERSION = ni-git
STREAMRIPPER_DIR = $(NI_STREAMRIPPER)
STREAMRIPPER_SOURCE = $(NI_STREAMRIPPER)
STREAMRIPPER_SITE = https://github.com/neutrino-images

STREAMRIPPER_DEPENDENCIES = libvorbisidec libmad glib2

STREAMRIPPER_AUTORECONF = YES

STREAMRIPPER_CONF_OPTS = \
	--includedir=$(TARGET_includedir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--with-ogg-includes=$(TARGET_includedir) \
	--with-ogg-libraries=$(TARGET_libdir) \
	--with-vorbis-includes=$(TARGET_includedir) \
	--with-vorbis-libraries=$(TARGET_libdir) \
	--with-included-argv=yes \
	--with-included-libmad=no

define STREAMRIPPER_INSTALL_BINARY
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/streamripper $(TARGET_bindir)/streamripper
endef
STREAMRIPPER_PRE_FOLLOWUP_HOOKS += STREAMRIPPER_INSTALL_BINARY

define STREAMRIPPER_INSTALL_SCRIPT
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/streamripper.sh $(TARGET_bindir)/streamripper.sh
endef
STREAMRIPPER_TARGET_FINALIZE_HOOKS += STREAMRIPPER_INSTALL_SCRIPT

streamripper: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(CONFIGURE); \
		$(MAKE)
	$(call TARGET_FOLLOWUP)
