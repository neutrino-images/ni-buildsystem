################################################################################
#
# libvorbisidec
#
################################################################################

LIBVORBISIDEC_VERSION = 1.2.1+git20180316
LIBVORBISIDEC_DIR = libvorbisidec-$(LIBVORBISIDEC_VERSION)
LIBVORBISIDEC_SOURCE = libvorbisidec_$(LIBVORBISIDEC_VERSION).orig.tar.gz
LIBVORBISIDEC_SITE = https://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec

LIBVORBISIDEC_DEPENDENCIES = libogg

LIBVORBISIDEC_AUTORECONF = YES

define LIBVORBISIDEC_PATCH_CONFIGURE
	$(SED) '122 s/^/#/' $(PKG_BUILD_DIR)/configure.in
endef
LIBVORBISIDEC_POST_PATCH_HOOKS += LIBVORBISIDEC_PATCH_CONFIGURE

libvorbisidec: | $(TARGET_DIR)
	$(call autotools-package)
