################################################################################
#
# duktape
#
################################################################################

DUKTAPE_VERSION = 2.7.0
DUKTAPE_DIR = duktape-$(DUKTAPE_VERSION)
DUKTAPE_SOURCE = duktape-$(DUKTAPE_VERSION).tar.xz
DUKTAPE_SITE = https://github.com/svaarala/duktape/releases/download/v$(DUKTAPE_VERSION)

DUKTAPE_MAKE_OPTS = \
	-f Makefile.sharedlibrary INSTALL_PREFIX=$(prefix)

duktape:
	$(call generic-package)
