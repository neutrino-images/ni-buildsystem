################################################################################
#
# iperf
#
################################################################################

IPERF_VERSION = 3.1.3
IPERF_DIR = iperf-$(IPERF_VERSION)
IPERF_SOURCE = iperf-$(IPERF_VERSION)-source.tar.gz
IPERF_SITE = https://iperf.fr/download/source

iperf: | $(TARGET_DIR)
	$(call autotools-package)
