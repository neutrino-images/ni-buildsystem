################################################################################
#
# popt
#
################################################################################

POPT_VERSION = 1.16
POPT_DIR = popt-$(POPT_VERSION)
POPT_SOURCE = popt-$(POPT_VERSION).tar.gz
POPT_SITE = ftp://anduin.linuxfromscratch.org/BLFS/popt

POPT_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir)

popt: | $(TARGET_DIR)
	$(call autotools-package)
