################################################################################
#
# libcap-ng
#
################################################################################

LIBCAP_NG_VERSION = 0.8.3
LIBCAP_NG_DIR = libcap-ng-$(LIBCAP_NG_VERSION)
LIBCAP_NG_SOURCE = libcap-ng-$(LIBCAP_NG_VERSION).tar.gz
LIBCAP_NG_SITE = http://people.redhat.com/sgrubb/libcap-ng

LIBCAP_NG_CONF_ENV = \
	ac_cv_prog_swig_found=no

LIBCAP_NG_CONF_OPTS = \
	--without-python

libcap-ng: | $(TARGET_DIR)
	$(call autotools-package)
