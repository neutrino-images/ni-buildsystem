################################################################################
#
# libdvbcsa
#
################################################################################

LIBDVBCSA_VERSION = git
LIBDVBCSA_DIR = libdvbcsa.$(LIBDVBCSA_VERSION)
LIBDVBCSA_SOURCE = libdvbcsa.$(LIBDVBCSA_VERSION)
LIBDVBCSA_SITE = https://code.videolan.org/videolan

LIBDVBCSA_AUTORECONF = YES

libdvbcsa: | $(TARGET_DIR)
	$(call autotools-package)
