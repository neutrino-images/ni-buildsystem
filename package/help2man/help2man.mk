################################################################################
#
# help2man
#
################################################################################

HELP2MAN_VERSION = 1.49.3
HELP2MAN_DIR = help2man-$(HELP2MAN_VERSION)
HELP2MAN_SOURCE = help2man-$(HELP2MAN_VERSION).tar.xz
HELP2MAN_SITE = $(GNU_MIRROR)/help2man

# -----------------------------------------------------------------------------

host-help2man: | $(HOST_DIR)
	$(call host-autotools-package)
