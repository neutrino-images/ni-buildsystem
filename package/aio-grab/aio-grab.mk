################################################################################
#
# aio-grab
#
################################################################################

AIO_GRAB_VERSION = master
AIO_GRAB_DIR = aio-grab.git
AIO_GRAB_SOURCE = aio-grab.git
AIO_GRAB_SITE = https://github.com/oe-alliance
AIO_GRAB_SITE_METHOD = git

AIO_GRAB_DEPENDENCIES = zlib libpng libjpeg-turbo

AIO_GRAB_AUTORECONF = YES

aio-grab: | $(TARGET_DIR)
	$(call autotools-package)
