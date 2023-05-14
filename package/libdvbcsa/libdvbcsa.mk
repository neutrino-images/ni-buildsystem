################################################################################
#
# libdvbcsa
#
################################################################################

LIBDVBCSA_VERSION = master
LIBDVBCSA_DIR = libdvbcsa.git
LIBDVBCSA_SOURCE = libdvbcsa.git
LIBDVBCSA_SITE = https://code.videolan.org/videolan
LIBDVBCSA_SITE_METHOD = git

LIBDVBCSA_AUTORECONF = YES

libdvbcsa: | $(TARGET_DIR)
	$(call autotools-package)
