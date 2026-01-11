################################################################################
#
# ffmpeg
#
################################################################################

FFMPEG_DEPENDENCIES = $(if $(filter $(BOXTYPE),coolstream),ffmpeg2,ffmpeg8)

ffmpeg: | $(TARGET_DIR)
	$(call virtual-package)
