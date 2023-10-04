################################################################################
#
# gzip
#
################################################################################

GZIP_VERSION = 1.13
GZIP_DIR = gzip-$(GZIP_VERSION)
GZIP_SOURCE = gzip-$(GZIP_VERSION).tar.xz
GZIP_SITE = $(GNU_MIRROR)/gzip

# -----------------------------------------------------------------------------

HOST_GZIP_CONF_ENV += \
	gl_cv_func_fflush_stdin=yes

host-gzip: | $(HOST_DIR)
	$(call host-autotools-package)
