################################################################################
#
# gperf
#
################################################################################

GPERF_VERSION = 3.1
GPERF_DIR = gperf-$(GPERF_VERSION)
GPERF_SOURCE = gperf-$(GPERF_VERSION).tar.gz
GPERF_SITE = $(GNU_MIRROR)/gperf

# -----------------------------------------------------------------------------

host-gperf: | $(HOST_DIR)
	$(call host-autotools-package)
