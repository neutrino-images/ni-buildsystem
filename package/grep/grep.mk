################################################################################
#
# grep
#
################################################################################

GREP_VERSION = 3.11
GREP_DIR = grep-$(GREP_VERSION)
GREP_SOURCE = grep-$(GREP_VERSION).tar.xz
GREP_SITE = $(GNU_MIRROR)/grep

# -----------------------------------------------------------------------------

host-grep: | $(HOST_DIR)
	$(call host-autotools-package)
