#
# makefile to add binary large objects
#
# -----------------------------------------------------------------------------

blobs:
	$(MAKE) firmware
	$(MAKE) $(BOXMODEL)-drivers
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),nevis apollo shiner kronos kronos_v2 hd60 hd61 multibox multiboxse))
	$(MAKE) $(BOXMODEL)-libs
endif
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 e4hdultra protek4k hd60 hd61 multibox multiboxse vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(MAKE) $(BOXMODEL)-libgles
endif
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(MAKE) vuplus-platform-util
endif
	$(call TOUCH)
