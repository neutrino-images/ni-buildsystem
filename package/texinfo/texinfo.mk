################################################################################
#
# texinfo
#
################################################################################

TEXINFO_VERSION = 7.1
TEXINFO_DIR = texinfo-$(TEXINFO_VERSION)
TEXINFO_SOURCE = texinfo-$(TEXINFO_VERSION).tar.xz
TEXINFO_SITE = $(GNU_MIRROR)/texinfo

# -----------------------------------------------------------------------------

host-texinfo: | $(HOST_DIR)
	$(call host-autotools-package)
