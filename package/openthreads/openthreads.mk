################################################################################
#
# openthreads
#
################################################################################

OPENTHREADS_CONF_OPTS = \
	-DCMAKE_SUPPRESS_DEVELOPER_WARNINGS="1" \
	-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE="0" \
	-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE__TRYRUN_OUTPUT="1"

openthreads: $(SOURCE_DIR)/$(NI_OPENTHREADS) | $(TARGET_DIR)
	$(REMOVE)/$(NI_OPENTHREADS)
	tar -C $(SOURCE_DIR) --exclude-vcs -cp $(NI_OPENTHREADS) | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI_OPENTHREADS)/; \
		$(CMAKE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(NI_OPENTHREADS)
	$(TOUCH)
