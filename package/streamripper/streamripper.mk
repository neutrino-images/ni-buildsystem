################################################################################
#
# streamripper
#
################################################################################

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

streamripper: $(STREAMRIPPER_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(NI_STREAMRIPPER)
	tar -C $(SOURCE_DIR) --exclude-vcs -cp $(NI_STREAMRIPPER) | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI_STREAMRIPPER); \
		$(CONFIGURE); \
		$(MAKE); \
		$(INSTALL_EXEC) -D streamripper $(TARGET_bindir)/streamripper
	$(INSTALL_EXEC) $(PKG_FILES_DIR)/streamripper.sh $(TARGET_bindir)/
	$(REMOVE)/$(NI_STREAMRIPPER)
	$(TOUCH)
