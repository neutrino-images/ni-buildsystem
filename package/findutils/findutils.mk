################################################################################
#
# findutils
#
################################################################################

FINDUTILS_VERSION = 4.9.0
FINDUTILS_DIR = findutils-$(FINDUTILS_VERSION)
FINDUTILS_SOURCE = findutils-$(FINDUTILS_VERSION).tar.xz
FINDUTILS_SITE = $(GNU_MIRROR)/findutils

# -----------------------------------------------------------------------------

HOST_FINDUTILS_CONF_ENV = \
	gl_cv_func_stdin=yes \
	ac_cv_func_working_mktime=yes \
	gl_cv_func_wcwidth_works=yes

HOST_FINDUTILS_CONF_OPTS = \
	--without-selinux

host-findutils: | $(HOST_DIR)
	$(call host-autotools-package)
