################################################################################
#
# ofgwrite
#
################################################################################

ofgwrite: $(SOURCE_DIR)/$(NI_OFGWRITE) | $(TARGET_DIR)
	$(REMOVE)/$(NI_OFGWRITE)
	tar -C $(SOURCE_DIR) --exclude-vcs -cp $(NI_OFGWRITE) | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI_OFGWRITE); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(NI_OFGWRITE)/ofgwrite_bin $(TARGET_bindir)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(NI_OFGWRITE)/ofgwrite_caller $(TARGET_bindir)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(NI_OFGWRITE)/ofgwrite $(TARGET_bindir)
	$(SED) 's|prefix=.*|prefix=$(prefix)|' $(TARGET_bindir)/ofgwrite
	$(REMOVE)/$(NI_OFGWRITE)
	$(TOUCH)
