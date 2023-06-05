################################################################################
#
# blobs - binary large objects
#
################################################################################

BLOBS_DEPENDENCIES = firmware
BLOBS_DEPENDENCIES += $(BOXMODEL)-drivers

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),nevis apollo shiner kronos kronos_v2 hd60 hd61 multibox multiboxse))
BLOBS_DEPENDENCIES += $(BOXMODEL)-libs
endif

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 e4hdultra protek4k hd60 hd61 multibox multiboxse vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
BLOBS_DEPENDENCIES += $(BOXMODEL)-libgles
endif

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
BLOBS_DEPENDENCIES += vuplus-platform-util
endif

blobs: | $(TARGET_DIR)
	$(call virtual-package)
