#
# makefile to build static libraries
#
# -----------------------------------------------------------------------------

LIBS-STATIC =
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd2 hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
  LIBS-STATIC += cortex-strings
endif

libs-static: $(LIBS-STATIC) | $(TARGET_DIR)
	$(INSTALL_COPY) $(STATIC_DIR)/. $(TARGET_DIR)/
	$(REWRITE_LIBTOOL)

# -----------------------------------------------------------------------------

PHONY += libs-static
